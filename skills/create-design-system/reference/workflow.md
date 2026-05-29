# Workflow — Detailed

8 steps from source intake to handoff. Update `SESSION.md` after every completed step. Do not skip the MANDATORY STOP at Step 5 — generating 20+ files based on a misread brand is the single most expensive failure mode of this skill.

---

## Step 1: Checkpoint check + SESSION.md initialization

The checkpoint protocol in `SKILL.md` is performed before this file is loaded. When you reach Step 2, `SESSION.md` already exists.

If you are reading this file as part of a fresh start (Case C from SKILL.md) and have not yet created `SESSION.md` — do it now using the schema at the bottom of this file. Set `Current step: Step 2 (in progress)` and continue.

If you are resuming work (Case A or B), the file already has prior steps recorded. Read it and resume from `Current step + 1`.

Do not skip this — every subsequent step assumes SESSION.md exists.

---

## Step 2: Source intake

Identify which input class the user provided. The downstream behavior changes per class.

**Before classifying:** `ls` the working directory and any user-provided path. Many users run extraction tools BEFORE invoking this skill, so the input often comes as a folder with `source-raw/{designlang,monolith,mirror}/` subfolders rather than a fresh URL. **Always detect existing tool outputs first** — re-running the same URL through `WebFetch` when designlang already extracted it is waste.

| Class | Signal | What to do first |
|---|---|---|
| **A. Live URL (fresh)** | User pastes `https://...` AND no extraction folder exists yet | `WebFetch` the URL. Optionally suggest `npx designlang <url>` if the user wants richer extraction (DTCG tokens, brand book PDF, screenshots). |
| **B. Codebase** | User attaches a folder / repo path with `package.json`, `tailwind.config.*`, `src/components/` | `Glob` for `*.css`, `package.json`, `tailwind.config.*`, `globals.css`. `Read` the most central style files first. |
| **C. Screenshots** | User attaches PNG/JPG | `Read` each image. Build an internal mental model of the visual language. Flag heavily — screenshots are lossy. |
| **D. ZIP archive** | `.zip` file | `Bash`: `unzip` to a temp dir. Then treat the contents as Class B or F. |
| **E. Brand brief (text only)** | User describes the brand in prose, no visual source | DO NOT generate yet. Ask 3-5 clarifying questions: industry, target audience, mood references (1-3 existing brands the user likes), required surfaces (web/slides/email). Strongly prefer at least 2 visual reference brands before proceeding. If after 2 rounds of clarification the user refuses to provide visual references, proceed with brief-only generation BUT flag every visual decision as `[INVENTED — needs review]` in README Caveats. |
| **F. Extraction tool output** | Folder contains `source-raw/designlang/` OR `*-design-language.md` + `*-design-tokens.json` OR `source-raw/monolith/*.html` OR `source-raw/mirror/<domain>/*.html` | **CRITICAL: read `reference/source-readers.md` BEFORE reading any file.** Designlang outputs 87 files but only 5 are MUST-READ (~95 KB curated vs 37 MB raw). Reading the wrong files wastes context and confuses the brand picture (10+ duplicate token formats exist). Monolith and wget mirror are fallback sources — use `grep`, never `Read` the full files. |
| **G. Claude Design ZIP bundle / pre-built DS** | Folder has `colors_and_type.css` + `preview/*.html` + `cards.json` + `design-system-viewer.html` | This is already a DS. Read `SKILL.md` → `README.md` → `colors_and_type.css` → `cards.json` in order. The task is usually to **extend or adapt**, not regenerate. Consult `reference/source-readers.md` §D. |

**Auto-detection signals (run in order):**

```bash
# Detect F (extraction tool output) — highest priority
ls source-raw/designlang/ 2>/dev/null && echo "→ Class F: designlang output"
ls source-raw/monolith/*.html 2>/dev/null && echo "→ Class F: monolith archive"
ls source-raw/mirror/*/ 2>/dev/null && echo "→ Class F: wget mirror"
ls *-design-tokens.json 2>/dev/null && echo "→ Class F: designlang (flat)"

# Detect G (pre-built DS)
ls colors_and_type.css cards.json design-system-viewer.html 2>/dev/null && echo "→ Class G: existing DS bundle"

# Detect B (codebase)
ls package.json tailwind.config.* 2>/dev/null && echo "→ Class B: codebase"
```

If multiple classes detected (e.g. user has BOTH `source-raw/designlang/` AND `source-raw/monolith/`), priority order: **F > G > B > A > C > E**.

