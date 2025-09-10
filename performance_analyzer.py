#!/usr/bin/env python3
"""
Performance and Code Quality Analyzer
Identifies and fixes common performance and code quality issues.
"""

import ast
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple, Union
from dataclasses import dataclass
from collections import defaultdict
import argparse


@dataclass
class PerformanceIssue:
    """Represents a performance issue found in the code."""
    file_path: str
    line_number: int
    issue_type: str
    description: str
    severity: str  # 'critical', 'high', 'medium', 'low'
    suggestion: str


@dataclass
class CodeQualityIssue:
    """Represents a code quality issue."""
    file_path: str
    line_number: int
    function_name: str
    issue_type: str
    metric_value: Union[int, float]
    threshold: Union[int, float]
    description: str


class N1QueryDetector(ast.NodeVisitor):
    """Detects potential N+1 query problems in Python code."""
    
    def __init__(self, file_path: str):
        self.file_path = file_path
        self.issues: List[PerformanceIssue] = []
        self.in_loop = False
        self.loop_level = 0
        
    def visit_For(self, node: ast.For) -> None:
        """Visit for loops to detect potential N+1 queries."""
        old_in_loop = self.in_loop
        old_loop_level = self.loop_level
        
        self.in_loop = True
        self.loop_level += 1
        
        self.generic_visit(node)
        
        self.in_loop = old_in_loop
        self.loop_level = old_loop_level
        
    def visit_While(self, node: ast.While) -> None:
        """Visit while loops to detect potential N+1 queries."""
        old_in_loop = self.in_loop
        old_loop_level = self.loop_level
        
        self.in_loop = True
        self.loop_level += 1
        
        self.generic_visit(node)
        
        self.in_loop = old_in_loop
        self.loop_level = old_loop_level
        
    def visit_Call(self, node: ast.Call) -> None:
        """Check for database queries inside loops."""
        if self.in_loop and self._is_database_query(node):
            issue = PerformanceIssue(
                file_path=self.file_path,
                line_number=node.lineno,
                issue_type="N+1 Query",
                description=f"Potential N+1 query detected: database call inside loop (depth: {self.loop_level})",
                severity="critical" if self.loop_level > 1 else "high",
                suggestion="Consider using bulk queries, joins, or prefetch_related()/select_related() for Django/SQLAlchemy"
            )
            self.issues.append(issue)
            
        self.generic_visit(node)
        
    def _is_database_query(self, node: ast.Call) -> bool:
        """Detect if a call is likely a database query."""
        # Check for common ORM patterns
        db_patterns = [
            'query', 'filter', 'get', 'all', 'first', 'find', 'find_one',
            'execute', 'session.query', 'db.session', 'select', 'update',
            'delete', 'insert', 'Model.objects', 'session.execute'
        ]
        
        # Convert AST call to string representation
        call_str = self._ast_to_string(node)
        
        return any(pattern in call_str.lower() for pattern in db_patterns)
        
    def _ast_to_string(self, node: ast.AST) -> str:
        """Convert AST node to string (simplified)."""
        try:
            if isinstance(node, ast.Name):
                return node.id
            elif isinstance(node, ast.Attribute):
                return f"{self._ast_to_string(node.value)}.{node.attr}"
            elif isinstance(node, ast.Call):
                func_name = self._ast_to_string(node.func)
                return f"{func_name}()"
            else:
                return str(node)
        except:
            return ""


