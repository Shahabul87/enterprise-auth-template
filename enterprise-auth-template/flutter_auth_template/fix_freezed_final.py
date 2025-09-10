#!/usr/bin/env python3
import os
import re
from pathlib import Path

def fix_freezed_file(file_path):
    """Fix malformed Freezed generated files."""
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    fixed_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Check if this line is in a mixin declaration and contains multiple getters
        if 'get ' in line and ';' in line:
            # Count how many getters are in this line
            getter_count = line.count('get ')
            
            if getter_count > 1 or (getter_count == 1 and 'Map<' in line and 'get ' in line):
                # This line has multiple getters or is malformed
                # Extract all the getter declarations
                remaining = line
                indent = len(line) - len(line.lstrip())
                
                # Find all patterns like "Type get name"
                pattern = r'(\s*)([A-Za-z_][\w<>,\s\?]*?)\s+get\s+(\w+)'
                matches = list(re.finditer(pattern, remaining))
                
                if matches:
                    # Process each getter separately
                    for match in matches:
                        type_name = match.group(2).strip()
                        prop_name = match.group(3).strip()
                        fixed_lines.append(' ' * indent + f'  {type_name} get {prop_name};\n')
                    
                    # Skip to next line only if we found and processed getters
                    i += 1
                    continue
            
            # Special case: line starts with type and next line has "get"
            # e.g., "Map<String, int>" on one line and "get users;" on next
            if i + 1 < len(lines) and 'get ' in lines[i + 1]:
                # Combine them
                type_part = line.strip()
                getter_part = lines[i + 1].strip()
                if type_part and not type_part.endswith(';'):
                    indent = len(line) - len(line.lstrip())
                    fixed_lines.append(' ' * indent + f'  {type_part} {getter_part}\n')
                    i += 2
                    continue
        
        # Default: keep the line as is
        fixed_lines.append(line)
        i += 1
    
    # Join and write back
    content = ''.join(fixed_lines)
    
    # Additional fixes for common patterns
    
    # Fix pattern where types and getters are separated incorrectly
    content = re.sub(
        r'\n\s*Map<String,\s*int>\s*\n\s*get\s+(\w+);',
        r'\n  Map<String, int> get \1;',
        content
    )
    
    # Fix multiple getters on same line (comprehensive)
    def split_getters(match):
        line = match.group(0)
        indent = match.group(1) if match.lastindex >= 1 else '  '
        
        # Find all getter patterns
        getters = re.findall(r'([A-Za-z_][\w<>,\s\?]*?)\s+get\s+(\w+)', line)
        
        if len(getters) > 1:
            result = ''
            for type_str, prop_name in getters:
                result += f'\n{indent}{type_str.strip()} get {prop_name};'
            return result
        return line
    
    # Apply the getter splitting
    content = re.sub(
        r'^(\s*).*?(?:Map|List|String|int|bool|double|\w+).*?get\s+\w+.*?;.*?get\s+\w+.*?$',
        split_getters,
        content,
        flags=re.MULTILINE
    )
    
    with open(file_path, 'w') as f:
        f.write(content)
    
    return True

def main():
    """Fix all Freezed generated files in the project."""
    project_root = Path('/Users/mdshahabulalam/basetemplate/enterprise-auth-template/flutter_auth_template')
    
    # Find all .freezed.dart files
    freezed_files = list(project_root.rglob('*.freezed.dart'))
    
    print(f"Found {len(freezed_files)} Freezed files to fix")
    
    for file_path in freezed_files:
        fix_freezed_file(file_path)
        print(f"Fixed: {file_path.relative_to(project_root)}")
    
    print(f"\nFixed all {len(freezed_files)} files")

if __name__ == '__main__':
    main()