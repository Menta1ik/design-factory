# DESIGN FACTORY · AI AGENT RULES

This project uses the Design Factory system for advanced, high-fidelity AI-assisted UI/UX engineering.

## ⛔ CRITICAL RULE: FENCE AGAINST "AI SLOP"
Do not generate generic, cookie-cutter artificial interfaces. Follow these constraints:
1. **NO SaaS Blue-to-Purple-to-Pink Glows:** Do not inject neon radial glowing gradient backgrounds unless specifically present in the brand materials.
2. **NO Arial/Inter Defaults:** Never default to generic Arial or Inter fonts for display/headline typography. Use distinctive, characterful typography pairings.
3. **NO Rounded Border-Left Alert Cards:** Avoid the standard LLM card aesthetic (`.rounded-lg` with `border-l-4 border-indigo-500`).
4. **NO Hand-drawn SVGs:** Use clean CDN libraries (Lucide, Heroicons) or exact vector values from source. Never code "approximate" shapes.

## 🎨 10 PREMIUM VISUAL STYLES
When editing CSS or HTML templates, align with one of these visual themes:
- **Neubrutalism:** Solid thick borders (`2px solid #000`), hard flat primary colors (`#FFF`, `#FACC15`), offset shadows (`box-shadow: 4px 4px 0px #000`), zero gradients.
- **Glassmorphism:** Semi-transparent backdrops (`rgba(255,255,255,0.05)`), thick blur filters (`backdrop-filter: blur(12px)`), glowing accents.
- **Bento Grid:** Asymmetrical multi-span layouts (`col-span-2`, `row-span-2`), uniform spacing (`24px`), generous rounded corners (`16-24px`).
- **Warm Editorial:** Cream paper backgrounds (`#FAF9F6`), high-contrast elegant serif headings, light grey hairline borders, spacious margins.
- **Sleek Cyber Tech:** True dark backgrounds (`#090E17`), razor-thin borders, sharp neon coordinates, monospaced labels.

## 🔤 SIGNATURE GOOGLE FONTS PAIRINGS
Select distinctive font pairs based on brand personality:
- **Luxury / Wellness:** Cormorant Garamond + Montserrat / Fraunces + Plus Jakarta Sans
- **SaaS / Technology:** Space Grotesk + Plus Jakarta Sans / Outfit + JetBrains Mono
- **Editorial / News:** DM Serif Display + DM Sans / Newsreader + Plus Jakarta Sans
- **Utilitarian / Modern:** Archivo Black + Archivo / Space Mono + Space Grotesk

## 🛠️ CLI TOOL INTEGRATIONS
Always use these tools instead of manually parsing or editing:
- Run `./df extract <URL>` to scrape raw brand styles.
- Run `./df make-ds <brand>` to configure folders.
- Use `/render-brand-pdf` to compile high-fidelity presentations.