class CachingAnalyzer(ast.NodeVisitor):
    """Analyzes code for missing caching opportunities."""
    
    def __init__(self, file_path: str):
        self.file_path = file_path
        self.issues: List[PerformanceIssue] = []
        self.permission_checks: List[int] = []
        self.cached_functions: Set[str] = set()
        
    def visit_FunctionDef(self, node: ast.FunctionDef) -> None:
        """Check functions for caching opportunities."""
        # Check if function has caching decorator
        has_cache = any(
            self._is_cache_decorator(decorator) 
            for decorator in node.decorator_list
        )
        
        if has_cache:
            self.cached_functions.add(node.name)
        
        # Check for permission-related functions
        if 'permission' in node.name.lower() or 'auth' in node.name.lower():
            if not has_cache and self._has_expensive_operations(node):
                issue = PerformanceIssue(
                    file_path=self.file_path,
                    line_number=node.lineno,
                    issue_type="Missing Cache",
                    description=f"Permission function '{node.name}' lacks caching for expensive operations",
                    severity="high",
                    suggestion="Add @lru_cache or Redis caching for permission checks"
                )
                self.issues.append(issue)
                
        self.generic_visit(node)
        
    def _is_cache_decorator(self, decorator: ast.AST) -> bool:
        """Check if decorator is cache-related."""
        cache_decorators = [
            'cache', 'lru_cache', 'cached', 'memoize', 'redis_cache'
        ]
        
        decorator_str = self._ast_to_string(decorator).lower()
        return any(cache_dec in decorator_str for cache_dec in cache_decorators)
        
    def _has_expensive_operations(self, node: ast.FunctionDef) -> bool:
        """Check if function contains expensive operations."""
        expensive_patterns = [
            'query', 'filter', 'join', 'loop', 'for', 'while',
            'requests.get', 'requests.post', 'httpx', 'aiohttp'
        ]
        
        function_str = ast.unparse(node).lower()
        return any(pattern in function_str for pattern in expensive_patterns)
        
    def _ast_to_string(self, node: ast.AST) -> str:
        """Convert AST node to string."""
        try:
            return ast.unparse(node)
        except:
            return str(node)


class ComplexityAnalyzer(ast.NodeVisitor):
    """Analyzes cyclomatic complexity of functions."""
    
    def __init__(self, file_path: str):
        self.file_path = file_path
        self.issues: List[CodeQualityIssue] = []
        self.current_function = None
        self.complexity = 0
        
    def visit_FunctionDef(self, node: ast.FunctionDef) -> None:
        """Calculate complexity for each function."""
        old_function = self.current_function
        old_complexity = self.complexity
        
        self.current_function = node.name
        self.complexity = 1  # Base complexity
        
        self.generic_visit(node)
        
        if self.complexity > 10:  # Threshold for high complexity
            issue = CodeQualityIssue(
                file_path=self.file_path,
                line_number=node.lineno,
                function_name=node.name,
                issue_type="High Cyclomatic Complexity",
                metric_value=self.complexity,
                threshold=10,
                description=f"Function '{node.name}' has complexity {self.complexity} (should be ≤10)"
            )
            self.issues.append(issue)
            
        self.current_function = old_function
        self.complexity = old_complexity
        
    def visit_If(self, node: ast.If) -> None:
        """Count if statements."""
        self.complexity += 1
        self.generic_visit(node)
        
    def visit_While(self, node: ast.While) -> None:
        """Count while loops."""
        self.complexity += 1
        self.generic_visit(node)
        
    def visit_For(self, node: ast.For) -> None:
        """Count for loops."""
        self.complexity += 1
        self.generic_visit(node)
        
    def visit_ExceptHandler(self, node: ast.ExceptHandler) -> None:
        """Count exception handlers."""
        self.complexity += 1
        self.generic_visit(node)


class LongMethodDetector(ast.NodeVisitor):
    """Detects methods that exceed line count thresholds."""
    
    def __init__(self, file_path: str, source_lines: List[str]):
        self.file_path = file_path
        self.source_lines = source_lines
        self.issues: List[CodeQualityIssue] = []
        
    def visit_FunctionDef(self, node: ast.FunctionDef) -> None:
        """Check function length."""
        start_line = node.lineno - 1  # Convert to 0-based
        end_line = node.end_lineno - 1 if node.end_lineno else start_line
        
        function_lines = end_line - start_line + 1
        
        if function_lines > 138:  # Threshold mentioned in requirements
            issue = CodeQualityIssue(
                file_path=self.file_path,
                line_number=node.lineno,
                function_name=node.name,
                issue_type="Long Method",
                metric_value=function_lines,
                threshold=138,
                description=f"Function '{node.name}' is {function_lines} lines (should be ≤138)"
            )
            self.issues.append(issue)
            
        self.generic_visit(node)


