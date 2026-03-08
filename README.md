# Compass

A personal productivity system powered by [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Clone this repo, open it with `claude`, and the AI guides you through setup.

## What is this?

Compass gives you an AI-powered chief of staff, personal coach, and communications drafter — all backed by a local knowledge base that learns about your work over time.

It combines:

- **[kbx](https://github.com/tenfourty/kbx)** — a local-first knowledge base that indexes your meetings, notes, people, and projects with hybrid search (full-text + semantic)
- **[cc-marketplace](https://github.com/tenfourty/cc-marketplace) plugins** for Claude Code:
  - **chief-of-staff** — meeting prep and debrief, daily briefings, task management, decision tracking, strategic advisory
  - **inner-game** — personal coaching, journaling, life assessment (based on Tim Gallwey's Inner Game)
  - **draft** — voice-aware message drafting for Slack, email, and announcements

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI)
- Python 3.11+
- [uv](https://docs.astral.sh/uv/) (Python package manager)

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/compass-template.git my-compass
cd my-compass
bash setup.sh
```

The setup script installs kbx (with semantic search and embeddings), builds the search index, registers the plugin marketplace, and installs the Claude Code plugins.

Then open Claude Code:

```bash
claude
```

Claude will detect it's a fresh install and guide you through:

1. Setting your name in `kbx.toml`
2. Running `/cos:setup` to connect your task manager, calendar, and chat tools
3. Optionally setting up the coach (`/ig:setup`) and drafter (`/draft:setup`)

## How It Works

### Three-tier capability model

| Tier | What you get | Requirements |
|------|-------------|-------------|
| **Tier 0** | Knowledge base + tasks.md | kbx only (works immediately) |
| **Tier 1** | + task management via your preferred tool | Connect a task CLI or MCP |
| **Tier 2** | + Slack, email, calendar, project tracking | Connect MCP servers via claude.ai |

You start at Tier 0 and add capabilities as you connect more tools. Everything degrades gracefully — you never need all of them.

### What gets stored locally

All your data stays in this repo under `memory/`:

- Meeting transcripts and notes
- People and project profiles
- Decision logs and tagged notes
- Journal entries and coaching files
- Company context and glossary

The search index (`kbx-data/`) is gitignored — it's rebuilt locally from your files.

### No PII in the template

This repo is a blank slate. All personalisation happens when you run the setup commands. Your data lives in `memory/` and never leaves your machine unless you push it.

## Plugins

### Chief of Staff (`/cos:*`)

Your AI operations partner. Handles meeting lifecycle (prep → attend → debrief), daily briefings, task management, decision tracking, and strategic review.

Key commands: `/cos:setup`, `/cos:briefing`, `/cos:prep`, `/cos:debrief`, `/cos:todos`

### Inner Game (`/ig:*`)

Personal life coach based on Tim Gallwey's Inner Game framework. Coaching conversations, daily journaling, identity work (The Document), and life domain assessment.

Key commands: `/ig:setup`, `/ig:morning`, `/ig:evening`, `/ig:session`, `/ig:document`

### Draft (`/draft:*`)

Communications drafter that learns your voice. Creates messages for Slack, email, and announcements in your authentic style, adapted to the audience.

Key commands: `/draft:setup`, `/draft:draft`, `/draft:restyle`

## Multi-Agent Teams

Compass includes a built-in multi-agent team for the Chief of Staff plugin. Three persistent agents run in separate tmux panes, each specialising in a different domain.

### CoS Team (`/cos-boot`, `/cos-focus`, `/cos-shutdown`)

| Agent | Role | Owns |
|-------|------|------|
| **ops** | Daily operations, tasks, accountability | `/cos:briefing`, `/cos:todos`, `/cos:status`, `/cos:decision` |
| **briefer** | Meeting lifecycle — prep and debrief | `/cos:prep`, `/cos:debrief` |
| **advisor** | Strategic advisory, coaching, patterns | `/cos:review`, `/cos:coach`, `/cos:blindspots`, `/cos:culture`, `/cos:codify`, `/cos:supergoal` |

```
/cos-boot              — spawn all 3 agents in a tmux layout
/cos-focus <agent>     — spotlight ops, briefer, or advisor (resize panes)
/cos-focus reset       — restore default layout
/cos-shutdown          — graceful shutdown, persist state to kbx
```

The agents coordinate automatically — ops delegates meeting work to briefer, flags patterns to advisor, and synthesises their input. Each agent reads and writes to the shared kbx knowledge base so context survives across sessions.

**Layout (default):**
```
┌───────────────┬──────────┐
│               │ briefer  │
│  ops (~45%)   ├──────────┤
│               │ advisor  │
└───────────────┴──────────┘
```

## Guides

- [Writing CLAUDE.md files](docs/guides/writing-claude-md.md) — how to structure CLAUDE.md for maximum agent effectiveness (synthesised from HumanLayer, Vercel's eval findings, and production patterns)

## Contributing

This is a template — fork it, make it yours. If you find improvements that would help everyone, PRs are welcome.

## Licence

MIT
