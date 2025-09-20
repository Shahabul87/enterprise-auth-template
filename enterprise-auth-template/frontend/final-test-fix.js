const fs = require('fs');
const path = require('path');

function fixTestFile(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf-8');
    let modified = false;

    // Remove all orphaned comments and broken mock structures
    content = content.replace(/\/\/ Orphaned closing removed/g, '');
    content = content.replace(/\/\/ Duplicate removed - \w+:.*$/gm, '');

    // Fix incomplete mock definitions
    // Find all jest.mock blocks and ensure they're properly closed
    content = content.replace(/jest\.mock\([^)]+\),\s*\{[\s\S]*?\}\)\);?/g, (match) => {
      // Count opening and closing braces/parens
      let openBraces = (match.match(/\{/g) || []).length;
      let closeBraces = (match.match(/\}/g) || []).length;
      let openParens = (match.match(/\(/g) || []).length;
      let closeParens = (match.match(/\)/g) || []).length;

      // Fix mismatched braces
      if (openBraces > closeBraces) {
        match += '}}'.substring(0, openBraces - closeBraces);
        modified = true;
      }

      // Fix mismatched parens
      if (openParens > closeParens) {
        match += '))'.substring(0, openParens - closeParens);
        modified = true;
      }

      // Ensure it ends with });
      if (!match.trim().endsWith('}));')) {
        match = match.trim();
        if (!match.endsWith(');')) {
          if (!match.endsWith(')')) {
            match += ');';
          } else {
            match += ';';
          }
          modified = true;
        }
      }

      return match;
    });

    // Fix specific auth.store mock pattern issues
    if (filePath.includes('auth.store') || content.includes('useAuthStore')) {
      // Find incomplete mock definitions and complete them
      content = content.replace(/jest\.mock\('@\/stores\/auth\.store',\s*\(\)\s*=>\s*\(\{[\s\S]*?\n(?=jest\.mock|describe|import|$)/g, (match) => {
        if (!match.trim().endsWith('}));')) {
          // Count braces to determine what's needed
          let openBraces = (match.match(/\{/g) || []).length;
          let closeBraces = (match.match(/\}/g) || []).length;
          let openParens = (match.match(/\(/g) || []).length;
          let closeParens = (match.match(/\)/g) || []).length;

          let closing = '';
          for (let i = closeBraces; i < openBraces; i++) closing += '}';
          for (let i = closeParens; i < openParens; i++) closing += ')';
          if (!closing.endsWith(');')) closing += ');';

          modified = true;
          return match.trim() + '\n' + closing + '\n';
        }
        return match;
      });
    }

    // Fix UserManagement specific issues
    if (filePath.includes('UserManagement')) {
      // Fix broken mock data objects
      content = content.replace(/\{\s*id:.*?\n\s*\{/g, (match) => {
        modified = true;
        return match.replace(/\n\s*\{/, '},\n    {');
      });

      // Fix interface definitions
      content = content.replace(/interface\s+\w+\s*\{[\s\S]*?\n(?=describe|interface|const|let|var|function)/g, (match) => {
        if (!match.includes('}')) {
          modified = true;
          return match.trim() + '\n}\n';
        }
        return match;
      });
    }

    // Clean up extra whitespace
    content = content.replace(/\n{4,}/g, '\n\n\n');
    content = content.replace(/^\s*\n/gm, '');

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

let allTestFiles = [];
for (const dir of testDirs) {
  if (fs.existsSync(dir)) {
    allTestFiles.push(...findTestFiles(dir));
  }
}

console.log(`Processing ${allTestFiles.length} test files...`);

let fixedCount = 0;
for (const file of allTestFiles) {
  if (fixTestFile(file)) {
    fixedCount++;
  }
}

console.log(`\nFixed ${fixedCount} test files`);

// Now run TypeScript check to see remaining issues
console.log('\nChecking TypeScript errors...');
const { execSync } = require('child_process');
try {
  execSync('npx tsc --noEmit', {
    cwd: '/Users/mdshahabulalam/basetemplate/enterprise-auth-template/frontend',
    stdio: 'pipe'
  });
  console.log('✅ No TypeScript errors!');
} catch (error) {
  const errorOutput = error.stdout ? error.stdout.toString() : '';
  const errorCount = (errorOutput.match(/error TS/g) || []).length;
  console.log(`⚠️  ${errorCount} TypeScript errors remaining`);
}