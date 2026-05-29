# render-brand-pdf — Agent Skill

A portable Agent Skill that renders branded, pixel-perfect PDFs and slide decks from HTML using design system tokens (`colors_and_type.css` + `fonts/`). Compatible with Claude Code, OpenAI Codex, Cursor, and any tools supporting the [agentskills.io](https://agentskills.io) standard.

## What This Skill Does

It takes structured HTML combined with a brand's design system and compiles it into a high-fidelity PDF using two optimized workflows:

| | **A — A4 Longread** | **B — Slide Deck** |
|---|---|---|
| **Use Case** | Essays, detailed reports, articles, homework, text-heavy booklets | Webinars, covers, stories, slide presentations, pitch decks |
| **Format** | A4 portrait (210×297mm) | 16:9 widescreen (1920×1080) or 9:16 vertical (1080×1920) |
| **PDF Type** | Native vector — selectable, searchable text | Rasterized — high-res PNG screenshots merged into PDF |
| **Engine** | Headless Chrome `--print-to-pdf` | Playwright capture → PIL PDF packaging |
| **Typography** | Vector web fonts embedded directly | baked into image pixels |
| **File Size** | Lightweight (0.5–2 MB) | Medium-heavy (5–25 MB) |
| **Best For** | Documents meant to be **READ** | Content meant to be **SHOWN** on screens |

---

## File Structure

```
render-brand-pdf/
├── SKILL.md                            # Entry point: YAML config & workflow router (~95 lines)
├── README.md                           # This file: Setup & usage documentation in English
└── reference/                          # Dynamic справочники loaded on demand
    ├── templates/                      # Premium styled slide and page templates
    │   └── swiss-style/                # Swiss International design layout (asymmetry, IKB blue)
    ├── workflow-a-longread.md          # Vector A4 PDF pipeline using headless Chrome
    ├── workflow-b-slides.md            # Slide deck capture pipeline using Playwright
    ├── component-library.md            # Reusable CSS/HTML elements (.eyebrow, .glass-card, etc.)
    ├── troubleshooting.md              # 9 known headless PDF bugs and their fixes
    └── quick-commands.md               # Ready-to-copy terminal command cheat sheet
```

The skill is built using the **distributor pattern**. The core `SKILL.md` stays small, while specific procedures and troubleshooting manuals reside in `reference/` to save context token budget during long interactive chats.

---

## Setup & Prerequisites

Ensure the following system tools are installed on your Mac before invoking this skill:

### 1. Headless Engine
- **Google Chrome** (`/Applications/Google Chrome.app/`)
- **Python 3** (`python3`)

### 2. Slide Rendering Dependencies (Workflow B only)
```bash
pip install playwright Pillow
playwright install chromium
```

### 3. Visual Verification Tools (Recommended)
On macOS, install via Homebrew:
```bash
brew install poppler
```
This provides `pdftoppm` (renders PDF pages as PNG for visual check) and `pdftotext` (validates vector copy-paste quality).

---

## Installation

### Global Installation (Recommended)
On macOS:
```bash
mkdir -p ~/.claude/skills/
cp -R skills/render-brand-pdf ~/.claude/skills/
```

### Verification
In Claude Code, type `/` — `render-brand-pdf` should appear in the commands menu.

---

## How to Use

### Direct Invocation (Slash Command)
Type `/` and select the command, or call it directly:
```
/render-brand-pdf
```
The agent will prompt you in Russian to select your workflow (A or B), specify the folder containing your design tokens, and select the HTML file to render.

### Automated Trigger (Natural Language)
```
"Compile deck.html into a 16:9 slide presentation using RixAI tokens"
"Render this markdown text into a branded A4 PDF booklet"
"Convert this HTML code into a vector PDF using render-brand-pdf"
```

---

## Key Features & Quality Control

### 1. Unified CSS/HTML Premium Templates
The skill includes ready-to-use premium layouts in `reference/templates/`, such as **Swiss International**:
- Asymmetrical technical layouts with grid coordinates and ASCII dot matrices.
- Ultra-contrasted large typography (`leading-[0.95] tracking-[-0.03em] font-black`).
- Traditional Swiss-style functional headers and footers.

### 2. Mandatory Page Overflow Protection
Prior to final handoff, the agent runs a strict **overflow-fix loop**:
- Every page is rasterized into a PNG via `pdftoppm`.
- The agent visually inspects the bottom and right edges of each page.
- If any text or layout element is cut off, the agent dynamically applies class modifiers (such as `.page.tight`, line-height adjustments, or trimming content by 1-2 lines), re-renders, and verifies again. **No PDF with visual layout bugs is ever delivered.**
