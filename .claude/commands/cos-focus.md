---
description: Resize tmux panes to spotlight a specific CoS agent. Usage: /cos-focus [ops|briefer|advisor|reset]
user_invocable: true
args: target
---

# CoS Focus

Adjust the tmux layout to spotlight a specific CoS agent's pane.

## Usage

`/cos-focus <agent>` where agent is one of:
- `ops` — spotlight ops (70% width)
- `briefer` — spotlight briefer (70% height)
- `advisor` — spotlight advisor (70% height)
- `reset` — restore the default 45/55 layout

## Instructions

Run the focus script with the user's chosen agent:

```bash
bash scripts/cos-team-focus.sh $ARGUMENTS
```

Report the result. If the script fails (e.g., no team window found, panes not labelled), explain what went wrong and suggest `/cos-boot` to start the team.
