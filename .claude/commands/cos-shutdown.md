---
description: Gracefully shut down the CoS team, preserving state.
user_invocable: true
---

# Shutdown CoS Team

Gracefully shut down the 3-agent Chief of Staff team, preserving state.

## Instructions

### 1. Announce shutdown
Tell the user you're initiating a graceful shutdown. Briefly summarise any in-progress work.

### 2. Instruct agents to wrap up
Send a message to both briefer and advisor:
> "Team shutdown initiated. Before exiting, please:
> 1. Persist any important insights to kbx via `kbx memory add`.
> 2. Report back what you persisted (or 'nothing to persist')."

### 3. Wait for agents to report, then shut them down
Once each agent reports back, send a `shutdown_request` to them via `SendMessage` (type: `"shutdown_request"`). Wait for both to confirm shutdown.

### 4. Persist ops state
If the day was complex, save an ops snapshot:
```bash
kbx memory add "Ops snapshot $(date +%Y-%m-%d)" --body "..." --tags ops,snapshot
```

### 5. Reset pane title
```bash
tmux set-option -p -t "$TMUX_PANE" -u pane-border-format
```

### 6. Delete the team
Call `TeamDelete`.

### 7. Present shutdown summary
```
CoS team shutdown complete.
- briefer: [what was persisted, or "nothing to persist"]
- advisor: [what was persisted, or "nothing to persist"]
- ops:     [what was persisted, or "nothing to persist"]
```
