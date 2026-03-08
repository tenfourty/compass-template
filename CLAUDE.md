# Compass

A personal knowledge base and productivity system powered by Claude Code.

## First-Time Setup

If `kbx` is NOT available (the SessionStart hook will tell you), run these steps:

### 1. Install the knowledge base

```bash
uv tool install "kbx[search]"
uv tool update-shell
```

Then initialise the index:

```bash
kbx index run
```

### 2. Install plugins

```bash
claude plugins marketplace add github:tenfourty/cc-marketplace
claude plugins install chief-of-staff
claude plugins install inner-game    # optional — personal coaching
claude plugins install draft         # optional — communications drafting
```

### 3. Run setup

After installing plugins, run their setup commands:

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

### Preferences

Update this section with your preferences so Claude adapts to your style:

- **Language:** (e.g., British English, American English)
- **Timezone:** (e.g., Europe/Paris, America/New_York)
- **Communication style:** (e.g., direct, detailed, concise)
- **Working hours:** (e.g., 09:00-18:00)

### Configuration

- **kbx:** `kbx.toml` (project-local, relative paths). Data in `kbx-data/`.
- **Global fallback:** `~/.config/kbx/config.toml` (absolute paths, for running kbx from any directory).
