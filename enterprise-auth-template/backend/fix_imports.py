#!/usr/bin/env python3
"""
Script to automatically remove unused imports based on flake8 F401 errors
"""
import subprocess
import re
import os
from pathlib import Path

def get_unused_imports():
    """Get all F401 unused import errors from flake8"""
    result = subprocess.run(
        ['python3', '-m', 'flake8', 'app/', '--select=F401', '--format=%(path)s:%(row)d:%(col)d: %(text)s'],
        capture_output=True, text=True, cwd='/Users/mdshahabulalam/basetemplate/enterprise-auth-template/backend'
    )
    
    if result.returncode != 0:
        print("Error running flake8:", result.stderr)
        return {}
    
    # Parse the output
    unused_imports = {}
    for line in result.stdout.strip().split('\n'):
        if not line:
            continue
        
        # Parse: file:line:col: F401 'module.name' imported but unused
        match = re.match(r'(.+):(\d+):\d+: F401 \'(.+)\' imported but unused', line)
        if match:
            file_path = match.group(1)
            line_num = int(match.group(2))
            import_name = match.group(3)
            
            if file_path not in unused_imports:
                unused_imports[file_path] = []
            unused_imports[file_path].append((line_num, import_name))
    
    return unused_imports

def remove_unused_imports_from_file(file_path, unused_imports_data):
    """Remove unused imports from a specific file"""
    try:
        with open(file_path, 'r') as f:
            lines = f.readlines()
        
        # Sort by line number in reverse order to avoid index shifting
        unused_imports_data.sort(key=lambda x: x[0], reverse=True)
        
        modified = False
        for line_num, import_name in unused_imports_data:
            line_index = line_num - 1  # Convert to 0-based indexing
            
            if line_index >= len(lines):
                continue
                
            line = lines[line_index]
            
            # Handle different import patterns
            if 'from ' in line and ' import ' in line:
                # Handle: from module import a, b, c
                parts = line.split(' import ')
                if len(parts) == 2:
                    imports = [imp.strip() for imp in parts[1].split(',')]
                    # Remove the unused import
                    remaining_imports = [imp for imp in imports if not any(import_name.endswith(imp.strip()) for imp in [imp])]
                    
                    if not remaining_imports:
                        # Remove the entire line if no imports remain
                        lines.pop(line_index)
                        modified = True
                    elif len(remaining_imports) < len(imports):
                        # Update the line with remaining imports
                        lines[line_index] = f"{parts[0]} import {', '.join(remaining_imports)}\n"
                        modified = True
            elif line.strip().startswith('import '):
                # Handle: import module
                if import_name.split('.')[-1] in line or import_name in line:
                    lines.pop(line_index)
                    modified = True
        
        if modified:
            with open(file_path, 'w') as f:
                f.writelines(lines)
            print(f"Fixed imports in {file_path}")
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

def main():
    """Main function to fix all unused imports"""
    print("Scanning for unused imports...")
    unused_imports = get_unused_imports()
    
    if not unused_imports:
        print("No unused imports found!")
        return
    
    print(f"Found unused imports in {len(unused_imports)} files")
    
    for file_path, import_data in unused_imports.items():
        full_path = f"/Users/mdshahabulalam/basetemplate/enterprise-auth-template/backend/{file_path}"
        if os.path.exists(full_path):
            print(f"Processing {file_path}...")
            remove_unused_imports_from_file(full_path, import_data)
    
    print("Import cleanup completed!")

if __name__ == "__main__":
    main()