#!/usr/bin/env python3
"""
N+1 Query Fixer Utility
Automatically detects and suggests fixes for N+1 query problems.
"""

import ast
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Set
from dataclasses import dataclass
import argparse


@dataclass 
class N1QueryFix:
    """Represents a suggested fix for an N+1 query problem."""
    file_path: str
    line_number: int
    original_code: str
    suggested_fix: str
    fix_type: str  # 'bulk_query', 'prefetch', 'join', 'cache'
    confidence: float  # 0.0 to 1.0
    explanation: str


class ORMPatternDetector:
    """Detects ORM-specific patterns for different frameworks."""
    
    # Django ORM patterns
    DJANGO_PATTERNS = {
        'bulk_query': [
            r'Model\.objects\.filter\(',
            r'\.filter\(',
            r'\.get\(',
            r'QuerySet\.'
        ],
        'prefetch': [
            r'prefetch_related\(',
            r'select_related\(',
        ],
        'model_access': [
            r'\.objects\.',
            r'Model\.',
        ]
    }
    
    # SQLAlchemy patterns
    SQLALCHEMY_PATTERNS = {
        'bulk_query': [
            r'session\.query\(',
            r'\.filter\(',
            r'\.first\(\)',
            r'\.all\(\)',
            r'session\.get\(',
        ],
        'prefetch': [
            r'joinedload\(',
            r'selectinload\(',
            r'contains_eager\(',
        ],
        'relationships': [
            r'relationship\(',
            r'backref\(',
        ]
    }
    
    # Async ORM patterns (e.g., Tortoise ORM, async SQLAlchemy)
    ASYNC_PATTERNS = {
        'bulk_query': [
            r'await.*\.filter\(',
            r'await.*\.get\(',
            r'await.*\.all\(\)',
            r'async.*query',
        ],
        'prefetch': [
            r'prefetch_related\(',
            r'fetch_related\(',
        ]
    }
    
    def detect_orm_framework(self, code: str) -> str:
        """Detect which ORM framework is being used."""
        code_lower = code.lower()
        
        if any(re.search(pattern, code, re.IGNORECASE) for pattern in self.DJANGO_PATTERNS['model_access']):
            return 'django'
        elif any(re.search(pattern, code, re.IGNORECASE) for pattern in self.SQLALCHEMY_PATTERNS['bulk_query']):
            return 'sqlalchemy'
        elif any(re.search(pattern, code, re.IGNORECASE) for pattern in self.ASYNC_PATTERNS['bulk_query']):
            return 'async_orm'
        else:
            return 'generic'
    
    def is_database_query(self, code: str, orm_framework: str) -> bool:
        """Check if code contains database queries."""
        patterns_map = {
            'django': self.DJANGO_PATTERNS['bulk_query'],
            'sqlalchemy': self.SQLALCHEMY_PATTERNS['bulk_query'],
            'async_orm': self.ASYNC_PATTERNS['bulk_query'],
            'generic': [r'query', r'filter', r'get', r'find', r'select']
        }
        
        patterns = patterns_map.get(orm_framework, patterns_map['generic'])
        return any(re.search(pattern, code, re.IGNORECASE) for pattern in patterns)


