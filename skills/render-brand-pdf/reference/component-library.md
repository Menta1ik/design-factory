# Visual Component Library

Reusable component classes for branded HTML documents. Reference list — these are conventions, not hardcoded in any CSS file. When you author HTML for a longread or slide deck, prefer composing these patterns rather than inventing new ones.

The classes assume `colors_and_type.css` defines variables: `--bg`, `--bg2`, `--bg3`, `--cyan`, `--yellow`, `--red`, `--green`, `--text`, `--text2`, `--text3`, `--glass-bg`, `--glass-border`, `--radius`, `--radius-lg`, `--font-display`, `--font-body`, `--font-compressed`.

If the brand's `colors_and_type.css` uses a different prefix (e.g. `--stripe-*`), adapt accordingly — but the component shapes stay the same.

---

## Headers and structure

| Class | What it does | Where used |
|---|---|---|
| `.eyebrow` | Cyan small-caps badge with diamond marker, sits above H2 | Above every H2 section title |
| `.cover h1` | Gigantic display heading for document/deck cover | First page only |
| `.section-title` | H2 with optional `.accent` (cyan gradient text) | Section headers throughout |
| `.corner-sm` | Bottom-right slide counter | Slide deck pages |
| `.signoff` / `.author-sig` | Author signature block | End of document |

---

## Cards and containers

| Class | What it does | Notes |
|---|---|---|
| `.glass-card` / `.gcard` | Semi-transparent card with blur + border | Universal container |
| `.gcard-outer` | Glass card with extra padding for hero context | Premium contexts |
| `.callout` (+ `.warn`, `.danger`) | Coloured panel with pill-tag and body | Key emphasis blocks |
| `.pullquote` | Large quote with cyan left-border | Memorable lines |
| `.num-grid` + `.num-card` | Cards with large outline numbers | Numbered points |

---

## Lists and bullets

| Class | What it does | Notes |
|---|---|---|
| `.dlist` | List with diamond markers (◇) instead of bullets | Any list |
| `.xlist` | List with red ✕ marks | "What NOT to do" sections |
| `.ul-brand` (+ `.cross`) | Brand list with ✓/✕ circles | "Fits / doesn't fit" |
| `.tier-table` / `.data-table` | Styled comparison tables | Pricing tiers, feature matrix |

---

## Process and flow visualizations

| Class | What it does | Notes |
|---|---|---|
| `.process-flow` / `.flow-chain` | Pill-step chain with arrows | Linear processes |
| `.tree` / `.tnode` | Decision tree if-then blocks | Route selection |
| `.steps` / `.step-item` | Numbered steps with CSS counter | Procedural instructions |
| `.timeline` (+ phases) | Coloured phase cards | N-day warmup, project phases |
| `.warmup` | Calendar grid with phase colours | Multi-day plans |
| `.hub` (+ inline SVG) | Hub-and-spoke diagram | Many-to-one relationships |
| `.layers` / `.layer` | Stacked horizontal layers | Brand strata |

---

## Stats and data

| Class | What it does | Notes |
|---|---|---|
| `.hero-stats` | 3+ stat grid: big number + label | Cover, section opening |
| `.stat-row` | Row of large stat-cards | Number-driven validation |
| `.bar-compare` | Horizontal bar chart | Number comparisons |
| `.compare` | "Winner vs rest" comparison | A/B, vs competitors |

---

## Code and technical

| Class | What it does | Notes |
|---|---|---|
| `.file-pill` | Pill with file name | `concept.md`, path references |
| `.fp` | Short `.md` pill | Artifact lists |
| `.slash` | Command-line `/skill-name` | Slash commands |
| `.prompt-block` | IDE-style block with label tag | Ready-to-use prompts |
| `code` / `.filename` | Inline monospace | Any inline code |

---

## Identity and personas

| Class | What it does | Notes |
|---|---|---|
| `.persona` | Card with pixel portrait + text | Agent introductions |
| `.charquote` | Pixel character + speech bubble | Quote with face |
| `.fantik-cloud` | Tag cloud | "29 wrappers" / topic cloud |
| `.verdict-cols` | 3-column bento: true / false / uncertain | Analytical verdicts |
| `.video-card` | Video card with URL + stats | Recommendations |
| `.gloss-grid` / `.gloss-cell` | Term grid | Glossary |
| `.conf` (`.fact/.high/.med/.spec/.unk`) | Confidence-level pills | Source-cited analytics |

---

## Composition rules

1. **One `.callout.danger` per page maximum** — overuse kills the signal
2. **`.pullquote` for spoken words / key insights only** — not for definitions
3. **`.eyebrow` before every H2** — even short sections benefit from this rhythm
4. **`.corner-sm` only on slide decks** — A4 longreads use page numbers in footer instead
5. **`.glass-card` is the default** — use plain `.section` only if you need transparency-free content

---

## Reuse policy

These components were developed across multiple projects (`personal_brand_v2`, `hermes-deck`, `raspakovka-deck`, `homework-track-v2`, `hw3-deck`, `html-md-deck`, `anthropic-spacex-deck`, `RixAI Dzen/`). They're not all defined in one shared CSS file — each project tends to copy what it needs into a project-local stylesheet.

When authoring a new document:
1. Start with the brand's `colors_and_type.css` linked
2. Add a `<style>` block in the HTML with just the components you use
3. Don't try to import every component pattern — only what this document needs

The component class names are convention. The visual recipes are documented in this file. Copy-paste the styles from any existing project in `/Users/max/Documents/RixAI эфир/` if you want production-tested CSS.
