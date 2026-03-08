# Writing CLAUDE.md Files

How to write effective CLAUDE.md files for Claude Code projects. Synthesised from [HumanLayer's guide](https://www.humanlayer.dev/blog/writing-a-good-claude-md), [Vercel's AGENTS.md eval findings](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals), and patterns proven in production CLIs.

## Core constraint

Claude starts every session with **zero codebase knowledge**. CLAUDE.md is the only file automatically injected into every conversation. Everything else requires the agent to decide to look — and Vercel's evals show agents fail to invoke tools 56% of the time. Passive context wins.

## The template

Every CLAUDE.md should answer three questions, in this order:

### 1. WHAT — one-liner + setup

```markdown
# project-name — What It Does

One sentence: what this project is and what problem it solves.

## Setup

\`\`\`bash
commands to install, verify, and orient
\`\`\`
```

The one-liner orients the agent on every session. Setup commands must be copy-pasteable.

### 2. HOW — architecture + file map + conventions

```markdown
## Architecture

One-line data flow pipeline showing how components connect.

**The boundary rule:** What each layer owns and what crosses boundaries.

## File Map

Compressed index: every source file with a one-line description.

## Conventions

- Bullet list of non-obvious rules the agent must follow
```

### 3. WHY — gotchas (what will bite you)

```markdown
## Gotchas

- **Bold label** — explanation of the non-obvious thing
```

Gotchas are the highest-value section. They encode lessons that took humans hours to learn. Without them, agents repeat the same mistakes.

## The rules

### Keep it short

| Target | Why |
|--------|-----|
| Under 300 lines | LLMs follow ~150-200 instructions reliably. Claude Code's system prompt already uses ~50. |
| Aim for 60 | HumanLayer's production file is 60 lines. |
| Every line universal | If a line only matters for one kind of task, it doesn't belong here. |

Instruction-following quality degrades **uniformly** — bloat hurts all instructions equally, not just the new ones.

### Embed a compressed index, not full docs

Vercel's key finding: a compressed 8KB index embedded in the instruction file achieved **100% pass rate**, while tool-based skills maxed at 79%. The agent doesn't need to decide whether to look — it already has the map.

Pattern:
```
src/myproject/
|cli.py — Click commands, all output via output()
|search.py — hybrid search: FTS5 + vector + RRF fusion
|types.py — Pydantic v2 strict models
```

This is not documentation. It's a table of contents the agent uses to know where to look.

### Use progressive disclosure for depth

Put detailed docs in a `docs/` folder. Reference them from the file map. The agent reads them when needed — but the CLAUDE.md tells it they exist and what each one covers.

```markdown
Deep dive: [`docs/models.md`](docs/models.md) | [`docs/testing.md`](docs/testing.md)
```

### Never put code style in CLAUDE.md

> "Never send an LLM to do a linter's job." — HumanLayer

Style rules waste tokens, bloat the instruction count, and are unreliably followed. Instead:
- **Pre-commit hooks** enforce formatting deterministically (ruff, mypy, bandit)
- **One line in CLAUDE.md** says to trust the hooks: `Pre-commit hooks enforce everything. Trust the hooks.`
- LLMs are in-context learners — they pick up patterns from existing code without being told

### Prefer retrieval over pre-training

Vercel found that agents perform better when explicitly told to read project files rather than relying on training data. One line does this:

```markdown
IMPORTANT: Prefer reading docs/ and source files over guessing.
```

### State the LLM API contract

If the CLI has a `--help` output that agents call to discover capabilities, say so explicitly:

```markdown
**`mycli --help` is the LLM API contract** — any CLI change MUST update the help output
```

This prevents drift between what the agent thinks is available and what actually works.

### Don't auto-generate

CLAUDE.md is the highest-leverage file in the repo. A bad line here multiplies into bad plans, bad code, and bad tests across every session. Write it by hand. Review every line.

## Anti-patterns

| Anti-pattern | Why it fails | Fix |
|--------------|-------------|-----|
| Embedding full documentation | Blows past instruction limits, triggers uniform quality degradation | Compressed index + `docs/` folder |
| Code style rules | Unreliable, expensive, duplicates linter work | Pre-commit hooks |
| Task-specific instructions | Not universally applicable, wastes tokens on irrelevant sessions | Separate docs or skills |
| Auto-generated content | Low-leverage, often wrong, not reviewed | Hand-craft every line |
| Inline code snippets | Go stale as code changes | File references: `see config.py:L42` |
| Vague instructions ("follow best practices") | Not actionable, agent can't verify compliance | Specific: "Coverage minimum 90% — enforced by pre-commit" |
| Sequencing instructions ("MUST do X first") | Vercel found these cause agents to anchor on one source, missing project context | Exploratory framing: "read docs/ and source files" |

## Checklist for new projects

- [ ] One-liner: what + why in a single sentence
- [ ] Setup: copy-pasteable install + verify + orient commands
- [ ] Architecture: one-line pipeline or data flow
- [ ] Boundary rule: what each layer owns
- [ ] File map: compressed index of every source file
- [ ] Conventions: only non-obvious, universally applicable rules
- [ ] Gotchas: things that will waste agent time if not stated
- [ ] Progressive disclosure: `docs/` folder linked from file map
- [ ] No style rules (delegate to hooks)
- [ ] Retrieval instruction: "prefer reading files over guessing"
- [ ] Under 100 lines (ideally under 60)
- [ ] Every line reviewed by a human
