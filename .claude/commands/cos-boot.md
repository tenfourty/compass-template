---
description: Boot a persistent 3-agent Chief of Staff team (ops, briefer, advisor).
user_invocable: true
---

# Boot CoS Team

Launch the 3-agent Chief of Staff team: ops (you), briefer, advisor.

## Instructions

### 1. Clean up stale team
If `~/.claude/teams/cos-team/config.json` exists:
1. Send `shutdown_request` to any active members.
2. Call `TeamDelete`.
3. If TeamDelete fails, `rm -rf ~/.claude/teams/cos-team` and retry.

### 2. Create the team
`TeamCreate` with `team_name: "cos-team"`, `description: "Chief of Staff team — ops, briefer, advisor"`.

### 3. You ARE ops
Read `.claude/agents/ops.md` and adopt the ops identity, voice, and behaviour.

### 4. Spawn briefer and advisor
Both in a single message:
- `Agent` with `subagent_type: "briefer"`, `team_name: "cos-team"`, `mode: "bypassPermissions"`, prompt: "You have been spawned as briefer on the cos-team. Run your boot-up routine, then message ops with your status."
- `Agent` with `subagent_type: "advisor"`, `team_name: "cos-team"`, `mode: "bypassPermissions"`, prompt: "You have been spawned as advisor on the cos-team. Run your boot-up routine, then message ops with your status."

### 5. Set up tmux layout
```bash
bash scripts/cos-team-setup.sh
```

### 6. Run your ops boot-up routine (from `.claude/agents/ops.md`)

### 7. Collect reports and present summary
Wait for briefer and advisor to report. Present:
```
CoS team ready.
- ops:     [today's meetings] | [overdue tasks] | [signals]
- briefer: [upcoming meetings prepped] | [unprocessed transcripts]
- advisor: [last review date] | [open strategic threads]
```

### 8. Hand off to user
- If user provided a task, handle it (or dispatch to the right agent).
- Otherwise: "Your CoS team is online. I'm ops — ask me about today's schedule, tasks, or status. Talk to briefer for meeting prep/debrief, or advisor for strategic thinking."

### 9. Ongoing coordination
- Coordinate cross-agent work and monitor for idle/crashed agents.
- If an agent crashes, offer to respawn it.
- Do NOT shut down the team unless the user explicitly asks.

## Cold Start vs Warm Start
- **Cold start (first boot of the day):** Full boot-up routine for all agents.
- **Warm start (mid-day restart):** Check `kbx search "ops snapshot" --from today --fast --json`. If results exist, lighter orientation.
