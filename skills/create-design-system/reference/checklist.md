# Output Checklist

> **THIS CHECKLIST MUST BE SAVED AS A FILE**
> Before delivering the bundle to the user — create `CHECKLIST-RESULT.md` at the bundle root.
> The handoff message is NOT delivered until every category is ✓.
> After any post-generation edits — re-run the checklist.

5 categories. Each category has concrete items and a **Proof format** stating the exact form the agent must use to demonstrate the check passed. Vague proofs ("verified", "looks good") are not acceptable.

---

## Category 1: Structure completeness

For the generated bundle:

- [ ] **Bundle isolation:** all DS files live inside a single subfolder named `<brand-slug>-design-system/` (or the user-chosen alternative). The parent directory (cwd where the skill was invoked) must NOT contain any of: `colors_and_type.css`, `cards.json`, `preview/`, `ui_kits/`, `assets/`, `fonts/`, `design-system-viewer.html`, `CHECKLIST-RESULT.md`. The only file allowed in the parent is `SESSION.md` (state tracking).
- [ ] `SKILL.md` exists at root with valid YAML front-matter containing `name`, `description`, `user-invocable` (or correct omission)
- [ ] `README.md` exists at root and has all required sections per templates.md §2: heading, aesthetic line, Sources, Index, Brand at a glance (optional — N/A if no sub-products), CONTENT FUNDAMENTALS, VISUAL FOUNDATIONS, ICONOGRAPHY, Caveats, Help me iterate
- [ ] `colors_and_type.css` exists at root and contains all token categories: brand color, accents, neutrals, typography, spacing, radii (shadows/motion if applicable)
- [ ] `cards.json` exists at root and is valid JSON (parses without error)
- [ ] `design-system-viewer.html` exists at root
- [ ] `preview/` folder exists with 10-25 HTML files (target band is 12-20 per rules.md §2; outside 10-25 is a fail and needs justification in CHECKLIST-RESULT.md)
- [ ] At least one `ui_kits/<name>/` exists with `index.html` and `README.md`
- [ ] `assets/` folder exists if the source provided any visual material
- [ ] `fonts/` folder exists ONLY if self-hosted fonts were provided
- [ ] `SESSION.md` exists with all steps marked complete

**Proof format:** "Bundle isolation: <slug>-design-system/ ✓ (parent cwd checked, no stray DS files outside bundle). Structure: SKILL.md ✓, README.md ✓ (sections present: heading, aesthetic, Sources, Index, [Brand at a glance: ✓ or N/A], CONTENT FUNDAMENTALS, VISUAL FOUNDATIONS, ICONOGRAPHY, Caveats, Help me iterate), colors_and_type.css ✓ (categories: brand/accents/neutrals/type/spacing/radii), cards.json ✓ (parses, N entries), viewer ✓, preview/ ✓ (N files), ui_kits/<name>/ ✓, assets/ ✓ or N/A, fonts/ ✓ or N/A, SESSION.md ✓ (in parent cwd)"

**How to verify isolation:**

```bash
# In the parent cwd (one level above the bundle):
cd "$(dirname <bundle-path>)"
ls colors_and_type.css cards.json design-system-viewer.html 2>/dev/null && echo "FAIL: stray DS files in parent" || echo "✓ parent clean"
ls preview/ ui_kits/ 2>/dev/null && echo "FAIL: stray DS folders in parent" || echo "✓ parent has no DS folders"
ls SESSION.md 2>/dev/null && echo "✓ SESSION.md found (expected)" || echo "WARNING: SESSION.md missing"
```

---

## Category 2: Self-contained file integrity

For each `preview/*.html`:

- [ ] Links `../colors_and_type.css` (relative path correct)
- [ ] Uses CSS variables from the brand prefix (no hardcoded brand colors)
- [ ] Renders standalone when opened via `file://` (no missing dependencies)
- [ ] No internal `<h1>` or visible title — title is in `cards.json`, viewer renders it
- [ ] Viewport size in `cards.json` reasonably matches actual rendered height (within ~50px)
- [ ] Contains real brand content (lifted quotes, real product names) — no lorem ipsum

For each `ui_kits/<name>/index.html`:

