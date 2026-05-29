# Design System Reference Bundle — Stripe (Mock Example)

This is a pre-compiled **Design Factory** reference bundle for the **Stripe** brand. It serves as:
1.  **A live example** of what the `/create-design-system` skill automatically generates.
2.  **A local testbed** to instantly test the `/render-brand-pdf` skill or CLI `./df render` command without needing to run the website scrapers.

## Brand DNA & Style Choice

-   **Theme Choice:** Sleek Cyber Tech / Clean SaaS
-   **Display Typography:** `Space Grotesk` (Google Fonts) — distinctive, technical, bold, and geometric.
-   **Body Typography:** `Plus Jakarta Sans` (Google Fonts) — highly readable, elegant, and modern sans-serif.

### Core Color Palette

-   **Stripe Indigo (`--stripe-indigo`):** `#635bff` (Primary brand action color)
-   **Stripe Dark Slate (`--stripe-dark`):** `#0a2540` (Primary text and dark surfaces)
-   **Stripe Cyan (`--stripe-cyan`):** `#00d4ff` (Highlight neon color)
-   **Warm Light Background (`--stripe-bg-light`):** `#f6f9fc` (Slightly blue-tinted neutral surface)

---

## How to Test Render PDF/Slides

To test the PDF engine using this mock design system, run the following CLI command from the repository root:

```bash
# Renders widescreen presentation slides using this brand's theme
./df render stripe examples/mock-slides.md --format slides --template swiss
```

*Note: On Windows, use `node df` instead of `./df`.*