class N1QueryFixGenerator:
    """Generates fixes for N+1 query problems."""
    
    def __init__(self):
        self.orm_detector = ORMPatternDetector()
    
    def generate_django_fix(self, loop_variable: str, query_code: str, 
                           context: str) -> N1QueryFix:
        """Generate Django-specific fix."""
        # Extract model and field being accessed
        model_match = re.search(r'(\w+)\.objects', query_code)
        field_match = re.search(r'\.(\w+)', query_code)
        
        if model_match and field_match:
            model = model_match.group(1)
            field = field_match.group(1)
            
            # Suggest prefetch_related or select_related
            if 'ForeignKey' in context or 'OneToOne' in context:
                fix_code = f"{model}.objects.select_related('{field}').filter(...)"
                fix_type = 'select_related'
            else:
                fix_code = f"{model}.objects.prefetch_related('{field}').filter(...)"
                fix_type = 'prefetch_related'
                
            return N1QueryFix(
                file_path="",
                line_number=0,
                original_code=query_code,
                suggested_fix=fix_code,
                fix_type=fix_type,
                confidence=0.8,
                explanation=f"Use {fix_type} to load related {field} objects in a single query"
            )
        
        # Fallback: suggest bulk operation
        return N1QueryFix(
            file_path="",
            line_number=0,
            original_code=query_code,
            suggested_fix="# Use bulk operations instead of individual queries",
            fix_type='bulk_query',
            confidence=0.6,
            explanation="Consider using bulk operations to reduce database hits"
        )
    
    def generate_sqlalchemy_fix(self, loop_variable: str, query_code: str,
                               context: str) -> N1QueryFix:
        """Generate SQLAlchemy-specific fix."""
        # Look for relationship loading opportunities
        if 'relationship' in context or 'backref' in context:
            fix_code = f"session.query(Model).options(joinedload(Model.relationship)).filter(...)"
            return N1QueryFix(
                file_path="",
                line_number=0,
                original_code=query_code,
                suggested_fix=fix_code,
                fix_type='joinedload',
                confidence=0.8,
                explanation="Use joinedload to eager load relationships in a single query"
            )
        
        # Suggest bulk loading
        fix_code = "# Use session.bulk_insert_mappings() or bulk operations"
        return N1QueryFix(
            file_path="",
            line_number=0,
            original_code=query_code,
            suggested_fix=fix_code,
            fix_type='bulk_query',
            confidence=0.7,
            explanation="Use SQLAlchemy bulk operations for better performance"
        )
    
    def generate_generic_fix(self, loop_variable: str, query_code: str,
                            context: str) -> N1QueryFix:
        """Generate generic fix suggestions."""
        suggestions = [
            "# Collect IDs and use IN query: WHERE id IN (1, 2, 3, ...)",
            "# Use bulk operations or batch processing",
            "# Consider caching frequently accessed data",
            "# Use JOIN queries instead of separate queries"
        ]
        
        return N1QueryFix(
            file_path="",
            line_number=0,
            original_code=query_code,
            suggested_fix="\n".join(suggestions),
            fix_type='bulk_query',
            confidence=0.5,
            explanation="Generic suggestions for fixing N+1 query problems"
        )


class N1QueryDetectorWithFixes(ast.NodeVisitor):
    """Enhanced N+1 query detector that suggests fixes."""
    
    def __init__(self, file_path: str, source_code: str):
        self.file_path = file_path
        self.source_code = source_code
        self.source_lines = source_code.splitlines()
        self.fixes: List[N1QueryFix] = []
        self.loop_stack: List[Dict] = []
        self.orm_detector = ORMPatternDetector()
        self.fix_generator = N1QueryFixGenerator()
        self.orm_framework = self.orm_detector.detect_orm_framework(source_code)
        
    def visit_For(self, node: ast.For) -> None:
        """Visit for loops and track context."""
        loop_info = {
            'type': 'for',
            'variable': self._get_loop_variable(node),
            'line': node.lineno,
            'queries': []
        }
        
        self.loop_stack.append(loop_info)
        self.generic_visit(node)
        
        # Check for queries in this loop
        loop_context = self.loop_stack.pop()
        if loop_context['queries']:
            for query_info in loop_context['queries']:
                fix = self._generate_fix_for_query(query_info, loop_context)
                if fix:
                    self.fixes.append(fix)
    
    def visit_While(self, node: ast.While) -> None:
        """Visit while loops and track context."""
        loop_info = {
            'type': 'while',
            'variable': 'iterator',
            'line': node.lineno,
            'queries': []
        }
        
        self.loop_stack.append(loop_info)
        self.generic_visit(node)
        
        loop_context = self.loop_stack.pop()
        if loop_context['queries']:
            for query_info in loop_context['queries']:
                fix = self._generate_fix_for_query(query_info, loop_context)
                if fix:
                    self.fixes.append(fix)
    
    def visit_Call(self, node: ast.Call) -> None:
        """Check for database queries inside loops."""
        if self.loop_stack:  # We're inside a loop
            call_code = self._get_code_from_node(node)
            
            if self.orm_detector.is_database_query(call_code, self.orm_framework):
                query_info = {
                    'code': call_code,
                    'line': node.lineno,
                    'full_line': self.source_lines[node.lineno - 1].strip(),
                    'node': node
                }
                
                self.loop_stack[-1]['queries'].append(query_info)
        
        self.generic_visit(node)
    
    def _get_loop_variable(self, node: ast.For) -> str:
        """Extract loop variable name."""
        if isinstance(node.target, ast.Name):
            return node.target.id
        elif isinstance(node.target, ast.Tuple):
            return ', '.join(self._get_name_from_target(elt) for elt in node.target.elts)
        else:
            return 'item'
    
    def _get_name_from_target(self, target: ast.AST) -> str:
        """Get name from assignment target."""
        if isinstance(target, ast.Name):
            return target.id
        else:
            return str(target)
    
    def _get_code_from_node(self, node: ast.AST) -> str:
        """Extract code from AST node."""
        try:
            return ast.unparse(node)
        except:
            # Fallback for older Python versions
            return self.source_lines[node.lineno - 1].strip()
    
    def _generate_fix_for_query(self, query_info: Dict, loop_context: Dict) -> Optional[N1QueryFix]:
        """Generate appropriate fix for the detected N+1 query."""
        # Get surrounding context (few lines before and after)
        start_line = max(0, query_info['line'] - 3)
        end_line = min(len(self.source_lines), query_info['line'] + 2)
        context = '\n'.join(self.source_lines[start_line:end_line])
        
        # Generate fix based on ORM framework
        if self.orm_framework == 'django':
            fix = self.fix_generator.generate_django_fix(
                loop_context['variable'],
                query_info['code'],
                context
            )
        elif self.orm_framework == 'sqlalchemy':
            fix = self.fix_generator.generate_sqlalchemy_fix(
                loop_context['variable'],
                query_info['code'],
                context
            )
        else:
            fix = self.fix_generator.generate_generic_fix(
                loop_context['variable'],
                query_info['code'],
                context
            )
        
        # Update fix with actual file information
        fix.file_path = self.file_path
        fix.line_number = query_info['line']
        
        return fix


