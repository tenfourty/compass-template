#!/bin/bash
set -e

echo "=== Compass Setup ==="
echo ""

# 1. Install kbx with semantic search (embeddings)
echo "--- Installing kbx with semantic search ---"
uv tool install "kbx[search]"
uv tool update-shell
echo ""

# Reload PATH so kbx is available
export PATH="$HOME/.local/bin:$PATH"

# 2. Build the search index
echo "--- Building search index ---"
kbx index run
echo ""

# 3. Register the cc-marketplace and install plugins
echo "--- Installing Claude Code plugins ---"
claude plugins marketplace add github:tenfourty/cc-marketplace
claude plugins install chief-of-staff
claude plugins install inner-game
claude plugins install draft
echo ""

echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Edit kbx.toml and set your name in the [user] section"
echo "  2. Run 'claude' in this directory"
echo "  3. Use /cos:setup to connect your task manager, calendar, and chat tools"
echo "  4. Optionally: /ig:setup (coaching) and /draft:setup (message drafting)"
