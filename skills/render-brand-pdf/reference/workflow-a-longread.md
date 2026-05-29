# Workflow A — A4 Longread (Native PDF via Chrome)

Use this workflow when the user wants a document that gets READ — essays, reports, methodologies, homework, articles. Text remains selectable, searchable, and copy-pasteable.

---

## Result format

- A4 portrait, 210×297mm
- Native PDF (vector text)
- File size: ~0.5–2 MB for typical 10-20 page document
- Fonts embedded as real glyphs

---

## Folder structure

```
project-name-deck/
├── deck.html             ← main document
├── colors_and_type.css   ← copy from brand DS root
├── fonts/                ← copy from brand DS (.woff2 files)
├── assets/               ← optional project images
└── *.pdf                 ← output
```

Always copy `colors_and_type.css` and `fonts/` **locally** into the artifact folder so it stays portable — user can zip and share without external dependencies.

---

## Step 1 · Bootstrap folder

```bash
DS_ROOT="/path/to/brand-design-system"   # where colors_and_type.css lives
PROJECT_DIR="/path/to/output/project-name-deck"

mkdir -p "$PROJECT_DIR/fonts"
cp "$DS_ROOT/colors_and_type.css" "$PROJECT_DIR/"
cp "$DS_ROOT/fonts/"*.woff2 "$PROJECT_DIR/fonts/"
```

---

## Step 2 · Author `deck.html`

Minimal HTML scaffold for one A4 page:

```html
<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<title>Document title</title>
<link rel="stylesheet" href="colors_and_type.css">
<style>
  @page { size: A4 portrait; margin: 0; }
  * { box-sizing: border-box; }
  html, body {
    margin: 0; padding: 0;
    background: var(--bg, #0a0c12);
    color: var(--text);
    font-family: var(--font-body, 'Inter', system-ui, sans-serif);
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }
  .page {
    width: 210mm; height: 297mm;
    position: relative; overflow: hidden;
    background: var(--bg);
    page-break-after: always;
    page-break-inside: avoid;
  }
  .page:last-child { page-break-after: auto; }
  /* optional: ambient brand glow */
  .page::before {
    content: ''; position: absolute; pointer-events: none;
    width: 420px; height: 420px;
    background: radial-gradient(circle, hsl(174 80% 50% / .14), transparent 65%);
    top: -180px; right: -160px;
  }
  .frame {
    position: relative; z-index: 2;
    width: 100%; height: 100%;
    padding: 22mm 20mm;
    display: flex; flex-direction: column;
  }
</style>
</head>
<body>

<section class="page">
  <div class="frame">
    <!-- page content -->
  </div>
</section>

<!-- repeat <section class="page"> for each page -->

</body>
</html>
```

### Critical CSS rules

- `@page { margin: 0 }` — strips Chrome's default margins. Control all spacing via `.frame` padding.
- `.page { width: 210mm; height: 297mm; overflow: hidden }` — fixed size. Anything that overflows is CUT OFF in the PDF.
- `page-break-after: always` — guarantees each `.page` becomes a new PDF page.
- `-webkit-print-color-adjust: exact` — without this, Chrome weakens background colors in print mode.

---

## Step 3 · Start local HTTP server

**Why a server.** Chrome won't load `@font-face` woff2 files via `file://` — only `http://`. Always serve via `python3 -m http.server`.

```bash
cd "$PROJECT_DIR"
python3 -m http.server 8795 > /tmp/srv.log 2>&1 &
echo $! > /tmp/srv.pid
sleep 2
curl -s -o /dev/null -w "HTTP %{code}\n" "http://localhost:8795/deck.html"
# expect HTTP 200
```

**Port choice.** Use a unique port per project to avoid collisions. Known-working: 8788, 8789, 8790, 8791, 8793, 8794, 8795, 8796.

**Cyrillic paths.** If the HTML file has a Russian name, URL-encode:

```bash
URL="http://localhost:8795/$(python3 -c "import urllib.parse; print(urllib.parse.quote('Эфир Модуль 1.html'))")"
```

---

## Step 4 · Generate PDF via Chrome headless

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --no-sandbox --hide-scrollbars \
  --print-to-pdf="$PROJECT_DIR/Output.pdf" \
  --print-to-pdf-no-header \
  --no-pdf-header-footer \
  --virtual-time-budget=10000 \
  "http://localhost:8795/deck.html"
```

### Flag reference

- `--headless=new` — newer headless mode (better font support than `--headless=old`)
- `--print-to-pdf-no-header` + `--no-pdf-header-footer` — removes Chrome's default URL/date header
- `--virtual-time-budget=10000` — gives 10 seconds for fonts + assets to load before printing
- `--hide-scrollbars` — safety net
- `--disable-gpu --no-sandbox` — required for headless on macOS

---

## Step 5 · Visual verification (MANDATORY — overflow loop)

**This step is non-optional.** Do not deliver a PDF without going through every page and confirming no content is cut off. The user's #1 complaint with prior runs was bottom-edge overflow that wasn't caught.

### 5.1 Render all pages to PNG

```bash
# Render every page at 110 DPI (good balance of size vs detail)
pdftoppm -png -r 110 "$PROJECT_DIR/Output.pdf" /tmp/check

