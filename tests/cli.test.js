const test = require('node:test');
const assert = require('node:assert');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const repoRoot = path.join(__dirname, '..');
const dfPath = path.join(repoRoot, 'df');

test('CLI version command output', () => {
  const output = execSync(`node "${dfPath}" version`, { encoding: 'utf8' }).trim();
  assert.strictEqual(output, 'v1.0.0');
});

test('CLI help command contains expected commands', () => {
  const output = execSync(`node "${dfPath}" help`, { encoding: 'utf8' });
  assert.match(output, /DESIGN FACTORY CLI/);
  assert.match(output, /Commands:/);
  assert.match(output, /install/);
  assert.match(output, /extract/);
  assert.match(output, /compile/);
});

test('CLI compile command generates rule files', () => {
  // Ensure fresh run
  const files = ['.cursorrules', '.clinerules', '.windsurfrules', 'instructions.md'];
  files.forEach(f => {
    const filePath = path.join(repoRoot, f);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  });

  // Run compile
  execSync(`node "${dfPath}" compile`, { cwd: repoRoot });
  
  // Verify files exist
  files.forEach(f => {
    const filePath = path.join(repoRoot, f);
    assert.ok(fs.existsSync(filePath), `File ${f} should be created by compile command.`);
  });
});