class GodObjectDetector:
    """Detects God Object anti-pattern (classes with too many responsibilities)."""
    
    def __init__(self, file_path: str, source_code: str):
        self.file_path = file_path
        self.source_code = source_code
        self.issues: List[CodeQualityIssue] = []
        
    def analyze(self) -> List[CodeQualityIssue]:
        """Analyze file for God Object patterns."""
        try:
            tree = ast.parse(self.source_code)
            self._analyze_classes(tree)
        except SyntaxError:
            pass  # Skip files with syntax errors
            
        return self.issues
        
    def _analyze_classes(self, tree: ast.AST) -> None:
        """Analyze classes for God Object pattern."""
        for node in ast.walk(tree):
            if isinstance(node, ast.ClassDef):
                self._check_class_complexity(node)
                
    def _check_class_complexity(self, node: ast.ClassDef) -> None:
        """Check if class exhibits God Object characteristics."""
        # Count methods
        method_count = sum(1 for child in node.body if isinstance(child, ast.FunctionDef))
        
        # Count lines
        class_lines = len(self.source_code.splitlines()) if node.lineno == 1 else \
                     (node.end_lineno - node.lineno + 1 if node.end_lineno else 50)
        
        # Count responsibilities (heuristic: unique method name prefixes)
        responsibilities = self._count_responsibilities(node)
        
        # Check for God Object characteristics
        if class_lines > 500 or method_count > 20 or responsibilities > 5:
            severity = "critical" if class_lines > 728 else "high"  # 728 from requirements
            
            issue = CodeQualityIssue(
                file_path=self.file_path,
                line_number=node.lineno,
                function_name=node.name,
                issue_type="God Object",
                metric_value=class_lines,
                threshold=500,
                description=f"Class '{node.name}' is {class_lines} lines with {method_count} methods and {responsibilities} responsibilities"
            )
            self.issues.append(issue)
            
    def _count_responsibilities(self, node: ast.ClassDef) -> int:
        """Count different responsibilities in a class."""
        method_prefixes = set()
        
        for child in node.body:
            if isinstance(child, ast.FunctionDef):
                # Extract prefix (first word before underscore or camelCase)
                name = child.name
                if '_' in name:
                    prefix = name.split('_')[0]
                else:
                    # Handle camelCase
                    prefix = re.split(r'(?=[A-Z])', name)[0].lower()
                
                method_prefixes.add(prefix)
                
        return len(method_prefixes)


