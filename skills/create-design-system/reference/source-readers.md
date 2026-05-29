# Source Readers — правила чтения сырья

> Этот файл описывает **как читать вывод инструментов** (`designlang`, `monolith`, `wget`, ZIP-бандлы Claude Design, codebase-папки).
> Цель: знать какие файлы читать всегда, какие по условию, какие игнорировать — независимо от того, какой это сайт.

---

## ⚠️ Универсальные правила

1. **Не доверяй именам файлов вслепую** — `designlang` префиксует все файлы slug'ом домена (`stripe-com-*`, `linear-app-*`, `notion-so-*`). Используй glob-паттерны типа `*-design-tokens.json`, а не точные имена.
2. **Размеры файлов и количество варьируются от сайта.** Простой лендинг даст монолит ~2 МБ и mirror на 5 страниц. Тяжёлый продуктовый сайт типа Stripe — монолит 87 МБ и mirror на 180 страниц. Скилл должен работать с обоими.
3. **Designlang выгружает примерно 50-90 файлов** (зависит от флагов `--full --platforms all` и от того, что нашёл на сайте). Из них критичны 4-7 файлов, остальные — дубли в других форматах или для других платформ.
4. **Проверяй на crash перед чтением.** Для любого `*.json` сначала смотри есть ли поля `error`, `unknown`, или нулевые данные — designlang иногда сохраняет неудачные extractions.

---

## Обнаружение типа источника

В Шаге 2 (Source intake) сначала определи тип источника. Запусти эти проверки **по порядку** — приоритет от высокого к низкому:

```bash
# F1 — designlang output (highest priority — самый информативный источник)
ls source-raw/designlang/ 2>/dev/null
find . -maxdepth 3 -name "*-design-language.md" 2>/dev/null | head -1
find . -maxdepth 3 -name "*-design-tokens.json" 2>/dev/null | head -1

# F2 — monolith archive (fallback)
ls source-raw/monolith/*.html 2>/dev/null

# F3 — wget mirror (fallback)
ls source-raw/mirror/*/ 2>/dev/null | head -1

# G — pre-built Claude Design bundle
ls colors_and_type.css cards.json design-system-viewer.html 2>/dev/null

# B — codebase
ls package.json tailwind.config.* 2>/dev/null
```

| Признак | Тип источника | Что обычно есть |
|---|---|---|
| `source-raw/designlang/` exists | **designlang output** | 50-90 файлов в разных форматах |
| `source-raw/monolith/*.html` (1 файл) | **monolith archive** | 1 HTML с inline base64 |
| `source-raw/mirror/<domain>/` (>1 HTML) | **wget mirror** | N HTML-страниц одного домена |
| `colors_and_type.css` + `preview/` + `cards.json` | **Claude Design bundle** | Готовая DS |
| `package.json` + `src/components/` | **codebase** | Lovable / Next.js app |

**Часто папка содержит несколько источников** (`source-raw/{designlang,monolith,mirror}/`). Тогда **читать в порядке приоритета: designlang → codebase → monolith (только grep) → mirror (только grep) → готовый bundle**.

---

## A. designlang output — детальные правила

Префикс файлов = `<slug>-` где `slug` производный от URL. Например `stripe-com-`, `linear-app-`, `notion-so-`, `iman-gadzhi-com-`. В правилах ниже используется паттерн `*-` чтобы было универсально.

### A.1 · MUST-READ (всегда, ~5 файлов)

Эти файлы дают всё необходимое для качественной DS. Суммарный объём для чтения обычно **80-120 КБ**:

| Файл (glob) | Типичный размер | Что внутри | Зачем |
|---|---|---|---|
| `*-DESIGN.md` | 3-5 КБ | 1-страничная сводка с YAML front-matter: colors, fonts, spacing, radii, shadows, headings, do/don't | **Читать первым** как введение в бренд |
| `*-design-tokens.json` | 4-10 КБ | DTCG-токены: primitive + semantic, structured tree | Канонический источник токенов для `colors_and_type.css` |
| `*-voice.json` | 2-4 КБ | Tone of voice, pronoun stance, heading style, CTA verbs, sample headings | Для генерации реальных preview-копий (не lorem!) |
| `*-design-language.md` | 30-100+ КБ | Глубокая референсная книга: цвета с HSL+usage, градиенты, raw CSS vars от сайта, component CSS с instance counts | Главный источник для component recipes + полная палитра. **Может быть длинным — читай с offset/limit** |
| `*-gradients.css` | 2-15 КБ | Именованные градиенты с готовыми утилитами `.grad-N` / `.grad-text-N` | Drop-in CSS. Если в бренде нет значимых градиентов — файл будет маленьким или пустым |

