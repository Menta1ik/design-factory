# Real-World Bugs — Universal Checklist

A library of failure modes seen in production PDF / slide rendering, organized by category. Each bug is **universal** — applies to any brand using `colors_and_type.css` + Chrome / Playwright pipeline. Each entry has: symptom → root cause → fix → lesson.

Read this list **before** finishing a render. Treat each bug as a sub-check during Step 6 visual verification.

---

## A. Content overflow / clipping

### A1 · Two H2 sections on one A4 page

**Symptom:** H2 heading sits in the middle of a page instead of at the top. Second section begins mid-page and tail continues onto the next page. Document reads choppy.

**Root cause:** Author packed two thematic sections into one `<section class="page">` to "save space".

**Fix:** One H2 = one page minimum. If a section truly fits in half a page, leave the bottom empty rather than starting the next H2.

**Lesson:** Page boundaries are semantic, not just spatial. The reader uses page edges as section breaks.

---

### A2 · Last page footer / endnote cut off

**Symptom:** Final page has section heading + several paragraphs + pullquote + closing CTA + endnote — and the endnote / footer disappear at the bottom edge.

**Root cause:** Closing pages tend to accumulate content (CTA, signature, endnote, source link). Total height exceeds 957px usable area on a 297mm A4 page.

**Fix:** Split the finale across two pages. One page for the last narrative section, one for a clean closing — one strong line + signature + footer with breathing room.

**Lesson:** When the ending feels overloaded, two pages with more air beat one page packed to the edge.

---

### A3 · Bottom-edge footer disappears on dense pages

**Symptom:** On pages with many cards (8+ num-cards, dense step-lists, large tag clouds), the footer is pushed off the bottom of the page and not visible in the PDF.

**Root cause:** Default component sizes were calibrated for "normal density" pages. When a page contains 8+ cards or 27+ tags, accumulated height exceeds the 297mm box.

**Fix:** Apply a `.tight` modifier to dense pages:

```css
.page.tight .frame { padding: 18mm 18mm; }
.page.tight .num-card { padding: 11px 14px; }
.page.tight .num-card h4 { font-size: 13px; }
.page.tight .step-item { padding: 10px 14px; font-size: 11.5px; gap: 7px; }
.page.tight .section-title { font-size: 30px; margin-bottom: 12px; }
/* etc — shrink everything by 15–20% on this page only */
```

```html
<section class="page tight">
  <!-- dense content -->
</section>
```

**Lesson:** Design components 15–20% more compact than feels comfortable. Space always runs out, not vice versa.

---

### A4 · Image overflow — solved with crop is wrong solution

**Symptom:** Screenshot or image extends past `.page { height: 297mm; overflow: hidden }`. Default reflex: add `object-fit: cover` and clip the image.

**Root cause:** Image at full container width + tall aspect ratio (e.g. 1202×752 → 1.6 ratio) = ~389px height at 600px width. Combined with surrounding content, exceeds page.

**Fix — priority order (crop is last resort):**

1. **Side-by-side layout** — image left, caption / description right:
   ```css
   .image-card {
     display: grid;
     grid-template-columns: 360px 1fr;
     gap: 16px;
     align-items: center;
   }
   .image-card img { width: 100%; height: auto; }
   ```
   At 360px fixed width:
   - ratio 2.6 → 138px height
   - ratio 1.6 → 225px height
   - ratio 1.47 → 245px height

   Natural aspect ratio preserved, nothing cropped.

2. **Reduce container width** to 70–80%

3. **Last resort: max-height + object-fit cover** — but image WILL be cropped:
   ```css
   img { max-height: 280px; object-fit: cover; object-position: center top; }
   ```

   Only use if user explicitly said "you can crop". Otherwise side-by-side first.

**Lesson:** Crop is an anti-solution. Try layout before crop. If you must crop, ask the user first.

---

### A5 · Cover page gets clipped after adding a large visual

