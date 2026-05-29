# 🏗️ Design Factory — Universal AI Design Engine

```text
    ____           _                ______           __                  
   / __ \___  ____(_)___ _____     / ____/___ ______/ /_____  _______  __
  / / / / _ \/ ___/ / __ `/ __ \   / /_  / __ `/ ___/ __/ __ \/ ___/ / / /
 / /_/ /  __(__  ) / /_/ / / / /  / __/ / /_/ / /__/ /_/ /_/ / /  / /_/ / 
/_____/\___/____/_/\__, /_/ /_/  /_/    \__,_/\___/\__/\____/_/   \__, /  
                  /____/                                         /____/   
```

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.0-5e6ad2?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/context%20optimizer-%3E99.98%25-green?style=flat-square" alt="Context Optimizer">
  <img src="https://img.shields.io/badge/vibe--coding-active-ff69b4?style=flat-square&logo=visual-studio-code" alt="Vibe Coding">
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux-5e6ad2?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/github/license/Menta1ik/design-factory?style=flat-square&color=5e6ad2" alt="License">
</p>
<p align="center">
  <a href="http://meowroom.top" target="_blank">
    <img src="https://img.shields.io/badge/kharkiv%20cats-meowroom.top-yellow?style=flat-square&logo=heart" alt="Kharkiv Cats">
  </a>
  <a href="http://meowroom.top" target="_blank">
    <img src="https://img.shields.io/badge/donate-PayPal-blue?style=flat-square&logo=paypal" alt="Donate PayPal">
  </a>
</p>

A multi-agent, cross-platform mono-repository that orchestrates a complete, high-fidelity AI design pipeline: **Scraping -> Tokenization -> Visual Rendering**. Compatible with **Google Antigravity**, **Claude Code**, **OpenAI Codex**, **Cursor**, **Windsurf**, and **VS Code (Roo Cline)**.

Designed to fight generic, cookie-cutter artificial intelligence aesthetics (Anti-AI-Slop) and produce world-class design systems, branded offline viewers, presentation decks, and selectable vector PDF reports directly on your local machine.

> [!IMPORTANT]
> **⚡ THE DESIGN FACTORY ADVANTAGE — 99.98% AI Context & Token Optimizer:**
> Design Factory features an advanced, ultra-efficient **Two-Phase Scraper & Compiler** that completely solves the **"LLM Context Trap"**. Instead of feeding raw, heavy website DOMs (**10MB–51.5MB** consuming up to **37,000,000 tokens** at a cost of ~$150 per prompt) directly to the AI, `df` runs scraping locally on your machine and compiles it into a highly compressed, structured **11KB token bundle** (only **~8,000 tokens**).
> - **Silent Mode (`--silent` / `-s`):** Completely silences terminal scraper log spam (wget/playwright progress logs) to protect your AI agent context window, saving up to **95% of output tokens**.
> - **Token Telemetry Calculator:** Provides real-time economic audit reports detailing raw-to-processed byte compression, token footprint, and exact context efficiency gains.

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

## 🚀 AI Token & Context Efficiency Optimizer

One of the biggest bottlenecks when using AI agents for web development is the **"LLM Context Trap"**:
-   **The Core Problem:** Direct scraping of corporate website landing pages (such as Stripe or Linear) yields raw HTML/CSS packages ranging from **10 MB to 51.5 MB** of raw data. Feeding these files directly into an LLM would consume between **7,500,000 and 37,000,000 input tokens** for a single prompt. This is financially unsustainable and physically exceeds modern LLM context limits, resulting in severe "hallucinations" or outright API failures.
-   **The LLM Terminal Spam:** Running scraper tools inside an AI agent environment without filtration generates huge stdout streams (e.g. `wget` file-by-file dynamic progress downloads). These outputs clog the agent's context window with useless logs, draining tokens and slowing down responses.

### 🛡️ The Two-Phase Solution (The Design Factory Advantage)

Design Factory solves this using a strict two-phase context compression architecture:

1.  **Phase 1: Local Heavy Lifting (Zero Token Cost)**
    The `df` CLI tool runs locally on your machine, leveraging `monolith`, `wget`, and `playwright` to fetch, mirror, and assemble brand assets in the background. **No LLM tokens are used** for this heavy downloading, scraping, and initial token categorization.
2.  **Phase 2: Ultra-Compressed AI Synthesis**
    Instead of raw HTML, the AI agent is fed with the highly structured [cards.json](file:///path/to/cards.json) (3.5 KB) and [colors_and_type.css](file:///path/to/colors_and_type.css) (7.9 KB) generated by the extraction step. This drops the input payload from **51.5 MB down to ~11 KB** (approx. **8,000 tokens**).
    *   **Compression Ratio:** **`> 99.98%`** context window compression.
    *   **Cost Savings:** Saves up to $150–$300 per AI prompt while delivering pixel-perfect brand fidelity.

### 🔇 Telemetry, Silent Mode & Progress Indicators

To maintain ultimate pipeline efficiency, the `df` CLI provides native telemetric optimization features:

*   **Silent Mode (`--silent` or `-s`):**
    Adding the silent flag (`./df extract <URL> --silent` or `./df check --silent`) redirects all raw command outputs (`wget`, `monolith`, `designlang`) to a localized debug file `source-raw/<brand>/extract.log`. This ensures that **zero terminal log spam is fed back to your AI agent**, saving up to **95% of output token generation**.
*   **Dynamic Progress Bar:**
    For interactive human terminal sessions, `df` displays a smooth, single-line progress indicator (`[██████░░░░] 60% | Step 3/4: Mirroring...`) which updates on the same line to keep your terminal output clean.
*   **Token Telemetry Calculator:**
    Upon completing an extraction, `df` automatically calculates and displays a detailed economic telemetry table showing raw data volume, compressed token count, exact compression ratio, and the estimated number of saved input tokens.

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

---

## 👤 About the Author

I'm a **vibe-coding evangelist** — a solo builder running multiple large projects simultaneously, using AI agents as my development team.

I believe the future of software creation is not about typing code line by line. It's about thinking in systems, orchestrating AI agents, and shipping products that matter — fast, intentionally, and without burning out.

This repository is the quintessence of everything I use. Every tool here has been battle-tested across real products: a legal platform for the Spanish jurisdiction, a talent competition system with AI judging, a veterinary assistant, and more. This isn't a curated list — it's a living toolkit, shaped by hundreds of hours of actual vibe-coding sessions.

### 🐱 The Cats of Kharkiv

I run a cat shelter in Kharkiv, Ukraine — a city that has been under constant bombardment since the full-scale invasion began in 2022.

While sirens go off and windows shake, the cats still need to be fed. Wounds still need treatment. Kittens found in the rubble still need warmth. The shelter keeps running — because someone has to.

Every star, every fork, every donation from this project goes directly to the shelter. Not to cloud infrastructure. Not to marketing. To food, medicine, and the people who show up every day — war or no war.

If this toolkit saved you time, made your project better, or just gave you a useful idea — please consider paying it forward.

*   🌍 **[meowroom.top](http://meowroom.top)** — see the shelter, meet the cats
*   💛 **Donate via PayPal** — 100% goes to the animals

> *"We write code to build the future. We rescue cats to keep our humanity."*
