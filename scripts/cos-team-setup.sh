#!/bin/bash
# cos-team-setup.sh — Set pane titles and default layout for the Chief of Staff team.
#
# Usage:
#   bash scripts/cos-team-setup.sh
#
# Call this AFTER spawning briefer and advisor agents via /boot-team.
# It discovers panes, sets descriptive pane-border-format on each,
# and applies the default layout.
#
# Discovery: The lead pane is $TMUX_PANE (running this script).
# Agent pane IDs are read from the team config file
# (~/.claude/teams/cos-team/config.json) — spawn order ≠ pane order.
#
# Default layout:
# ┌───────────────┬──────────┐
# │               │ briefer  │
# │  ops          ├──────────┤
# │  (~45%)       │ advisor  │
# │               │          │
# └───────────────┴──────────┘

set -euo pipefail

# --- Discover lead pane ---
# Use $TMUX_PANE (the pane this shell runs in), NOT display-message -p
# (which returns the *active* pane, which may have shifted when agents were spawned).
LEAD="${TMUX_PANE}"

if [ -z "$LEAD" ]; then
    echo "ERROR: \$TMUX_PANE is not set. Are you running inside tmux?" >&2
    exit 1
fi

# Verify the pane actually exists
if ! tmux display-message -t "$LEAD" -p '#{pane_id}' &>/dev/null; then
    echo "ERROR: Pane $LEAD does not exist. \$TMUX_PANE may be stale." >&2
    exit 1
fi

# --- Find the window containing the lead pane ---
WINDOW=$(tmux display-message -t "$LEAD" -p '#{session_name}:#{window_index}')

# --- Get window dimensions ---
W=$(tmux display-message -t "$WINDOW" -p '#{window_width}')
H=$(tmux display-message -t "$WINDOW" -p '#{window_height}')

# Read agent→pane mapping from team config (spawn order ≠ pane order).
TEAM_CONFIG="$HOME/.claude/teams/cos-team/config.json"
if [ ! -f "$TEAM_CONFIG" ]; then
    echo "ERROR: Team config not found at $TEAM_CONFIG." >&2
    exit 1
fi

eval "$(python3 - "$TEAM_CONFIG" <<'PYEOF'
import json, sys
members = {m['name']: m['tmuxPaneId'] for m in json.load(open(sys.argv[1]))['members']}
mapping = {'briefer': 'BRIEFER', 'advisor': 'ADVISOR'}
missing = []
for agent, var in mapping.items():
    pane = members.get(agent, '')
    if not pane:
        missing.append(agent)
    print(f'{var}={pane}')
if missing:
    print(f'echo "ERROR: Missing pane IDs for: {", ".join(missing)}" >&2; exit 1', file=sys.stderr)
    sys.exit(1)
PYEOF
)"

echo "Discovered panes: ops=$LEAD briefer=$BRIEFER advisor=$ADVISOR"

# --- Set pane-border-format (descriptive titles) ---
# Use pane-border-format, NOT pane_title — Claude Code overwrites pane_title.
tmux set-option -p -t "$LEAD" pane-border-format '#{?pane_active,#[reverse],}#{pane_index}#[default] "cos:ops — /briefing /todos /status /decision"'
tmux set-option -p -t "$BRIEFER" pane-border-format '#{?pane_active,#[reverse],}#{pane_index}#[default] "cos:briefer — /prep /debrief"'
tmux set-option -p -t "$ADVISOR" pane-border-format '#{?pane_active,#[reverse],}#{pane_index}#[default] "cos:advisor — /review /coach /blindspots /culture /codify /supergoal"'

echo "Pane titles set."

# --- Get pane indices for layout ---
idx_ops=$(tmux display-message -t "$LEAD" -p '#{pane_index}')
idx_briefer=$(tmux display-message -t "$BRIEFER" -p '#{pane_index}')
idx_advisor=$(tmux display-message -t "$ADVISOR" -p '#{pane_index}')

# --- Compute layout checksum ---
layout_checksum() {
    python3 -c "
layout = '''$1'''
csum = 0
for c in layout:
    csum = (csum >> 1) + ((csum & 1) << 15)
    csum += ord(c)
print(f'{csum & 0xffff:04x},{layout}')
"
}

# --- Apply default layout: ops 45%, right column 55% split evenly ---
ops_w=$((W * 45 / 100))
right_w=$((W - ops_w - 1))  # -1 for border
top_h=$((H / 2))
bot_h=$((H - top_h - 1))  # -1 for border

right_x=$((ops_w + 1))
bot_y=$((top_h + 1))

layout="${W}x${H},0,0{${ops_w}x${H},0,0,${idx_ops},${right_w}x${H},${right_x},0[${right_w}x${top_h},${right_x},0,${idx_briefer},${right_w}x${bot_h},${right_x},${bot_y},${idx_advisor}]}"
result=$(layout_checksum "$layout")
tmux select-layout -t "$WINDOW" "$result"

# Select the lead pane
tmux select-pane -t "$LEAD"

echo "Default layout applied (${W}x${H}). ops: 45%, briefer + advisor: 55%."
