# 🏗️ Design Factory — Universal AI Design Engine

A multi-agent, cross-platform mono-repository that orchestrates a complete, high-fidelity AI design pipeline: **Scraping -> Tokenization -> Visual Rendering**. Compatible with **Google Antigravity**, **Claude Code**, **OpenAI Codex**, **Cursor**, **Windsurf**, and **VS Code (Roo Cline)**.

Designed to fight generic, cookie-cutter artificial intelligence aesthetics (Anti-AI-Slop) and produce world-class design systems, branded offline viewers, presentation decks, and selectable vector PDF reports directly on your local machine.

---

## 🧭 The End-to-End Pipeline

```
[ Step 1: Extraction ]       -->  [ Step 2: Tokenization ]       -->  [ Step 3: Rendering ]
./df extract <URL>                ./df make-ds <brand>                 ./df render <brand>
(Monolith, Wget, Designlang)       (Colors, Fonts, Spacing, React UI)   (Swiss International, Editorial)
```

1.  **Extraction (`/extract-brand-assets`):** Scrapes a website using three tools in parallel (`monolith` for offline archives, `wget` for directories, and `designlang` for raw CSS variables & PDF brandbooks).
2.  **Tokenization (`/create-design-system`):** Takes raw scraped assets and transforms them into an official design system folder, compiling colors, typography scales, spacing tokens, and a standalone offline interactive `design-system-viewer.html`.
3.  **Rendering (`/render-brand-pdf`):** Takes branded markdown documents and renders them into vector A4 reports or high-resolution 16:9 slide decks (equipped with an automated visual overflow-fix quality control loop).

---

## 📂 Repository Structure

```
design-factory/
├── README.md                     # This file: Universal English roadmap & documentation
├── install.sh                    # Intelligent automated Mac installer script
├── install.ps1                   # Intelligent automated Windows PowerShell installer
├── df                            # Executable Node.js CLI tool (macOS/Linux)
├── df.cmd                        # Windows Command Prompt execution wrapper
├── df.ps1                        # Windows PowerShell execution wrapper
├── mcp-server.js                 # Model Context Protocol (MCP) Server
├── .gitignore                    # Local sandbox folder isolator
│
├── skills/                       # The actual active AI Custom Skills (COMMITTED)
│   ├── extract-brand-assets/     # Step 1: Parallel website asset scraper
│   ├── create-design-system/     # Step 2: Claude Design token compiler
│   └── render-brand-pdf/         # Step 3: Headless PDF & slide deck renderer
│
├── examples/                     # Pre-packaged samples for local testing (COMMITTED)
│   ├── stripe-design-system/     # Example pre-compiled design system folder
│   └── mock-slides.md            # Sample markdown slides to test rendering
│
├── console/                      # Design Factory Web Console (Local Web App)
│   ├── server.js                 # Pure Node.js backend HTTP server
│   └── public/                   # Sleek Dark Mode glassmorphic web dashboard
│
└── raw/                          # Local temporary staging/backup folder (GITIGNORED)
```

---

## 🌐 Universal IDE & AI Agent Compatibility

Design Factory is standard-compliant and works out-of-the-box in all major development environments:

### 1. Local Autonomous Orchestrators (Antigravity, Aider, Roo Cline, etc.)
Highly compatible with any modern local autonomous coding agent and command-line workspace assistant:
-   **Aider:** Natively reads project rules (instructions.md) and automates pipeline execution directly in your git repository.
-   **Roo Cline / Cline (VS Code):** Autonomously triggers step-by-step design pipelines by connecting directly to the built-in MCP server.
-   **Google Antigravity:** Natively runs complex multi-agent orchestrator loops, spawns design sub-agents, and runs background tasks.

### 2. Claude Code CLI (Slash Commands)
The installation script registers the custom skills into your global Claude Code environment (`~/.claude/skills/`). You get three fast slash commands inside the terminal:
-   `/extract-brand-assets <URL>`
-   `/create-design-system`
-   `/render-brand-pdf`

### 3. OpenAI Codex (Desktop App, CLI, Web)
-   **Codex CLI / Desktop:** Codex agents natively call the `./df` executable to fetch assets and build PDFs.
-   **Instructions:** The compiled `instructions.md` at the root instructs OpenAI models inside the editor on brand guidelines and styling rules.

### 4. Custom MCP Server (`design-factory-mcp`)
Our built-in `mcp-server.js` exposes core functions to any tool supporting the Model Context Protocol:
-   **Cursor:** Add under `Settings -> Features -> MCP` as a `command` type (`node /path/to/mcp-server.js`).
-   **Windsurf:** Registers natively inside Cascade's `mcp_config.json`.
-   **VS Code (Roo Cline):** Integrates directly, enabling AI agents to click-to-run CLI commands.

### 5. Automated Rules Compiler
Running `./df compile` instantly generates dedicated IDE rule files:
-   `.cursorrules` (Cursor)
-   `.windsurfrules` (Windsurf)
-   `.clinerules` (Roo Cline / Cline)
-   `instructions.md` (OpenAI Codex / Continue)

AI models inside these editors automatically inherit the rules, typography lists, and styling guides.

---

## 🛠️ The "Anti-AI-Slop" Manifesto (Core Styling Rules)

Every tool and agent in this repository is strictly bound to fight generic AI design clichés:
-   **NO Cliche Grids:** No generic 3-column layouts with Lucide icons inside small colored circles.
-   **NO Bluish-Purple Grids/Glows:** Never default to purple-to-pink neon glowing radial spots behind dark cards.
-   **NO Arial/Inter Typography Trap:** Do not use Arial or Inter for display headings. Use the typography database.
-   **DO Choose a Bold Aesthetic Theme:** Neubrutalism, Warm Editorial, Bento Grid, Sleek Cyber, or Soft Wellness. Commit and execute with precision.

---

## 📦 Installation & Setup

Design Factory provides automated cross-platform scripts and agent tools to install all prerequisites and register AI skills globally.

### 1. Universal Setup via CLI (Recommended)
Runs natively on any OS (macOS, Windows, Linux). Simply run:
```bash
node df install
```

### 2. Autonomous Setup via AI Agent (MCP)
If your AI assistant (in Cursor, Windsurf, or Roo Cline) is connected to the Design Factory MCP server, you can simply instruct it in the chat:
> *"Please install and configure the Design Factory pipeline on my machine."*
The agent will call the `install_pipeline` tool and configure your system autonomously.

### 3. Native Shell Installers (Fallbacks)
- **macOS / Linux (Terminal):**
  ```bash
  chmod +x install.sh
  ./install.sh
  ```
- **Windows (PowerShell):**
  ```powershell
  Set-ExecutionPolicy Bypass -Scope Process -Force
  .\install.ps1
  ```

---

## 🚀 Quick Start in 60 Seconds

### 1. Compile Helper Rules
Generate rules files for Cursor, Windsurf, Roo Cline, and Codex:
- On macOS/Linux: `./df compile`
- On Windows: `node df compile`

### 2. Scrape a Target Brand
- On macOS/Linux: `./df extract https://stripe.com`
- On Windows: `node df extract https://stripe.com`

### 3. Initialize Design System
- On macOS/Linux: `./df make-ds stripe`
- On Windows: `node df make-ds stripe`

### 4. Launch the Web Console
- On macOS/Linux: `./df console`
- On Windows: `node df console`

Open `http://localhost:8080` in your web browser to browse the visual dashboard, edit colors with a color picker, write markdown content with a live preview, and download custom slide decks in one click.