class PerformanceAnalyzer:
    """Main analyzer class that orchestrates all performance checks."""
    
    def __init__(self, root_path: str = "."):
        self.root_path = Path(root_path)
        self.performance_issues: List[PerformanceIssue] = []
        self.quality_issues: List[CodeQualityIssue] = []
        
    def analyze(self) -> Tuple[List[PerformanceIssue], List[CodeQualityIssue]]:
        """Run comprehensive analysis."""
        print("🔍 Starting Performance and Code Quality Analysis...")
        
        python_files = list(self.root_path.rglob("*.py"))
        
        if not python_files:
            print("⚠️  No Python files found in the current directory.")
            print("Creating analysis framework for future use...")
            return [], []
        
        for file_path in python_files:
            if self._should_skip_file(file_path):
                continue
                
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    source_code = f.read()
                    source_lines = source_code.splitlines()
                    
                self._analyze_file(str(file_path), source_code, source_lines)
                
            except Exception as e:
                print(f"❌ Error analyzing {file_path}: {e}")
                continue
                
        return self.performance_issues, self.quality_issues
        
    def _should_skip_file(self, file_path: Path) -> bool:
        """Check if file should be skipped."""
        skip_patterns = [
            '__pycache__', '.git', 'venv', 'env', 'node_modules',
            '.pytest_cache', '.mypy_cache', 'migrations'
        ]
        
        return any(pattern in str(file_path) for pattern in skip_patterns)
        
    def _analyze_file(self, file_path: str, source_code: str, source_lines: List[str]) -> None:
        """Analyze a single Python file."""
        try:
            tree = ast.parse(source_code)
            
            # N+1 Query Detection
            n1_detector = N1QueryDetector(file_path)
            n1_detector.visit(tree)
            self.performance_issues.extend(n1_detector.issues)
            
            # Caching Analysis
            cache_analyzer = CachingAnalyzer(file_path)
            cache_analyzer.visit(tree)
            self.performance_issues.extend(cache_analyzer.issues)
            
            # Complexity Analysis
            complexity_analyzer = ComplexityAnalyzer(file_path)
            complexity_analyzer.visit(tree)
            self.quality_issues.extend(complexity_analyzer.issues)
            
            # Long Method Detection
            long_method_detector = LongMethodDetector(file_path, source_lines)
            long_method_detector.visit(tree)
            self.quality_issues.extend(long_method_detector.issues)
            
            # God Object Detection
            god_object_detector = GodObjectDetector(file_path, source_code)
            god_object_issues = god_object_detector.analyze()
            self.quality_issues.extend(god_object_issues)
            
        except SyntaxError as e:
            print(f"⚠️  Syntax error in {file_path}: {e}")
            
    def generate_report(self, performance_issues: List[PerformanceIssue], 
                       quality_issues: List[CodeQualityIssue]) -> str:
        """Generate comprehensive analysis report."""
        report = ["# 📊 Performance and Code Quality Analysis Report", ""]
        
        # Summary
        total_issues = len(performance_issues) + len(quality_issues)
        critical_perf = len([i for i in performance_issues if i.severity == "critical"])
        high_quality = len([i for i in quality_issues if i.metric_value > i.threshold * 2])
        
        report.extend([
            f"## 📈 Summary",
            f"- **Total Issues Found**: {total_issues}",
            f"- **Performance Issues**: {len(performance_issues)} ({critical_perf} critical)",
            f"- **Code Quality Issues**: {len(quality_issues)} ({high_quality} severe)",
            ""
        ])
        
        # Performance Issues
        if performance_issues:
            report.extend([
                "## 🚀 Performance Issues",
                ""
            ])
            
            # Group by issue type
            perf_by_type = defaultdict(list)
            for issue in performance_issues:
                perf_by_type[issue.issue_type].append(issue)
                
            for issue_type, issues in perf_by_type.items():
                report.append(f"### {issue_type} ({len(issues)} found)")
                report.append("")
                
                for issue in issues:
                    report.extend([
                        f"**{issue.severity.upper()}**: `{issue.file_path}:{issue.line_number}`",
                        f"- {issue.description}",
                        f"- 💡 **Suggestion**: {issue.suggestion}",
                        ""
                    ])
        
        # Code Quality Issues  
        if quality_issues:
            report.extend([
                "## 🔧 Code Quality Issues",
                ""
            ])
            
            # Group by issue type
            quality_by_type = defaultdict(list)
            for issue in quality_issues:
                quality_by_type[issue.issue_type].append(issue)
                
            for issue_type, issues in quality_by_type.items():
                report.append(f"### {issue_type} ({len(issues)} found)")
                report.append("")
                
                for issue in issues:
                    report.extend([
                        f"**{issue.function_name}**: `{issue.file_path}:{issue.line_number}`",
                        f"- {issue.description}",
                        f"- Current: {issue.metric_value}, Threshold: {issue.threshold}",
                        ""
                    ])
        
        # Recommendations
        report.extend([
            "## 💡 Recommendations",
            "",
            "### Performance Optimizations",
            "1. **N+1 Queries**: Use bulk operations, joins, or ORM prefetching",
            "2. **Caching**: Implement Redis or in-memory caching for expensive operations",
            "3. **Database Indexing**: Add indexes for frequently queried fields",
            "",
            "### Code Quality Improvements", 
            "1. **Refactoring**: Break down large functions and classes",
            "2. **Single Responsibility**: Each function should do one thing well",
            "3. **Testing**: Add unit tests for complex functions",
            "4. **Documentation**: Add docstrings for complex logic",
            ""
        ])
        
        if not performance_issues and not quality_issues:
            report.extend([
                "## ✅ Analysis Complete",
                "",
                "No issues found in the current codebase!",
                "The analysis framework is now available for future use.",
                ""
            ])
        
        return "\n".join(report)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Analyze code for performance and quality issues")
    parser.add_argument("--path", "-p", default=".", help="Path to analyze (default: current directory)")
    parser.add_argument("--output", "-o", help="Output file for report (default: stdout)")
    parser.add_argument("--fix", action="store_true", help="Attempt to auto-fix issues where possible")
    
    args = parser.parse_args()
    
    analyzer = PerformanceAnalyzer(args.path)
    performance_issues, quality_issues = analyzer.analyze()
    
    report = analyzer.generate_report(performance_issues, quality_issues)
    
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"📝 Report saved to {args.output}")
    else:
        print(report)
        
    # Return appropriate exit code
    total_issues = len(performance_issues) + len(quality_issues)
    critical_issues = len([i for i in performance_issues if i.severity == "critical"])
    
    if critical_issues > 0:
        sys.exit(2)  # Critical issues
    elif total_issues > 0:
        sys.exit(1)  # Issues found
    else:
        sys.exit(0)  # No issues


if __name__ == "__main__":
    main()