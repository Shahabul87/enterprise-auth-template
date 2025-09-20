#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// List of specific files with known syntax errors
const specificFixes = [
  {
    file: 'src/__tests__/components/login-form.test.tsx',
    pattern: /expect\(screen\.getByRole\('button', \{ name: \/sign in\/i \}\)\)\}\}\}\)\)\);\.toBeInTheDocument\(\);/g,
    replacement: "expect(screen.getByRole('button', { name: /sign in/i })).toBeInTheDocument();"
  },
  {
    file: 'src/__tests__/hooks/use-debounce-comprehensive.test.ts',
    fixes: [
      // Remove the arrow syntax before the import
      { pattern: /,->\s+useDebounce,/g, replacement: 'import {\n  useDebounce,' },
      { pattern: /\|->\s+type DebounceOptions,/g, replacement: '  type DebounceOptions,' },
      // Fix any remaining syntax issues
      { pattern: /\s+useAdvancedDebounce,\n\s+useDebouncedCallback,\n\s+useDebouncedSearch,\n\s+type DebounceOptions,\n\s+type DebouncedState,\n\} from '@\/hooks\/use-debounce';/g,
        replacement: `  useAdvancedDebounce,
  useDebouncedCallback,
  useDebouncedSearch,
  type DebounceOptions,
  type DebouncedState,
} from '@/hooks/use-debounce';` }
    ]
  }
];

function fixFile(filePath, fixes) {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    let modified = false;

    if (Array.isArray(fixes)) {
      fixes.forEach(fix => {
        if (fix.pattern && fix.replacement !== undefined) {
          const newContent = content.replace(fix.pattern, fix.replacement);
          if (newContent !== content) {
            content = newContent;
            modified = true;
            console.log(`Applied fix to ${filePath}: ${fix.pattern.source.substring(0, 50)}...`);
          }
        }
      });
    } else if (fixes.pattern && fixes.replacement !== undefined) {
      const newContent = content.replace(fixes.pattern, fixes.replacement);
      if (newContent !== content) {
        content = newContent;
        modified = true;
        console.log(`Applied fix to ${filePath}: ${fixes.pattern.source.substring(0, 50)}...`);
      }
    }

    if (modified) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`✓ Fixed ${filePath}`);
    } else {
      console.log(`No changes needed for ${filePath}`);
    }
  } catch (error) {
    console.error(`Error processing ${filePath}:`, error.message);
  }
}

console.log('Fixing specific syntax errors in test files...\n');

// Apply specific fixes
specificFixes.forEach(({ file, pattern, replacement, fixes }) => {
  const fullPath = path.join(__dirname, file);
  if (fixes) {
    fixFile(fullPath, fixes);
  } else if (pattern && replacement !== undefined) {
    fixFile(fullPath, { pattern, replacement });
  }
});

// Now let's also check and fix the use-debounce-comprehensive.test.ts file more thoroughly
const debouncePath = path.join(__dirname, 'src/__tests__/hooks/use-debounce-comprehensive.test.ts');
if (fs.existsSync(debouncePath)) {
  let content = fs.readFileSync(debouncePath, 'utf8');

  // Look for the import statement and fix it properly
  const importMatch = content.match(/import[\s\S]*?from\s+['"]@\/hooks\/use-debounce['"]/);
  if (importMatch) {
    const originalImport = importMatch[0];

    // Clean up the import statement
    const cleanImport = `import {
  useDebounce,
  useAdvancedDebounce,
  useDebouncedCallback,
  useDebouncedSearch,
  type DebounceOptions,
  type DebouncedState,
} from '@/hooks/use-debounce'`;

    if (!originalImport.includes('import {')) {
      content = content.replace(originalImport, cleanImport);
      fs.writeFileSync(debouncePath, content, 'utf8');
      console.log('✓ Fixed import statement in use-debounce-comprehensive.test.ts');
    }
  }
}

console.log('\nDone! Specific syntax errors have been fixed.');