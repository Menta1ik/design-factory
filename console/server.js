#!/usr/bin/env node

/**
 * Design Factory Console Backend Server
 * Written in pure Node.js (http module) to ensure ZERO external dependencies.
 * Launches on http://localhost:8080 and communicates with the CLI.
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const PORT = 8080;
const repoRoot = path.join(__dirname, '..');

// MIME types lookup
const MIME_TYPES = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.woff2': 'font/woff2'
};

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const pathname = url.pathname;

  // ----------------------------------------------------------------
  // 0. API: List Available Brands
  // ----------------------------------------------------------------
  if (pathname === '/api/brands') {
    try {
      const items = fs.readdirSync(repoRoot);
      const brands = items.filter(name => {
        const fullPath = path.join(repoRoot, name);
        return name.endsWith('-design-system') && fs.statSync(fullPath).isDirectory();
      }).map(name => name.replace('-design-system', ''));
      
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(brands));
    } catch (err) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
    }
    return;
  }

  // ----------------------------------------------------------------
  // 1. API: Extract Brand Assets (Server-Sent Events stream for real-time logs)
  // ----------------------------------------------------------------
  if (pathname === '/api/extract') {
    const targetUrl = url.searchParams.get('url');
    if (!targetUrl) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'URL parameter is required.' }));
      return;
    }

    // Set headers for Event Stream
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Access-Control-Allow-Origin': '*'
    });

    res.write(`data: [SYSTEM] Starting brand extraction for: ${targetUrl}\n\n`);

    // Create brand slug locally
    let slug = targetUrl
      .replace(/^https?:\/\//i, '')
      .replace(/^www\./i, '')
      .split('/')[0]
      .replace(/\.[a-z]{2,}$/i, '')
      .toLowerCase()
      .replace(/[^a-z0-9]/g, '-');

    // Spawn the df CLI process
    const dfProcess = spawn('node', [path.join(repoRoot, 'df'), 'extract', targetUrl], { cwd: repoRoot });

    dfProcess.stdout.on('data', (data) => {
      const lines = data.toString().split('\n');
      lines.forEach(line => {
        if (line.trim()) {
          res.write(`data: ${line}\n\n`);
        }
      });
    });

    dfProcess.stderr.on('data', (data) => {
      res.write(`data: [ERROR] ${data.toString()}\n\n`);
    });

    dfProcess.on('close', (code) => {
      res.write(`data: [SYSTEM] Extraction process finished with code: ${code}\n\n`);
      res.write(`data: [DONE] ${slug}\n\n`);
      res.end();
    });
    return;
  }

  // ----------------------------------------------------------------
  // 2. API: Make Design System Structure
  // ----------------------------------------------------------------
  if (pathname === '/api/make-ds') {
    const brand = url.searchParams.get('brand');
    if (!brand) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Brand parameter is required.' }));
      return;
    }

    try {
      const dfProcess = spawn('node', [path.join(repoRoot, 'df'), 'make-ds', brand], { cwd: repoRoot });
      dfProcess.on('close', (code) => {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, code }));
      });
    } catch (err) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
    }
    return;
  }

  // ----------------------------------------------------------------
  // 3. API: Load Tokens (CSS & JSON cards)
  // ----------------------------------------------------------------
  if (pathname === '/api/tokens') {
    const brand = url.searchParams.get('brand');
    if (!brand) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Brand parameter is required.' }));
      return;
    }

    const dsDir = path.join(repoRoot, `${brand}-design-system`);
    const cssPath = path.join(dsDir, 'colors_and_type.css');
    const jsonPath = path.join(dsDir, 'cards.json');

    if (!fs.existsSync(cssPath)) {
      res.writeHead(404, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: `Design system not found for brand: ${brand}. Please generate it first.` }));
      return;
    }

    const cssContent = fs.readFileSync(cssPath, 'utf8');
    const jsonContent = fs.existsSync(jsonPath) ? JSON.parse(fs.readFileSync(jsonPath, 'utf8')) : { cards: [] };

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ css: cssContent, json: jsonContent }));
    return;
  }

  // ----------------------------------------------------------------
  // 4. API: Save Tokens (Write modified CSS/JSON back to file)
  // ----------------------------------------------------------------
  if (pathname === '/api/save-tokens' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });

    req.on('end', () => {
      try {
        const payload = JSON.parse(body);
        const { brand, css, json } = payload;

        if (!brand) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Brand parameter is required.' }));
          return;
        }

        const dsDir = path.join(repoRoot, `${brand}-design-system`);
        const cssPath = path.join(dsDir, 'colors_and_type.css');
        const jsonPath = path.join(dsDir, 'cards.json');

        if (css) {
          fs.writeFileSync(cssPath, css, 'utf8');
        }
        if (json) {
          fs.writeFileSync(jsonPath, JSON.stringify(json, null, 2), 'utf8');
        }

        // Trigger IDE rules recompile automatically upon save to keep them in sync
        const dfPath = path.join(repoRoot, 'df');
        spawn('node', [dfPath, 'compile'], { cwd: repoRoot });

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true }));
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // ----------------------------------------------------------------
  // 5. Static Files Server (Serves the frontend dashboard from console/public/)
  // ----------------------------------------------------------------
  let filePath = path.join(__dirname, 'public', pathname === '/' ? 'index.html' : pathname);
  
  // Security check to prevent traversing outside public folder
  if (!filePath.startsWith(path.join(__dirname, 'public'))) {
    res.writeHead(403, { 'Content-Type': 'text/plain' });
    res.end('Forbidden');
    return;
  }

  const ext = path.extname(filePath);
  const mimeType = MIME_TYPES[ext] || 'text/plain';

  fs.access(filePath, fs.constants.F_OK, (err) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('File Not Found');
      return;
    }

    fs.readFile(filePath, (error, content) => {
      if (error) {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end(`Server Error: ${error.code}`);
      } else {
        res.writeHead(200, { 'Content-Type': mimeType });
        res.end(content);
      }
    });
  });
});

server.listen(PORT, () => {
  console.log(`\n===============================================`);
  console.log(`📡 Design Factory Console: http://localhost:${PORT}`);
  console.log(`===============================================\n`);
});