class N1QueryFixer:
    """Main class for finding and fixing N+1 query problems."""
    
    def __init__(self, root_path: str = "."):
        self.root_path = Path(root_path)
        self.fixes: List[N1QueryFix] = []
    
    def analyze_and_fix(self) -> List[N1QueryFix]:
        """Analyze files and generate fixes."""
        print("🔍 Analyzing N+1 Query Problems...")
        
        python_files = list(self.root_path.rglob("*.py"))
        
        for file_path in python_files:
            if self._should_skip_file(file_path):
                continue
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    source_code = f.read()
                
                detector = N1QueryDetectorWithFixes(str(file_path), source_code)
                detector.visit(ast.parse(source_code))
                
                self.fixes.extend(detector.fixes)
                
            except Exception as e:
                print(f"❌ Error analyzing {file_path}: {e}")
                continue
        
        return self.fixes
    
    def _should_skip_file(self, file_path: Path) -> bool:
        """Check if file should be skipped."""
        skip_patterns = [
            '__pycache__', '.git', 'venv', 'env', 'node_modules',
            '.pytest_cache', '.mypy_cache', 'migrations'
        ]
        
        return any(pattern in str(file_path) for pattern in skip_patterns)
    
    def apply_fixes(self, fixes: List[N1QueryFix], auto_apply: bool = False) -> None:
        """Apply suggested fixes to files."""
        if not fixes:
            print("✅ No N+1 query issues found!")
            return
        
        print(f"\n🔧 Found {len(fixes)} potential N+1 query issues:")
        
        for i, fix in enumerate(fixes, 1):
            print(f"\n--- Issue #{i} ---")
            print(f"📁 File: {fix.file_path}:{fix.line_number}")
            print(f"🎯 Confidence: {fix.confidence:.1%}")
            print(f"📝 Problem: {fix.original_code}")
            print(f"💡 Suggested Fix ({fix.fix_type}):")
            print(f"   {fix.suggested_fix}")
            print(f"ℹ️  Explanation: {fix.explanation}")
            
            if not auto_apply:
                apply = input("Apply this fix? (y/n/s=skip all): ").lower()
                if apply == 's':
                    break
                elif apply == 'y':
                    self._apply_single_fix(fix)
            else:
                if fix.confidence > 0.7:  # Only apply high-confidence fixes
                    self._apply_single_fix(fix)
    
    def _apply_single_fix(self, fix: N1QueryFix) -> None:
        """Apply a single fix to a file."""
        try:
            with open(fix.file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # Add comment with suggestion above the problematic line
            line_index = fix.line_number - 1
            indent = len(lines[line_index]) - len(lines[line_index].lstrip())
            
            comment = f"{' ' * indent}# N+1 Query Fix Suggestion ({fix.fix_type}):\n"
            comment += f"{' ' * indent}# {fix.explanation}\n"
            
            # Insert fix suggestions as comments
            lines.insert(line_index, comment)
            
            with open(fix.file_path, 'w', encoding='utf-8') as f:
                f.writelines(lines)
            
            print(f"✅ Applied fix to {fix.file_path}:{fix.line_number}")
            
        except Exception as e:
            print(f"❌ Error applying fix to {fix.file_path}: {e}")
    
    def generate_report(self, fixes: List[N1QueryFix]) -> str:
        """Generate a detailed report of N+1 query issues."""
        if not fixes:
            return "# N+1 Query Analysis Report\n\n✅ No N+1 query issues detected!"
        
        report = ["# 🚀 N+1 Query Analysis Report", ""]
        
        # Summary
        high_confidence = [f for f in fixes if f.confidence > 0.7]
        by_framework = {}
        for fix in fixes:
            framework = fix.fix_type
            by_framework[framework] = by_framework.get(framework, 0) + 1
        
        report.extend([
            f"## 📊 Summary",
            f"- **Total Issues**: {len(fixes)}",
            f"- **High Confidence**: {len(high_confidence)}",
            f"- **Fix Types**: {', '.join(f'{k}: {v}' for k, v in by_framework.items())}",
            ""
        ])
        
        # Detailed Issues
        report.extend([
            "## 🔍 Detailed Issues",
            ""
        ])
        
        for i, fix in enumerate(fixes, 1):
            confidence_emoji = "🟢" if fix.confidence > 0.7 else "🟡" if fix.confidence > 0.5 else "🔴"
            
            report.extend([
                f"### {i}. {fix.fix_type.title()} Issue {confidence_emoji}",
                f"**File**: `{fix.file_path}:{fix.line_number}`",
                f"**Confidence**: {fix.confidence:.1%}",
                "",
                f"**Problematic Code**:",
                f"```python",
                fix.original_code,
                f"```",
                "",
                f"**Suggested Fix**:",
                f"```python",
                fix.suggested_fix,
                f"```",
                "",
                f"**Explanation**: {fix.explanation}",
                "",
                "---",
                ""
            ])
        
        # Best Practices
        report.extend([
            "## 💡 Best Practices for Avoiding N+1 Queries",
            "",
            "### Django ORM",
            "- Use `select_related()` for ForeignKey and OneToOne relationships",
            "- Use `prefetch_related()` for ManyToMany and reverse ForeignKey relationships",
            "- Use `only()` and `defer()` to limit fields loaded",
            "",
            "### SQLAlchemy",
            "- Use `joinedload()` for eager loading relationships",
            "- Use `selectinload()` for collections",
            "- Use `contains_eager()` with explicit joins",
            "",
            "### General Tips",
            "- Batch database operations when possible",
            "- Use database-level aggregations instead of Python loops",
            "- Consider caching for frequently accessed data",
            "- Profile your queries to identify bottlenecks",
            ""
        ])
        
        return "\n".join(report)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Find and fix N+1 query problems")
    parser.add_argument("--path", "-p", default=".", help="Path to analyze")
    parser.add_argument("--output", "-o", help="Output file for report")
    parser.add_argument("--fix", action="store_true", help="Apply suggested fixes")
    parser.add_argument("--auto", action="store_true", help="Auto-apply high confidence fixes")
    
    args = parser.parse_args()
    
    fixer = N1QueryFixer(args.path)
    fixes = fixer.analyze_and_fix()
    
    if args.fix:
        fixer.apply_fixes(fixes, auto_apply=args.auto)
    
    report = fixer.generate_report(fixes)
    
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"📝 Report saved to {args.output}")
    else:
        print(report)
    
    return len(fixes)


if __name__ == "__main__":
    exit_code = main()
    exit(min(exit_code, 127))  # Limit exit code to valid range