**Reading order:**
1. `*-DESIGN.md` (warm-up, понять бренд за 4 КБ)
2. `*-design-tokens.json` (структурированные токены → `colors_and_type.css`)
3. `*-voice.json` (для preview-копий)
4. `*-design-language.md` (для component recipes + raw vars; **с offset/limit если >50 КБ**)
5. `*-gradients.css` (если файл > 2 КБ — значит градиенты в бренде есть)

### A.2 · CONDITIONAL (читать только при условии)

| Файл (glob) | Когда читать |
|---|---|
| `*-AGENT.md` | Если нужны enforcement-правила (no-invent-hex, snap-to-scale). Иначе паря­фразируй из `*-DESIGN.md` + `*-voice.json` |
| `*-anatomy.tsx` | Если генерируешь `ui_kits/react/` с типизированными компонентами. Variant unions — source of truth для buttons/cards |
| `*-screenshots.json` + `screenshots/button-*.png`, `card-*.png`, `other-*.png` (НЕ `full-page.png`!) | Если создаёшь визуальные preview-карточки. Маппит PNG → компонент-вариант. **Размер PNG-папки сильно варьируется** (от нескольких файлов до десятков) |
| `*-motion-tokens.json` | Если в бренде значимая motion-секция. Проверь размер — пустой файл значит motion не извлёкся, не читай |
| `*-tailwind-v4.css` | Если пользователь явно попросил Tailwind v4 ui_kit. Иначе дубль `*-design-tokens.json` |
| `*-reset.css` | Если в DS-бандле нужен `reset.css` файл. Иначе достаточно паря­фразировать в `colors_and_type.css` |
| `*-logo.svg` + `*-logo.json` | Если нужен бренд-лого в `assets/` или в hero/nav previews. **Проверь что .svg не пустой** — designlang иногда не находит логотип |
| `*.brand.pdf` | Если пользователь попросил визуальный sanity-check или хочет следовать chapter-структуре оригинала. Большой файл (~200-700 КБ), читать только при явном запросе |
| `*.brand.html` | Если создаёшь `design-system-viewer.html` и хочешь референс на chapter layout / TOC |

### A.3 · IGNORE (никогда не читать)

#### A.3.1 Дубли токенов в альтернативных форматах
Эти файлы содержат **те же** токены что `*-design-tokens.json`, но в формате для других экосистем:

- `*-variables.css` — top строк дубль DTCG, остальное — raw HDS-vars (уже есть в `*-design-language.md`)
- `*-tailwind.config.js` — Tailwind v3 (заменён v4)
- `*-theme.js` — Chakra/Stitches/MUI shape
- `*-tokens.d.ts` — TS типы без данных
- `*-shadcn-theme.css` — крошечный shadcn-блок
- `*-figma-variables.json` — для Figma-плагинов
- `*-gradients.json` — JSON-форма `*-gradients.css` для code-gen

#### A.3.2 Другие платформы (не HTML/CSS)

Эти подпапки или файлы целиком игнорируй — они для генерации кода под другие платформы:

- `ios/DesignTokens.swift` — iOS only
- `flutter/design_tokens.dart` — Flutter only
- `android/*` (`Theme.kt`, `colors.xml`, `dimens.xml`) — Android only
- `wordpress-theme/*` (`functions.php`, `index.php`, `style.css`, `theme.json`, `templates/`) — WordPress only
- `*-wordpress-theme.json` — дубль WP theme.json

#### A.3.3 Мета-файлы для других агентов

Designlang создаёт 4 файла-промпта для разных AI-инструментов. **Все четыре содержат идентичный ~40-строчный промпт** с разным заголовком. Читать **только один** (`*-AGENT.md` — самый информативный) или **ни одного**:

- `agents.md`
- `CLAUDE.md.fragment`
- `.cursor/rules/designlang.mdc`
- `.claude/skills/designlang/SKILL.md`

#### A.3.4 Сломанные / неудавшиеся extractions

Designlang иногда выдаёт мусор — этого не читать:

- `*-prompts/cursor.md`, `*-prompts/claude-artifacts.md`, `*-prompts/lovable.txt`, `*-prompts/v0.txt` — часто содержат `[object Object]` placeholder-баги
- `*-prompts/recipe-*.md` — часто `[object Object]` + degenerate CSS (`padding: 0px` для компонентов которые явно имеют padding)
- `*-multipage.json` — может содержать `{"error": "..."}` при crash
- `*-icon-system.json` — часто `library: "unknown", confidence: 0` если иконки proprietary
- `*-library.json` — часто `library: "unknown"`
- `*-stack-intel.json` — часто `cms: [], analytics: []` если ничего не задетектилось
- `*-form-states.json` — если на странице нет форм, всё нулями

**Защитное правило:** для любого `.json` сначала `cat | head -10` или `Read offset=1 limit=10` — проверь нет ли `error` / `"unknown"` / нулевых полей. Если есть — пропускай молча, не используй данные.

#### A.3.5 Не релевантно для DS-скилла

- `*-preview.html` — собственный dashboard designlang, не брендирован
- `*-intent.json` — page-section roles с bounding boxes (для recreate layout, не для DS)
- `*-perf.json` — Web Vitals (не DS)
- `*-seo.json` — OG/Twitter/favicon URLs (не DS)
- `*-responsive.json` — индекс на `screenshots/responsive/` (которые тоже игнор)
- `*-visual-dna.json` — 2-3 факта уже в `*-DESIGN.md`
- `*-mcp.json` — крупный дамп (10-100+ КБ) для MCP-pipeline, дубль других данных
- `screenshots/full-page.png` — большой (3-15+ МБ), не нужен для DS bundle
- `screenshots/responsive/*.png` — full-page mobile/tablet/desktop captures, размер десятки МБ, не нужны
- `screenshots/button.png`, `screenshots/card.png`, `screenshots/nav.png` (без числового суффикса) — v0-scratch outputs, использовать только нумерованные файлы (`button-default-*`, `card-default-*`)
- `.DS_Store` файлы (macOS metadata)

---

## B. monolith — fallback на детали

`monolith` даёт один HTML-файл со всем встроенным (CSS, JS, картинки base64). Размер 1-100+ МБ (зависит от сайта).

### Когда читать
**Только когда designlang не дал ответа на конкретный вопрос.** Например:
- Нужен точный текст hero-заголовка (designlang цитирует только sample)
- Нужен base64-PNG для логотипа (если `*-logo.svg` пустой)
- Нужно проверить специфичную inline-стилизацию компонента которая не попала в extraction
- Нужен оригинальный favicon (если в `*-seo.json` только URL)

### Как читать
**НЕ читай весь файл через Read — может быть до 100 МБ и убьёт контекст.** Используй grep / поиск:

```bash
# Hero-заголовок
grep -oE '<h1[^>]*>[^<]+' source-raw/monolith/*.html | head -3

# Цвета конкретного класса (примеры паттернов)
grep -A1 'class="btn-primary"' source-raw/monolith/*.html | head -20
grep -B1 -A3 'hero' source-raw/monolith/*.html | head -30

# Base64 логотипа
grep -oE 'data:image/[^"]{50,200}' source-raw/monolith/*.html | head -5

# Inline CSS-переменные
grep -oE '\-\-[a-z][a-z-]+:\s*[^;}]+' source-raw/monolith/*.html | sort -u | head -50
```

Никогда не делай `Read source-raw/monolith/file.html` без offset/limit.

---

## C. wget mirror — fallback на под-страницы

`wget --mirror` даёт папку с N HTML-страницами разных URL домена (`/atlas.html`, `/connect.html`, `/billing.html` etc). Количество страниц зависит от сайта и `--level` флага (от 5 до 500+).

### Когда читать
**Только если нужна вариативность контента/компонентов между страницами:**
- Hero паттерны на разных страницах для разнообразия UI Kit
- Разные тоны voice на product vs pricing vs about
- SEO-варианты заголовков

### Как читать
**Прочитай 3-5 ключевых страниц через grep, не весь mirror:**

```bash
# Список ключевых страниц (по типичным именам)
ls source-raw/mirror/*/ | grep -iE '(index|home|pricing|about|product|customers|features|how-it-works|signup|contact)\.html'

# Hero на конкретной странице
grep -oE '<h1[^>]*>[^<]+' source-raw/mirror/*/pricing.html 2>/dev/null | head -3
```