**Symptom:** Hero/cover page was working, then someone added a screenshot or illustration. Now the bottom disclaimer or stats row is cut off.

**Root cause:** Adding any large visual element (screenshot, illustration, big quote) eats space. Surrounding elements need proportional shrinking.

**Fix:** When you add a major visual element, immediately compact the surrounding content:

- H1 down 10–15% (e.g. 52px → 44px)
- `.hero-stats` cards more compact, smaller numbers
- `.cover-meta` padding reduced
- New visual itself with explicit `max-height: 280px`

**Lesson:** Don't wait for the bottom to clip — compact other elements proactively when adding major visuals.

---

## B. Broken copy-paste from PDF

### B1 · Single Cyrillic letters on their own lines («Ё» problem)

**Symptom:** Copy text out of PDF and get garbage like:

```
ОТ Ч Ё Т · 3 С К Р И Н А
1. Начало ч т ния стат е ьи — в скриншот попада т вр е е...
```

Words break in random places. Single Cyrillic characters appear on their own lines when re-pasted.

**Root cause — combination of factors:**

1. `text-transform: uppercase` + `letter-spacing: 0.15em` + Cyrillic «Ё» in a custom display font (any font without proper toUnicode mapping for Ё) → Chrome generates Type 3 glyphs. «Ё» is extracted as a separate line. Letter-spacing values become real spaces in the copy.

2. `<b>...</b>` mid-Cyrillic-sentence triggers font-weight switching that also worsens Type 3 rendering.

**Fix — apply all four:**

1. **Replace `<b>` mid-Cyrillic with structured markup:**
   ```html
   <!-- BAD -->
   <b>1. Начало чтения статьи</b> — описание процесса.

   <!-- GOOD -->
   <div class="rl-row">
     <span class="rl-num">01</span>
     <span class="rl-name">Начало чтения статьи</span>
     <span class="rl-desc">— описание процесса.</span>
   </div>
   ```

2. **Replace «Ё» with «Е» in uppercase contexts** (Russian typography allows this in display caps):
   - «ОТЧЁТ» → «ОТЧЕТ»
   - «ВСЁ» → «ВСЕ»

3. **Use a system font for pills / tags / chips containing «Ё»:**
   ```css
   .pill, .tag, .ctag { font-family: 'Helvetica Neue', Arial, sans-serif; }
   ```

4. **Reduce letter-spacing** in problem pills from `.15em` to `.02em`.

**Verification:**
```bash
pdftotext file.pdf - | grep -c "Ё"                        # count of «Ё»
pdftotext file.pdf - | awk 'length($0)==1 && $0 ~ /[А-Я]/'  # single-letter lines
```

If any single-letter Cyrillic lines appear → fix needed.

**Lesson:** Custom display fonts + Cyrillic uppercase + bold-mid-word is a triple risk. Test extraction before delivery.

---

## C. Visual glitches

### C1 · Rectangular halo around rotated diamonds / pills

**Symptom:** A small decorative element (diamond marker, pill chip) shows a hard rectangular semi-transparent block around it in the PDF — looks like a glitch. ~140×60px area of soft fill where there should be subtle glow.

**Root cause:** Chrome's print-to-PDF incorrectly renders `box-shadow` with large blur on elements that have `transform: rotate(45deg)` or `border-radius: 9999px` (pills). The blur becomes a hard rectangle instead of a soft glow.

**Fix:** Remove `box-shadow` from small transformed / rounded elements:

```css
/* BAD on rotated diamond */
.diamond-marker {
  transform: rotate(45deg);
  box-shadow: 0 0 18px var(--brand-cyan);  /* renders as rectangle in PDF */
}

/* GOOD */
.diamond-marker {
  transform: rotate(45deg);
  /* no box-shadow — keep small elements clean */
}
```

Keep glow effects only on **large** non-transformed elements (full glass-cards, hero sections).

**Lesson:** `box-shadow` + transform / pill-radius = PDF artifact. Glow only on big static rectangles.

