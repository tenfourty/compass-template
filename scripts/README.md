# Scripts

Automation scripts for your Compass instance. None are required — add what's useful for your workflow.

## Ideas

### Meeting sync

If you use a meeting tool that kbx can sync from (Granola, Notion), set up a recurring sync:

```bash
#!/bin/bash
# sync-meetings.sh — run via cron or launchd
kbx sync granola --since 7d
kbx index run
```

Schedule it every 30 minutes with cron (`crontab -e`):

```
*/30 * * * * cd /path/to/compass && bash scripts/sync-meetings.sh >> scripts/logs/sync.log 2>&1
```

Or on macOS, use a launchd plist for better reliability.

### Unattended meeting prep/debrief

Use Claude Code in non-interactive mode to generate meeting prep or debrief notes automatically:

```bash
claude -p "Prep me for my next meeting" --allowedTools "Bash(kbx *)"
```

This pairs well with a sync script — sync first, then generate intelligence.

### Custom slash commands

Put reusable workflows in `.claude/commands/`. For example, a `/sync` command that runs your sync script and reindexes.

## Logs

Scripts that run on a schedule should log to `scripts/logs/` (gitignored).