- [ ] Links `../../colors_and_type.css` (correct relative path from nested folder)
- [ ] Links local `styles.css` for layout (separate from brand tokens)
- [ ] Self-contained (CDN dependencies via `https://` are OK)
- [ ] Opens without console errors
- [ ] **🚨 No external `text/babel` scripts.** All JSX is inline in a single `<script type="text/babel">` block (data + components + render together). Babel-standalone cannot load `<script type="text/babel" src="*.jsx">` under `file://` (Chrome blocks `fetch()` to file URLs). This is a HARD FAIL — without it the viewer shows a blank iframe. Verify: `grep -E 'script[^>]+text/babel[^>]+src=' ui_kits/<name>/index.html` must return nothing. Same for `<script src="data.js">` style external loaders.
- [ ] **🚨 No `components.jsx` or `data.js` files in the folder.** If they exist, they're either (a) legacy artifacts from the broken pattern that must be deleted, or (b) the file path-loading bug above. Verify: `ls ui_kits/<name>/*.jsx ui_kits/<name>/data.js 2>/dev/null` should be empty.

For each `ui_kits/<name>/styles.css`:

- [ ] No `:root { ... }` token declarations (those belong in `colors_and_type.css`)
- [ ] No `@font-face` (those belong in `colors_and_type.css`)
- [ ] No hardcoded hex brand colors — only `var(--brand-...)` references
- [ ] Contains only layout structure for THIS surface

For each `ui_kits/<name>/README.md`:

- [ ] Lists "Components included" (the kept N)
- [ ] Lists "Combined into the above" (if source components were merged)
- [ ] Lists "What's intentionally omitted" (domain-specific / third-party / decorative)
- [ ] If anything was inferred (not in source) — lists it under "Inferred" section

For `design-system-viewer.html`:

- [ ] Opens via `file://` in Chrome by double-click (no server needed)
- [ ] Cards data is INLINED in the viewer's `<script>`, NOT fetched from `cards.json` (verify: the file contains `const CARDS = [...]` with actual entries, not `[]`)
- [ ] Inlined `CARDS` array contents match `cards.json` exactly (same N entries, same titles)
- [ ] All groups in correct order: Type → Colors → Spacing → Components → Brand → UI Kits → Slides
- [ ] Empty groups omitted
- [ ] All accordion rows expand on click
- [ ] All iframes load the referenced files

**Proof format:** "Preview cards: N tested, all link ../colors_and_type.css, all use brand-prefixed vars, all render standalone, no internal titles found via grep '<h1>' preview/*.html. UI kits: N tested, correct relative paths, **all inline JSX (no external text/babel src=, no components.jsx, no data.js files)**. Viewer: opens via file://, all groups in order, all rows expand."

How to test:

```bash
# UI kit inline-JSX guard — these MUST return nothing (else hard fail)
grep -rE 'script[^>]+text/babel[^>]+src=' ui_kits/*/index.html && echo "FAIL: external babel src= found" || echo "✓ no external text/babel src"
ls ui_kits/*/components.jsx ui_kits/*/data.js 2>/dev/null && echo "FAIL: external JSX/data files exist" || echo "✓ no external JSX/data files"

# CSS link check
grep -l "colors_and_type.css" preview/*.html | wc -l   # should equal number of preview files

# No internal title check
grep -L "<h1>" preview/*.html | wc -l                   # should equal number of preview files (all WITHOUT <h1>)

# Hardcoded color check (should return nothing for brand-prefix systems)
grep -E "#[0-9a-fA-F]{3,6}" preview/*.html | grep -v "var(--" || echo "no hardcoded brand colors found"

# Open viewer
open design-system-viewer.html
```

---

## Category 3: cards.json integrity

- [ ] Valid JSON, parses with `python3 -m json.tool cards.json`
- [ ] Every entry has all required fields: `file`, `title`, `subtitle`, `group`, `viewport.width`, `viewport.height`
- [ ] Every `file` path exists on disk
- [ ] Every `group` is one of: Type, Colors, Spacing, Components, Brand, UI Kits, Slides
- [ ] Every `title` follows `[Group] · [Subname]` format with middle dot (`·`)
- [ ] Every `subtitle` is 2-10 words, sentence case, no trailing period
- [ ] Preview cards have `viewport.width` = 700 (default; if a card is intentionally wider for legibility, justify in CHECKLIST-RESULT.md)
- [ ] UI kits / slides have `viewport.width` = 1280 (or explicit brand design width recorded in SESSION.md)
- [ ] No duplicate `file` references (same path referenced twice)
- [ ] No duplicate `title` references (two cards with the same `[Group] · [Subname]`)