---

### C2 · Stray colored line at the bottom of a page

**Symptom:** A thin colored line appears at the bottom of a page, with no text or content next to it. Looks like a random visual artifact.

**Root cause:** An element with `border-left: 2px solid var(--brand-color)` sits at the page boundary. The block tries to start at the bottom of the page, but its content is pushed to the next page. Only the top sliver of the border-left renders — as a stray line.

**Fix — pick one:**

1. **Move the element to the next page** so it renders whole
2. **Replace `border-left` with `background-color`** — backgrounds clip cleanly:
   ```css
   /* BAD */
   .endnote { border-left: 2px solid var(--brand-cyan); padding-left: 16px; }

   /* GOOD */
   .endnote { background: var(--brand-cyan-tint); border-radius: 4px; padding: 12px 16px; }
   ```
3. **Remove the element entirely** if it's near-overflow (endnotes/teasers often can be cut)

**Lesson:** Border-left at the page edge becomes a stray line. Use background blocks for elements near overflow boundaries.

---

## D. Wrong content — not what was asked

### D1 · Wrong brand / series attribution

**Symptom:** Final document carries the wrong brand label or series name — e.g. "Course Module 1" when the document is a standalone article, or "Research blog" when it's a course material.

**Root cause:** Agent inferred the attribution from context instead of asking. When the user has multiple sub-brands or contexts (academy, research blog, podcast, newsletter), they're easy to mix up.

**Fix:** **Ask before tagging.** Before adding any of:
- Series name / module number
- Brand sub-label (Academy vs Research vs Newsletter)
- Footer attribution
- Cover slate

Ask: "Which brand context is this for? [list known options]"

**Lesson:** Don't infer brand context. Multiple sub-brands exist; mixing them up requires re-rendering.

---

### D2 · Document ends with a teaser, not a closing

**Symptom:** Final page has a "next time I'll tell you more about X" teaser. User wanted the document to feel **complete and closed**, not a cliffhanger.

**Root cause:** Agent added an `endnote` or `teaser` block at the end thinking it was good practice. User had said "the report should be complete" but the teaser undermined that.

**Fix:** Remove teasers from documents marked as "complete" / "standalone". The final page should be one strong closing thought, possibly an author signature, then footer. No promises of future content.

**Lesson:** "Complete document" literally means closing within itself. Cut teasers.

---

### D3 · Source has "either-or" options but the final intent is one

**Symptom:** Source markdown offers "you can use the short prompt OR the long prompt" / "choose between version A or B". Agent reflected this as a "2 options" callout in the design. User actually wanted to simplify to ONE final version.

**Root cause:** Source content was a draft with author-facing options, not final-reader-facing options.

**Fix:** When source has "options on choice" → ask: "Is this a final decision yet? Should I show ONE version or show both as options?"

**Lesson:** "Choice on the table" in a draft ≠ "options to present". Clarify intent.

---

## E. Stylistic / creative

### E1 · Wall-of-text, no visual hooks

**Symptom:** Document is technically correct but boring. All N pages are text-heavy without visual breaks. User says "it works but no wow factor".

**Root cause:** Agent prioritized content density over reading experience. Treats every page as a paragraph container.

**Fix:** Replace 2-4 key pull-quotes with **character-quote blocks** using brand mascots / pixel personas:
- Voice from inside (fear, doubt) → one character
- Analyst voice (data, AI) → another character
- Mentor voice (wisdom, perspective) → another
- Audience voice (the reader speaking) → another

Plus visual hooks per page:
- Stat-card with large number
- Pullquote with cyan accent
- Inline diagram (hub-spoke, flow-chart, decision tree)
- Charts where data exists

**Lesson:** Dense documents need visual rest stops. If the brand has mascots / illustrations / personas — use them.

---

### E2 · Over-creative naming when user wants simple

