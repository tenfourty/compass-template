#!/bin/bash
# cos-team-focus.sh — Resize tmux panes to spotlight a CoS team agent.
#
# Usage:
#   bash scripts/cos-team-focus.sh <agent|reset>
#   agent: ops | briefer | advisor
#   reset: restore default layout
#
# Layout (ops focused):
# ┌──────────────────────┬──────────┐
# │                      │ briefer  │
# │  ops (~70%)          ├──────────┤
# │                      │ advisor  │
# └──────────────────────┴──────────┘
#
# Layout (briefer focused):
# ┌──────────┬───────────────────────┐
# │          │ briefer (~70% height) │
# │  ops     ├───────────────────────┤
# │  (~30%)  │ advisor (~30% height) │
# └──────────┴───────────────────────┘
#
# Layout (advisor focused):
# ┌──────────┬───────────────────────┐
# │          │ briefer (~30% height) │
# │  ops     ├───────────────────────┤
# │  (~30%)  │ advisor (~70% height) │
# └──────────┴───────────────────────┘
#
# Layout (reset / default):
# ┌───────────────┬──────────┐
# │               │ briefer  │
# │  ops (~45%)   ├──────────┤
# │               │ advisor  │
# └───────────────┴──────────┘

set -euo pipefail

# Auto-detect window by finding the one with a "cos:ops" pane
WINDOW=""
for win in $(tmux list-windows -a -F '#{session_name}:#{window_index}'); do
    pane_count=0
    found=false
    for pane_id in $(tmux list-panes -t "$win" -F '#{pane_id}' 2>/dev/null); do
        pane_count=$((pane_count + 1))
        fmt=$(tmux show-options -p -t "$pane_id" -v pane-border-format 2>/dev/null || true)
        if echo "$fmt" | grep -q '"cos:ops"'; then
            found=true
        fi
    done
    if [ "$found" = true ] && [ "$pane_count" -eq 3 ]; then
        WINDOW="$win"
        break
    fi
done

if [ -z "$WINDOW" ]; then
    echo "ERROR: Could not find a tmux window with a 'cos:ops' pane and exactly 3 panes." >&2
    echo "Is the CoS team running? Start it with /cos-boot first." >&2
    exit 1
fi

# --- Get window dimensions dynamically ---
WIN_WIDTH=$(tmux display-message -t "$WINDOW" -p '#{window_width}')
WIN_HEIGHT=$(tmux display-message -t "$WINDOW" -p '#{window_height}')

# --- Discover panes by their border-format labels ---
discover_pane() {
    local label="$1"
    for pane_id in $(tmux list-panes -t "$WINDOW" -F '#{pane_id}'); do
        local fmt
        fmt=$(tmux show-options -p -t "$pane_id" -v pane-border-format 2>/dev/null || true)
        if echo "$fmt" | grep -q "\"$label\""; then
            echo "$pane_id"
            return
        fi
    done
}

OPS=$(discover_pane "cos:ops")
BRIEFER=$(discover_pane "cos:briefer")
ADVISOR=$(discover_pane "cos:advisor")

# Validate all panes found
for name in OPS BRIEFER ADVISOR; do
    if [ -z "${!name}" ]; then
        echo "ERROR: Could not find pane for $name. Are pane border-formats set?" >&2
        exit 1
    fi
done

# --- Get pane indices ---
pane_index() {
    tmux display-message -t "$1" -p '#{pane_index}'
}

idx_ops=$(pane_index "$OPS")
idx_briefer=$(pane_index "$BRIEFER")
idx_advisor=$(pane_index "$ADVISOR")

# --- Compute tmux layout checksum ---
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

# --- Map agent name to focus target ---
agent_name="${1:-}"

if [ -z "$agent_name" ]; then
    echo "Usage: $0 <ops|briefer|advisor|reset>"
    exit 1
fi

# --- Calculate proportional dimensions ---
W=$WIN_WIDTH
H=$WIN_HEIGHT

case "$agent_name" in
    ops|cos:ops)
        # ops 70% left, briefer/advisor 30% right (even split)
        ops_w=$((W * 70 / 100))
        right_w=$((W - ops_w - 1))
        top_h=$((H / 2))
        bot_h=$((H - top_h - 1))
        right_x=$((ops_w + 1))
        bot_y=$((top_h + 1))

        layout="${W}x${H},0,0{${ops_w}x${H},0,0,${idx_ops},${right_w}x${H},${right_x},0[${right_w}x${top_h},${right_x},0,${idx_briefer},${right_w}x${bot_h},${right_x},${bot_y},${idx_advisor}]}"
        result=$(layout_checksum "$layout")
        tmux select-layout -t "$WINDOW" "$result"
        tmux select-pane -t "$OPS"
        echo "Focused on ops (${W}x${H})."
        ;;

    briefer|cos:briefer)
        # ops 30% left, briefer 70% height right, advisor 30% height right
        ops_w=$((W * 30 / 100))
        right_w=$((W - ops_w - 1))
        briefer_h=$((H * 70 / 100))
        advisor_h=$((H - briefer_h - 1))
        right_x=$((ops_w + 1))
        advisor_y=$((briefer_h + 1))

        layout="${W}x${H},0,0{${ops_w}x${H},0,0,${idx_ops},${right_w}x${H},${right_x},0[${right_w}x${briefer_h},${right_x},0,${idx_briefer},${right_w}x${advisor_h},${right_x},${advisor_y},${idx_advisor}]}"
        result=$(layout_checksum "$layout")
        tmux select-layout -t "$WINDOW" "$result"
        tmux select-pane -t "$BRIEFER"
        echo "Focused on briefer (${W}x${H})."
        ;;

    advisor|cos:advisor)
        # ops 30% left, briefer 30% height right, advisor 70% height right
        ops_w=$((W * 30 / 100))
        right_w=$((W - ops_w - 1))
        briefer_h=$((H * 30 / 100))
        advisor_h=$((H - briefer_h - 1))
        right_x=$((ops_w + 1))
        advisor_y=$((briefer_h + 1))

        layout="${W}x${H},0,0{${ops_w}x${H},0,0,${idx_ops},${right_w}x${H},${right_x},0[${right_w}x${briefer_h},${right_x},0,${idx_briefer},${right_w}x${advisor_h},${right_x},${advisor_y},${idx_advisor}]}"
        result=$(layout_checksum "$layout")
        tmux select-layout -t "$WINDOW" "$result"
        tmux select-pane -t "$ADVISOR"
        echo "Focused on advisor (${W}x${H})."
        ;;

    reset)
        # ops 45% left, briefer/advisor 55% right (even split)
        ops_w=$((W * 45 / 100))
        right_w=$((W - ops_w - 1))
        top_h=$((H / 2))
        bot_h=$((H - top_h - 1))
        right_x=$((ops_w + 1))
        bot_y=$((top_h + 1))

        layout="${W}x${H},0,0{${ops_w}x${H},0,0,${idx_ops},${right_w}x${H},${right_x},0[${right_w}x${top_h},${right_x},0,${idx_briefer},${right_w}x${bot_h},${right_x},${bot_y},${idx_advisor}]}"
        result=$(layout_checksum "$layout")
        tmux select-layout -t "$WINDOW" "$result"
        echo "Reset to default layout (${W}x${H})."
        ;;

    *)
        echo "Unknown agent: $agent_name"
        echo "Options: ops | briefer | advisor | reset"
        exit 1
        ;;
esac
