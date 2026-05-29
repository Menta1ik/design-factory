# Quick Commands — Cheat Sheet

Copy-paste shell commands for both workflows. Set `$PROJECT_DIR`, `$DS_ROOT`, `$PORT` first, then run blocks.

---

## Variables to set

```bash
DS_ROOT="/path/to/brand-design-system"      # where colors_and_type.css lives
PROJECT_DIR="/path/to/output/my-deck"        # where the PDF will be created
PORT=8795                                     # unique per session: 8788-8796
```

---

## Workflow A — A4 longread

### Bootstrap

```bash
mkdir -p "$PROJECT_DIR/fonts"
cp "$DS_ROOT/colors_and_type.css" "$PROJECT_DIR/"
cp "$DS_ROOT/fonts/"*.woff2 "$PROJECT_DIR/fonts/"
```

### Start server

```bash
cd "$PROJECT_DIR"
python3 -m http.server $PORT > /tmp/srv.log 2>&1 &
echo $! > /tmp/srv.pid
sleep 2
curl -s -o /dev/null -w "HTTP %{code}\n" "http://localhost:$PORT/deck.html"
# expect: HTTP 200
```

### Generate PDF

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --no-sandbox --hide-scrollbars \
  --print-to-pdf="$PROJECT_DIR/Output.pdf" \
  --print-to-pdf-no-header \
  --no-pdf-header-footer \
  --virtual-time-budget=10000 \
  "http://localhost:$PORT/deck.html"
```

### Visual verification

```bash
# All pages as PNG
pdftoppm -png -r 110 "$PROJECT_DIR/Output.pdf" /tmp/check

# One page at high resolution
pdftoppm -png -r 200 -f 5 -l 5 "$PROJECT_DIR/Output.pdf" /tmp/p5
```

### Copy-paste verification

```bash
# Preview first 50 lines
pdftotext "$PROJECT_DIR/Output.pdf" - | head -50

# Specific page
pdftotext -f 11 -l 11 "$PROJECT_DIR/Output.pdf" -

# Look for broken Cyrillic glyphs
pdftotext "$PROJECT_DIR/Output.pdf" - | awk 'length($0)==1 && $0 ~ /[А-Я]/'

# Count «Ё» appearances (Type 3 diagnostic)
pdftotext "$PROJECT_DIR/Output.pdf" - | grep -c "Ё"
```

### Clean up

```bash
PID=$(cat /tmp/srv.pid) && kill $PID 2>/dev/null
rm -f /tmp/srv.pid /tmp/srv.log
```

---

## Workflow B — Slide deck

### Bootstrap (requires deck-stage template)

```bash
DECK_TEMPLATE="/path/to/RixAI Dzen"  # or wherever slides-shared.css + deck-stage.js live

mkdir -p "$PROJECT_DIR/fonts"
cp "$DS_ROOT/colors_and_type.css" "$PROJECT_DIR/"
cp "$DECK_TEMPLATE/slides-shared.css" "$PROJECT_DIR/"
cp "$DECK_TEMPLATE/deck-stage.js" "$PROJECT_DIR/"
cp "$DS_ROOT/fonts/"*.woff2 "$PROJECT_DIR/fonts/"
```

### Start server

```bash
cd "$PROJECT_DIR"
python3 -m http.server $PORT > /tmp/serv.log 2>&1 &
echo $! > /tmp/srv.pid
sleep 2
```

### Capture all slides

```bash
# Edit _capture.py first: set ROOT and PORT
python3 "$PROJECT_DIR/_capture.py"
```

### Merge PNG → PDF

```bash
python3 << 'PYEOF'
from PIL import Image
from pathlib import Path

PROJECT = Path("/path/to/output/my-deck")  # SET THIS
shots = sorted((PROJECT / "_shots").glob("slide_*.png"))
pages = [Image.open(f).convert("RGB") for f in shots]
out = PROJECT / "Final-deck.pdf"
pages[0].save(out, save_all=True, append_images=pages[1:],
              format="PDF", resolution=288.0,
              title="Deck title", author="Brand Name")
print(f"{out} · {out.stat().st_size / (1024*1024):.1f} MB · {len(pages)} pages")
PYEOF
```

### Clean up

```bash
PID=$(cat /tmp/srv.pid) && kill $PID 2>/dev/null
rm -f /tmp/srv.pid /tmp/serv.log
# rm -rf "$PROJECT_DIR/_shots"  # optional
```

---

## Diagnostics

```bash
# Server running?
curl -s -o /dev/null -w "HTTP %{code}\n" "http://localhost:$PORT/deck.html"

# Fonts reachable?
curl -I "http://localhost:$PORT/fonts/TT-Severs-DemiBold.woff2"

# Chrome present?
ls -la "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Playwright ready?
python3 -c "from playwright.sync_api import sync_playwright; print('ok')"

# PDF page count
pdftotext "$PROJECT_DIR/file.pdf" - | grep -c "\f"

# All PNG renders side-by-side
pdftoppm -png -r 90 "$PROJECT_DIR/file.pdf" /tmp/all && ls /tmp/all-*.png
```

---

## Format presets

```bash
# 16:9 webinar (1920×1080 → 13.33×7.5 inch PDF)
viewport="1920×1080"; pil_resolution=288

# 9:16 stories (1080×1920 → 3.75×6.67 inch PDF)
viewport="1080×1920"; pil_resolution=288

# Print-quality (3x detail)
device_scale_factor=3; pil_resolution=432
```

---

## What I never do

- Markdown → PDF via pandoc/wkhtmltopdf (loses brand styling, can't control pagination)
- Direct file:// opening in Chrome (fonts won't load)
- macOS Print → Save as PDF (adds header/footer, not reproducible)
- Google Fonts via CDN (headless Chrome may have no internet)
- Base64-embedded images in `<img src="data:...">` (bloats HTML to 100+ MB)
- `position: absolute` for main content (risky for Chrome pagination)
- JS that mutates layout after load (Chrome may not wait)
- `animation: ... infinite` without `noscale` (Playwright catches random frame)
