# Operational Rules

## Contents
1. [Naming conventions (strict)](#section-1)
2. [Three-pass preview card selection](#section-2)
2.3. [UI kit component compression](#section-2-3)
3. [Tool substitutions (Claude Code vs Claude Design)](#section-3)
4. [Antipatterns to avoid](#section-4)
5. [Bilingual content rule](#section-5)
6. [Self-contained file principle](#section-6)
7. [Substitution flagging](#section-7)
8. [Plain Russian handoff (Step 8 chat reply rules)](#section-8)

---

## Section 1: Naming conventions (strict) {#section-1}

These names are MANDATORY. Other agents and tools look for these exact strings.

### File names

| Required name | Never use |
|---|---|
| `SKILL.md` | `skill.md`, `agent.md`, `manifest.md` |
| `README.md` | `readme.md`, `BRAND.md` |
| `colors_and_type.css` | `tokens.css`, `theme.css`, `design-tokens.css` |
| `cards.json` | `manifest.json`, `assets.json` |
| `design-system-viewer.html` | `viewer.html`, `index.html` (at root) |
| `CHECKLIST-RESULT.md` | `checklist.md`, `validation.md` |
| `SESSION.md` | `session.md`, `state.md` |

### Folder names

| Required name | Never use |
|---|---|
| `preview/` | `cards/`, `specimens/`, `samples/` |
| `ui_kits/` | `templates/`, `kits/`, `mocks/` |
| `assets/` | `images/`, `media/`, `static/` |
| `fonts/` | `typefaces/`, `webfonts/` |
| `slides/` | `deck/`, `presentation/` |

### CSS variable prefix

All CSS variables MUST be prefixed with the brand name in kebab-case:
- `--stripe-indigo` ✓
- `--rixai-cyan` ✓
- `--fg-yellow` (Focus Group, abbreviated) ✓
- `--indigo` ✗ (no prefix)
- `--color-primary` ✗ (generic, not branded)

Semantic classes use the same prefix:
- `.stripe-h1`, `.stripe-display-xxl` ✓
- `.rixai-eyebrow`, `.rixai-glass-card` ✓

### Card title format

Format: `[Group] · [Subname]` with **middle dot** (`·`), not hyphen, not en-dash.

- `Type · Body & Script` ✓
- `Colors · Accents` ✓
- `Type - Body` ✗ (hyphen)
- `Colors – Accents` ✗ (en-dash)

### Group names (fixed list — 5 token-groups + 2 surface-groups)

For `cards.json` `group` field, only these 7 values are allowed. Anything else fails Category 3 of the checklist.

**5 token-groups** (preview cards):
1. **Type** — typography specimens and scales
2. **Colors** — palettes, scales, semantic colors, surfaces, glass
3. **Spacing** — radii, shadows, spacing tokens, elevation, animation
4. **Components** — buttons, inputs, cards, badges, menus, nav, footer
5. **Brand** — logos, imagery, custom assets, anything not fitting above

**2 surface-groups** (live recreations):

6. **UI Kits** — for `ui_kits/*/index.html` entries
7. **Slides** — for `slides/*.html` entries (only if slides exist)

Title-cased exactly. Consistent across all entries.

---

## Section 2: Three-pass preview card selection {#section-2}

When deciding which preview cards to create, apply three passes. Do NOT just dump every token into a card.

### Pass 1 — "What obviously fits?"

Based on the brand analysis in SESSION.md, identify cards with direct functional match.

- Brand has 1+ accent color → `colors-accents.html`
- Brand has 4+ neutral surfaces → `colors-surfaces.html`
- Brand has 2+ font families → one card per family
- Brand has typography scale → `type-display.html`, `type-body.html`
- Brand has any radii → `radii.html`
- Brand has any motion → `animation-tokens.html`

Record the list in SESSION.md under "Planned structure → Preview cards".

### Pass 2 — "What did I miss?" (Reverse-lens review)

Re-read the brand analysis with the question: **"Which cards did I NOT add, and what will an agent using this skill MISS without them?"**

Common misses:
- Hover/focus states for components — often skipped, but signature for the brand
- Specific decorative motifs (pixel sprites, hero lines, paint blobs) → `brand-*.html`
- Glass / blur ladder if the brand uses transparency
- Letter-spacing samples for display type
- Inter-component spacing examples (not just token list)
- WCAG contrast pairs if the brand has accessibility focus

Add what was missed.

### Pass 3 — "What is redundant?"

For each card selected: **"If I remove this card, what specific information about the brand is lost?"**

If the answer is vague or duplicative — remove the card.

Common redundancies:
- Separate `colors-primary.html` + `colors-accents.html` when there's only one primary color (merge)
- `shadows.html` when the brand has exactly one shadow recipe (fold into spacing card)
- Multiple `type-*` cards when one would suffice

Target: 12-20 cards total. Below 10 = thin; above 25 = noisy.

---

## Section 2.3: UI kit component compression {#section-2-3}

Source codebases often contain **far more components than belong in the UI kit**. Lovable/v0/shadcn projects typically have 20-50 components in `src/components/`. Copying every one defeats the purpose of a UI kit (high-fidelity recreation, not a storybook clone).

### When to compress

| Source component count | Action |
|---|---|
| 1-7 components | Use all of them |
| 8-15 components | Keep all; group into logical clusters in `index.html` |
| 16-25 components | Compress to 10-12 most representative |
| 26+ components | Compress to 8-12 most representative — aggressive curation |

### Compression rules

**1. Combine adjacent / overlapping components.**

Example pattern from real source: `ProblemSection.tsx + InnerProblem.tsx + Differentiator.tsx + ForWhom.tsx` → one `Program.tsx` (positioning block). The four originals all argue why the product exists. UI kit shows one consolidated section.

**2. Drop domain-specific components that don't carry brand DNA.**

Examples to drop:
- `PixelOffice.tsx` — custom decorative canvas tied to one brand's metaphor
- `DotWave.tsx` — particle animation, not reusable
- `GetCourseWidget.tsx` — third-party integration shell
- Anything with `Widget`, `Embed`, `Integration` in the name

These should be **listed in the UI kit README as omitted**, not silently dropped. Format:

```markdown
## Intentionally omitted from this UI kit
- **PixelOffice** — decorative canvas tied to the brand's office metaphor; not reusable outside this product
- **DotWave** — animated particle background; out of scope for static UI kit
- **GetCourseWidget** — third-party iframe shell, stubbed to `console.log`
```

**3. Keep the layout-defining components.**

Always keep: `Navbar`, `Hero`, primary CTA section (Pricing / Apply / FinalCTA), `Footer`. These set the page rhythm.

**4. Choose ONE per category, not all variants.**

If source has `Pricing.tsx + CostComparison.tsx + ValueStack.tsx` — they're three angles on commercial offering. Pick the most representative for the UI kit; mention the other two in README as variants.

**5. Quality > completeness.**

Better to have 10 polished, pixel-accurate recreations than 25 rushed approximations. The UI kit demonstrates **how the brand handles each pattern**, not every page section that exists.

### Recording the compression decision

In the UI kit's `README.md`, list:
- **Included** components (the 8-12 you kept) — what each demonstrates
- **Combined** components (e.g. "Program section consolidates ProblemSection + InnerProblem + Differentiator + ForWhom") — what got merged
- **Omitted** components — why (domain-specific, third-party, decorative)

This gives the user a clear map: "here's what you got, here's why you got that vs. something else."

---

## Section 3: Tool substitutions (Claude Code vs Claude Design) {#section-3}

The original Claude Design prompt assumes internal tools that don't exist in Claude Code. Substitute as follows:

| Claude Design tool | Substitute in Claude Code | Notes |
|---|---|---|
| `set_project_title` | Suggest renaming the working directory to the user; do not block | Cosmetic only |
| `register_assets` | Append entries to `cards.json` | Same data shape, see templates.md |
| `local_ls` | `Glob` or `Bash: ls` | Glob for patterns, ls for one dir |
| `local_copy_to_project` | `Bash: cp` | Use absolute or relative paths |
| `get-design-context` (Figma MCP) | Ask user for Figma export; skip Figma-specific extraction | If Figma is the primary source and there's no export, STOP and ask |
| `get_variable_defs` (Figma) | N/A — skip | Only relevant inside Figma MCP |
| `repl` (JS sandbox) | `Bash: node -e` or `Bash: python3 -c` | For data transformations, image processing |
| `Viewing image` | `Read` on the image path | Claude Code reads images natively |

The Iframe-based "Design System tab" UI from Claude Design has no equivalent in Claude Code. That's why this skill generates a `design-system-viewer.html` as a static replacement.

---

## Section 4: Antipatterns to avoid {#section-4}

These are explicit DON'Ts from the Claude Design prompt. Do not produce these patterns unless verified in the source codebase.

1. **No bluish-purple gradients** unless the brand source uses them. The model has a tendency to add purple gradients to anything; resist.
2. **No emoji cards.** Emoji never appears in a Claude Design preview card. If the source uses emoji intentionally (e.g. for category tiles), copy them as actual content, but never substitute them for missing icons.
3. **No "rounded corner + colored left-border" cards.** This is a generic-LLM-aesthetic that has nothing to do with the brand.
4. **No hand-rolled SVG icons.** Copy from source or use a CDN icon library (Lucide / Phosphor / Heroicons). Never draw shapes "approximating" the source.
5. **No reading SVG content.** Waste of context. Copy the SVG file as-is and reference it.
6. **No screenshots-only UI kit recreation if a codebase exists.** Screenshots are lossy; if you have access to the source code, use it.
7. **No lorem ipsum or "Sample text".** Use real brand content (lifted quotes from the source) in preview cards.
8. **No internal titles on preview cards.** The viewer renders title/subtitle outside the card. An internal `<h1>Colors · Accents</h1>` is duplication.
9. **No silent substitutions.** Every font replacement, icon replacement, placeholder logo MUST be listed in README.md Caveats and in the final handoff.
10. **No CLAUDE.md generation.** This skill creates SKILL.md only. CLAUDE.md is for project-level memory, not brand documentation.
11. **🚨 No external `text/babel` scripts in UI kits.** `<script type="text/babel" src="components.jsx">` and `<script src="data.js">` are both broken under `file://`. The viewer embeds UI kits via `<iframe src="ui_kits/...">` and Chrome blocks `fetch()` to file URLs. Result: silent failure, blank iframe. **Always inline data + components + render in one `<script type="text/babel">` block in `index.html`.** See `templates.md §7` for the correct pattern. See `checklist.md` Category 2 for the verification grep.

---

## Section 5: Bilingual content rule {#section-5}

For non-English brands (Russian, Chinese, Arabic, etc.):

- **Prose in README.md** — CONTENT FUNDAMENTALS, VISUAL FOUNDATIONS, voice examples → **language of the brand**
- **File names, folder names** → always English (`preview/`, `colors_and_type.css`, `ui_kits/landing/`)
- **CSS variable names** → always English (`--rixai-cyan`, not `--rixai-голубой`)
- **Code comments** → English
- **Card subtitles in cards.json** → can be brand-language for clarity

Result: bilingual files. Example from RixAI export:
```
README.md → Russian sections "Эстетика в одной строке", "CONTENT FUNDAMENTALS" (heading English), Russian body, English variable references
colors_and_type.css → English variable names, English code comments
preview/components-buttons.html → Russian button labels ("ХОЧУ УЗНАТЬ ПОДРОБНЕЕ"), English CSS class names
```

---

## Section 6: Self-contained file principle {#section-6}

Every preview card, every UI kit screen must work in isolation.

**Requirements:**
- Card HTML files link `../colors_and_type.css` (relative path from `preview/` to root)
- UI kit HTML files link `../../colors_and_type.css` (relative path from `ui_kits/<name>/` to root)
- No card depends on the viewer being open
- No card imports from another card
- **Preview cards:** vanilla HTML/CSS only. Google Fonts via `@import` inside `colors_and_type.css` is fine (since the CSS file is shared). No JS framework dependencies inside the card HTML itself.
- **UI kits:** MAY use React + Babel via CDN (no build step), but ALL JSX must be inline in `index.html`. See `templates.md §7` for the structure.

**🚨 Antipattern — broken under file://:** Loading external JSX via `<script type="text/babel" src="components.jsx">` or external data via `<script src="data.js">`. Babel-standalone fetches these via `fetch()`, which Chrome blocks under `file://`. Result: blank iframe in the viewer, silent failure with no errors visible to the user. **The viewer renders UI kits via `<iframe src="ui_kits/...">` — both viewer and iframe run under `file://` — so this bug bites every time.** Always inline data + components + render in a single `<script type="text/babel">` block.

**Test:** open any `preview/*.html` directly with `file://` in a browser. It must render correctly with no missing CSS, no missing assets, no console errors. Google Fonts via CDN is the only external dependency permitted. For UI kits — open `ui_kits/<name>/index.html` directly via double-click AND open it inside the viewer; both must render React content, not a blank page.

---

## Section 7: Substitution flagging {#section-7}

Every substitution must be flagged in three places:

1. **README.md** — in a `## Caveats` section near the end, numbered list
2. **SESSION.md** — under "Planned structure → Substitutions to flag"
3. **Final handoff message** — in the bullet list of Caveats

If the substitution is high-impact (e.g. display font is proprietary, brand uses Söhne, you used Inter):
- Also mention in SKILL.md `## Hard rules` section: `Display type is X (substituted with Y from Google Fonts as closest free match).`
- Reference the exact CSS variable to swap: `Replace --rixai-font-display in colors_and_type.css.`

If the substitution is low-impact (e.g. one missing platform logo):
- README.md Caveats only.

---

## Section 8: Plain Russian handoff {#section-8}

The handoff message in Step 8 (chat reply to user after the DS is generated) **must be readable by a non-technical Russian-speaking user with zero English knowledge**. This is not a stylistic preference — it's a hard rule. If you violate it, you ship a deliverable the user can't act on.

### 8.1 — Audience assumption

Assume the user:
- Has never read a CSS file, doesn't know what `--variable-name:` means
- Doesn't know what "fidelity", "extraction", "anatomy", "voice extraction" mean in design context
- Doesn't know what `designlang`, `monolith`, `wget` are (these are skill internals — the user only knows they "запустили какую-то команду и пошёл скилл")
- Doesn't know font foundry names ("Klim Type Foundry", "Hoefler", "Pangram Pangram") and doesn't care
- Doesn't speak in file paths — `ui_kits/landing/index.html` looks like a riddle, "на лендинге" is clear
- Reads short sentences faster than long ones; participial clauses make Russian harder to parse, not richer

### 8.2 — Jargon translation table

When you catch yourself writing one of these (or its synonym) — replace with the Russian phrase on the right.

| ❌ Don't write | ✅ Write instead |
|---|---|
| `fidelity-gap`, `fidelity` | "видимая разница с оригиналом" |
| `hi-fi recreation`, `hi-fi static recreation` | "максимально похожая копия" |
| `sub-surface`, `surface` | "страница" (например, "лендинг", "дашборд", "страница про команду") |
| `tone of voice`, `voice` | "стиль текстов", "как звучит бренд" |
| `paraphrased`, `lifted from` | "взял из ... ", "переписал по смыслу" |
| `extracted`, `extraction` | "нашёл в исходниках", "достал из сайта" |
| `proprietary` | "платный", "закрытый", "защищённый" |
| `designlang` / `monolith` / `wget` extracted X | "автоматический разбор сайта не нашёл X" (без названий инструментов) |
| `--brand-font-display`, `--stripe-bg-card` (или любая CSS-переменная) | "шрифт заголовков", "цвет карточек" — переведи смысл переменной, не показывай имя |
| `ui_kits/landing/index.html` | "на лендинге" |
| `colors_and_type.css` | "файл с цветами и шрифтами" (если вообще надо упоминать) |
| `Lucide`, `Phosphor`, `JetBrains Mono`, `Inter` (имена библиотек/шрифтов) | "бесплатный аналог", "открытый набор похожего стиля" — без брендов-конкурентов |
| `Stats в hero`, `eyebrow`, `H1`, `CTA`, `subhead` | "цифры в шапке", "заголовок", "подзаголовок", "кнопка" |
| `gradient discipline`, `hero gradient` | "градиенты на странице" |
| `tokens`, `design tokens` | "цвета, шрифты, отступы" (перечисли вместо общего термина) |
| `placeholder` | "заглушка", "поставил [плашку/квадрат] вместо настоящего" |
| `library: unknown, confidence: 0` (любой output JSON-поля скилла) | "не смог точно определить" |
| `inferred`, `assumed` | "я предположил" |
| `pixel-accurate`, `pixel-perfect` | "пиксель в пиксель" или "очень точно" |
| `compressed N components into M` | "несколько похожих блоков объединил в один" |
| `dark mode`, `light mode` | "тёмная тема", "светлая тема" |
| `breakpoint` | "под мобильный / планшет / десктоп" |
| `iterate` (как глагол в адресации пользователя) | "поправить", "доработать" |

### 8.3 — Sentence-level rules

1. **Один смысл = одно предложение.** Не "Recreated voice — 'you-only, sentence case, neutral, длинные информативные заголовки с точкой' — попадает в то, как ты бы писал внутри?" Это пять смыслов слиплись с английскими терминами. Сделай: "Проверь тексты в карточках. Если стиль не такой как ты бы написал сам — скажи."
2. **Без причастных оборотов длиннее 5 слов.** "Извлечение иконок дало library: unknown, confidence: 0, поэтому использован свободный аналог" → "Иконки бренда закрытые. Использовал бесплатный аналог."
3. **Не пиши скобки с уточнениями для технарей.** "Шрифт sohne-var (Klim Type Foundry, проприетарный)" → "Шрифт бренда платный."
4. **Не вставляй CSS-переменные.** Никогда не пиши `--что-то` в чате. Если технический детайл нужен — он уже есть в `README.md` Caveats, чат — для смысла.
5. **Не упоминай имена файлов внутри объяснений.** "Это видно в ui_kits/landing/index.html — иконки сейчас просто цветные квадраты" → "На лендинге иконки продуктов — пока цветные квадраты-заглушки."

### 8.4 — When the user asks for technical detail

If the user replies with a technical question ("а как поменять шрифт?", "где этот файл?"), THEN you switch to technical mode and reference exact paths and CSS variables. But never **start** with that — the first handoff must be plain Russian.

### 8.5 — Self-check before sending

Re-read your handoff message and answer honestly:
1. Если бы это читал мой родственник, который никогда не видел код — он бы понял?
2. Есть ли в тексте хоть одно английское слово без перевода?
3. Есть ли символы `--`, `[]`, `{}`, `.html`, `.css` в тексте, который пользователь должен прочитать?
4. Можно ли сократить любое предложение в два раза без потери смысла?

If any answer is "нет/да/да/да" — rewrite.

---

## Section 9: Anti-AI-Slop Visual Guidelines {#section-9}

These guidelines are inspired by Anthropic's etalon `frontend-design` principles. They enforce distinctiveness and fight generic, cookie-cutter artificial aesthetics.

### 9.1 · What is "AI Slop"?

Avoid these clichés at all costs unless explicitly found in the source:
1.  **The "SaaS Indigo/Purple Gradient" background:** Dark background with blue-to-purple-to-pink glowing radial or linear blobs behind white text. This has become the default "AI-generated SaaS" look. Avoid it.
2.  ** Arial/Inter Typography Trap:** Defaulting to generic system fonts for display elements.
3.  **Rounded Corner Left-Border Cards:** Cards with `.rounded-lg` and `border-l-4 border-indigo-500` used as generic "highlight" components.
4.  **Cookie-Cutter Grids:** Uniform 3-column layouts with centered Lucide icons inside small colored circles.

### 9.2 · The Bold Aesthetic Choice

Before writing a single class, commit to a BOLD and unified design theme:
-   **Brutalist / Neubrutalism:** Hard solid black borders, primary flat colors (signal yellow, high-contrast cyan), zero gradients, thick hard offset shadows, technical tables.
-   **Warm Editorial / Magazine:** High-contrast serif display headers, ample "air" (padding/margin), warm cream paper backgrounds (`#FAF9F6`), light-grey border lines, editorial spacing, clean book-style typography.
-   **Sleek Cyber / Tech:** Deep dark space backgrounds, razor-sharp glowing colored border lines (using borders with `opacity` or neon text-shadows), monospaced technical labels, grid coordinate markings, terminal headers.
-   **Soft Luxury / Wellness:** Calming color systems, organic curved shapes, thick soft blur shadows, warm white and sage backgrounds, elegant serif-serif font pairings.
-   **Utilitarian / Industrial:** Mono fonts, hairline borders, dense technical grids, progress bars, coordinates, status dots, raw functional spacing.

---

## Section 10: UI-UX Pro Max Design Intelligence Database {#section-10}

This section compiles premium design tokens, 10 visual styles, and 57 font pairings to expand the token generator's vocabulary.

### 10.1 · 10 Signature Visual Styles Spec

| Style Name | Key Typography | Backgrounds & Borders | Shadows & Effects | Best For |
|---|---|---|---|---|
| **Neubrutalism** | Heavy Geometric Sans (Archivo Black) / Mono | High-contrast solid colors (`#FFF` / `#FACC15`), solid black border `2px solid #000` | Hard offset shadow: `box-shadow: 4px 4px 0px 0px #000` | Gen-Z apps, creative agencies, personal portfolios |
| **Glassmorphism** | Syne / Plus Jakarta Sans | Semi-transparent surfaces (`rgba(255,255,255,0.05)`), border `1px solid rgba(255,255,255,0.1)` | Blur: `backdrop-filter: blur(12px)`, radial accent glows behind surfaces | Tech dashboards, SaaS features, web apps |
| **Bento Grid** | Outfit / Plus Jakarta Sans | Solid or glass cards, rounded corners `16px` to `24px` | Soft depth, uniform margins, grid-span items (`col-span-2`, `row-span-2`) | Showcases, dashboards, product features |
| **Claymorphism** | Syne / Outfit | Pastel backgrounds, thick border-radius `24px` | Inner shadows for 3D depth, soft external shadows | E-learning, playful apps, SaaS onboarding |
| **Soft UI Evolution** | Cormorant Garamond / Montserrat | Warm-toned whites (`#FFFBFB`), organic rounded cards | Ultra-soft shadows: `blur 30px`, opacity `0.05`, offset `4px` | Luxury brands, spa, wellness, premium lifestyle |
| **Sleek Dark Mode** | Plus Jakarta Sans / Mono | True dark backgrounds (`#090E17`), subtle grey borders | Contrast neon text glows, colorful accent lines | Dev tools, crypto, tech SaaS |
| **Warm Editorial** | Playfair Display / Lato | Warm cream paper (`#FAF9F6`), hairline borders | Ample whitespace, negative padding, book layouts | Blogs, magazines, luxury products, newsletters |
| **Industrial / Utilitarian** | JetBrains Mono / Space Grotesk | Hairline grids, technical status dots, coordinates | Dense informational cards, raw layout blocks | Technical docs, developer panels, monitoring |
| **Minimalist Geometric** | Space Grotesk / Inter Tight | Pure whites/blacks, razor-thin borders | Zero shadows, maximum grid alignment, razor-sharp | Portfolios, architectural sites, design studios |
| **Retro-Futuristic** | Space Mono / Outfit | Tech dark overlays, amber/green terminal colors | Glitch effects, scanlines, digital technical frames | Web3, indie games, retro SaaS |

### 10.2 · 57 Google Fonts Pairings (Curated Library)

When generating `colors_and_type.css`, use these signature pairings instead of generic fonts:

#### Group A: Premium, Luxury, and Wellness (Serif Headings + Sleek Sans)
1.  **Cormorant Garamond / Montserrat** — Signature soft luxury, elegant book headings.
2.  **Playfair Display / Lato** — Classic editorial, highly readable.
3.  **Cinzel / Montserrat** — Cinematic, premium stone carving look.
4.  **Fraunces / Plus Jakarta Sans** — Warm, editorial, high-end organic look.
5.  **Bodoni Moda / Lato** — High-fashion, geometric serif styling.

#### Group B: Tech, Web3, and SaaS (Geometric/Technical Headings + Clean Sans/Mono)
6.  **Space Grotesk / Plus Jakarta Sans** — Tech-forward, geometric and distinctive.
7.  **Outfit / JetBrains Mono** — Highly technical, clean, developer-centric.
8.  **Syne / Inter Tight** — Art-directed, creative tech.
9.  **Lexend / JetBrains Mono** — High accessibility, clean geometric technicality.
10. **Bricolage Grotesque / Plus Jakarta Sans** — Playful, distinctive SaaS, high character.

#### Group C: Editorial, Book, and Magazine (Display Serif + Highly Readable Body)
11. **DM Serif Display / DM Sans** — Clean, modern editorial magazine style.
12. **Yeseva One / Open Sans** — Heavy, classical, organic serif display.
13. **Lora / Merriweather** — Double-serif classic book reading layout.
14. **Newsreader / Plus Jakarta Sans** — Warm newspaper vibes, highly professional.

#### Group D: Utilitarian and Brutalist (Heavy Sans-serif or Monospace)
15. **Archivo Black / Archivo** — Massively heavy headings, highly impactful.
16. **Space Mono / Space Grotesk** — technical, raw retro-cyber styling.
17. **Cabinet Grotesk / Inter Tight** — High contrast geometric sans.
