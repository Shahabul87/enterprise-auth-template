const fs = require('fs');
const path = require('path');

function fixTestFile(filePath) {
  try {
    let content = fs.readFileSync(filePath, 'utf-8');
    let modified = false;
    
    // Fix missing closing braces for interfaces before describe
    content = content.replace(/(\s+\w+:\s+\w+;)\s*\ndescribe\(/g, (match, lastProp) => {
      modified = true;
      return lastProp + '\n}\n\ndescribe(';
    });
    
    // Fix duplicated mock definitions
    content = content.replace(/}}\)\),\s*useAuthStore:/g, () => {
      modified = true;
      return '}}));/*duplicate removed*/\n// useAuthStore:';
    });
    
    // Move imports to the top if they're after mocks
    const importRegex = /^import\s+.*?;$/gm;
    const imports = content.match(importRegex) || [];
    const jestEnvRegex = /^\/\*\*\s*\n\s*\*\s*@jest-environment\s+jsdom\s*\n\s*\*\/$/m;
    const jestEnvMatch = content.match(jestEnvRegex);
    
    if (imports.length > 0) {
      // Remove imports from their current position
      let cleanContent = content;
      imports.forEach(imp => {
        cleanContent = cleanContent.replace(imp, '');
      });
      
      // Add imports at the top (after jest-environment if present)
      if (jestEnvMatch) {
        const jestEnvIndex = cleanContent.indexOf(jestEnvMatch[0]) + jestEnvMatch[0].length;
        cleanContent = cleanContent.slice(0, jestEnvIndex) + '\n' + imports.join('\n') + '\n' + cleanContent.slice(jestEnvIndex);
      } else {
        cleanContent = imports.join('\n') + '\n\n' + cleanContent;
      }
      
      if (cleanContent !== content) {
        content = cleanContent;
        modified = true;
      }
    }
    
    // Clean up empty lines
    content = content.replace(/\n{4,}/g, '\n\n\n');
    
    if (modified) {
      fs.writeFileSync(filePath, content);
      console.log(`Fixed: ${filePath}`);
      return true;
    }
    return false;
  } catch (error) {
    console.error(`Error processing ${filePath}:`, error.message);
    return false;
  }
}

function findTestFiles(dir) {
  const files = [];
  const items = fs.readdirSync(dir);
  
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory() && !item.startsWith('.') && item !== 'node_modules') {
      files.push(...findTestFiles(fullPath));
    } else if (stat.isFile() && (item.endsWith('.test.ts') || item.endsWith('.test.tsx'))) {
      files.push(fullPath);
    }
  }
  
  return files;
}

// Main execution
const testDir = '/Users/mdshahabulalam/basetemplate/enterprise-auth-template/frontend/src/__tests__';
const testFiles = findTestFiles(testDir);
const frontendTestFiles = findTestFiles('/Users/mdshahabulalam/basetemplate/enterprise-auth-template/frontend/__tests__');
const allTestFiles = [...testFiles, ...frontendTestFiles];

console.log(`Found ${allTestFiles.length} test files`);

let fixedCount = 0;
for (const file of allTestFiles) {
  if (fixTestFile(file)) {
    fixedCount++;
  }
}

console.log(`\nFixed ${fixedCount} test files`);
