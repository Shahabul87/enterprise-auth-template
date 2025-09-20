const fs = require('fs');
const path = require('path');

function fixSyntaxErrors(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf-8');
    let modified = false;

    // Fix excessive closing parentheses/braces patterns
    content = content.replace(/\}\}\)\)\)\)\);+/g, '}));');
    content = content.replace(/\}\)\}\}\)\)\)\);+/g, '}));');
    content = content.replace(/\)\}\}\}\)\)\)\);+/g, '}));');

    // Fix specific pattern in login-form.test.tsx
    content = content.replace(/\)\)\}\}\}\)\)\)\);\.toBeInTheDocument/g, ').toBeInTheDocument');

    // Fix broken statements
    content = content.replace(/expect\(.*?\)\)\}\}\}\)\)\)\);/g, (match) => {
      return match.replace(/\)\}\}\}\)\)\)\);/, ');');
    });

    // Fix specific issues with mock definitions
    content = content.replace(/\}\)\)\)\)\);,/g, '})),');
    content = content.replace(/\}\)\)\}\}\)\);/g, '}));');

    // Fix double React import issue
    content = content.replace(/import\s+\{[\s\S]*?\noimport React/g, 'import React');

    // Fix broken waitFor blocks
    content = content.replace(/\}, \s*\n\s*\{ timeout: \d+ \}\);\s*\}\); \}\);/g, '}, { timeout: 5000 }); });');

    // Fix broken mock closures in specific files
    if (filePath.includes('auth-context.test') || filePath.includes('SystemMetrics.test') || filePath.includes('UserManagement.test') || filePath.includes('page.test')) {
      // Fix the specific pattern of broken closures
      content = content.replace(/useGuestOnly: jest\.fn\(\(\) => \(\{[\s\S]*?\}\)\)\}\}\)\)\)\)\);,/g,
        `useGuestOnly: jest.fn(() => ({
    isLoading: false,
  })),`);

      content = content.replace(/\}\)\)\}\}\)\)\)\);,\s*\}\}\)\);/g, '}));');
      modified = true;
    }

    // Fix broken import statements
    if (filePath.includes('use-debounce-comprehensive.test') || filePath.includes('use-password-strength.test')) {
      content = content.replace(/import \{\s*import React from 'react';/g, `import React from 'react';
import {`);
      modified = true;
    }

    // Fix orphaned import statements
    content = content.replace(/^import \{$/gm, '');

    // Fix broken describe blocks
    content = content.replace(/\}\);[\s\n]*describe\(/g, '});\n\ndescribe(');

    // Clean up multiple semicolons
    content = content.replace(/;{2,}/g, ';');

    // Fix broken jest.mock patterns
    content = content.replace(/jest\.mock\([^)]+\), \(\) => \(\{[^}]*$\n\s*jest\.mock/gm, (match) => {
      return match.replace(/jest\.mock$/, '}));\n\njest.mock');
    });

    // Clean up excessive whitespace
    content = content.replace(/\n{4,}/g, '\n\n\n');

    if (content !== fs.readFileSync(filePath, 'utf-8') || modified) {
      fs.writeFileSync(filePath, content);
      console.log(`Fixed syntax in: ${path.basename(filePath)}`);
      return true;
    }
    return false;
  } catch (error) {
    console.error(`Error processing ${path.basename(filePath)}:`, error.message);
    return false;
  }
}

// Find all test files
function findTestFiles(dir) {
  const files = [];
  try {
    const items = fs.readdirSync(dir);
    for (const item of items) {
      const fullPath = path.join(dir, item);
      try {
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory() && !item.startsWith('.') && item !== 'node_modules') {
          files.push(...findTestFiles(fullPath));
        } else if (stat.isFile() && (item.endsWith('.test.ts') || item.endsWith('.test.tsx'))) {
          files.push(fullPath);
        }
      } catch (e) {
        // Skip inaccessible files
      }
    }
  } catch (e) {
    console.error(`Error reading directory ${dir}:`, e.message);
  }
  return files;
}

// Main execution
const testDirs = [
  '/Users/mdshahabulalam/basetemplate/enterprise-auth-template/frontend/src/__tests__',
  '/Users/mdshahabulalam/basetemplate/enterprise-auth-template/frontend/__tests__'
];

console.log('Fixing syntax errors in test files...\n');

let allTestFiles = [];
for (const dir of testDirs) {
  if (fs.existsSync(dir)) {
    allTestFiles.push(...findTestFiles(dir));
  }
}

let fixedCount = 0;
for (const file of allTestFiles) {
  if (fixSyntaxErrors(file)) {
    fixedCount++;
  }
}

console.log(`\n✅ Fixed syntax errors in ${fixedCount} files`);