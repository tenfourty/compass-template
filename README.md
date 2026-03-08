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
claude
```

Claude will detect that kbx isn't installed yet and walk you through:

1. Installing kbx and building the search index
2. Installing the Claude Code plugins
3. Running `/cos:setup` to connect your task manager, calendar, and chat tools
4. Optionally setting up the coach (`/ig:setup`) and drafter (`/draft:setup`)

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

## Contributing

This is a template — fork it, make it yours. If you find improvements that would help everyone, PRs are welcome.

## Licence

MIT
