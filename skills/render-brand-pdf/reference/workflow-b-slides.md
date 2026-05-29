# Workflow B — Slide Deck (Rasterized PDF via Playwright + PIL)

Use this workflow when the user wants a presentation, social media content, or anything shown on a screen — where pixel-perfect appearance matters more than text selectability.

---

## Result format

- 16:9 (1920×1080) or 9:16 (1080×1920)
- Rasterized PDF: each page = one PNG screenshot
- File size: 5–25 MB
- Fonts baked into pixels (no text-extraction possible)

---

## Folder structure

```
project-name-deck/
├── deck.html             ← slides as <section class="slide">
├── colors_and_type.css   ← copy from brand DS root
├── slides-shared.css     ← slide-level classes (.slide, .frame, .gcard, .ul-brand)
├── deck-stage.js         ← <deck-stage> web component
├── fonts/                ← copy from brand DS
├── assets/               ← optional
├── _capture.py           ← Playwright capture script
├── _shots/               ← PNG screenshots (created by script)
└── *.pdf                 ← final output
```

**Prerequisite:** brand DS must include `slides-shared.css` + `deck-stage.js`. These provide the `<deck-stage>` component that handles 1920×1080 scaling and slide navigation. If absent, the user needs to add them (template in `/Users/max/Documents/RixAI эфир/RixAI Dzen/`).

---

## Step 1 · Bootstrap with deck engine

```bash
DS_ROOT="/path/to/brand-design-system"
DECK_TEMPLATE_DIR="/path/to/deck-engine"  # where slides-shared.css + deck-stage.js live
PROJECT_DIR="/path/to/output/project-name-deck"

mkdir -p "$PROJECT_DIR/fonts"
cp "$DS_ROOT/colors_and_type.css" "$PROJECT_DIR/"
cp "$DECK_TEMPLATE_DIR/slides-shared.css" "$PROJECT_DIR/"
cp "$DECK_TEMPLATE_DIR/deck-stage.js" "$PROJECT_DIR/"
cp "$DS_ROOT/fonts/"*.woff2 "$PROJECT_DIR/fonts/"
```

---

## Step 2 · Author `deck.html` with `<deck-stage>`

```html
<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<link rel="stylesheet" href="colors_and_type.css">
<link rel="stylesheet" href="slides-shared.css">
<style>
  body { margin: 0; background: var(--bg-deep); color: var(--text); font-family: var(--font-body); }
  /* local styles */
</style>
</head>
<body>

<deck-stage width="1920" height="1080">

  <section class="slide" data-label="01 Cover">
    <div class="frame">
      <div class="eb">— Eyebrow text</div>
      <h1 class="h1">Slide headline</h1>
    </div>
    <div class="corner-sm"><span class="d"></span><span>01 / 24</span></div>
  </section>

  <section class="slide" data-label="02 ...">
    <div class="frame">
      <!-- slide content -->
    </div>
  </section>

  <!-- repeat for each slide -->

</deck-stage>

<script src="deck-stage.js"></script>
</body>
</html>
```

### What `<deck-stage>` provides

- Auto-scales 1920×1080 canvas to fit any browser window (for preview)
- `noscale` attribute disables auto-scale — slides render at authored size (used for screenshots)
- Keyboard navigation: arrows / PgUp-PgDn / number key
- API: `document.querySelector('deck-stage').goTo(i)` to jump to slide i
- Overlay in shadow DOM (slide counter at bottom) — must be hidden before screenshots

### Format variants

- **16:9** (webinars, presentations): `<deck-stage width="1920" height="1080">`
- **9:16** (Instagram stories, vertical content): `<deck-stage width="1080" height="1920">` — also update Playwright viewport and PIL DPI accordingly

---

## Step 3 · Playwright capture script

Save as `_capture.py` in the project folder:

```python
"""Capture every slide at authored resolution."""
import time
import urllib.parse
from pathlib import Path
from playwright.sync_api import sync_playwright

ROOT = Path("/path/to/project-name-deck")  # SET THIS
SHOTS = ROOT / "_shots"
SHOTS.mkdir(exist_ok=True)
PORT = 8790  # match your http.server port
URL = f"http://localhost:{PORT}/" + urllib.parse.quote("deck.html")

# Viewport — adjust for 9:16
VIEWPORT_W = 1920
VIEWPORT_H = 1080


def main() -> None:
    with sync_playwright() as p:
        browser = p.chromium.launch()
        ctx = browser.new_context(
            viewport={"width": VIEWPORT_W, "height": VIEWPORT_H},
            device_scale_factor=2,  # retina-sharp PNG (output 3840×2160)
        )
        page = ctx.new_page()
        page.goto(URL, wait_until="networkidle", timeout=60_000)

        # Apply noscale + hide nav overlay (shadow DOM injection)
        page.evaluate("""() => {
          const ds = document.querySelector('deck-stage');
          ds.setAttribute('noscale', '');
          const s = document.createElement('style');
          s.textContent = 'html, body { background: #000 !important; margin: 0; }';
          document.head.appendChild(s);
          if (ds.shadowRoot) {
            const ss = document.createElement('style');
            ss.textContent = '.overlay, .tapzones { display: none !important; }';
            ds.shadowRoot.appendChild(ss);
          }
        }""")

        n = page.evaluate("document.querySelector('deck-stage')._slides.length")
        print(f"slides: {n}")
        page.evaluate("document.fonts.ready")
        time.sleep(0.4)

        for i in range(n):
            page.evaluate(f"document.querySelector('deck-stage').goTo({i})")
            # Wait for fonts + images on this slide to load
            page.evaluate("""async () => {
              await document.fonts.ready;
              const ds = document.querySelector('deck-stage');
              const active = ds._slides[ds._index];
              const imgs = active.querySelectorAll('img');
              await Promise.all(Array.from(imgs).map(im => im.complete ? null :
                new Promise(r => { im.addEventListener('load', r, {once: true}); im.addEventListener('error', r, {once: true}); })));
              await new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r)));
            }""")
            page.wait_for_timeout(350)  # let animations settle

            label = page.evaluate(
                "i => (document.querySelector('deck-stage')._slides[i] || {}).getAttribute?.('data-label') || ''",
                i,
            )
            out = SHOTS / f"slide_{i+1:03d}.png"
            page.screenshot(path=str(out),
                            clip={"x": 0, "y": 0, "width": VIEWPORT_W, "height": VIEWPORT_H})
            print(f"  [{i+1:03d}/{n}] {label[:60]} -> {out.name}")

        browser.close()


if __name__ == "__main__":
    main()
```

---

## Step 4 · Run capture

```bash
cd "$PROJECT_DIR"

# Start server
python3 -m http.server 8790 > /tmp/serv.log 2>&1 &
echo $! > /tmp/srv.pid
sleep 2

# Capture all slides
python3 _capture.py
```

You'll see one line per captured slide. Each slide takes ~1–2 seconds.

If a slide hangs > 10 seconds, kill the process — usually an animation set to `infinite` without explicit duration. See `troubleshooting.md` Bug 7.

---

## Step 5 · Merge PNG → PDF

```python
from PIL import Image
from pathlib import Path

PROJECT = Path("/path/to/project-name-deck")
shots = sorted((PROJECT / "_shots").glob("slide_*.png"))
pages = [Image.open(f).convert("RGB") for f in shots]
out = PROJECT / "Final-deck.pdf"

# resolution=288 → 13.33×7.5 inches for 1920×1080 (standard 16:9 slide)
# For 9:16 (1080×1920): keep resolution=288 → 3.75×6.67 inches
pages[0].save(
    out,
    save_all=True,
    append_images=pages[1:],
    format="PDF",
    resolution=288.0,
    title="Brand presentation",
    author="Brand Name",
)
print(f"PDF: {out} · {out.stat().st_size / (1024*1024):.1f} MB · {len(pages)} pages")
```

### DPI reference

| Viewport (px) | resolution= | PDF page size (inches) |
|---|---|---|
| 1920×1080 | 288.0 | 13.33 × 7.50 (16:9) |
| 1080×1920 | 288.0 | 3.75 × 6.67 (9:16) |
| 1920×1080 @ 2x | 288.0 | 13.33 × 7.50 (same size, 2x detail) |

Higher `resolution` = smaller physical page dimensions but more detail per inch. Default 288 is good balance.

---

## Step 6 · Visual verification (MANDATORY — overflow loop)

**This step is non-optional.** Do not deliver a slide deck without going through every slide and confirming no content is cut off at the 1920×1080 (or 1080×1920) frame edges.

The slide-level overflow is more subtle than longread overflow — slides have fixed frame dimensions, and content extending beyond gets simply clipped at the edge with no visual "page break" cue.

### 6.1 Render slides back as PNG for inspection

```bash
# The _shots/ folder already contains screenshots from capture — use those directly
ls "$PROJECT_DIR/_shots/" | wc -l   # count of slides

# OR render the final PDF back to PNG if you want to see exactly what user gets
pdftoppm -png -r 100 "$PROJECT_DIR/Final-deck.pdf" /tmp/verify
```

