#!/usr/bin/env python3
"""
Fix common syntax issues in Jest test files
"""

import os
import re
from pathlib import Path

def fix_jest_mock_syntax(content):
    """Fix missing closing parentheses for jest.mock calls"""
    lines = content.split('\n')
    fixed_lines = []
    in_mock = False
    brace_count = 0
    paren_count = 0

    for i, line in enumerate(lines):
        # Check if we're starting a new jest.mock
        if 'jest.mock(' in line:
            in_mock = True
            # Count braces and parentheses
            brace_count = line.count('{') - line.count('}')
            paren_count = line.count('(') - line.count(')')

            # Check if the next line starts with another jest.mock
            if i + 1 < len(lines) and 'jest.mock(' in lines[i + 1]:
                # Add missing closing
                if brace_count > 0 or paren_count > 0:
                    line += '}));'
                    in_mock = False
                    brace_count = 0
                    paren_count = 0
        elif in_mock:
            brace_count += line.count('{') - line.count('}')
            paren_count += line.count('(') - line.count(')')

            # Check if we need to close the mock
            if i + 1 < len(lines):
                next_line = lines[i + 1]
                # If next line is a new mock or certain patterns
                if ('jest.mock(' in next_line or
                    'const mock' in next_line or
                    'describe(' in next_line or
                    'interface ' in next_line or
                    '/**' in next_line or
                    '// Mock' in next_line):
                    if brace_count > 0 or paren_count > 1:
                        # Close the mock properly
                        while brace_count > 0:
                            line += '}'
                            brace_count -= 1
                        while paren_count > 0:
                            line += ')'
                            paren_count -= 1
                        if not line.endswith(';'):
                            line += ';'
                        in_mock = False

        fixed_lines.append(line)

    return '\n'.join(fixed_lines)

def fix_missing_semicolons(content):
    """Add missing semicolons after common patterns"""
    patterns = [
        (r'(\)\s*)$', r'\1;'),  # Add semicolon after closing parenthesis at end of line
        (r'(}\s*)$', r'\1;'),    # Add semicolon after closing brace at end of line
    ]

    lines = content.split('\n')
    fixed_lines = []

    for line in lines:
        # Skip if line already ends with semicolon or is a comment
        if line.strip().endswith((';', '{', '}', ',', '*/')) or line.strip().startswith('//'):
            fixed_lines.append(line)
            continue

        # Check for specific patterns that need semicolons
        if any(keyword in line for keyword in ['jest.fn()', 'mockResolvedValue', 'mockReturnValue']):
            if not line.rstrip().endswith(';'):
                line = line.rstrip() + ';'

        fixed_lines.append(line)

    return '\n'.join(fixed_lines)

def fix_specific_test_issues(file_path, content):
    """Fix specific issues in individual test files"""

    # Fix user-modal.test.tsx - property access issues
    if 'user-modal.test.tsx' in file_path:
        # The UserModal expects name property, not first_name/last_name
        content = content.replace("first_name: 'John',", "name: 'John Doe',")
        content = content.replace("last_name: 'Doe',", "")
        content = content.replace("first_name: 'Jane',", "name: 'Jane Smith',")
        content = content.replace("last_name: 'Smith',", "")

    # Fix navigation menu test
    if 'nav-menu.test.tsx' in file_path:
        # Add null check for pathname
        content = content.replace(
            "const isActive = (href?: string) => {",
            "const isActive = (href?: string) => {\n    if (!pathname || !href) return false;"
        )

    return content

def process_test_file(file_path):
    """Process a single test file to fix syntax issues"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        original = content

        # Apply fixes
        content = fix_jest_mock_syntax(content)
        content = fix_missing_semicolons(content)
        content = fix_specific_test_issues(str(file_path), content)

        # Only write if changed
        if content != original:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Fixed: {file_path}")
            return True
        return False
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    """Main function to fix all test files"""
    test_dir = Path('/Users/mdshahabulalam/basetemplate/enterprise-auth-template/frontend/src/__tests__')

    # Find all test files
    test_files = list(test_dir.rglob('*.test.ts*'))

    print(f"Found {len(test_files)} test files")

    fixed_count = 0
    for test_file in test_files:
        if process_test_file(test_file):
            fixed_count += 1

    print(f"\nFixed {fixed_count} files")

if __name__ == "__main__":
    main()