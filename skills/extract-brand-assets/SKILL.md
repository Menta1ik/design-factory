---
name: extract-brand-assets
description: Extracts raw design tokens, assets, and offline copies from any brand URL using monolith, wget, and designlang. Prepares structured folders in source-raw/ for create-design-system.
when_to_use: User provides a brand URL and asks to download, scrape, extract, or mirror its assets, code, tokens, or styling, or explicitly invokes /extract-brand-assets.
allowed-tools: Read Write Edit Bash Grep Glob WebFetch
---

## 🎯 Назначение навыка

Этот навык автоматизирует сбор «сырья» (raw assets) с любого указанного веб-сайта бренда. Он запускает параллельный сбор тремя специализированными инструментами для получения всестороннего слеза данных, структурирует вывод в папку `source-raw/` и готовит почву для запуска следующего этапа — `/create-design-system`.

## 🛠️ Предварительные требования (Prerequisites)

Перед запуском убедитесь, что в системе установлены:
- `monolith` (через brew)
- `wget` (через brew)
- `node` и `playwright` (для работы designlang)

## 📋 Процедура выполнения

### Шаг 0 · Парсинг URL и подготовка
1. Извлеки URL бренда из запроса пользователя. Если URL не указан или невалиден — спроси пользователя и не начинай сбор.
2. Создай слаг бренда (kebab-case без `www.`, `http://`, `https://` и доменной зоны):
   - `https://stripe.com` → `stripe`
   - `https://linear.app` → `linear`
3. Создай структурированную директорию в текущей папке:
   ```bash
   mkdir -p source-raw/{monolith,mirror,designlang}
   ```

### Шаг 1 · Прогрев Chromium (Pre-warm)
Инструмент `designlang` под капотом использует Playwright. Чтобы первый запуск на холодном Chromium не упал по таймауту, проверь или установи Chromium:
```bash
npx -y playwright install chromium 2>&1 | tail -3 || true
```

### Шаг 2 · Параллельный сбор данных

Запусти три процесса параллельно (или последовательно, если параллельный запуск недоступен):

#### 2a · monolith — создание единого оффлайн-архива
Скачивает сайт в один self-contained HTML-файл (все стили, скрипты и картинки встраиваются в base64):
```bash
monolith "[URL]" -o "source-raw/monolith/site.html" --timeout 120
```
*Если упало — зафиксируй ошибку и продолжай.*

#### 2b · wget --mirror — структурированное зеркало сайта
Скачивает страницы и ассеты с сохранением иерархии папок:
```bash
wget --mirror --convert-links --adjust-extension --page-requisites \
     --no-parent --restrict-file-names=windows --level=1 \
     --timeout=30 --tries=2 \
     -P source-raw/mirror/ "[URL]"
```
*Если блокируетсяrobots.txt или выдает 403 — отметь как «wget: частично» и продолжай.*

#### 2c · designlang — извлечение токенов и PDF-брендбука
Самый важный инструмент для сбора дизайн-токенов. Выполняй запуск:
```bash
npx -y designlang "[URL]" --full --pdf --platforms all --out source-raw/designlang/
```
**Обработка таймаутов `designlang`:**
Если падает с ошибкой `Timeout exceeded` на стадии загрузки DOM:
- Не меняй юзер-агент и не переключайся на другие страницы.
- Просто запусти команду повторно (на прогретом Chromium она сработает):
```bash
npx -y designlang "[URL]" --full --pdf --platforms all --out source-raw/designlang/
```
- Если упало повторно — запусти облегченную версию без `--platforms all` (только PDF и базовые токены):
```bash
npx -y designlang "[URL]" --pdf --out source-raw/designlang/
```

### Шаг 3 · Финальный анализ и отчет

1. Проверь размеры и количество собранных файлов:
   ```bash
   du -sh source-raw/*
   echo "monolith: $(find source-raw/monolith -type f | wc -l) files"
   echo "mirror: $(find source-raw/mirror -type f | wc -l) files"
   echo "designlang: $(find source-raw/designlang -type f | wc -l) files"
   ```

2. Выдай пользователю структурированный отчет на **русском языке** строго в следующем формате:

```
✓ Сбор сырья завершен!

Результаты сбора:
  monolith     [✓ / ✗ / частично]  [размер], [N] файлов
  wget mirror  [✓ / ✗ / частично]  [размер], [N] файлов
  designlang   [✓ / ✗ / частично]  [размер], [N] файлов

Всего занято на диске: [X] МБ

Что делать дальше:
  Я успешно собрал сырые ассеты бренда. Чтобы превратить их в полноценную дизайн-систему, запустите команду:

    /create-design-system

  Скилл автоматически проанализирует собранные файлы в source-raw/ и построит дизайн-систему в отдельной подпапке.
```

**ВАЖНО:** Не пытайся запускать `/create-design-system` автоматически или генерировать токены в рамках этого навыка. Твоя единственная задача — качественный сбор сырья.
