# Troubleshooting — 9 Known Bugs

Battle-tested fixes for Chrome PDF rendering and Playwright slide capture. Listed in order of likelihood.

> **See also `real-bugs.md`** — universal failure modes from production runs with concrete symptoms and fixes. This file covers technical bugs (Ё, fonts, headless quirks). `real-bugs.md` covers broader failure modes (overflow, wrong attribution, wall-of-text, etc.) discovered in real usage.

---

## Bug 1 · «Ё» breaks copy-paste

**Symptom:** copying text from PDF produces `ОТ Ч Ё Т` (with spaces between letters) or text with line breaks mid-word.

**Cause:** brand fonts (TT Severs, TT Norms Condensed, similar custom Cyrillic faces) generate **Type 3 glyphs** for «Ё» without proper toUnicode mapping. Especially triggered by `text-transform: uppercase`.

**Fix — pick one:**

1. **For pills and tags containing «Ё»**, use a system font:
   ```css
   .ctag { font-family: 'Helvetica Neue', Arial, sans-serif; }
   ```

2. **Replace «Ё» with «Е»** (acceptable in Russian typography)

3. **Verify with diagnostics:**
   ```bash
   pdftotext file.pdf - | grep -c "Ё"
   pdftotext file.pdf - | awk 'length($0)==1 && $0 ~ /[А-Я]/'
   ```

---

## Bug 2 · Box-shadow on transformed elements renders as rectangle

**Symptom:** `box-shadow: 0 0 24px ...` on an element with `transform: rotate(45deg)` or `border-radius: 9999px` (pill) appears in PDF as a solid translucent rectangle around the element.

**Cause:** Chrome's print-to-PDF rasterizes box-shadow incorrectly on transformed or fully-rounded elements.

**Fix:** remove `box-shadow` from `.signoff-mark`, `.slash`, pill chips, small decorative elements. Keep glow effects only on large rectangular `.glass-card`.

---

## Bug 3 · Image overflow — clipped at bottom of page

**Symptom:** screenshot or image extends past `.page { height: 297mm; overflow: hidden }`.

**Fix (priority order):**

1. **Side-by-side layout** — image left, caption right. Natural aspect ratio preserved at fixed width:
   ```css
   .ts-card {
     display: grid;
     grid-template-columns: 360px 1fr;
     gap: 16px; align-items: center;
   }
   .ts-card img { width: 100%; height: auto; }
   ```

2. **Shrink container** — `max-width: 70%` on the image wrapper

3. **Last resort: max-height + object-fit** (image WILL be cropped):
   ```css
   img { max-height: 280px; object-fit: cover; object-position: center top; }
   ```

---

## Bug 4 · Page doesn't fit — bottom elements clipped

**Symptom:** too much content on a page, last element or footer is cut off.

**Fix — `.page.tight` / `.page.dense` pattern:** apply a tighter modifier class to specific overcrowded pages:

```css
/* global */
.page.tight .frame { padding: 18mm 18mm; }
.page.tight h2.section-title { font-size: 30px; margin-bottom: 12px; }
.page.tight .step-item { padding: 9px 14px; }
.page.tight .step-item .stepbody { font-size: 11px; line-height: 1.45; }
.page.tight .callout { padding: 10px 14px; margin: 6px 0; }
/* etc — shrink everything by 15–20% */
```

```html
<section class="page tight">
  <!-- dense content -->
</section>
```

---

## Bug 5 · Fonts don't load in headless Chrome

**Symptom:** PDF rendered with default font (Times New Roman or system sans), not the brand's `TT Severs` / custom font.

**Cause:** Chrome refuses to load `@font-face url('fonts/...')` over `file://` protocol.

**Fix:** ALWAYS serve HTML via `http://` (local `python3 -m http.server`). Never open `file:///path/to/deck.html` for production rendering.

If fonts still don't load via HTTP:
- Check `colors_and_type.css` path is correct from `deck.html`
- Check `fonts/*.woff2` files exist in the expected directory
- Verify with `curl -I http://localhost:PORT/fonts/font.woff2` returns 200

---

## Bug 6 · Cyrillic in paths breaks grep/find