# Count pages — should match expected
ls /tmp/check-*.png | wc -l
```

### 5.2 Inspect EVERY page with `Read`

For each `/tmp/check-NN.png` — `Read` the image and look for these failure modes:

| Failure | What it looks like | Severity |
|---|---|---|
| **Bottom-edge overflow** | Text/element clipped at page bottom — partial last line visible, missing footer | **CRITICAL — must fix** |
| **Right-edge overflow** | Wide table or image clipped at page right edge | **CRITICAL — must fix** |
| **Empty bottom half** | Page has lots of empty space at bottom (content split awkwardly to next page) | Medium — could rebalance |
| **Missing fonts** | Times New Roman serif appearing instead of brand display font | **CRITICAL — fonts didn't load via HTTP** |
| **Wrong colors** | Backgrounds too light, gradient blob missing | High — `print-color-adjust: exact` not applied |
| **Misaligned elements** | Card halfway off-screen, text overlapping image | High |
| **«Ё» garbled** | Single letters on own lines, weird spacing | High — see troubleshooting Bug 1 |

DO NOT just glance at the grid preview. **Read each page individually.** Grid is for orientation, not for QA.

### 5.3 Overflow-fix loop (THE CRITICAL PART)

If ANY page shows bottom-edge overflow:

1. **Identify which page** — `/tmp/check-07.png` shows overflow → page 7 in HTML
2. **Identify the section in HTML** — open `deck.html`, find the 7th `<section class="page">` (count from 1)
3. **Apply ONE of these fixes** (in priority order):
   - **Add `.tight` modifier**: `<section class="page tight">` and add tight CSS (see troubleshooting Bug 4)
   - **Split content across two pages**: cut at logical boundary, create new `<section class="page">`
   - **Reduce component sizes**: smaller fonts, less padding, side-by-side instead of stacked
   - **Remove non-essential content**: secondary illustration, redundant callout
4. **Re-generate PDF** — go back to Step 4, run Chrome again
5. **Re-render page**: `pdftoppm -png -r 110 -f 7 -l 7 "$PROJECT_DIR/Output.pdf" /tmp/check_p7_v2`
6. **Read /tmp/check_p7_v2-07.png** — verify the fix
7. **If still overflowing** — go back to step 3 with a different fix. **Maximum 5 attempts per page** — if not fixed after 5 tries, escalate to user with screenshot and ask what to drop.

### 5.4 Grid preview (orientation only, not QA)

After all pages pass individual review, generate a grid for the final visual sanity check:

```python
from PIL import Image
import os
files = sorted([f for f in os.listdir("/tmp") if f.startswith("check-") and f.endswith(".png")])
ims = [Image.open(f"/tmp/{f}") for f in files]
tw, th = 280, 396  # thumbnail size
cols = 4
rows = (len(ims) + cols - 1) // cols  # auto-fit all pages
canvas = Image.new("RGB", (cols * tw + 10, rows * th + 10), (10, 12, 18))
for i, im in enumerate(ims):
    t = im.resize((tw, th), Image.LANCZOS)
    r, c = divmod(i, cols)
    canvas.paste(t, (c * tw + 5, r * th + 5))
canvas.save("/tmp/grid.png")
```

Then `Read /tmp/grid.png` for a final overview — confirm rhythm is consistent across pages, no surprise blank spaces, no obvious anomalies.

### 5.5 Pass criteria

Document is ready to hand to user when ALL of these are true:

- [ ] Every page rendered as PNG and read individually
- [ ] No bottom-edge overflow on any page
- [ ] No right-edge overflow on any page
- [ ] Fonts loaded correctly (brand display font visible, not Times New Roman)
- [ ] Colors look correct (no faded backgrounds)
- [ ] No layout misalignments
- [ ] Grid preview shows consistent rhythm
- [ ] Page count matches expected (no missing or extra pages)

If ANY checkbox fails → loop back to 5.3 and fix. Do NOT proceed to Step 6 with known overflow.

---

## Step 6 · Copy-paste verification

If text needs to copy cleanly out of the PDF (which is the main reason to use workflow A):

```bash
# View extracted text
pdftotext "$PROJECT_DIR/Output.pdf" - | head -50

# Specific page
pdftotext -f 11 -l 11 "$PROJECT_DIR/Output.pdf" -

# Detect broken lines (single-character Cyrillic lines indicate font encoding issues)
pdftotext "$PROJECT_DIR/Output.pdf" - | awk 'length($0) == 1 && $0 ~ /[А-Я]/'

# Count «Ё» occurrences — main diagnostic for Type 3 glyph issues
pdftotext "$PROJECT_DIR/Output.pdf" - | grep -c "Ё"
```

If single Cyrillic characters appear on their own lines, or if «Ё» causes problems — see `troubleshooting.md` Bug 1.

---

## Step 7 · Clean up

```bash
PID=$(cat /tmp/srv.pid) && kill $PID 2>/dev/null
rm -f /tmp/srv.pid /tmp/srv.log
```

---

## Common content patterns

For specific component classes (`.eyebrow`, `.glass-card`, `.callout`, `.dlist`, `.tier-table`, etc.) — see `component-library.md`.

For typical overflow / Ё / font-loading bugs — see `troubleshooting.md`.

For a copy-paste cheat sheet — see `quick-commands.md`.
