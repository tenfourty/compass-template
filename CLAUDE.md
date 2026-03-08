# Compass

A personal knowledge base and productivity system powered by Claude Code.

## First-Time Setup

The SessionStart hook detects whether setup has been completed. If it hasn't, it outputs a `[FIRST RUN]` message — guide the user through these steps.

### 1. Run the setup script

The user must run this **from a terminal outside Claude Code** (it calls `claude` CLI commands that can't run inside a session):

```bash
bash setup.sh
```

This installs kbx (with semantic search), builds the search index, registers the cc-marketplace, and installs all three plugins.

### 2. Set your name

Edit `kbx.toml` and uncomment the `name` field in `[user]`:

```toml
[user]
name = "Your Name"
```

### 3. Run plugin setup

After restarting Claude in this directory, run these setup commands:

- `/cos:setup` — Chief of Staff: discovers your task manager, calendar, chat, and email tools. Configures connected sources. Creates pinned docs. Falls back to `tasks.md` if no task tool is available.
- `/ig:setup` — Inner Game (optional): creates coaching identity and journal structure.
- `/draft:setup` — Draft (optional): creates voice profile for message drafting.

During `/cos:setup`, Claude will:
- Check for task CLIs (todoist, things, gm, etc.) and MCP servers (Linear, Slack, Gmail, etc.)
- Ask which tools you use for tasks, calendar, chat, and email
- Configure the task backend accordingly

---

## After Setup

### Knowledge Base (kbx)

`kbx` is the primary interface for reading and writing memory. Run `kbx --help` for the full command reference.

**Key commands:**
- `kbx context` — load pinned docs and KB summary (auto-injected via SessionStart hook)
- `kbx search "query"` — hybrid search across all indexed content
- `kbx view <path>` — read a specific file
- `kbx note edit <target> --body "content"` / `--append "content"` — edit notes
- `kbx memory add "title" --body "..." --tags t1,t2` — create new notes
- `kbx entity find "name"` — look up a person or project
- `kbx index run` — reindex after manual file edits

### Memory Structure

```
memory/
├── meetings/    # Meeting transcripts and notes (YYYY/MM/DD/)
├── notes/       # Tagged notes (initiatives, CIRs, cadence, etc.)
├── people/      # Person entity files
├── projects/    # Project entity files
├── context/     # Company and org context
├── decisions/   # Decision log entries
├── draft/       # Draft plugin voice files (created by /draft:setup)
├── priorities/  # Current priorities and focus areas
├── rhythms/     # Recurring cadences and rituals
├── journal/     # Inner-game journal entries (created by /ig:setup)
├── coaching/    # Inner-game coaching files (created by /ig:setup)
└── glossary.md  # Acronyms and jargon
```

### Connected Sources

Configured during `/cos:setup`. These are the source categories the system understands:

| Category | Examples | How to connect |
|----------|----------|---------------|
| Knowledge base | kbx | Pre-installed |
| Task manager | Todoist, Things, Linear, Morgen, tasks.md | CLI or MCP |
| Calendar | Google Calendar, Outlook | MCP via claude.ai |
| Chat | Slack, Teams | MCP via claude.ai |
| Email | Gmail, Outlook | MCP via claude.ai |
| Meeting transcripts | Granola, Notion | kbx sync plugins |
| Project tracker | Linear, Jira, Notion | MCP via claude.ai |

### Day-to-Day Usage

Once `/cos:setup` has run, the system is operational. Common workflows:

- **Morning briefing:** `/cos:briefing` — summarises overnight changes, today's calendar, outstanding tasks, and anything matching your CIRs.
- **Meeting prep:** `/cos:prep` — before a meeting, pulls attendee context, recent interactions, and open items.
- **Meeting debrief:** `/cos:debrief` — after a meeting, extracts decisions, action items, and commitments. Logs them to kbx.
- **Task management:** `/cos:todos` — review, create, and update tasks via your configured backend.
- **Knowledge capture:** Ask Claude to remember something — it creates kbx notes, facts on people/projects, or decision log entries as appropriate.
- **Search:** Ask a question about past meetings, people, or decisions — Claude searches kbx automatically.

### Preferences

Update this section so Claude adapts to your style:

- **Language:** (e.g., British English, American English)
- **Timezone:** (e.g., Europe/Paris, America/New_York)
- **Communication style:** (e.g., direct and concise, detailed, conversational)
- **Working hours:** (e.g., 09:00-18:00 Mon-Fri)
- **Working pattern:** (e.g., in-office Tue-Thu, remote Mon/Fri)

### Configuration

- **kbx:** `kbx.toml` (project-local, relative paths). Data in `kbx-data/`.
- **Global fallback:** `~/.config/kbx/config.toml` (absolute paths, for running kbx from any directory).
- **Scripts:** `scripts/` — automation scripts (sync, cron jobs). See `scripts/README.md` for ideas.
