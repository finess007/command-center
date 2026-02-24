#!/usr/bin/env python3
"""Generate a safe, public-ish cron health snapshot for the Command Center.

Reads OpenClaw cron store (~/.openclaw/cron/jobs.json) and writes a trimmed JSON file
into command-center/src so it can be deployed as a static dashboard.

We intentionally OMIT payload bodies (prompt text) to avoid leaking sensitive content
and to keep the dashboard lightweight.
"""

from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from pathlib import Path

SRC_JOBS = Path(os.path.expanduser("~/.openclaw/cron/jobs.json"))
OUT = Path("/Users/jarvis/Projects/command-center/src/cron-health-data.json")


def iso(ms: int | None) -> str | None:
    if not ms:
        return None
    return datetime.fromtimestamp(ms / 1000, tz=timezone.utc).isoformat()


def main() -> None:
    if not SRC_JOBS.exists():
        raise SystemExit(f"Missing jobs file: {SRC_JOBS}")

    obj = json.loads(SRC_JOBS.read_text())
    jobs = obj.get("jobs", [])

    out_jobs = []
    for j in jobs:
        schedule = j.get("schedule") or {}
        delivery = j.get("delivery") or {}
        state = j.get("state") or {}

        out_jobs.append(
            {
                "id": j.get("id"),
                "name": j.get("name"),
                "description": j.get("description"),
                "enabled": bool(j.get("enabled")),
                "agentId": j.get("agentId"),
                "sessionTarget": j.get("sessionTarget"),
                "wakeMode": j.get("wakeMode"),
                "schedule": {
                    "kind": schedule.get("kind"),
                    "expr": schedule.get("expr"),
                    "tz": schedule.get("tz"),
                },
                "delivery": {
                    "mode": delivery.get("mode"),
                    "channel": delivery.get("channel"),
                    "to": delivery.get("to"),
                },
                "state": {
                    "lastRunAtMs": state.get("lastRunAtMs"),
                    "lastRunAt": iso(state.get("lastRunAtMs")),
                    "nextRunAtMs": state.get("nextRunAtMs"),
                    "nextRunAt": iso(state.get("nextRunAtMs")),
                    "lastStatus": state.get("lastStatus"),
                    "lastDurationMs": state.get("lastDurationMs"),
                    "consecutiveErrors": state.get("consecutiveErrors"),
                    "lastError": state.get("lastError"),
                },
            }
        )

    # Sort: enabled first, then by name.
    out_jobs.sort(key=lambda x: (not x["enabled"], (x["name"] or "").lower()))

    generated_at = datetime.now(timezone.utc).isoformat()
    enabled_count = sum(1 for j in out_jobs if j["enabled"])
    error_count = sum(
        1
        for j in out_jobs
        if j["enabled"]
        and (
            (j.get("state", {}).get("lastStatus") == "error")
            or (j.get("state", {}).get("consecutiveErrors") or 0) > 0
        )
    )

    out = {
        "generatedAt": generated_at,
        "source": str(SRC_JOBS),
        "summary": {
            "total": len(out_jobs),
            "enabled": enabled_count,
            "enabledWithErrors": error_count,
        },
        "jobs": out_jobs,
    }

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(out, indent=2, ensure_ascii=False) + "\n")
    print(f"Wrote: {OUT} (jobs={len(out_jobs)})")


if __name__ == "__main__":
    main()