Prefer `_shots/` (raw screenshots) — they're already at full resolution.

### 6.2 Inspect EVERY slide with `Read`

For each `_shots/slide_NNN.png` — `Read` and check:

| Failure | What it looks like | Severity |
|---|---|---|
| **Right-edge text clipping** | Headline runs into right wall, last word cut | **CRITICAL — must fix** |
| **Bottom-edge content** | Last bullet/list item missing, footer cut | **CRITICAL — must fix** |
| **Off-frame elements** | Element positioned with negative margin extends past frame | **CRITICAL — must fix** |
| **Hidden corner counter** | `.corner-sm` slide number missing | Medium — check CSS |
| **Empty space on cover** | Lots of empty real estate, content tiny vs frame | Medium — could enlarge |
| **Wrong font** | System sans instead of brand display | **CRITICAL — fonts didn't load** |
| **Navigation overlay visible** | `< 1/24 Reset R >` pill at bottom | High — see troubleshooting Bug 7 |
| **Animation mid-frame** | Element half-faded-in (caught between states) | Medium — increase wait time |

DO NOT spot-check first/middle/last — read **every** slide.

### 6.3 Overflow-fix loop

If ANY slide shows edge-clipping:

1. **Identify slide N** — `_shots/slide_007.png` shows clipping → 7th `<section class="slide">` in HTML
2. **Open `deck.html`**, find the 7th slide section
3. **Apply ONE of these fixes** (in priority order):
   - **Reduce font size** on the offending element (e.g. headline 96px → 72px)
   - **Shorten the text** — rewrite for fewer words (slides should be terse anyway)
   - **Add column / split layout** — if too much content for vertical stack, use 2-column
   - **Change frame padding** — if margin is too aggressive, reduce it for this slide
   - **Split slide into two** — last resort, breaks slide numbering
4. **Re-capture** — run `python3 _capture.py` again (or modify it to re-capture only that slide)
5. **Read the new `_shots/slide_007.png`** — verify the fix
6. **If still clipping** — different fix. **Maximum 4 attempts per slide** — if not fixed, escalate with screenshot and ask user what to drop.

### 6.4 Re-merge PDF after all fixes

After every slide passes inspection, **re-run Step 5** to merge updated PNGs into the final PDF. Don't deliver an older PDF that doesn't reflect the fixes.

### 6.5 Pass criteria

Deck is ready to hand to user when ALL of these are true:

- [ ] Every slide rendered as PNG and read individually
- [ ] No right-edge text clipping on any slide
- [ ] No bottom-edge content clipping
- [ ] All `corner-sm` slide numbers visible (where present in source HTML)
- [ ] Brand display font loaded (not system sans)
- [ ] No navigation overlay artifacts
- [ ] Slide count matches `<section class="slide">` count in HTML
- [ ] Final PDF re-generated AFTER any fixes (not stale)

If ANY checkbox fails → loop back to 6.3. Do NOT proceed to Step 7 (clean up) with known clipping.

---

## Step 7 · Clean up

```bash
PID=$(cat /tmp/srv.pid) && kill $PID 2>/dev/null
rm -f /tmp/srv.pid /tmp/serv.log

# Optional: remove _shots/ if you don't need raw PNGs
# rm -rf "$PROJECT_DIR/_shots"
```

---

## When to keep `_shots/`

Keep PNGs if:
- User wants to post individual slides on social media
- You may regenerate the PDF with different DPI / page order
- Source HTML is complex and re-capturing takes minutes

Delete if:
- One-shot final delivery to user
- Disk space matters (typically 50-300 KB per slide × N slides)

---

## Format-specific recipes

### Instagram carousel (9:16)

```python
viewport = {"width": 1080, "height": 1920}
# in PIL: resolution=288.0 → 3.75 × 6.67 inches
# best uploaded as PNG to Instagram, not PDF
```

### Webinar deck (16:9)

```python
viewport = {"width": 1920, "height": 1080}
# resolution=288.0 → 13.33 × 7.5 inches (industry standard)
# can be uploaded to Google Slides as PDF and edited further
```

### Print-quality presentation (rare)

```python
viewport = {"width": 1920, "height": 1080}
device_scale_factor=3  # 3x for print
# resolution=432.0 in PIL → smaller page, much higher detail
```

For bugs — see `troubleshooting.md`. For component classes — see `component-library.md`.