**STOP condition:** If a referenced source is inaccessible (URL behind login, codebase path doesn't exist, Figma link not loadable, ZIP corrupt) — stop and ask the user to fix. Do not generate a partial bundle based on incomplete input.

Record in SESSION.md under "Source intake":
- Input class (A-G) — if F or G, note which subtype (designlang / monolith / wget mirror / Claude Design bundle)
- Specific sources received
- Inventory of accessible material (file paths, URL status)
- What's missing (proprietary fonts, logos, etc.)
- **For Class F:** explicit list of which designlang files were read (MUST-READ) vs ignored. Reference `source-readers.md §A.1-A.3`. Example:
  ```
  Read (5 files, ~85 KB):
    - source-raw/designlang/stripe-com-DESIGN.md
    - source-raw/designlang/stripe-com-design-tokens.json
    - source-raw/designlang/stripe-com-voice.json
    - source-raw/designlang/stripe-com-design-language.md
    - source-raw/designlang/stripe-com-gradients.css
  Read conditionally (2 files):
    - source-raw/designlang/stripe-com-motion-tokens.json (brand has signature motion)
    - source-raw/designlang/screenshots/button-*.png (4 PNGs for preview cards)
  Ignored (per source-readers.md §A.3):
    - 70+ files (ios/, android/, flutter/, wordpress-theme/, *-mcp.json, alt token formats)
  ```

---

## Step 3: Brand analysis

Extract the brand's visual and verbal language. **No files written yet — only SESSION.md notes.**

For each of these dimensions, write 1-3 lines of analysis to SESSION.md:

1. **Voice** — tone, person (1st/2nd/3rd), formality, signature phrases. Pull direct quotes.
2. **Color palette** — primary, accent(s), neutrals, semantic (success/error). Include hex values.
3. **Typography** — display family, body family, accent/script family if any. Weights actually used. Tracking on display.
4. **Spacing** — base unit (looks like 4px? 8px?), scale, section rhythm, content max-width.
5. **Iconography** — line vs filled, stroke weight, source library if identifiable (Lucide/Phosphor/Heroicons), or custom.
6. **Imagery** — photography style, illustration presence, processing (color/mono/grain).
7. **Surfaces** — what products does this brand have? (marketing site, dashboard, mobile app, slides, longreads). This drives `ui_kits/`.
8. **Motion** — easings, durations, what animates and what doesn't.
9. **Hard rules / signatures** — the 3-5 things that make this brand recognizable. These will be embedded in the generated SKILL.md `## Hard rules` section in Step 6a.

Update SESSION.md under "Brand analysis".

---

## Step 4: Plan structure

Decide what files will be generated. This is a PLAN, not yet writing.

Plan **four** things: bundle location, preview cards, UI kits, substitutions.

### Plan list 0: Bundle directory (MANDATORY — must be confirmed at Step 5)

The DS bundle **always** lives in its own subfolder, never directly in cwd. Default naming:

```
<brand-slug>-design-system/
```

Where `<brand-slug>` is the kebab-case brand identifier (e.g. `stripe`, `linear`, `notion`, `iman-gadzhi`).

Examples:
- `stripe-design-system/`
- `linear-design-system/`
- `iman-gadzhi-design-system/`

**Conflict handling:** before showing the plan at Step 5, check if the target folder already exists:

```bash
ls "<brand-slug>-design-system/" 2>/dev/null
```

If it exists and is non-empty → in the plan ask explicitly: "Папка `<slug>-design-system/` уже существует. Что делать: (1) дописать в неё (рискованно — могу затереть твои правки), (2) создать `<slug>-design-system-2/`, (3) выбрать другое имя?"

If it doesn't exist → use the default name, but still surface it in the plan so the user can rename if desired.



### Plan list 1: Preview cards

Apply the Three-pass card selection protocol from `rules.md` §2 to decide which cards to make.

Format (illustrative — fonts/colors shown are an example from the RixAI brand; your card names and subtitles must reflect THIS brand's actual tokens):

```
PREVIEW CARDS:
  Type:
    - type-display.html — [display family + sizes covered + signature trait]
    - type-body.html — [body family + variations]
    - type-script.html — [accent family, only if brand uses one]
  Colors:
    - colors-accents.html — [accent palette description]
    - colors-surfaces.html — [neutral surface ramp description]
    - colors-text-glass.html — [text + glass tokens]
  Spacing:
    - spacing-scale.html — [base unit scale]
    - radii.html — [radii ladder]
    - shadows.html — [shadow recipes, only if more than one]
    - animation-tokens.html — [keyframe gallery, only if signature animations exist]
  Components:
    - components-buttons.html — [button variants]
    - components-[card-pattern].html — [card pattern this brand uses]
    - ...
  Brand:
    - brand-logos.html — [logos this brand has]
    - brand-imagery.html — [imagery style]
```

Target 12-20 cards. Skip a category if the brand has nothing meaningful there (e.g. brutalist brand → no shadows).

### Plan list 2: UI kits

What surfaces does this brand have? Each gets a `ui_kits/<name>/` folder.

- Marketing landing → `ui_kits/landing/` always for marketing brands
- Dashboard → only if the brand is SaaS with an app
- Mobile → only if a mobile product exists
- Slides → goes to `slides/` separately (not under `ui_kits/`)

### Plan list 3: Substitutions to flag

What must be substituted because the source didn't provide it?

```
SUBSTITUTIONS:
- Display font: original is proprietary [name] → Google Fonts [substitute]
- Body font: not specified → Inter (safe default)
- Icon system: no source set → Lucide via CDN
- Logo: placeholder wordmark from display family
```

Record all three lists in SESSION.md under "Planned structure".

---

## Step 5: ⛔ MANDATORY STOP

Show the user:
1. **📁 Папка вывода:** `./<brand-slug>-design-system/` — explicit, with note "(новая подпапка, твой cwd останется чистым)" or "(уже существует — что делать?)" if conflict detected
2. Brand-at-a-glance — 1-paragraph summary of what you understood
3. Plan list 1 (preview cards) — full list with subtitles
4. Plan list 2 (UI kits)
5. Plan list 3 (substitutions to flag)
6. Estimated file count and any large assumptions

Format the message clearly. End with:

> **Before I write 20+ files: does this plan match what you want? Папка `<slug>-design-system/` ок? Reply OK to proceed, or tell me what to change (имя папки, карточки, UI kits, замены — что угодно).**

**STOP IMMEDIATELY. Do not call any file-writing tool. Wait for the user's response.**

### Handling corrections

If the user requests changes:
1. Update the relevant plan list
2. Update SESSION.md under "User corrections" with the date and specific change
3. Re-show the updated plan
4. Wait for approval again
5. Repeat until the user replies with explicit approval ("OK", "go ahead", "proceed")

Do NOT proceed to Step 6 until you have explicit approval.

---

## Step 6: Generation

Write files in this exact order. Stop and update SESSION.md after each block.

**Pre-condition:** Step 5 (MANDATORY STOP) is approved AND all three plan lists in SESSION.md are stable. If the user changed substitutions in Step 5, the changes must be reflected in SESSION.md before starting 6a — `colors_and_type.css` and `SKILL.md` both encode substitutions and cannot be patched cheaply later.

### 6a. Bundle folder + skeleton files (5 min)

**Step 6a.0 — Create the bundle folder FIRST.** Before writing any DS file, materialize the subfolder confirmed at Step 5:

```bash
mkdir -p "<brand-slug>-design-system"
```

From this point on, **every path in steps 6a-6g is relative to this folder**. Either `cd` into it or prefix every Write/Edit with the folder path. Pick one approach and stick with it within a session.

Record the absolute bundle path in `SESSION.md` under `Bundle directory:` (see schema at the bottom of this file). Future steps reference this path; the checklist verifies isolation against it.

**Forbidden in cwd (parent of the bundle):** any of `README.md`, `colors_and_type.css`, `SKILL.md`, `cards.json`, `preview/`, `ui_kits/`, `assets/`, `fonts/`, `design-system-viewer.html`, `CHECKLIST-RESULT.md`. The ONLY file the skill is allowed to write in cwd is `SESSION.md` (state tracking from Step 1).

**Step 6a.1 — Write skeleton files INSIDE the bundle folder:**

```
<brand-slug>-design-system/
├── README.md           — brand documentation per templates.md §2. Index section lists planned preview cards
│                         (file names from Plan list 1), even though files don't exist yet — they will after 6b.
├── colors_and_type.css — design tokens + semantic classes per templates.md §1.
├── SKILL.md            — brand SKILL.md per templates.md §3. Embed substitutions from Plan list 3 in
│                         the "Hard rules" section if substitutions are high-impact (see rules.md §7).
└── cards.json          — empty array initially: []
```

### 6b. Preview cards (longest step, ~70% of time)

For each card in Plan list 1:
1. Write `preview/<filename>.html`
2. Append entry to `cards.json` immediately (don't batch — survives interruption)

Card requirements (see `templates.md` for full skeleton):
- Self-contained HTML linking `../colors_and_type.css`
- ~700px width, ≤400px height
- No internal title — name is rendered by the viewer
- Show the actual token (real swatches, real type at real size, real component)
- Real brand content where applicable, not lorem ipsum

### 6c. Assets

`Bash`: copy logos, photos, icons into `assets/`. Organize by type (`assets/logos/`, `assets/hero/`, `assets/photo/`).

The Brand-group preview cards from 6b reference these assets via relative paths (`../assets/...`). No edit to `cards.json` is needed — only verify the asset paths in those HTML cards resolve correctly.

### 6d. UI kits

For each item in Plan list 2:
1. Create `ui_kits/<name>/index.html` (self-contained, can use React via CDN or vanilla)
2. Create `ui_kits/<name>/README.md` listing what's included and what's stubbed
3. Append entry to `cards.json` with `viewport: {width: 1280, height: 720}`

### 6e. Slides (only if slide template was provided in source)

Skip if no slide reference exists. Otherwise: `slides/index.html` + per-layout files. Register each in `cards.json` with `viewport: {width: 1280, height: 720}`.

### 6f. Fonts

If the brand has proprietary fonts the user uploaded: `cp` to `fonts/`. If substituting: do NOT download Google Fonts files — link via `@import` in `colors_and_type.css`.

### 6g. design-system-viewer.html

Generate per the template in `templates.md` §6. This is the **last generated file** — needs `cards.json` to be complete first.

Procedure:
1. `Read` the final `cards.json` content
2. Inline that JSON array into the viewer's `<script>` block at the `INSERT_CARDS_JSON_CONTENT_HERE` marker, replacing `[]`
3. Write `design-system-viewer.html` to the bundle root
4. `cards.json` stays on disk as the canonical machine-readable manifest

This dual-storage approach is intentional: `cards.json` is for tooling and re-generation; the inlined data in the viewer is for offline browsing without `file://` CORS issues.

Update SESSION.md after each sub-step (6a → 6g).

---

## Step 7: Self-checklist (mandatory gate)

Run `reference/checklist.md` against the generated bundle.

Write the result to `CHECKLIST-RESULT.md` in the bundle root with the exact format specified in `checklist.md`.

**Do not proceed to Step 8 until every category is ✓.** If a category fails, fix the issue, re-run the check, regenerate `CHECKLIST-RESULT.md`.

---

## Step 8: Handoff

Tell the user **in chat** (the file-version of Caveats lives in `README.md` for future readers — chat is for the current conversation).

### ⚠️ Language and tone rules for the handoff (NON-NEGOTIABLE)

The handoff **must be readable by a non-technical user with no English**. See `rules.md §8 (Plain Russian handoff)` for the full rules. Quick checklist before sending:

- [ ] Russian-only. No English jargon without translation.
- [ ] No CSS variable names in user-facing text (`--stripe-font-display` → "шрифт заголовков").
- [ ] No file paths inside explanations (`ui_kits/landing/index.html` → "на лендинге"). It's OK to reference a folder once at the very end if needed.
- [ ] No skill internals: no "designlang extracted", no "voice extraction", no "library: unknown", no JSON field names.
- [ ] No company / library / foundry names that the user has no use for ("Klim Type Foundry", "JetBrains Mono") — say "платный шрифт" and "бесплатный аналог".
- [ ] Short sentences. One thought per sentence. No nested participial clauses.
- [ ] No English design terms without translation: `fidelity-gap` → "видимая разница с оригиналом"; `hi-fi recreation` → "максимально похожая копия"; `sub-surfaces` → "другие страницы"; `tone of voice` → "стиль текстов"; `surface` → "страница".

### Block 1: «Что я подменил» (Caveats — what was substituted)

Numbered list, 4-7 items. For each item:
1. **What** got swapped (in plain words — "шрифт", not "font-family")
2. **Why** (one phrase — "платный шрифт", "не нашёл в исходниках", "защищено")
3. **How visible the difference is** ("главная видимая разница", "почти незаметно", "только если знать оригинал")

Example structure:
```
Что я подменил:

1. Шрифт. Оригинальный шрифт бренда платный — поставил бесплатный
   похожий. Это главная видимая разница с оригиналом.

2. Иконки. Иконки бренда закрытые — взял открытый набор похожего стиля.

3. Логотип. [настоящий из исходников / placeholder с пометкой]

4. [и т.д. — реальные подмены из этого бандла]
```

### Block 2: «Что улучшить дальше» (the bold ask)

3-5 numbered items, **sorted by impact**. Each item is:
- A **question** the user can answer with yes/no or a short reply
- Phrased as a **suggestion**, not as a task list
- **Concrete**: "хочешь добавить дашборд?" — not "want me to tackle the next surface?"

Example:
```
Что улучшить дальше:

1. Если у тебя есть лицензионный [шрифт] — пришли файл, заменю
   обратно и DS станет неотличим от оригинала.

2. Сейчас сделан только лендинг. Хочешь добавить ещё одну
   страницу — например дашборд или страницу про команду?

3. Проверь тексты в карточках. Если стиль не такой как ты бы
   написал сам — скажи, поменяю на свой.
```

### What NOT to do

- ❌ "Recreated voice — 'you-only, sentence case, neutral' — попадает в то, как ты бы писал внутри?" → too long, mixes English jargon with Russian.
- ❌ "designlang дал library: unknown" → internal skill detail.
- ❌ "Sub-surfaces не покрыты: Dashboard, Docs, Stripe Press — у каждого свой визуальный язык" → English term + jargon "визуальный язык".
- ❌ "Gradient discipline. Бренд диктует один hero-gradient на страницу" → English terms (`gradient`, `hero`).
- ❌ "Stats в hero ('500M API requests / 99.999% uptime')" → user doesn't speak in CSS class names.

### What to do instead

- ✅ "Стиль текстов в карточках — такой как ты бы написал сам? Если нет — скажи, поменяю."
- ✅ Skip the "designlang did X" lines entirely. The user doesn't need to know which tool produced what.
- ✅ "Я сделал только лендинг. Хочешь ещё дашборд или страницу про команду?"
- ✅ "На лендинге есть градиенты — у бренда их обычно один на страницу, у меня шесть. Хочешь оставить или сократить?"

**Do not summarize what you did.** The viewer.html and the bundle structure are the deliverable. The chat is for what's still imperfect.

The Caveats in chat and the Caveats in README.md cover the same substitutions — that is intentional. README is the durable record for future agents; chat is the live conversation. (README может быть техничнее, чат — обязательно простой.)

---

## SESSION.md schema

Conventions:
- `Current step:` — the step the agent is actively executing OR most recently completed. Format: `Step Nx: description (in progress)` or `Step Nx: description (done)`. When resuming, the agent moves to the next step after the most recent `(done)`. If the most recent is `(in progress)`, the agent re-runs that step from where it stopped.
- Status values for substeps: `pending`, `in progress`, `done`, `N/A` (only for 6e Slides and 6f Fonts if not applicable).

```markdown
# Session State — create-design-system
Updated: [YYYY-MM-DD HH:MM]
Current step: [e.g. "Step 6c: assets (in progress)"]

## Task
[1-2 sentences: brand name + what we're building]

## Bundle directory  ← MANDATORY field (set at Step 4, materialized at Step 6a)
Slug: [e.g. stripe / linear / iman-gadzhi]
Folder name: [e.g. stripe-design-system]
Absolute path: [e.g. /Users/max/Stripe DS/stripe-design-system]
Cwd parent: [e.g. /Users/max/Stripe DS]
Created at Step 6a: [yes / no — must be yes by Step 6a.1]

## Source intake
- Input class: [A / B / C / D / E / F / G]
- Sources received:
  - [path or URL]
- Accessible: [list]
- Missing / inaccessible: [list]

## Brand analysis
- Voice: [1-3 lines]
- Color palette: [list with hex]
- Typography: [families + usage]
- Spacing: [base + scale]
- Iconography: [style + source]
- Imagery: [style]
- Surfaces: [marketing / dashboard / mobile / slides / longread]
- Motion: [easings + durations]
- Hard rules / signatures: [3-5 brand-distinctive rules]

## Planned structure
Preview cards: [list with subtitles, grouped by Type/Colors/Spacing/Components/Brand]
UI kits: [list]
Substitutions to flag: [list]

## User corrections
- [YYYY-MM-DD]: [specific change requested + how applied]

## Generation status
- 6a Skeleton: [pending / in progress / done]
- 6b Preview cards: [N of M done]
- 6c Assets: [pending / in progress / done]
- 6d UI kits: [N of M done]
- 6e Slides: [pending / in progress / N/A / done]
- 6f Fonts: [pending / in progress / done]
- 6g Viewer: [pending / in progress / done]

## Checklist status
- Category 1 Structure: [pending / ✓ / failed: ...]
- Category 2 Self-contained files: [pending / ✓ / failed: ...]
- Category 3 cards.json integrity: [pending / ✓ / failed: ...]
- Category 4 Brand SKILL.md: [pending / ✓ / failed: ...]
- Category 5 Caveats accuracy: [pending / ✓ / failed: ...]
```

Update this file after every completed step. The file wins over context if they disagree.
