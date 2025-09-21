#!/usr/bin/env python3
"""
Fix bulk test syntax issues across all test files
"""

import os
import re
from pathlib import Path

def fix_common_test_issues(content, filename):
    """Fix common test issues in a single file"""

    # Fix missing closing for jest.mock calls
    lines = content.split('\n')
    fixed_lines = []

    i = 0
    while i < len(lines):
        line = lines[i]

        # Handle jest.mock calls that aren't properly closed
        if 'jest.mock(' in line and not line.strip().endswith('));'):
            # Look ahead to find where this mock should end
            mock_content = [line]
            brace_count = line.count('{') - line.count('}')
            paren_count = line.count('(') - line.count(')')

            j = i + 1
            while j < len(lines) and (brace_count > 0 or paren_count > 1):
                next_line = lines[j]
                mock_content.append(next_line)
                brace_count += next_line.count('{') - next_line.count('}')
                paren_count += next_line.count('(') - next_line.count(')')

                # Stop if we hit another jest.mock or certain patterns
                if ('jest.mock(' in next_line or
                    'const mock' in next_line or
                    'describe(' in next_line or
                    'interface ' in next_line):
                    break
                j += 1

            # Close the mock properly
            last_line = mock_content[-1]
            if not last_line.strip().endswith('));'):
                while brace_count > 0:
                    last_line += '}'
                    brace_count -= 1
                while paren_count > 0:
                    last_line += ')'
                    paren_count -= 1
                if not last_line.endswith(';'):
                    last_line += ';'
                mock_content[-1] = last_line

            fixed_lines.extend(mock_content)
            i = j
            continue

        fixed_lines.append(line)
        i += 1

    content = '\n'.join(fixed_lines)

    # Fix specific patterns
    fixes = [
        # Add missing imports
        (r'import { render, screen', r'import { render, screen, act'),

        # Fix expect statements in incomplete blocks
        (r'expect\(([^)]+)\)\.toBe\([^)]+\)\n\s*}\);', r'expect(\1).toBe(...); });'),

        # Fix incomplete describe blocks
        (r'describe\(([^{]+)\{\s*$', r'describe(\1, () => {'),

        # Fix incomplete test blocks
        (r'it\(([^{]+)\{\s*$', r'it(\1, () => {'),

        # Fix dangling semicolons and syntax
        (r'}\s*}\)\);?\s*$', r'});'),

        # Fix describe and it syntax
        (r'describe\s*\(\s*[\'"`]([^\'"`]+)[\'"`]\s*\)\s*\{', r'describe("\1", () => {'),
        (r'it\s*\(\s*[\'"`]([^\'"`]+)[\'"`]\s*\)\s*\{', r'it("\1", () => {'),

        # Fix common token issues
        (r'Expected.*got.*interface', ''),
        (r'Expected.*got.*FormControlProps', ''),
        (r'Unexpected token.*Expected', ''),
    ]

    for pattern, replacement in fixes:
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)

    # File-specific fixes
    if 'user-table.test.tsx' in filename:
        # Fix missing closing brackets
        content = content.replace('}));', '}));')
        if not content.endswith('\n'):
            content += '\n'

    return content

def process_all_test_files():
    """Process all test files to fix syntax issues"""
    test_dir = Path('/Users/mdshahabulalam/basetemplate/enterprise-auth-template/frontend/src/__tests__')

    # Find all test files
    test_files = list(test_dir.rglob('*.test.ts*'))

    print(f"Processing {len(test_files)} test files...")

    fixed_count = 0
    for test_file in test_files:
        try:
            with open(test_file, 'r', encoding='utf-8') as f:
                content = f.read()

            original = content
            content = fix_common_test_issues(content, str(test_file))

            # Only write if changed
            if content != original:
                with open(test_file, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Fixed: {test_file}")
                fixed_count += 1

        except Exception as e:
            print(f"Error processing {test_file}: {e}")

    print(f"Fixed {fixed_count} files")

if __name__ == "__main__":
    process_all_test_files()