# create-design-system — Agent Skill

A portable Agent Skill that transforms any target brand source (website URL, code repository, screenshots, designlang ZIP, or brand brief) into a structured, highly refined design-system bundle in the **Claude Design** format. Compatible with Claude Code, OpenAI Codex, Cursor, and any tools supporting the [agentskills.io](https://agentskills.io) standard.

## What This Skill Does

It replicates Anthropic's internal Claude Design reasoning engine. Given a brand source, it extracts, formats, and generates a portable design system folder including:

-   **`SKILL.md`**: An Agent Skill manifest specifically tailored for the brand.
-   **`README.md`**: Rich brand documentation (brand personality, voice and tone, typography system, spacing, and icon guidelines).
-   **`colors_and_type.css`**: Design tokens and semantic layout helper classes.
-   **`cards.json`**: Metadata manifest for visual preview cards.
-   **`design-system-viewer.html`**: A standalone, fully responsive offline viewer replacing the Claude Design "Design System tab," allowing the entire bundle to be browsed locally.
-   **`preview/`**: 12–20 pixel-perfect specification cards (Colors, Type, Spacing, Components, Brand).
-   **`ui_kits/`**: High-fidelity React-standalone recreations of the brand's key interface sections (Landing page, navigation, forms, dashboards).
-   **`assets/`, `fonts/`, `slides/`**: Hosted local design assets, custom typography files, and presentation slide decks.

---

## File Structure

```
create-design-system/
├── SKILL.md                  # Main entry point: YAML metadata, checkpoint protocol, & workflow (~95 lines)
├── README.md                 # This file: Setup & usage documentation in English
└── reference/                # Loaded dynamically by the AI to save context budget
    ├── workflow.md           # 8-step extraction and generation procedure
    ├── rules.md              # Naming, compression rules, Anti-AI-Slop and UI-UX Pro Max style database
    ├── templates.md          # Skeleton files for CSS, HTML, cards.json, and React UI kits
    └── checklist.md          # Verification steps for 5 compliance categories
```

The skill uses a **distributor pattern** to keep the core `SKILL.md` light. Detailed guidelines, templates, and specifications are placed in the `reference/` subfolder. The agent reads these files only when required, keeping the context window highly efficient during long development sessions.

---

## Setup & Installation

To register this skill with your AI terminal, copy the skill folder to your agent's directory.

### Global Installation (Accessible across all projects)

On macOS:
```bash
mkdir -p ~/.claude/skills/
cp -R skills/create-design-system ~/.claude/skills/
```

### Verification
In Claude Code, type `/` — `create-design-system` should appear in the commands menu. Alternatively, ask the agent: *"What skills do you have access to?"*

---

## How to Use

### Direct Invocation (Slash Command)
```
/create-design-system https://stripe.com
```
Or simply prompt the agent in your IDE:
```
"Build a design system from https://linear.app using create-design-system"
"Extract design tokens from this screenshot bundle into a brand kit"
```

---

## Key Integrations & Advanced Features

### 1. Anti-AI-Slop Engine (Inspired by Anthropic `frontend-design`)
The skill prohibits generic "AI aesthetics." It strictly:
-   Bans the default "SaaS purple-pink radial gradient on dark background" unless verified in source.
-   Bans boring typography defaults (like Inter or system Arial). The agent must select a bold, custom aesthetic path.
-   Enforces grid-breaking layouts, overlapping shapes, high-contrast negative space, and asymmetrical structures.

### 2. UI-UX Pro Max Style & Font Database
Integrated directly into the reference guidelines:
-   **10 Visual Styles Spec:** Ready-to-use token values for Neubrutalism, Bento Grid, Glassmorphism, Claymorphism, Soft UI Evolution, Sleek Dark Mode, Warm Editorial, and more.
-   **57 Google Fonts Pairings:** A curated database of font couples grouped by brand mood (e.g., Premium Luxury, Technical Tech/SaaS, Creative Magazine, Brutalist Monospace).

### 3. Checkpoint Protocol (`SESSION.md`)
At Step 1, the agent automatically initializes `SESSION.md` in the current working directory. If a long chat session gets compacted or the agent restarts, the skill reads `SESSION.md` and resumes exactly from the last completed step instead of starting from scratch.

### 4. Interactive Live Viewer (`design-system-viewer.html`)
Every generated folder contains a standalone static HTML app. It serves as an offline, portable dashboard visualizing all generated preview cards and UI kits, allowing you to preview the system locally by double-clicking the file in your browser.
