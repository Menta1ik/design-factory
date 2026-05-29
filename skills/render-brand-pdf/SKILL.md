---
name: render-brand-pdf
description: Render branded PDFs and slide decks from HTML using brand tokens (colors_and_type.css + fonts). Two workflows: A4 longread (native PDF via Chrome — text is selectable) and slide deck (rasterized PDF via Playwright screenshots). Use when the user asks to make a PDF, render slides, build a deck, export a presentation, or convert HTML to PDF using brand styles.
when_to_use: User has a design system (colors_and_type.css + fonts/) and wants to produce a branded PDF artifact — a longread, deck, presentation, or report. Also when the user explicitly types /render-brand-pdf.
allowed-tools: Read Write Edit Bash Grep Glob
---

## Interaction language (IMPORTANT)

**All user-facing prose — IN RUSSIAN.** Questions, plan presentations, progress updates, caveats — all in Russian.

Keep in English regardless:
- File names, folder names, CSS-variable names, code comments
- Shell commands and Python identifiers

For brand content in the PDF (headlines, body copy) — language of the brand, follow the source HTML.

## Two workflows — pick the right one

Decide BEFORE generating which workflow fits the artifact:

| | **A — A4 longread** | **B — Slide deck** |
|---|---|---|
| **When** | Essays, reports, articles, homework, methodologies | Webinars, covers, stories, presentations |
| **Format** | A4 portrait 210×297mm | 16:9 (1920×1080) or 9:16 (1080×1920) |
| **PDF type** | Native — text selectable, searchable, copy-pasteable | Rasterized — PNG screenshots merged |
| **Engine** | Chrome `--print-to-pdf` | Playwright screenshots → PIL PDF |
| **Fonts in PDF** | Real glyphs (vector) | Baked into pixels |
| **Size** | Small (0.5–2 MB) | Medium (5–25 MB) |
| **Best for** | Documents that get READ | Things that get SHOWN on screen |

**Decision rule:** documents people READ → A. Things shown on a SCREEN → B.

Full procedures in `reference/`:
- `reference/workflow-a-longread.md` — A4 longread procedure with Chrome
- `reference/workflow-b-slides.md` — Slide deck procedure with Playwright
- `reference/component-library.md` — Reusable visual components (.eyebrow, .glass-card, .callout, etc.)
- `reference/troubleshooting.md` — 9 technical bugs (Ё-character, headless quirks, fonts)
- `reference/real-bugs.md` — Universal failure modes from production runs (overflow, wrong attribution, wall-of-text, etc.) — READ BEFORE FINISHING
- `reference/quick-commands.md` — Cheat sheet of all shell commands

## Prerequisites

Before invoking this skill, the user must have:

1. **A design system folder** with at minimum:
   - `colors_and_type.css` (brand tokens + @font-face)
   - `fonts/*.woff2` (self-hosted brand fonts — Chrome requires local fonts for headless PDF)

2. **Source HTML** to render — either:
   - User provides it directly
   - User asks you to author it from a markdown brief (then write HTML using the brand DS)

3. **Tools installed:**
   - Google Chrome (`/Applications/Google Chrome.app/`)
   - Python 3 (`python3`)
   - For workflow B only: `pip install playwright Pillow && playwright install chromium`
   - Optional but recommended: `brew install poppler` (pdftoppm + pdftotext for verification)

If any prerequisite is missing — STOP and ask the user to provide / install before continuing.

## Pre-start questions (ASK BEFORE STEP 1)

The single most important rule learned from production runs: **asking a clarifying question BEFORE doing beats re-doing AFTER.**

At the start of every invocation, ask these 6 questions (in Russian per the interaction rule). Skip a question only if the user already answered it in the initial message.

1. **Aspect ratio?** — 16:9 (presentations, webinars), 9:16 (Instagram stories, vertical content), 4:3 (print, classic), or A4 (longread document)
2. **Brand attribution?** — if the brand has multiple sub-brands (Academy / Research / Newsletter / etc.), which one is this for? What goes in the footer / cover slate?
3. **Document closure?** — Should it feel **complete and standalone**, or is it part of a series with teasers / "next time" references?
4. **Images / screenshots?** — Can they be cropped if they don't fit, or must they be shown in FULL (use side-by-side layout instead of crop)?
5. **Naming style?** — If naming agents / entities / sections: functional and short, or creative and descriptive?
6. **Source has options?** — If the source material offers "version A or B" / "short or long" — is the final intent to show ONE or BOTH?

If the user's initial message already answers a question, skip it. Don't pepper with redundant questions. But before generating ANY layout, **ensure at least aspect ratio and brand attribution are explicit**.