**Proof format:** "cards.json: parses ✓, N entries, all 6 fields present per entry, all files exist on disk (verified via for-loop test), all groups in allowed list, all titles use middle dot, no duplicates."

How to test:

```bash
# Valid JSON
python3 -m json.tool cards.json > /dev/null && echo "valid"

# All files exist
python3 -c "import json; [print(c['file'], 'MISSING') for c in json.load(open('cards.json')) if not __import__('os').path.exists(c['file'])]"
```

---

## Category 4: Brand SKILL.md (inside generated bundle)

- [ ] `SKILL.md` has YAML front-matter between `---` markers at top
- [ ] `name` field uses kebab-case format `[brand]-design` (lowercase, hyphens, no spaces)
- [ ] `description` field references the brand name and includes the phrase "Use this skill to generate well-branded interfaces and assets for"
- [ ] `user-invocable: true` present
- [ ] Body opens with the phrase "Read the README.md file within this skill" (substring match, not strict verbatim — the rest of the sentence may vary)
- [ ] Contains the three standard paragraphs (visual artifacts / production code / no-guidance defaults) — exact wording per templates.md §3
- [ ] If brand has signature visual rules: `## Hard rules for [Brand]-style design` section present with 5-8 bullets

**Proof format:** "SKILL.md: YAML front-matter valid, name=[brand]-design ✓, description references [Brand] ✓, user-invocable: true ✓, body matches template structure ✓, hard rules section [present/N-A]."

---

## Category 5: Caveats accuracy

Every substitution made must be flagged in three places. Cross-check:

- [ ] Every font substitution listed in README.md `## Caveats` section
- [ ] Every font substitution listed in SESSION.md "Substitutions to flag"
- [ ] Every font substitution mentioned in the final handoff message (Caveats bullets)
- [ ] Every icon substitution listed in all three places
- [ ] Every placeholder asset (logo, hero image) listed in all three places
- [ ] **Cross-check, not keyword scan:** For each substitution recorded in SESSION.md, confirm it appears in BOTH README.md Caveats AND the handoff message. Then for each font name / icon library / asset referenced in `colors_and_type.css` and HTML files: confirm it is either (a) an original brand asset (no substitution needed) or (b) a substitution documented in SESSION.md. Do NOT keyword-scan for "Inter" / "Lucide" / "Phosphor" — those may be the brand's actual choice, not substitutes.
- [ ] If brand had proprietary fonts (Söhne, TT Severs, etc.) — Caveats explicitly state which CSS variable to replace

**Proof format:** "Substitutions: font [X→Y], icon [N/A or X→Y], logo [N/A or placeholder]. Cross-checked: README.md Caveats ✓ (N items), SESSION.md ✓ (N items match), handoff message ✓ (N items match). No silent substitutions found."

---

## CHECKLIST-RESULT.md template

Write this file at the bundle root before handoff:

```markdown
# Checklist Result — [Brand Name] Design System

Date: [YYYY-MM-DD HH:MM]
Bundle path: [absolute path]
Total cards in bundle: [N]

## Category 1: Structure completeness — [✓ / N failed]
[Proof per format above]

## Category 2: Self-contained file integrity — [✓ / N failed]
[Proof per format above]

## Category 3: cards.json integrity — [✓ / N failed]
[Proof per format above]

## Category 4: Brand SKILL.md — [✓ / N failed]
[Proof per format above]

## Category 5: Caveats accuracy — [✓ / N failed]
[Proof per format above]

## RESULT: [ALL ✓ / N items failed — correction required]
```

If RESULT is not "ALL ✓":
1. List failed items at the bottom of CHECKLIST-RESULT.md
2. Fix each one
3. Re-run the checklist
4. Update CHECKLIST-RESULT.md with new result
5. Only proceed to handoff (Step 8 in workflow) when ALL ✓
