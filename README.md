# Dashboards

Local dashboards for tracking various metrics and progress.

## Available Dashboards

### 📚 Quiz Progress (`quiz-progress.html`)
Visual tracker for the general knowledge spaced repetition system.

**Features:**
- Stats overview (total figures, due today, accuracy, sessions)
- Mastery progress bar (Leitner box distribution)
- Due-for-review cards
- Leitner box breakdown with figure chips
- Session history with scores

**To view:**
```bash
open dashboards/quiz-progress.html
# or
python3 -m http.server 8080 --directory dashboards
# then visit http://localhost:8080/quiz-progress.html
```

**To update with latest quiz data:**
```bash
./dashboards/update-quiz-dashboard.sh
```

---

## Adding New Dashboards

Dashboards are self-contained HTML files with embedded CSS/JS. No build step needed.

Pattern:
1. Create `your-dashboard.html` in this folder
2. Embed data as JS variable or fetch from JSON
3. Add update script if needed

Built by Nova ✨