**Symptom:** Agent proposed 3 creative naming directions (warm-personal: "Bob the Unpacker, Vince the Carver"; tool-functional: "Root / Frame / Layer"; craft-poetic: "Potter / Architect / Radiologist"). User pushed back: "simpler, no creativity".

**Root cause:** Creative variety feels valuable but the user just wanted functional names.

**Fix:** When user says "simpler" / "no creativity" / "functional names" — give them **one-word functional names** matching the role. No metaphors, no human first names. "Unpacker / Strategist / Diagnostician" — done.

**Lesson:** "Simpler" is literal. Stop trying to sell more creative options.

---

### E3 · Wrong aspect ratio (16:9 vs 9:16)

**Symptom:** Agent built a deck in 16:9 (1920×1080) by default. User actually wanted 9:16 (1080×1920) for Instagram stories / vertical content. Full re-layout required.

**Root cause:** Default format wasn't confirmed before building.

**Fix:** Ask BEFORE Step 2: "What aspect ratio? 16:9 (presentations, webinars), 9:16 (Instagram stories, vertical), or 4:3 (print, classic)?"

Re-layout from 16:9 to 9:16 means:
- `<deck-stage width="1080" height="1920">` instead of 1920×1080
- 4-column hero-stats → 2×2 grid
- Horizontal stat-row → vertical stack
- Yes/No two-column → stacked
- 3-column timeline → vertical column

**Lesson:** Aspect ratio is a Step 0 question, not a Step 5 question.

---

### E4 · Cut too much when source said "keep everything"

**Symptom:** Agent compressed long source markdown into "executive summary" deck. User said "save all the meaning, add interesting elements" — they wanted complete preservation, not summary.

**Root cause:** Agent defaulted to "shorter is better" instead of asking how complete.

**Fix:** When user says "keep all thesis points" → don't cut. Add pages, don't subtract. Better +3 slides with full content than -3 with summarized content.

Add visual elements that make density readable:
- New diagram pages (hub-spoke, comparison chart)
- Inline data visualizations
- Glossary page for terms
- Expanded methodology section

**Lesson:** "Don't summarize" literally means don't cut. Length is acceptable; loss is not.

---

## F. Text edits gotchas

### F1 · Stat-card numbers don't match reality

**Symptom:** Cover has "5 files" but the document actually has 8 files inside. Numbers in stat-cards are out of sync with content.

**Root cause:** Numbers were chosen at draft time and not updated when content evolved.

**Fix:** Before finalizing, **recount every number on the cover**:
- Files count → match files actually shown / referenced
- Steps count → match procedure steps shown
- Days count → match timeline shown
- Pages count → match real page count

**Lesson:** Cover stats are the loudest text — they must match the content.

---

### F2 · User changes mind mid-edit, take the last version

**Symptom:** User says "remove X", then 30 seconds later "actually replace with Y". Agent confused between versions.

**Root cause:** Iterative edits, fast feedback.

**Fix:** Take the **latest** instruction as final. Don't try to compromise between earlier and later messages. Make the change cleanly and move on.

**Lesson:** Latest message wins. Don't agonize over previous versions.

---

### F3 · URLs in final page broken mid-string

**Symptom:** Source URLs on the references page rendered as `x.com/user/status/1234567` with `<br>` mid-string. Not clickable in PDF, looks broken.

**Root cause:** Agent tried to manually wrap long URLs.

**Fix:** Three rules for URLs in PDF:
1. **Full URL** including `https://` in `<a href>` — clickable in PDF viewers
2. **One line, no manual wrapping** (CSS `word-break: break-all` if needed)
3. **Pill / button style** with arrow icon:
   ```html
   <a href="https://example.com/article/123" class="url-pill">
     example.com/article/123 <span class="arrow">↗</span>
   </a>
   ```

**Lesson:** URLs are functional content, not decorative. They must be clickable and clean.

---

### F4 · Rename agent / entity names — Cyrillic declension trap

