#!/bin/bash
# Update quiz-progress.html with latest quiz-state.json data
# Then encrypt with staticrypt for deployment

set -e

QUIZ_STATE="/Users/jarvis/clawd/life/areas/projects/general-knowledge/quiz-state.json"
TEMPLATE="/Users/jarvis/clawd/dashboards/src/quiz-progress.html"
OUTPUT="/Users/jarvis/clawd/dashboards/quiz-progress.html"
PASSWORD="W5l3bA1MFOYkEn0X"

if [ ! -f "$QUIZ_STATE" ]; then
    echo "❌ Error: quiz-state.json not found"
    exit 1
fi

if [ ! -f "$TEMPLATE" ]; then
    echo "❌ Error: template not found at $TEMPLATE"
    exit 1
fi

echo "📊 Updating quiz dashboard..."

# Update template with latest data
python3 << 'PYEOF'
import json

template_path = "/Users/jarvis/clawd/dashboards/src/quiz-progress.html"
quiz_state_path = "/Users/jarvis/clawd/life/areas/projects/general-knowledge/quiz-state.json"

# Read the template
with open(template_path, 'r') as f:
    html = f.read()

# Read the quiz data
with open(quiz_state_path, 'r') as f:
    quiz_data = json.load(f)

# Find markers
start_marker = "// QUIZ_DATA_START"
end_marker = "// QUIZ_DATA_END"

start_idx = html.find(start_marker)
end_idx = html.find(end_marker)

if start_idx == -1 or end_idx == -1:
    print("❌ Error: Could not find QUIZ_DATA markers in template")
    exit(1)

# Build new HTML with updated data
new_json = json.dumps(quiz_data, ensure_ascii=False)
new_html = html[:start_idx + len(start_marker)] + "\n        const quizData = " + new_json + ";\n        " + html[end_idx:]

# Write back to template
with open(template_path, 'w') as f:
    f.write(new_html)

print("✅ Template updated with latest quiz data")
PYEOF

# Encrypt with staticrypt
echo "🔐 Encrypting..."
npx staticrypt "$TEMPLATE" -p "$PASSWORD" -o "$OUTPUT" --short

echo "✅ Dashboard updated and encrypted!"
echo "📁 Output: $OUTPUT"
