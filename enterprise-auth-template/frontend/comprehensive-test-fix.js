const fs = require('fs');
const path = require('path');

function fixTestFile(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf-8');
    let modified = false;

    // Remove duplicate mock definitions (handle various patterns)
    // Pattern 1: })),\n  useAuthStore: or similar
    content = content.replace(/}\)\),\s*\n\s*useAuthStore:/g, () => {
      modified = true;
      return '}));\n\n// Duplicate removed - useAuthStore:';
    });

    // Pattern 2: })),\n  useAuth: or similar
    content = content.replace(/}\)\),\s*\n\s*useAuth:/g, () => {
      modified = true;
      return '}));\n\n// Duplicate removed - useAuth:';
    });

    // Pattern 3: })),\n  useRequireAuth: or similar
    content = content.replace(/}\)\),\s*\n\s*useRequireAuth:/g, () => {
      modified = true;
      return '}));\n\n// Duplicate removed - useRequireAuth:';
    });

    // Remove orphaned mock closing
    content = content.replace(/^\s*}\)\);\s*$/gm, (match, offset) => {
      // Check if this is an orphaned closing (not part of a proper mock)
      const before = content.substring(Math.max(0, offset - 100), offset);
      if (!before.includes('jest.mock') && !before.includes('mockReturnValue')) {
        modified = true;
        return '// Orphaned closing removed';
      }
      return match;
    });

    // Fix missing interface closing braces before describe
    content = content.replace(/(\s+\w+:\s+[\w\[\]<>]+;)\s*\ndescribe\(/g, (match, lastProp) => {
      modified = true;
      return lastProp + '\n}\n\ndescribe(';
    });

    // Ensure imports are at the top
    const lines = content.split('\n');
    const imports = [];
    const jestEnvComments = [];
    const otherLines = [];
    let inMultilineComment = false;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      // Handle multiline comments
      if (line.includes('/**')) {
        inMultilineComment = true;
      }
      if (inMultilineComment && line.includes('*/')) {
        inMultilineComment = false;
        if (line.includes('@jest-environment')) {
          jestEnvComments.push(lines.slice(Math.max(0, i-2), i+1).join('\n'));
          continue;
        }
      }

      // Collect imports
      if (line.trim().startsWith('import ')) {
        imports.push(line);
      } else if (!jestEnvComments.some(c => c.includes(line))) {
        otherLines.push(line);
      }
    }

    // Reconstruct file with proper order
    if (imports.length > 0) {
      const newContent = [
        ...jestEnvComments,
        '',
        ...imports,
        '',
        ...otherLines.filter(line => !imports.includes(line))
      ].join('\n');

      if (newContent !== content) {
        content = newContent;
        modified = true;
      }
    }

    // Clean up excessive empty lines
    content = content.replace(/\n{4,}/g, '\n\n\n');

    // Fix specific component issues
    if (filePath.includes('UserManagement.test')) {
      // Fix the specific duplicate mock issue in UserManagement
      content = content.replace(/}\)\),\s*\n\s*useAuthStore:[\s\S]*?}\)\),\s*\n\s*useRequireAuth:.*?\n}\)\);/g, '}));');
      modified = true;
    }

    if (modified) {
      fs.writeFileSync(filePath, content);
      console.log(`Fixed: ${path.basename(filePath)}`);
      return true;
    }
    return false;
  } catch (error) {
    console.error(`Error processing ${path.basename(filePath)}:`, error.message);
    return false;
  }
}

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
        // Skip files we can't access
      }
    }
  } catch (e) {
    console.error(`Error reading directory ${dir}:`, e.message);
  }

  return files;
}

// Main execution
const dirs = [
  '/Users/mdshahabulalam/basetemplate/enterprise-auth-template/frontend/src/__tests__',
  '/Users/mdshahabulalam/basetemplate/enterprise-auth-template/frontend/__tests__'
];

let allTestFiles = [];
for (const dir of dirs) {
  if (fs.existsSync(dir)) {
    allTestFiles.push(...findTestFiles(dir));
  }
}

console.log(`Found ${allTestFiles.length} test files`);

let fixedCount = 0;
for (const file of allTestFiles) {
  if (fixTestFile(file)) {
    fixedCount++;
  }
}

console.log(`\nFixed ${fixedCount} test files`);