**Symptom:** `grep "что-то" /Users/max/Documents/RixAI\ эфир/file.md` silently returns 0 matches.

**Cause:** macOS APFS stores filenames in NFD normalisation. GNU grep expects NFC.

**Fix:** use Python for file search and manipulation in Cyrillic paths:

```python
import os, shutil
for f in os.listdir('/Users/max/Desktop/'):
    if 'нужная_строка' in f:
        shutil.copy(f'/Users/max/Desktop/{f}', '/tmp/result.png')
```

Or temporarily rename to ASCII for the operation, then rename back.

---

## Bug 7 · Slide capture catches navigation overlay

**Symptom:** screenshots from `_capture.py` show `< 1/24 Reset R >` navigation pill at the bottom of slides.

**Cause:** `<deck-stage>` renders its navigation overlay inside Shadow DOM. External CSS cannot reach it.

**Fix:** inject CSS into the shadow root from the Playwright script:

```javascript
const ds = document.querySelector('deck-stage');
if (ds.shadowRoot) {
  const s = document.createElement('style');
  s.textContent = '.overlay, .tapzones { display: none !important; }';
  ds.shadowRoot.appendChild(s);
}
```

This is already in the `_capture.py` template in `workflow-b-slides.md`.

---

## Bug 8 · `<b>` mid-Cyrillic-sentence breaks Type 3 glyphs

**Symptom:** in callout with `<b>1. Начало чтения статьи</b> — описание...`, copy-pasted text has random line breaks between individual letters.

**Cause:** font-weight switch mid-Cyrillic-word sometimes triggers Type 3 rendering of individual characters in the font subset.

**Fix:** for critical Cyrillic text, use structured markup with separate elements instead of inline `<b>`:

```html
<!-- was: -->
<div class="cbody">
  <b>1. Начало чтения статьи</b> — в скриншот попадает время.
</div>

<!-- becomes: -->
<div class="rl-row">
  <span class="rl-num">01</span>
  <span class="rl-name">Начало чтения статьи</span>
  <span class="rl-desc">— в скриншот попадает время.</span>
</div>
```

With matching CSS for `.rl-row`, `.rl-num`, `.rl-name`, `.rl-desc`. The trick is each piece gets its own font context, no mid-word weight switching.

---

## Bug 9 · Slide `data-label` ≠ real slide index

**Symptom:** author inserted a slide in the middle. Now `data-label="27 …"` actually appears at position 30 in the deck.

**Cause:** `data-label` is editorial metadata, not an index. The real slide index is the `<section>` position inside `<deck-stage>`.

**Fix:** when referring to a specific slide, check content not the label. Author numbering can drift by ±2.

If precise indexing matters (e.g., for jumping to a specific slide programmatically):
```javascript
document.querySelector('deck-stage').goTo(N)  // 0-indexed position
```

Don't rely on `data-label` for navigation.

---

## Quick-fire diagnostics

```bash
# Is the server actually running?
curl -s -o /dev/null -w "HTTP %{code}\n" "http://localhost:PORT/deck.html"

# Are fonts loadable?
curl -I http://localhost:PORT/fonts/TT-Severs-DemiBold.woff2

# Is Chrome installed where expected?
ls -la "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Is Playwright Chromium installed?
python3 -c "from playwright.sync_api import sync_playwright; print('ok')"
ls ~/Library/Caches/ms-playwright/

# How many pages did the PDF produce?
pdftotext "file.pdf" - | grep -c "\f"  # form-feed chars = page breaks

# Quick visual check of all pages as PNG grid
pdftoppm -png -r 100 "file.pdf" /tmp/check
ls /tmp/check-*.png | wc -l
```

---

## When to escalate to user

Stop and ask for help if:

- More than 3 pages have overflow after `.tight` adjustments — content may be genuinely too dense
- «Ё» appears garbled even after Helvetica fallback — possibly a different glyph issue (try `e ё` with explicit space)
- Playwright can't find `<deck-stage>` element — HTML structure is wrong
- Chrome PDF rendering produces 0-byte file — fonts/CSS are missing, not loading

Don't silently work around — the user needs to know what compromised.