## Process (overview)

1. **Identify workflow** — A (longread) or B (slides). Already determined by aspect ratio answer above.
2. **Bootstrap folder** — copy `colors_and_type.css` + `fonts/*.woff2` into the artifact folder so it's portable.
3. **Author or accept HTML** — either receive HTML from user or write it using brand tokens.
4. **Start local HTTP server** — `python3 -m http.server` on a unique port (8788–8796 range; never `file://` because `@font-face` won't load).
5. **Render PDF:**
   - Workflow A: Chrome headless `--print-to-pdf` with `--print-to-pdf-no-header --no-pdf-header-footer --virtual-time-budget=10000`
   - Workflow B: Playwright capture each slide at authored resolution, then PIL merges PNG → PDF
6. **⛔ MANDATORY visual verification with overflow-fix loop** — render every page as PNG, `Read` each one individually, check for bottom/right-edge content clipping. If any page overflows: fix HTML/CSS → re-render → re-verify. Maximum 4-5 fix attempts per page before escalating to user. **Do not deliver a PDF with known overflow.** See workflow-a §5 / workflow-b §6 for the full loop.
7. **Copy-paste verification** (workflow A only) — `pdftotext file.pdf - | head -50` and check for broken glyphs especially around the letter «Ё».
8. **Clean up** — kill the HTTP server (`kill $(cat /tmp/srv.pid)`).
9. **Handoff** — give the user the PDF path. Report any compromises (substitutions, dense layouts, known issues).

Detailed step-by-step is in `reference/workflow-a-longread.md` and `reference/workflow-b-slides.md`.

### Why step 6 is non-negotiable

The single most-reported failure of prior runs: text/content cut off at the bottom of A4 pages, or extending past the right edge of slides. The user has to manually open the PDF, find the broken page, tell the agent what's wrong. **Now the agent must catch this BEFORE delivery** by reading every page and applying the overflow-fix loop until everything fits.

## Sanity checklist before delivery

A 12-point review based on real production failures. Run all of these before declaring done. Full failure details in `reference/real-bugs.md`.

| # | Check | How |
|---|---|---|
| 1 | All pages visible end-to-end, no clipped footer / content | Visual review every page via `pdftoppm` |
| 2 | No H2 headings in the middle of a page | One H2 = one page minimum |
| 3 | Copy-paste from PDF gives clean words | `pdftotext file.pdf` + `grep -c "Ё"` + single-letter line check |
| 4 | Images shown in full, not cropped | `object-fit: contain` or side-by-side layout, not `cover` |
| 5 | No glow artifacts around diamonds / pills | Remove `box-shadow` from rotated / pill elements |
| 6 | Document feels **complete**, not a teaser | Final page = closing thought, no "next time" promises |
| 7 | Correct brand / series / sub-brand attribution | Confirmed via pre-start question 2 |
| 8 | Not "wall of text" — visual hooks per page | Stat, pullquote, character-quote, chart, diagram |
| 9 | All cover numbers match real content | Recount every stat-card number |
| 10 | URLs are clickable, single-line, complete | `<a href="https://...">` with no manual wrap |
| 11 | Renamed entities consistent in all grammatical forms | Separate edits per case (declension trap in inflected languages) |
| 12 | Aspect ratio matches what user asked | Confirmed via pre-start question 1 |

If ANY of these fail → fix before delivery. Do NOT hand off a PDF with known issues from this list.

## Required tools (Claude Code)

- **Read, Write, Edit** — author HTML, read PDFs back for verification
- **Bash** — run Chrome, Python servers, pdftoppm, pdftotext
- **Glob, Grep** — find existing CSS/fonts in the project

## Output style (handoff)

When done, DO NOT summarize step-by-step. Tell the user:

- **Path to the PDF** (absolute path)
- **Quick stats:** N pages, size in MB
- **Overflow-fix loop summary:** how many pages were inspected, how many needed fixes, what was fixed (e.g. "All 12 pages verified. Page 7 had bottom overflow — applied `.tight` modifier, re-rendered, now fits. Page 11 needed text shortened by 1 line.")
- **Known compromises:** what was simplified, any anti-pattern triggered, font substitutions
- **Bold ask:** specific concrete questions for next iteration (e.g., "Page 7 is dense even after fix — want me to split it into 7a + 7b?", "The cover photo is dark — want me to brighten or replace?")

## Source

This skill encodes a battle-tested workflow developed for the RixAI brand. Generalized to work with any brand that provides `colors_and_type.css` + `fonts/`.