**Symptom:** Agent ran `sed s/OldName/NewName/g` to rename a character throughout a Cyrillic document. Now declensions are broken: "к Васе", "с Васей", "Васю" became "к Васе" (unchanged because didn't match new spelling exactly).

**Root cause:** Cyrillic / inflected languages have multiple word forms for one entity. Simple find-replace catches only the nominative.

**Fix:** Make **separate edits for each case** that appears in the text:
- Nominative: "Вася" → "Распаковщик"
- Genitive: "Васи" → "Распаковщика"
- Dative: "Васе" → "Распаковщику"
- Accusative: "Васю" → "Распаковщика"
- Instrumental: "Васей" → "Распаковщиком"
- Prepositional: "Васе" → "Распаковщике"

Search through document for each form, replace individually.

**Lesson:** Rename in inflected languages = N edits, not one global replace.

---

## G. Edge cases (not bugs, but important)

### G1 · Source markdown is huge because base64 images are embedded

**Symptom:** Source `.md` file is reported as 127k+ tokens but only has ~500 lines. Can't read it through normal Read.

**Root cause:** Markdown export tool embedded images as base64 inline strings. Each image ~50–100k tokens.

**Fix:** Strip base64 before reading:

```python
import re
text = open('source.md').read()
clean = re.sub(r'!\[[^\]]*\]\(data:image/[^)]+\)', '[IMAGE]', text)
clean = re.sub(r'data:image/[^"\'\s)]+', '[BASE64]', clean)
open('source.clean.md', 'w').write(clean)
print(f"Cleaned: {len(text)} → {len(clean)} chars")
```

Then read `source.clean.md` instead.

**Lesson:** Large MD with few lines = embedded base64. Strip first, read second.

---

## Sanity checklist before delivery

A condensed version of all above bugs as a final review:

| # | Check | How |
|---|---|---|
| 1 | All pages visible end-to-end, no clipped footer / content | Visual review every page via `pdftoppm` |
| 2 | No H2 headings in the middle of a page | One H2 = one page minimum |
| 3 | Copy-paste from PDF gives clean words | `pdftotext file.pdf` + `grep -c "Ё"` + single-letter line check |
| 4 | Images shown in full, not cropped | `object-fit: contain` or side-by-side layout, not `cover` |
| 5 | No glow artifacts around diamonds / pills | Remove `box-shadow` from rotated / pill elements |
| 6 | Document feels **complete**, not a teaser | Final page = closing thought, no "next time" promises |
| 7 | Correct brand / series / sub-brand attribution | Ask before tagging |
| 8 | Not "wall of text" — visual hooks per page | Stat, pullquote, character-quote, chart, diagram |
| 9 | All cover numbers match real content | Recount every stat-card number |
| 10 | URLs are clickable, single-line, complete | `<a href="https://...">` with no manual wrap |
| 11 | Renamed entities consistent in all grammatical forms | Separate edits per case for inflected languages |
| 12 | Aspect ratio confirmed before render | 16:9 / 9:16 / 4:3 — ask at Step 1 |

---

## The single most important rule across all these bugs

> **Asking a clarifying question BEFORE doing beats re-doing AFTER.**

Most bugs above could have been prevented by one clarifying sentence at Step 1:

- "Aspect ratio: 16:9 or 9:16?"
- "Which brand: [Academy / Research / Newsletter]?"
- "Should the document feel complete, or is it part of a series with teasers?"
- "Can images be cropped, or must they be shown in full?"
- "Entity naming: functional and short, or creative and descriptive?"
- "Source has options — do you want one final or both shown?"
- "Compress meaning into summary, or preserve everything and add pages?"

Treat the first 30 seconds of a render request as a question round, not a planning round. Save hours of re-rendering.

---

*This document is universal — applies to any brand using the `colors_and_type.css` + Chrome / Playwright pipeline. Concrete project examples in original sources were anonymized to focus on the failure pattern, not the specific brand.*
