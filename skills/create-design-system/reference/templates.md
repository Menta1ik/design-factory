# Templates

Reference templates for every generated file. Treat each template as a skeleton — fill in brand-specific content, but preserve the structure and section order.

## Contents
1. [colors_and_type.css](#section-1)
2. [README.md](#section-2)
3. [Brand SKILL.md (for the generated bundle)](#section-3)
4. [Preview card HTML](#section-4)
5. [cards.json schema](#section-5)
6. [design-system-viewer.html](#section-6)
7. [UI kit index.html (React via CDN)](#section-7)

---

## Section 1: colors_and_type.css {#section-1}

### 1.1 Extracting tokens from a Tailwind/shadcn codebase

If source is a Tailwind + shadcn project (very common — Lovable, v0, Vercel templates produce this stack), tokens live in **two places**:

1. **`tailwind.config.ts`** — declares names: `colors: { primary: { DEFAULT: "hsl(var(--primary))" } }` — points to CSS variables but doesn't define values
2. **`src/index.css`** (or `globals.css`) — `:root { --primary: 174 80% 50%; }` — the actual HSL values, usually without `hsl()` wrapper

Procedure to flatten both into one `colors_and_type.css`:

1. Read `tailwind.config.ts` — collect all CSS variable names referenced (`--background`, `--primary`, `--card`, etc.)
2. Read `src/index.css` — find the `:root { ... }` block, get actual values
3. **Write flat CSS variables** in our format — wrap raw HSL in `hsl(...)` so consumers don't need to: `--bg: hsl(220 20% 3%);` not `--bg: 220 20% 3%;`
4. Drop Tailwind-specific naming (`--background` → `--bg`, `--foreground` → `--text`, `--primary` → `--<brand-primary-color-name>`)
5. Map semantic Tailwind tokens to brand names: `--accent` → `--cyan`, `--destructive` → `--red`, etc. — choose names that describe the brand role, not generic shadcn defaults
6. Keep `--radius` from Tailwind config — it's a meaningful brand token

If source has **both** Tailwind and `index.css` defining the same token (sometimes shadcn duplicates) — `index.css` wins (it's the actual rendered value).

If source uses `hsl(var(--token))` everywhere in JSX with raw HSL components in CSS — DO NOT preserve that pattern in the bundle. Convert to fully-wrapped CSS variables that consumers can drop in without the `hsl(var())` ceremony.

### 1.2 CSS template

```css
/* ============================================================
   [Brand Name] Design System — core tokens
   [Aesthetic note: e.g. "Dark-first. Cyan primary + Yellow CTA."]
   [If extracted: Extracted from <source> on <date>.]
   [If substituting: [Proprietary Font] substituted with [Google Font].]
   ============================================================ */

/* Google Fonts (only for free fonts; never for proprietary substitutes the user might license) */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

/* @font-face for self-hosted brand fonts.
   Use whatever format the source provides — DO NOT convert.
   Common formats: .woff2 (best for web), .otf (common in Lovable/design exports), .ttf (older).
   Format mapping:
   - .woff2 → format('woff2')
   - .otf   → format('opentype')
   - .ttf   → format('truetype')
*/
@font-face {
  font-family: '[Brand Font]';
  src: url('fonts/[file].otf') format('opentype');
  /* OR: src: url('fonts/[file].woff2') format('woff2'); */
  /* OR: src: url('fonts/[file].ttf') format('truetype'); */
  font-weight: [N];
  font-style: normal;
  font-display: swap;
}

:root {
  /* ── COLOR — Brand ── */
  --[brand]-[primary]: #hex;
  --[brand]-[primary]-hover: #hex;
  --[brand]-[primary]-pressed: #hex;
  /* tints 25/50/100/200 if applicable */

  /* ── COLOR — Accents ── */
  --[brand]-[accent-name]: #hex;
  --[brand]-[accent-name]-50: #hex;
  /* ...one block per accent */

  /* ── COLOR — Neutrals ── */
  --[brand]-white: #ffffff;
  --[brand]-bg: #...;
  --[brand]-bg-subdued: #...;
  --[brand]-bg-quiet: #...;
  --[brand]-bg-dark: #...;
  --[brand]-border: #...;
  --[brand]-border-quiet: #...;
  --[brand]-text: #...;
  --[brand]-text-body: #...;
  --[brand]-text-subdued: #...;
  --[brand]-text-quiet: #...;

  /* ── TYPE ── */
  --[brand]-font-display: "[Display]", fallbacks;
  --[brand]-font-body: "[Body]", system-ui, sans-serif;
  --[brand]-font-mono: "[Mono]", ui-monospace, monospace;
  /* --[brand]-font-script if applicable */

  --[brand]-w-light: 300;
  --[brand]-w-regular: 400;
  --[brand]-w-medium: 500;
  --[brand]-w-semibold: 600;

  /* Type scale (px) */
  --[brand]-size-hero-xxl: 56px;
  --[brand]-size-hero-xl: 48px;
  --[brand]-size-h1: 32px;
  --[brand]-size-h2: 26px;
  --[brand]-size-h3: 22px;
  --[brand]-size-body: 16px;
  --[brand]-size-body-sm: 14px;
  --[brand]-size-caption: 12px;

  --[brand]-lh-tight: 1.05;
  --[brand]-lh-heading: 1.2;
  --[brand]-lh-body: 1.4;

  --[brand]-track-display: -0.02em;
  --[brand]-track-body: 0em;

  /* ── SPACING — Npx base ── */
  --[brand]-space-1: 4px;
  --[brand]-space-2: 8px;
  --[brand]-space-3: 12px;
  --[brand]-space-4: 16px;
  --[brand]-space-6: 24px;
  --[brand]-space-8: 32px;
  --[brand]-space-12: 48px;
  --[brand]-space-16: 64px;
  --[brand]-space-24: 96px;
  --[brand]-space-section: 96px;
  --[brand]-content-max: 1264px;

  /* ── RADII ── */
  --[brand]-radius-xs: 4px;
  --[brand]-radius-sm: 8px;
  --[brand]-radius-md: 12px;
  --[brand]-radius-lg: 16px;
  --[brand]-radius-xl: 24px;
  --[brand]-radius-pill: 9999px;

  /* ── SHADOWS ── */
  --[brand]-shadow-card: [recipe];
  /* ...named per visual function */

  /* ── MOTION ── */
  --[brand]-ease: cubic-bezier(0.2, 0.7, 0.2, 1);
  --[brand]-duration-fast: 150ms;
  --[brand]-duration: 240ms;
  --[brand]-duration-slow: 500ms;
}

/* ============================================================
   Semantic classes (drop-in for HTML mocks)
   ============================================================ */

.[brand]-display-xxl {
  font-family: var(--[brand]-font-display);
  font-size: var(--[brand]-size-hero-xxl);
  font-weight: var(--[brand]-w-light);
  letter-spacing: var(--[brand]-track-display);
  line-height: var(--[brand]-lh-tight);
}

.[brand]-h1 { /* ... */ }
.[brand]-h2 { /* ... */ }
.[brand]-body { /* ... */ }

/* Base element styling (sparse — only what's signature) */
body { font-family: var(--[brand]-font-body); background: var(--[brand]-bg); color: var(--[brand]-text); }
h1 { font: 300 var(--[brand]-size-h1)/1.2 var(--[brand]-font-display); }
button { background: var(--[brand]-primary); color: var(--[brand]-white); border-radius: var(--[brand]-radius-sm); }

/* Keyframes (only if signature animations exist) */
@keyframes [name] { from { /* */ } to { /* */ } }
```

---

## Section 2: README.md {#section-2}

Required sections in this exact order:

```markdown
# [Brand Name] — Design System

[1-sentence description: product + surface this system serves]

[1-sentence aesthetic in italic or quote: palette + key typeface + signature visual move]

> ⚠️ [If reconstructed from public materials: disclaimer that this is a teardown, not a license.]

## Sources

| Source | URL/Path | Access |
|---|---|---|
| [Live site] | [...] | Public |
| [Codebase] | [...] | [private/public] |

[If from screenshots: list each screenshot with what's on it.]

## Index

| File / folder | Purpose |
|---|---|
| `README.md` | This file |
| `SKILL.md` | Agent Skill manifest |
| `colors_and_type.css` | All tokens + semantic classes |
| `cards.json` | Preview card manifest |
| `design-system-viewer.html` | Offline browser for all cards |
| `preview/` | Spec cards (Type / Colors / Spacing / Components / Brand) |
| `ui_kits/<name>/` | High-fidelity product recreations |
| `assets/` | Logos, imagery, custom assets |
| `fonts/` | Self-hosted brand fonts (if any) |

## Brand at a glance

[Optional: if brand has sub-products, a table of them]

## CONTENT FUNDAMENTALS

### Voice
[Tone, register, who is speaking, in what person]

### Tone
[2-4 bullets characterizing tone]

### Casing
- Display headers: [rule]
- Subheads: [rule]
- Body: [rule]
- Quotation marks: [« » or " "]
- Dashes: [— with spaces, etc.]

### Pronouns
[1st / 2nd / 3rd person; "you" vs "вы" vs "ты"]

### Emoji
[Where allowed, where forbidden]

### Examples from the live site
> [3-5 real quotes in italic blockquotes]

### Copy patterns to follow
- [Pattern 1]
- [Pattern 2]

## VISUAL FOUNDATIONS

### Palette
[Discipline statement: e.g. "Cyan + yellow only. No purple/pink."]

| Role | Token | Value |
|---|---|---|
| Page bg | `--[brand]-bg` | `hsl(...)` |
| Primary accent | `--[brand]-cyan` | `#1AD8C8` |
| ... | ... | ... |

### Typography
- Display — [font, weight, fallback, usage]
- Body — [...]
- Mono — [...]
- Script accent — [...]

[Type scale + tracking + line-height per level]

### Spacing
[Base + scale + section rhythm + content max-width]

### Backgrounds
[3-4 background modes — solid, textured, gradient, hero]

### Animations
[Table of keyframes — name, duration, where used]

### Hover / Press states
[Per-component recipes]

### Borders & shadows
[Per-component recipes — what defines elevation in this brand]

### Blur & transparency
[Standard alpha ladder]

### Imagery
[Photography style + processing + restrictions]

### Layout rules
[Containers, grid, breakpoints]

### Corner radii
[Per-component]

### Cards — anatomy (optional)
[Standard card structure as CSS-like recipe block]

## ICONOGRAPHY

[Icon system description + rules + emoji policy + Unicode allowances]

## ⚠ Caveats

These are best-guess defaults — please supply originals so the system matches your brand exactly:

1. **Display font.** [What was substituted, why, where to put the original.]
2. **Body font.** [...]
3. **Logo / wordmark.** [...]
4. **Icon set.** [...]
5. **Photography / silhouettes.** [...]

## Help me iterate

1. [Most impactful question]
2. [Surface coverage question]
3. [Tone validation question]
4. [Specific sub-brand or surface question]
```

---

## Section 3: Brand SKILL.md {#section-3}

This is the SKILL.md that goes INSIDE the generated bundle (not the one for create-design-system itself).

```markdown
---
name: [brand]-design
description: Use this skill to generate well-branded interfaces and assets for [Brand Name], either for production or throwaway prototypes/mocks/etc. Contains essential design guidelines, colors, type, fonts, assets, and UI kit components for prototyping.
user-invocable: true
---

Read the README.md file within this skill, and explore the other available files.

If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out and create static HTML files for the user to view. If working on production code, you can copy assets and read the rules here to become an expert in designing with this brand.

If the user invokes this skill without any other guidance, ask them what they want to build or design, ask some questions, and act as an expert designer who outputs HTML artifacts or production code, depending on the need.

[OPTIONAL — only if brand has signature visual rules:]

## Hard rules for [Brand]-style design

Format: `- **Property** with specific value/condition. Reason or restriction.`
Aim for 6-8 rules. Each rule is one line, declarative, with a strong specific number/color/font instead of generic advice.

Example (Stripe):
- Headings at weight **300** with **-0.02em tracking**. This is the signature look — never weight 500/600 on display text.
- Primary action is always **`#533AFD`** indigo. Hover `#4032C8`. No other purple.
- Sentence case everywhere — never Title Case.
- Sans-serif only (Inter substitutes for proprietary Söhne).
- No emoji. Use inline SVG icons, Lucide-style, 1.6 stroke.
- Card recipe: `1px #E5EDF5 border + 0px 5px 14px 0px #00377014 shadow` — never just border, never just shadow.
- Aurora gradient hero only ONCE per page.
- Use ONE accent color per surface (ruby, magenta, orange, OR lemon — never two).
```

---

## Section 4: Preview card HTML {#section-4}

### 4.1 Shared `preview/_card.css`

**Write this ONCE** at `preview/_card.css`. Every preview card imports it. This eliminates 18× duplication of the same base styles.

```css
/* Shared style for design-system preview cards */
@import url('../colors_and_type.css');

html, body { margin: 0; padding: 0; }
body {
  font-family: var(--[brand]-font-sans);
  color: var(--[brand]-text);
  background: var(--[brand]-bg);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  box-sizing: border-box;
}
*, *::before, *::after { box-sizing: border-box; }
.card-frame {
  width: 700px;
  padding: 32px;
  background: var(--[brand]-bg);
  display: flex;
  flex-direction: column;
  gap: 20px;
}
.label {
  font: 500 11px/1 var(--[brand]-font-mono);
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--[brand]-text-subdued);
}
.mono { font-family: var(--[brand]-font-mono); }
```

### 4.2 Card HTML skeleton

Each `preview/*.html` is minimal — links `_card.css`, adds only card-specific styles, wraps content in `.card-frame`.

```html
<!doctype html>
<html><head><meta charset="utf-8"><link rel="stylesheet" href="_card.css">
<style>
  /* ONLY styles specific to this card */
  .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
  /* etc — minimal, brand colors via var(--[brand]-*) only */
</style></head>
<body><div class="card-frame">

  <div class="label">[ONE LINE OF METADATA · brand-relevant]</div>

  <!-- The actual token shown at its real value -->
  <!-- Example for type-display.html: -->
  <h1 class="[brand]-display-xxl">Real brand headline lifted from source</h1>

  <!-- Example for colors-accents.html: -->
  <div class="grid">
    <div style="background: var(--[brand]-cyan); padding: 24px; border-radius: var(--[brand]-radius-md);">
      <div class="label">CYAN · PRIMARY</div>
      <div class="mono" style="margin-top: 32px; font-size: 12px;">#1AD8C8</div>
    </div>
    <!-- ...more swatches -->
  </div>

</div></body></html>
```

### 4.3 Rules

- **No `<h1>` heading "Colors · Accents" or similar** — the viewer renders the title outside the iframe
- **Use brand tokens via CSS variables** — never hardcode hex
- **Show the token AT ITS REAL VALUE** — real type at real size, real swatch at real color
- **Use real brand content** (lifted quotes, real product names), not lorem ipsum
- **Keep total height ≤400px** for the viewport declared in cards.json
- **Wrap content in `<div class="card-frame">`** — provides consistent 700×N padding from `_card.css`
- **Only card-specific styles inline** — base styles come from `_card.css`

---

## Section 5: cards.json schema {#section-5}

`cards.json` lives at the bundle root. It's a JSON array. Each entry:

```json
{
  "file": "preview/colors-accents.html",
  "title": "Colors · Accents",
  "subtitle": "Cyan + yellow + semantic",
  "group": "Colors",
  "viewport": {
    "width": 700,
    "height": 450
  }
}
```

Field rules:
- `file` — relative path from bundle root, forward slashes
- `title` — must follow `[Group] · [Subname]` pattern with middle dot
- `subtitle` — short descriptive line, 2-10 words, sentence case, no trailing period
- `group` — one of: `Type`, `Colors`, `Spacing`, `Components`, `Brand`, `UI Kits`, `Slides`
- `viewport.width` — 700 for preview cards, 1280 for UI kits and slides, or custom width
- `viewport.height` — your estimate of the rendered card height, ≤400 for preview cards

Full file example:

```json
[
  {
    "file": "preview/colors-accents.html",
    "title": "Colors · Accents",
    "subtitle": "Cyan + yellow + semantic",
    "group": "Colors",
    "viewport": { "width": 700, "height": 450 }
  },
  {
    "file": "preview/type-display.html",
    "title": "Type · Display",
    "subtitle": "TT Severs H1-H3 with cyan gradient",
    "group": "Type",
    "viewport": { "width": 700, "height": 380 }
  },
  {
    "file": "ui_kits/landing/index.html",
    "title": "UI Kit · Landing",
    "subtitle": "Hi-fi recreation of the marketing page",
    "group": "UI Kits",
    "viewport": { "width": 1280, "height": 720 }
  }
]
```

---

## Section 6: design-system-viewer.html {#section-6}

Single self-contained HTML file at the bundle root. Reads `cards.json` and renders all cards as accordion grouped by section. Opens in any browser via `file://` with no server.

### Hard requirements

- Vanilla JS only — no React, no frameworks
- System fonts only for the viewer chrome (`-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`)
- **Card data INLINED into viewer as `const CARDS = [...]`** — do NOT rely on `fetch('./cards.json')`. Chrome blocks `fetch()` from `file://` URLs by default (CORS), which makes a fetch-based viewer fail when double-clicked. The viewer must be a single file that works offline without a local server.
- Procedure at Step 6g: read `cards.json` from disk, inline its content into the viewer's `<script>` block. The `cards.json` file ALSO stays on disk as the canonical machine-readable manifest.
- Group ordering FIXED: Type → Colors → Spacing → Components → Brand → UI Kits → Slides
- Omit any group with zero cards
- Closed by default. Click row to expand.
- Iframes use `loading="lazy"`
- No external CDN

### Skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>[Brand Name] — Design System</title>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      padding: 40px 60px;
      background: #F5F5F5;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      color: #1a1a1a;
      line-height: 1.5;
    }
    h1 {
      font-size: 24px;
      font-weight: 600;
      margin: 0 0 8px 0;
    }
    .header-meta {
      color: #666;
      font-size: 13px;
      margin-bottom: 32px;
    }
    .group-label {
      font-size: 13px;
      color: #888;
      margin: 32px 0 12px 4px;
      font-weight: 500;
    }
    .card {
      background: white;
      border-radius: 10px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.08);
      margin-bottom: 8px;
      overflow: hidden;
      transition: box-shadow 0.15s;
    }
    .card:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.10); }
    .card-header {
      padding: 16px 20px;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 12px;
      user-select: none;
    }
    .card-chevron {
      width: 12px; height: 12px;
      transition: transform 0.15s;
      flex-shrink: 0;
      opacity: 0.5;
    }
    .card.open .card-chevron { transform: rotate(90deg); }
    .card-title {
      font-weight: 600;
      font-size: 14px;
    }
    .card-subtitle {
      font-size: 13px;
      color: #666;
      margin-left: 8px;
    }
    .card-body {
      display: none;
      border-top: 1px solid #eee;
      background: #fafafa;
      padding: 16px;
    }
    .card.open .card-body { display: block; }
    iframe {
      width: 100%;
      border: 1px solid #e5e5e5;
      border-radius: 6px;
      background: white;
      display: block;
    }
    footer {
      margin-top: 48px;
      color: #999;
      font-size: 12px;
      text-align: center;
    }
  </style>
</head>
<body>
  <h1>[Brand Name] — Design System</h1>
  <div class="header-meta">
    <span id="card-count">0</span> cards · open card files directly from <code>preview/</code>, <code>ui_kits/</code>, <code>slides/</code> for editing.
  </div>
  <div id="root"></div>
  <footer>Generated by create-design-system skill. View offline via <code>file://</code>.</footer>

  <script>
    // INLINED from cards.json — written at Step 6g.
    // Inline is required because Chrome blocks fetch() from file:// URLs by default.
    const CARDS = /* INSERT_CARDS_JSON_CONTENT_HERE */ [];

    const GROUP_ORDER = ['Type', 'Colors', 'Spacing', 'Components', 'Brand', 'UI Kits', 'Slides'];

    function render() {
      document.getElementById('card-count').textContent = CARDS.length;

      const grouped = {};
      CARDS.forEach(c => {
        if (!grouped[c.group]) grouped[c.group] = [];
        grouped[c.group].push(c);
      });

      const root = document.getElementById('root');
      GROUP_ORDER.forEach(g => {
        if (!grouped[g] || grouped[g].length === 0) return;

        const label = document.createElement('div');
        label.className = 'group-label';
        label.textContent = g;
        root.appendChild(label);

        grouped[g].forEach(card => {
          const el = document.createElement('div');
          el.className = 'card';
          el.innerHTML = `
            <div class="card-header" onclick="toggleCard(this)">
              <svg class="card-chevron" viewBox="0 0 12 12" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M4 2 L8 6 L4 10"/></svg>
              <span class="card-title">${card.title}</span>
              <span class="card-subtitle">${card.subtitle}</span>
            </div>
            <div class="card-body">
              <iframe loading="lazy" src="${card.file}" width="${card.viewport.width}" height="${card.viewport.height}"></iframe>
            </div>
          `;
          root.appendChild(el);
        });
      });
    }

    function toggleCard(header) {
      header.parentElement.classList.toggle('open');
    }

    render();
  </script>
</body>
</html>
```

### Test before delivering

1. Open `design-system-viewer.html` directly with `file://` in Chrome (double-click in Finder)
2. Verify all cards render in correct group order
3. Click a card — iframe must load without console errors
4. Test in Safari and Firefox

Because cards data is inlined (not fetched), the viewer works in all three browsers from `file://` without a local server. The on-disk `cards.json` remains as the canonical manifest for tooling — but the viewer does NOT depend on it at runtime.

If the user wants to add a card after generation, they edit BOTH `cards.json` AND the inline `CARDS` array in the viewer, or re-run the skill's Step 6g to regenerate the viewer from the updated `cards.json`.

---

## Section 7: UI kit (inline-first structure) {#section-7}

UI kits use React + Babel via CDN with **no build step**. Structure:

```
ui_kits/<surface>/
├── index.html        ← HTML shell + CDN scripts + INLINE data/components/render
├── styles.css        ← layout-specific styles (NOT brand tokens)
└── README.md         ← what's included / what's stubbed
```

### ⛔ CRITICAL: data and components MUST be INLINE in index.html

**Do NOT** split JSX into external `components.jsx` and `data.js` files loaded via `src=`. This is the most common cause of broken UI kit previews.

**Why:** Babel-standalone fetches external `text/babel` scripts via `fetch()`. Chrome blocks `fetch()` to `file://` URLs (CORS policy). The viewer (`design-system-viewer.html`) embeds UI kits via `<iframe src="ui_kits/landing/index.html">`, both running under `file://`. External `.jsx`/`.js` files silently fail to load → React app never mounts → blank page in the viewer.

**The fix:** put data, all components, and the render call directly in `<script type="text/babel">` inside `index.html`. This is the only reliable way for `file://` double-click previewing to work.

This is enforced by `checklist.md` Category 2 — any external `<script ... src="*.jsx">` or `<script src="data.js">` in a UI kit is a hard fail.

### Separation of concerns: `colors_and_type.css` vs `styles.css`

| File | What goes here |
|---|---|
| `colors_and_type.css` (root) | **Tokens.** CSS variables, `@font-face`, base semantic classes (`.brand-h1`, `.brand-body`) |
| `ui_kits/<surface>/styles.css` | **Layout.** Hero composition, navbar grid, pricing card structure — specific to THIS surface |

This separation matches Claude Design's canonical export pattern. It means:
- Want the same look in another project? Take `styles.css` + the JSX block from `index.html`, drop in any project that has `colors_and_type.css`
- Want to rebrand the same UI kit? Swap `colors_and_type.css`, keep `styles.css` and the inline JSX

### 7.1 `index.html` — everything in one file

Links BOTH stylesheets: brand tokens from root + UI-kit-specific layout from local `styles.css`. All React data, components, and render are inline in a single `<script type="text/babel">` block.

```html
<!doctype html>
<html lang="[ru/en]">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>[Brand Name] — [Surface]</title>
  <link rel="stylesheet" href="../../colors_and_type.css">
  <link rel="stylesheet" href="styles.css">
  <script src="https://unpkg.com/react@18.3.1/umd/react.development.js" crossorigin="anonymous"></script>
  <script src="https://unpkg.com/react-dom@18.3.1/umd/react-dom.development.js" crossorigin="anonymous"></script>
  <script src="https://unpkg.com/@babel/standalone@7.29.0/babel.min.js" crossorigin="anonymous"></script>
</head>
<body>
  <div id="root"></div>

  <!-- INLINE data + components + render.
       DO NOT split into external .jsx/.js files — Babel cannot load them
       under file://. See templates.md §7 for the explanation. -->
  <script type="text/babel" data-presets="react">

    /* ============ DATA ============ */
    const DATA = {
      hero: {
        title: "Real brand headline",
        subtitle: "Lifted from the source site",
        cta: "Get started"
      },
      features: [
        { title: "...", body: "...", icon: "..." },
      ],
      pricing: [ /* ... */ ]
    };

    /* ============ COMPONENTS ============ */
    function Hero({ data }) {
      return (
        <section className="hero">
          <h1>{data.title}</h1>
          <p>{data.subtitle}</p>
        </section>
      );
    }

    function FeatureGrid({ features }) { /* ... */ }
    function Pricing({ tiers }) { /* ... */ }
    // one component per concern, factored small (30-80 lines each)

    /* ============ RENDER ============ */
    function App() {
      return (
        <div className="layout">
          <Hero data={DATA.hero} />
          <FeatureGrid features={DATA.features} />
        </div>
      );
    }

    ReactDOM.createRoot(document.getElementById('root')).render(<App />);
  </script>
</body>
</html>
```

**Resulting file size:** typical UI kit (landing with 4-6 components, ~50 data items) lands at 6-12 KB. Well within reasonable limits for inline.

### When inlining feels too long

If the UI kit grows past ~400 lines and you're tempted to split:

- **Better:** factor smaller components, drop low-value sections. UI kit demonstrates *patterns*, not every page section that exists (see `rules.md §2.3`).
- **If you really need a dev server:** create a sibling `dev/` folder with externalized `components.jsx` / `data.js` for editing. But `index.html` at the UI kit root **must always work via file://** — that's what the viewer renders.

### 7.2 `styles.css` — layout-specific stylesheet

This is **layout structure for THIS surface only**, using brand tokens from `../../colors_and_type.css`. No `:root { --... }` declarations here — those live in the token file.

```css
/* [Surface] — layout
   Tokens come from ../../colors_and_type.css.
   Keep this file focused on layout structure, not brand decisions. */

html, body { margin: 0; padding: 0; background: var(--[brand]-bg); }
body {
  font-family: var(--[brand]-font-sans);
  color: var(--[brand]-text-body);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
* { box-sizing: border-box; }

/* Top-level layout */
.layout { display: flex; min-height: 100vh; }
.main { flex: 1; min-width: 0; }
.content { padding: 32px; max-width: var(--[brand]-content-max); }

/* Hero composition */
.hero { position: relative; padding: clamp(48px, 8vw, 120px) 0 var(--[brand]-space-9); overflow: hidden; }
.hero-grid { display: grid; grid-template-columns: 1.3fr 1fr; gap: var(--[brand]-space-8); }
/* ...etc — one block per major section: .navbar, .pricing, .features, .footer */
```

**What belongs here:**
- Section layouts (`.hero`, `.pricing-grid`, `.feature-row`, `.footer`)
- Component-specific spacing (`.hero-meta`, `.testimonial-card`, `.faq-item`)
- Responsive breakpoints for this surface
- Animations specific to this surface (e.g. `.scroll-fade-in`)

**What does NOT belong here:**
- Brand colors as hex values (use `var(--brand-cyan)`, never `#1AD8C8`)
- Font-family declarations beyond `body { font-family: var(--brand-font-sans) }`
- `@font-face` (lives in `colors_and_type.css`)
- Token definitions (`:root { ... }` — never in styles.css)

### 7.3 `README.md` — what's included / combined / omitted

If you compressed N source components into M UI kit components (see `rules.md §2.3`), document the decision here.

```markdown
# [Brand Name] — [Surface] UI kit

Hi-fi static recreation of the [surface]. Single-page prototype.

## Components included (N)
- **Navbar** — sticky top nav with primary + secondary links
- **Hero** — large display headline + CTA + background image
- **Program** — what you get / what you avoid (consolidates ProblemSection + InnerProblem + Differentiator + ForWhom from source)
- **Pricing** — N tiers with feature list (consolidates Pricing + CostComparison + ValueStack from source; the other two are mentioned but not separately shown)
- **Testimonials** — social proof carousel
- **FAQ** — collapsible accordion
- **Footer** — minimal link row

## Combined into the above (not separate components)
- **InnerProblem, Differentiator, ForWhom** → merged into `Program` section — they all argue why the product exists, presented as one consolidated block

## What's intentionally omitted
- **PixelOffice** — decorative canvas tied to brand's office metaphor; not reusable outside this product
- **DotWave** — animated particle background; out of scope for static UI kit
- **GetCourseWidget** — third-party iframe shell, stubbed to `console.log`

## Inferred (not in source)
(skip this section if everything is faithful recreation — use only when something was generated without source basis)

Open `index.html` to view.
```

### Rules

- **No build step** — files are read directly by browser via `<script src="...">` and `<script type="text/babel" src="...">`
- **Mock data lives in `data.js`** — exposed via `window.<NAME>_DATA`, not via React props/imports
- **Click-through interactivity OK** — `useState` for modal/tab/drawer states
- **No fetch calls** — all data inline
- **No real backend operations** — stub button handlers with `console.log`
- **integrity hashes on CDN scripts** — production-safe pattern (copy hashes from existing Claude Design exports if unsure of the latest)
- **Tokens in `colors_and_type.css`, layout in `styles.css`** — see §7.4. Never define brand colors as hex inside `styles.css` — always reference via `var(--brand-...)`.
- **Component count compression** — see `rules.md §2.3`. If source has 20+ components, compress to 8-12 representative ones; document compression in README.