### Когда НЕ читать
- Если все 100+ страниц это локали одного сайта (`en-de.html`, `de-de.html`, `es.html` — переводы, не варианты) — берёшь только `index.html`
- Если designlang уже извлёк все нужные паттерны
- Никогда не читай больше 5 файлов из mirror без явной причины

---

## D. Claude Design ZIP-бандл

Если источник — это **уже готовая DS** (наш собственный или экспорт из Claude Design web-app), правила другие:

- `SKILL.md` — читай первым (бренд + правила)
- `README.md` — читай вторым (brand book)
- `colors_and_type.css` — токены готовы, можно копировать или адаптировать
- `cards.json` — список preview карточек
- `preview/*.html` — каждая spec-карточка (по запросу, не все сразу)
- `ui_kits/*/index.html` + `styles.css` — готовый layout
- `SESSION.md` — лог сессии с substitutions

В этом случае ты **расширяешь / адаптируешь** существующую DS, а не создаёшь с нуля.

---

## E. Codebase (Lovable / Next.js / React app)

Если источник — это **код реального приложения**, читай в порядке:

1. `package.json` — фреймворк (Next.js / Remix / Vite), UI-библиотеки (shadcn / Radix / Chakra)
2. `tailwind.config.{js,ts}` или `tailwind.config.css` (v4) — токены
3. `app/globals.css` / `src/index.css` / `app/layout.tsx` — глобальные стили
4. `src/components/ui/*` — компонентная база (если shadcn)
5. `src/app/*/page.tsx` или `pages/*` — реальные секции с реальным контентом

Если в проекте Tailwind+shadcn — следуй процедуре «Tailwind → flat CSS» из `templates.md §1.1`.

---

## F. Общие правила

### F.1 Никогда не читай слепо
Не делай `Read` на 87 МБ файл. Не делай `Read directory_listing` без понимания структуры. Сначала `ls -la` и `du -sh` → понимание → точечный `Read`.

### F.2 Дубли — выбирай один
Если две колонки таблицы выше говорят «одно и то же в разных форматах» — выбирай тот что в **MUST-READ**. Не путай контекст параллельной информацией.

### F.3 Проверяй на crash
Любой `.json` сначала проверь на наличие полей `error`, `unknown`, нулевых данных. Если есть — это failed extraction, пропускай молча.

### F.4 Fallback chain
Стандартный путь: **designlang → monolith (только grep) → wget mirror (только grep)**. Не читай monolith/mirror пока designlang не сказал «нет».

### F.5 Документируй что взял
В `SESSION.md` (Шаг 2) фиксируй явно, сколько файлов прочитал и сколько пропустил:

```
## Sources read

### designlang output (типовая выгрузка ~50-90 файлов)
Прочитано (MUST-READ, N файлов, ~Y КБ):
  - source-raw/designlang/<brand>-DESIGN.md
  - source-raw/designlang/<brand>-design-tokens.json
  - source-raw/designlang/<brand>-voice.json
  - source-raw/designlang/<brand>-design-language.md (offset/limit для больших)
  - source-raw/designlang/<brand>-gradients.css

Прочитано условно:
  - source-raw/designlang/<brand>-motion-tokens.json (бренд имеет signature motion)
  - source-raw/designlang/screenshots/button-*.png (N PNG для preview)

Игнорировано (per source-readers.md §A.3): остальные ~M файлов
  - ios/, android/, flutter/, wordpress-theme/ (другие платформы)
  - *-figma-variables.json, *-tailwind.config.js, *-theme.js (дубли токенов)
  - agents.md, CLAUDE.md.fragment, .cursor/, .claude/ (дубли мета-промптов)
  - *-mcp.json, *-preview.html (не релевантно)

### monolith
  - source-raw/monolith/site-monolith.html (grep only, N запросов)

### wget mirror
  - source-raw/mirror/<domain>/ (grep only, прочитано N страниц из M)
```

Это нужно для прозрачности — будущий пользователь увидит откуда что взялось.

### F.6 Размеры — всегда диапазоны, никогда «точно столько-то»
Если упоминаешь размеры файлов или количество файлов — давай **диапазон** («2-15 КБ», «30-100+ КБ», «50-90 файлов»). Конкретные числа верны только для конкретного сайта.
