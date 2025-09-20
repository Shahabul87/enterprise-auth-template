#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('🔧 Fixing import syntax errors in test files...\n');

// Get all test files
const testFiles = execSync('find src/__tests__ -name "*.test.ts*" -type f', {
  cwd: __dirname,
  encoding: 'utf8'
}).trim().split('\n');

let fixedCount = 0;

testFiles.forEach(file => {
  const fullPath = path.join(__dirname, file);
  if (!fs.existsSync(fullPath)) return;

  let content = fs.readFileSync(fullPath, 'utf8');
  let modified = false;

  // Pattern 1: Fix broken imports missing "import {"
  const brokenImportPattern = /\n\s*([\w,\s]+)\}\s*from\s*['"][@\/\w-]+['"]/g;
  const matches = content.matchAll(brokenImportPattern);

  for (const match of matches) {
    const fullMatch = match[0];
    // Check if this is not already a proper import
    if (!fullMatch.includes('import') && !fullMatch.includes('export')) {
      const fixed = '\nimport {' + fullMatch.substring(1);
      content = content.replace(fullMatch, fixed);
      modified = true;
      console.log(`Fixed import in ${path.basename(file)}: "${fullMatch.trim().substring(0, 30)}..."`);
    }
  }

  // Pattern 2: Fix imports that are split incorrectly
  // Like: \n  usePasswordStrength,\n  getStrengthColor,\n} from '@/hooks/use-password-strength';
  const splitImportPattern = /\n\s*(\w+),[\s\S]*?\}\s*from\s*['"][@\/\w-]+['"]/g;
  const splitMatches = content.matchAll(splitImportPattern);

  for (const match of splitMatches) {
    const fullMatch = match[0];
    // Check if this doesn't have "import" before it
    const startIndex = match.index;
    const beforeText = content.substring(Math.max(0, startIndex - 20), startIndex);

    if (!beforeText.includes('import') && !beforeText.includes('export') && !beforeText.includes('{')) {
      const fixed = '\nimport {' + fullMatch.substring(1);
      content = content.replace(fullMatch, fixed);
      modified = true;
      console.log(`Fixed split import in ${path.basename(file)}`);
    }
  }

  // Pattern 3: Fix duplicate closing braces
  content = content.replace(/\}\}\}\)\)\);/g, '});');
  content = content.replace(/\}\}\}\)\);/g, '});');
  content = content.replace(/\}\}\);/g, '});');

  // Pattern 4: Fix act() calls with incorrect syntax
  content = content.replace(/act\(\(\) => \{ fireEvent\.([^}]+)\) \}\)/g, 'act(() => { fireEvent.$1) })');
  content = content.replace(/await act\(async \(\) => \{ await userEvent\.([^}]+) \}\)/g, 'await act(async () => { await userEvent.$1 })');

  if (modified) {
    fs.writeFileSync(fullPath, content, 'utf8');
    fixedCount++;
  }
});

// Now specifically fix the use-password-strength.test.ts file
const passwordTestFile = path.join(__dirname, 'src/__tests__/hooks/use-password-strength.test.ts');
if (fs.existsSync(passwordTestFile)) {
  let content = fs.readFileSync(passwordTestFile, 'utf8');

  // Find the broken import and fix it
  const importStart = content.indexOf('usePasswordStrength,');
  if (importStart > -1 && !content.substring(importStart - 20, importStart).includes('import {')) {
    // Find the start of this import statement
    const lineStart = content.lastIndexOf('\n', importStart);
    const importEnd = content.indexOf("from '@/hooks/use-password-strength';", importStart);

    if (importEnd > -1) {
      const endOfImport = content.indexOf(';', importEnd) + 1;
      const importContent = content.substring(lineStart + 1, endOfImport);

      const fixedImport = `import {
  usePasswordStrength,
  getStrengthColor,
  getStrengthBarColor,
  getStrengthLabel,
} from '@/hooks/use-password-strength';`;

      content = content.substring(0, lineStart + 1) + fixedImport + content.substring(endOfImport);
      fs.writeFileSync(passwordTestFile, content, 'utf8');
      console.log('✓ Fixed use-password-strength.test.ts import');
      fixedCount++;
    }
  }
}

console.log(`\n✅ Fixed ${fixedCount} files with import syntax errors`);