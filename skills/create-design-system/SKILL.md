---
name: create-design-system
description: Build a Claude-Design-style design system bundle from any brand source (URL, code repo, screenshots, designlang ZIP, brand brief). Produces SKILL.md, README.md, colors_and_type.css, preview/ cards, ui_kits/, assets/, fonts/, slides/, cards.json, and a standalone offline design-system-viewer.html. Use when the user asks to create a design system, build a brand kit, extract design tokens into a system, or provides brand materials and wants them organized into a reusable design-system folder.
when_to_use: User uploads a brand URL, screenshots, codebase, Figma file, or ZIP and asks to turn it into a structured design system. Also when the user explicitly types /create-design-system.
allowed-tools: Read Write Edit Bash Grep Glob WebFetch
---

## ⚠️ CHECKPOINT PROTOCOL (READ FIRST!)

**Before ANY other action, locate any work in progress:**

```bash
# Check current directory and immediate subdirectories for SESSION.md
ls SESSION.md 2>/dev/null
find . -maxdepth 2 -name "SESSION.md" 2>/dev/null
```

**Case A: SESSION.md found**
→ CONTINUED work (after context compaction, conversation reset, or long session).
→ Note its directory — that is the bundle root from this point on.
→ Read it — it contains all completed steps, decisions, user corrections.
→ DO NOT re-ask questions already answered there.
→ Resume from the next incomplete step.

**Case B: No SESSION.md found BUT a conversation summary exists in context**
→ Context was compacted before SESSION.md could be created.
→ Reconstruct `SESSION.md` in the agreed bundle directory from what the summary tells you.
→ If the bundle directory cannot be determined from the summary — ask the user.
→ Then continue.

**Case C: No SESSION.md AND no prior summary**
→ Fresh start.
→ **DO NOT write any DS file into the current working directory.** The DS bundle must always live in its own subfolder `<brand-slug>-design-system/` created during Step 6 (Generation). Until then, only `SESSION.md` lives in cwd to track state.
→ Create `SESSION.md` in cwd immediately at Step 1 (template in `reference/workflow.md`). This is the only file allowed in cwd.
→ Proceed to the procedure below. The `<brand-slug>` will be confirmed at Step 4 (Plan) and the subfolder will be created at Step 6a.

## Purpose

Replicate Anthropic's Claude Design tool as an Agent Skill. Given a brand source, produce a portable design-system bundle that any AI agent (Claude Code, Cursor, OpenCode) can consume as a brand reference.

The bundle output is identical in shape to Claude Design exports (RixAI, Stripe, Focus Group, Iman Gadzhi examples), plus one addition: a standalone `design-system-viewer.html` that replaces the Claude Design "Design System tab" so the bundle is browsable offline without any web app.

## When to use this skill

Triggers (any one of these):
- User provides a brand URL and says "build a design system" / "extract a brand kit"
- User attaches screenshots/Figma/codebase and asks to turn it into a system
- User explicitly invokes `/create-design-system`
- User describes a brand and wants tokens + components + UI kit assembled

Do NOT use this skill for:
- Single-file artifacts (one HTML mock, one component) — use direct generation instead
- Editing an existing design system — use direct Edit operations
- Pure research without producing files

## Process (overview)

Detailed workflow lives in `reference/workflow.md`. Sequence matches step numbers in workflow.md:

1. **Step 1 — Checkpoint** → already handled above; create or resume SESSION.md
2. **Step 2 — Source intake** → identify input class (URL / code / screenshots / ZIP / brief / `designlang` output / `monolith` + `wget` mirror), inventory materials. **For `designlang` / `monolith` / `wget` outputs — consult `reference/source-readers.md` to know which files to read, which to read conditionally, and which to ignore (designlang выгружает обычно 50-90 файлов с префиксом домена в имени; критичны 4-7 файлов, остальные — дубли в других форматах или для других платформ).**
3. **Step 3 — Brand analysis** → voice, palette, type, spacing, iconography (notes to SESSION.md only)
4. **Step 4 — Plan structure** → preview cards, UI kits, substitutions
5. **Step 5 — ⛔ MANDATORY STOP** → show plan, wait for explicit user approval; correction loop inside this step until approved
6. **Step 6 — Generation** → 7 sub-steps (6a skeleton → 6g viewer)
7. **Step 7 — Self-checklist** → write `CHECKLIST-RESULT.md`; do not deliver until every category ✓
8. **Step 8 — Handoff** → no summary, only Caveats + bold ask to iterate

## Reference files (load on demand)

| Topic | File |
|---|---|
| Detailed workflow (8 steps + SESSION.md schema) | `reference/workflow.md` |
| Operational rules, tool substitutions, three-pass selection, antipatterns | `reference/rules.md` |
| Templates for every generated file (CSS, SKILL.md, viewer, cards.json) | `reference/templates.md` |
| Output checklist with 5 categories and proof format | `reference/checklist.md` |
| **How to read tool outputs (`designlang`, `monolith`, `wget`, ZIP bundles, codebases) — must-read / conditional / ignore tables** | **`reference/source-readers.md`** |

Read each reference file the first time you need its content in the current session. Do not pre-load all of them — that wastes context budget.

## Required tools (Claude Code)

- **Read, Write, Edit** — file operations
- **Bash** — `cp`, `mkdir`, `ls`, `find` for asset management
- **Glob, Grep** — exploring source codebases
- **WebFetch** — if the source is a URL

## Interaction language (IMPORTANT)

**All user-facing prose — IN RUSSIAN.** This is non-negotiable for this user.

Russian applies to:
- Every question you ask the user (clarifications, choices, confirmations)
- Every `AskUserQuestion` interactive prompt — question text, header (макс 12 chars), option labels, option descriptions
- The plan you present at Step 5 (MANDATORY STOP)
- Progress updates and status messages during generation
- Caveats and bold-ask handoff at Step 8

Keep in English regardless:
- File names (`colors_and_type.css`, `SKILL.md`, `cards.json`)
- Folder names (`preview/`, `ui_kits/`, `assets/`)
- CSS variable names (`--rixai-cyan`)
- Code comments inside generated files
- YAML front-matter field names

Brand content (README prose, voice examples, card subtitles) follows the bilingual rule in `rules.md` §5 — use the brand's own language. If the brand language is unclear, ask the user in Russian.

Examples of correct Russian interaction:
- "Какой источник бренда у тебя есть?" (instead of "What kind of brand source...")
- "Куда сохранить бундл?" (instead of "Where should the bundle land?")
- "Перед тем как я напишу 20+ файлов: план выглядит так — устраивает? Ответь ОК или скажи что поменять."

## Output style (handoff)

When you finish, DO NOT summarize what you did. Mirror Claude Design's handoff style:

- **Caveats** («Что я подменил»): numbered list of every substitution (fonts, icons, imagery), unverifiable assumptions, known limitations.
- **A clear, bold ask** («Что улучшить дальше»): 3-5 concrete iteration paths phrased as questions. Bias toward the most fidelity-impacting gaps first.
- Never close with "I have completed X, Y, Z."

**🚨 Plain Russian — non-negotiable.** The chat handoff must be readable by a non-technical user with zero English. No CSS variable names, no file paths inside explanations, no skill internals (`designlang`, `voice extraction`, `library: unknown`), no foundry/library brand names, no English design jargon (`fidelity-gap`, `hi-fi recreation`, `surface`, `tone of voice`). Short sentences, one thought per sentence. Full rules + jargon translation table: `reference/rules.md §8`. Step-by-step format and self-check: `reference/workflow.md` Step 8.

The bundle is the artifact. The Caveats + ask are the conversation.
