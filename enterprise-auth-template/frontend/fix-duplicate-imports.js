#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('🔧 Fixing duplicate import statements in test files...\n');

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

  // Fix duplicate "import {" statements
  content = content.replace(/import \{\s*import \{/g, 'import {');
  if (content.includes('import {\nimport {')) {
    content = content.replace(/import \{\nimport \{/g, 'import {');
    modified = true;
  }

  // Fix any remaining syntax issues
  content = content.replace(/\}\}\}\)\)\);/g, '});');
  content = content.replace(/\}\}\}\)\);/g, '});');

  // Fix broken act() calls
  content = content.replace(/act\(\(\) => \{ fireEvent\.([^)]+)\) \}\)/g, 'act(() => { fireEvent.$1) })');

  if (modified || content.includes('import {\nimport {')) {
    fs.writeFileSync(fullPath, content, 'utf8');
    fixedCount++;
    console.log(`Fixed ${path.basename(file)}`);
  }
});

// Specifically fix known problematic files
const filesToFix = [
  'src/__tests__/hooks/use-debounce-comprehensive.test.ts',
  'src/__tests__/hooks/use-password-strength.test.ts',
  'src/__tests__/components/ui/card.test.tsx',
  'src/__tests__/components/ui/dialog.test.tsx',
  'src/__tests__/lib/validation.test.ts'
];

filesToFix.forEach(file => {
  const fullPath = path.join(__dirname, file);
  if (!fs.existsSync(fullPath)) return;

  let content = fs.readFileSync(fullPath, 'utf8');

  // For use-debounce-comprehensive.test.ts
  if (file.includes('use-debounce-comprehensive')) {
    content = content.replace('import {\nimport {', 'import {');
    content = content.replace(/import \{[\s\S]*?useDebounce,/, 'import {\n  useDebounce,');
  }

  // For use-password-strength.test.ts
  if (file.includes('use-password-strength')) {
    content = content.replace(/import \{\s*\n\s*usePasswordStrength,/, 'import {\n  usePasswordStrength,');
  }

  // For card.test.tsx
  if (file.includes('card.test')) {
    content = content.replace(/import \{\s*\n\s*Card,/, 'import {\n  Card,');
  }

  // For dialog.test.tsx
  if (file.includes('dialog.test')) {
    content = content.replace(/import \{\s*\n\s*Dialog,/, 'import {\n  Dialog,');
  }

  // For validation.test.ts
  if (file.includes('validation.test')) {
    content = content.replace(/import \{[\s\S]*?validateEmail,/, 'import {\n  validateEmail,');
  }

  fs.writeFileSync(fullPath, content, 'utf8');
  console.log(`✓ Fixed ${path.basename(file)}`);
});

console.log(`\n✅ Fixed ${fixedCount + filesToFix.length} files with duplicate imports`);