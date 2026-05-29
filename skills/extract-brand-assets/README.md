# extract-brand-assets — Agent Skill

A portable Agent Skill for extracting raw design tokens, styling assets, and offline mirrors from any target brand URL. It is Step 1 of the **Design Factory** pipeline, designed for Claude Code, OpenAI Codex, Cursor, and other agentic environments.

## What It Does

Given a target URL, the skill automates the parallel execution of three scraping and token extraction utilities to capture a comprehensive snapshot of the brand's styling:

1. **`monolith`**: Downloads the website as a single, self-contained offline HTML archive (embedding all assets, CSS, and scripts in base64).
2. **`wget --mirror`**: Downloads a structured directory mirror of pages and public assets (images, stylesheets, icons) up to 1 level deep.
3. **`designlang`**: Automates a headless browser (Playwright) to extract raw CSS variables, color palettes, typography specs, and renders a standalone brand book PDF.

All raw output is neatly organized into a local `source-raw/` folder, ready to be digested by the `/create-design-system` skill.

## Folder Structure

The skill organizes raw materials in the following format:
```
source-raw/
├── monolith/
│   └── site.html            # Unified single-file offline copy of the site
├── mirror/
│   └── [domain]/            # Structured static assets and page copies
└── designlang/
    └── [brand]-tokens/      # Extracted CSS design tokens and brand book PDF
```

## Setup & Prerequisites

Before invoking this skill, ensure the following utilities are installed on your system:

### 1. Monolith & Wget
On macOS, install via Homebrew:
```bash
brew install monolith wget
```

### 2. Node.js & Playwright
`designlang` is executed via `npx` and requires a pre-warmed Chromium instance:
```bash
npx -y playwright install chromium
```

## How to Use

### Inside Claude Code (Slash Command)
Type `/` and select the command, or call it directly with a URL:
```
/extract-brand-assets https://stripe.com
```

### Inside Cursor / Windsurf / Roo Cline
You can prompt the agent naturally:
```
"Scrape raw assets and styling from https://linear.app using extract-brand-assets"
```
Or the agent will automatically detect and trigger this skill if it is configured in your MCP server or rules files.

## Output Format & Handoff

Once the extraction is complete, the skill provides a clear, structured summary showing the sizes and file counts of the extracted assets. It then prints a clear action call directing you to proceed to Step 2:

```
✓ Raw brand extraction complete!
Run "/create-design-system" to compile these materials into a unified design system.
```
