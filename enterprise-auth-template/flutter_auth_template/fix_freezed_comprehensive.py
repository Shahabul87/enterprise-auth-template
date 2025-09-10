#!/usr/bin/env python3
import os
import re
from pathlib import Path

def fix_freezed_file(file_path):
    """Fix malformed Freezed generated files with comprehensive fixes."""
    with open(file_path, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Fix 1: Split getter declarations that are all on one line in mixins
    # Pattern: Multiple "get propertyName;" on the same line
    def fix_inline_getters(match):
        getters_line = match.group(1)
        # Split by semicolon followed by space and a word character
        getters = re.findall(r'(\w+(?:\<[^>]+\>)?\??)\s+get\s+(\w+)', getters_line)
        
        if len(getters) > 1:
            # Multiple getters on one line - split them
            result = '\n'
            for type_str, prop_name in getters:
                result += f'  {type_str} get {prop_name};\n'
            return result
        else:
            # Single getter or malformed - return as is
            return match.group(0)
    
    # Match lines with multiple getters
    content = re.sub(
        r'\n\s*([^/\n].*?get\s+\w+.*?;.*?get\s+\w+.*?;)',
        fix_inline_getters,
        content
    )
    
    # Fix 2: Fix getter declarations that span multiple lines incorrectly
    # Pattern: Type on one line, "get propertyName" on next line
    content = re.sub(
        r'\n\n(\w+(?:\<[^>]+\>)?\??)\s*\n\s*get\s+(\w+);',
        r'\n  \1 get \2;\n',
        content
    )
    
    # Fix 3: Ensure proper spacing between getters in mixins
    # Add blank line before getter if missing
    content = re.sub(
        r'(\w+;)\n(\s*\w+(?:\<[^>]+\>)?\??)\s+get\s+',
        r'\1\n\n  \2 get ',
        content
    )
    
    # Fix 4: Fix constructor parameters that are too long
    # Split long parameter lists in constructors
    def fix_long_constructors(match):
        indent = match.group(1)
        params = match.group(2)
        
        # If the line is too long (> 120 chars), split it
        if len(params) > 100:
            # Split by comma but keep the structure
            param_list = []
            current = ""
            depth = 0
            
            for char in params:
                if char in '<[{(':
                    depth += 1
                elif char in '>]})':
                    depth -= 1
                
                current += char
                
                if char == ',' and depth == 0:
                    param_list.append(current.strip())
                    current = ""
            
            if current.strip():
                param_list.append(current.strip())
            
            # Format with proper indentation
            if len(param_list) > 1:
                formatted = f"{indent}(\n"
                for param in param_list:
                    formatted += f"{indent}    {param}\n"
                formatted += f"{indent}  )"
                return formatted
        
        return match.group(0)
    
    # Match constructors with long parameter lists
    content = re.sub(
        r'^(\s*)(const\s+_\w+\([^)]{100,}\))',
        fix_long_constructors,
        content,
        flags=re.MULTILINE
    )
    
    # Fix 5: Ensure proper formatting of factory constructors
    content = re.sub(
        r'factory\s+(\w+)\.fromJson\(Map<String,\s*dynamic>\s*json\)\s*=>\s*_\$(\w+)FromJson\(json\);',
        r'factory \1.fromJson(Map<String, dynamic> json) =>\n      _$\2FromJson(json);',
        content
    )
    
    # Fix 6: Fix @override annotations that are on wrong lines
    content = re.sub(
        r'\n\n@override\s*(\w+)',
        r'\n\n  @override\n  \1',
        content
    )
    
    # Fix 7: Clean up excessive blank lines
    content = re.sub(r'\n{4,}', '\n\n\n', content)
    
    # Only write if changes were made
    if content != original_content:
        with open(file_path, 'w') as f:
            f.write(content)
        return True
    return False

def main():
    """Fix all Freezed generated files in the project."""
    project_root = Path('/Users/mdshahabulalam/basetemplate/enterprise-auth-template/flutter_auth_template')
    
    # Find all .freezed.dart files
    freezed_files = list(project_root.rglob('*.freezed.dart'))
    
    print(f"Found {len(freezed_files)} Freezed files to check")
    
    fixed_count = 0
    for file_path in freezed_files:
        if fix_freezed_file(file_path):
            fixed_count += 1
            print(f"Fixed: {file_path.relative_to(project_root)}")
    
    print(f"\nFixed {fixed_count} files")

if __name__ == '__main__':
    main()