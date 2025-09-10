#!/usr/bin/env python3
"""
Test Coverage Analyzer
Analyzes test coverage, identifies gaps, and generates test implementations.
"""

import ast
import json
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple, Union
import argparse


@dataclass
class CoverageGap:
    """Represents a test coverage gap."""
    file_path: str
    function_name: str
    line_number: int
    gap_type: str  # 'untested_function', 'untested_branch', 'untested_exception', 'untested_edge_case'
    severity: str  # 'critical', 'high', 'medium', 'low'
    suggested_test: str
    explanation: str


@dataclass
class TestSuggestion:
    """Suggested test implementation."""
    test_name: str
    test_code: str
    test_type: str  # 'unit', 'integration', 'edge_case', 'exception'
    coverage_target: str
    rationale: str


class FunctionAnalyzer(ast.NodeVisitor):
    """Analyzes functions to understand testing requirements."""
    
    def __init__(self, file_path: str, source_code: str):
        self.file_path = file_path
        self.source_code = source_code
        self.functions: List[Dict] = []
        self.current_class = None
    
    def visit_ClassDef(self, node: ast.ClassDef) -> None:
        """Track current class context."""
        old_class = self.current_class
        self.current_class = node.name
        self.generic_visit(node)
        self.current_class = old_class
    
    def visit_FunctionDef(self, node: ast.FunctionDef) -> None:
        """Analyze functions for test requirements."""
        # Skip private methods and test methods
        if node.name.startswith('_') or node.name.startswith('test_'):
            return
        
        function_info = {
            'name': node.name,
            'class_name': self.current_class,
            'line_number': node.lineno,
            'args': [arg.arg for arg in node.args.args if arg.arg != 'self'],
            'returns': self._analyze_return_statements(node),
            'raises': self._analyze_exceptions(node),
            'branches': self._count_branches(node),
            'complexity': self._estimate_complexity(node),
            'dependencies': self._find_dependencies(node),
            'async': isinstance(node, ast.AsyncFunctionDef),
            'decorators': [ast.unparse(dec) for dec in node.decorator_list]
        }
        
        self.functions.append(function_info)
        self.generic_visit(node)
    
    def _analyze_return_statements(self, node: ast.FunctionDef) -> List[str]:
        """Analyze return statements to understand possible return types."""
        returns = []
        for child in ast.walk(node):
            if isinstance(child, ast.Return) and child.value:
                try:
                    return_expr = ast.unparse(child.value)
                    returns.append(return_expr)
                except:
                    returns.append("unknown_return")
        
        return returns if returns else ['None']
    
    def _analyze_exceptions(self, node: ast.FunctionDef) -> List[str]:
        """Find exceptions that can be raised."""
        exceptions = []
        for child in ast.walk(node):
            if isinstance(child, ast.Raise) and child.exc:
                if isinstance(child.exc, ast.Call):
                    if isinstance(child.exc.func, ast.Name):
                        exceptions.append(child.exc.func.id)
                elif isinstance(child.exc, ast.Name):
                    exceptions.append(child.exc.id)
        
        return exceptions
    
    def _count_branches(self, node: ast.FunctionDef) -> int:
        """Count branching points (if, for, while, try)."""
        branches = 0
        for child in ast.walk(node):
            if isinstance(child, (ast.If, ast.For, ast.While, ast.Try)):
                branches += 1
        return branches
    
    def _estimate_complexity(self, node: ast.FunctionDef) -> str:
        """Estimate testing complexity."""
        branches = self._count_branches(node)
        args_count = len(node.args.args)
        returns_count = len(self._analyze_return_statements(node))
        
        if branches > 5 or args_count > 4:
            return 'high'
        elif branches > 2 or args_count > 2:
            return 'medium'
        else:
            return 'low'
    
    def _find_dependencies(self, node: ast.FunctionDef) -> List[str]:
        """Find external dependencies (imports, calls)."""
        dependencies = []
        
        for child in ast.walk(node):
            if isinstance(child, ast.Call):
                if isinstance(child.func, ast.Name):
                    dependencies.append(child.func.id)
                elif isinstance(child.func, ast.Attribute):
                    dependencies.append(ast.unparse(child.func))
        
        return list(set(dependencies))


class TestExistenceChecker:
    """Checks if tests exist for given functions."""
    
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.test_patterns = [
            "**/test_*.py",
            "**/tests/*.py", 
            "**/*_test.py",
            "**/tests/**/*.py"
        ]
    
    def find_test_files(self) -> List[Path]:
        """Find all test files in the project."""
        test_files = []
        for pattern in self.test_patterns:
            test_files.extend(self.project_root.glob(pattern))
        return test_files
    
    def find_tests_for_function(self, function_name: str, class_name: Optional[str] = None) -> List[str]:
        """Find existing tests for a specific function."""
        test_files = self.find_test_files()
        found_tests = []
        
        for test_file in test_files:
            try:
                with open(test_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Look for test methods that might test this function
                possible_test_names = [
                    f"test_{function_name}",
                    f"test_{function_name.lower()}",
                    f"test_{class_name.lower()}_{function_name}" if class_name else None
                ]
                
                for test_name in possible_test_names:
                    if test_name and f"def {test_name}" in content:
                        found_tests.append(f"{test_file}::{test_name}")
                
            except Exception:
                continue
        
        return found_tests
    
    def get_coverage_report(self) -> Dict[str, float]:
        """Get coverage report using coverage.py if available."""
        try:
            # Try to run coverage report
            result = subprocess.run(
                ['coverage', 'report', '--format=json'],
                capture_output=True,
                text=True,
                cwd=self.project_root
            )
            
            if result.returncode == 0:
                coverage_data = json.loads(result.stdout)
                file_coverage = {}
                
                for file_info in coverage_data.get('files', []):
                    file_coverage[file_info['filename']] = file_info['summary']['percent_covered']
                
                return file_coverage
            
        except (subprocess.SubprocessError, json.JSONDecodeError, FileNotFoundError):
            pass
        
        return {}


class TestGenerator:
    """Generates test code for uncovered functions."""
    
    def __init__(self):
        self.test_frameworks = {
            'pytest': self._generate_pytest_test,
            'unittest': self._generate_unittest_test
        }
    
    def generate_test_for_function(self, func_info: Dict, framework: str = 'pytest') -> TestSuggestion:
        """Generate test code for a function."""
        generator = self.test_frameworks.get(framework, self._generate_pytest_test)
        return generator(func_info)
    
    def _generate_pytest_test(self, func_info: Dict) -> TestSuggestion:
        """Generate pytest-style test."""
        function_name = func_info['name']
        class_name = func_info['class_name']
        args = func_info['args']
        returns = func_info['returns']
        raises = func_info['raises']
        complexity = func_info['complexity']
        
        # Generate test name
        test_name = f"test_{function_name.lower()}"
        if class_name:
            test_name = f"test_{class_name.lower()}_{function_name.lower()}"
        
        # Generate test code
        test_code = self._build_pytest_code(func_info, test_name)
        
        # Determine test type
        test_type = 'unit'
        if complexity == 'high' or len(raises) > 0:
            test_type = 'integration'
        
        return TestSuggestion(
            test_name=test_name,
            test_code=test_code,
            test_type=test_type,
            coverage_target=f"{class_name}.{function_name}" if class_name else function_name,
            rationale=self._generate_test_rationale(func_info)
        )
    
    def _build_pytest_code(self, func_info: Dict, test_name: str) -> str:
        """Build pytest test code."""
        function_name = func_info['name']
        class_name = func_info['class_name']
        args = func_info['args']
        returns = func_info['returns']
        raises = func_info['raises']
        is_async = func_info['async']
        
        lines = []
        
        # Imports
        lines.extend([
            "import pytest",
            "from unittest.mock import Mock, patch",
            ""
        ])
        
        if class_name:
            lines.append(f"from your_module import {class_name}")
        else:
            lines.append(f"from your_module import {function_name}")
        lines.append("")
        
        # Test fixtures if needed
        if class_name:
            lines.extend([
                "@pytest.fixture",
                f"def {class_name.lower()}_instance():",
                f"    return {class_name}()",
                ""
            ])
        
        # Main test function
        async_prefix = "async " if is_async else ""
        fixture_param = f"{class_name.lower()}_instance" if class_name else ""
        
        lines.append(f"{async_prefix}def {test_name}({fixture_param}):")
        lines.append('    """Test the basic functionality."""')
        
        # Test setup
        if args:
            lines.append("    # Arrange")
            for arg in args[:3]:  # Limit to first 3 args
                lines.append(f"    {arg} = None  # TODO: Provide appropriate test value")
        
        lines.append("")
        lines.append("    # Act")
        
        # Function call
        if class_name:
            call_args = ", ".join(args[:3]) if args else ""
            call = f"{class_name.lower()}_instance.{function_name}({call_args})"
        else:
            call_args = ", ".join(args[:3]) if args else ""
            call = f"{function_name}({call_args})"
        
        if is_async:
            call = f"await {call}"
        
        lines.append(f"    result = {call}")
        lines.append("")
        
        # Assertions
        lines.append("    # Assert")
        if 'None' not in returns:
            lines.append("    assert result is not None")
        
        lines.append("    # TODO: Add specific assertions based on expected behavior")
        lines.append("")
        
        # Exception tests
        if raises:
            for exception in raises[:2]:  # Limit to first 2 exceptions
                lines.extend([
                    f"{async_prefix}def {test_name}_{exception.lower()}({fixture_param}):",
                    f'    """Test {exception} handling."""',
                    "    # TODO: Set up conditions that trigger the exception",
                    "",
                    f"    with pytest.raises({exception}):",
                    f"        {'await ' if is_async else ''}{call}",
                    ""
                ])
        
        # Edge case tests
        if func_info['complexity'] in ['medium', 'high']:
            lines.extend([
                f"{async_prefix}def {test_name}_edge_cases({fixture_param}):",
                f'    """Test edge cases and boundary conditions."""',
                "    # TODO: Test with empty/null inputs",
                "    # TODO: Test with maximum/minimum values",
                "    # TODO: Test with invalid inputs",
                "    pass",
                ""
            ])
        
        return "\n".join(lines)
    
    def _generate_unittest_test(self, func_info: Dict) -> TestSuggestion:
        """Generate unittest-style test."""
        function_name = func_info['name']
        class_name = func_info['class_name']
        
        test_name = f"Test{class_name or function_name.title()}"
        
        lines = [
            "import unittest",
            "from unittest.mock import Mock, patch",
            "",
            f"from your_module import {class_name or function_name}",
            "",
            f"class {test_name}(unittest.TestCase):",
            f'    """Test cases for {class_name or function_name}."""',
            ""
        ]
        
        if class_name:
            lines.extend([
                "    def setUp(self):",
                f"        self.instance = {class_name}()",
                ""
            ])
        
        lines.extend([
            f"    def test_{function_name.lower()}_basic(self):",
            f'        """Test basic functionality of {function_name}."""',
            "        # TODO: Implement test",
            "        pass",
            "",
            "if __name__ == '__main__':",
            "    unittest.main()"
        ])
        
        test_code = "\n".join(lines)
        
        return TestSuggestion(
            test_name=test_name,
            test_code=test_code,
            test_type='unit',
            coverage_target=f"{class_name}.{function_name}" if class_name else function_name,
            rationale=self._generate_test_rationale(func_info)
        )
    
    def _generate_test_rationale(self, func_info: Dict) -> str:
        """Generate rationale for why this test is needed."""
        complexity = func_info['complexity']
        branches = func_info['branches']
        exceptions = func_info['raises']
        
        rationale_parts = []
        
        if complexity == 'high':
            rationale_parts.append("High complexity function requires thorough testing")
        
        if branches > 3:
            rationale_parts.append(f"Function has {branches} branching points that need coverage")
        
        if exceptions:
            rationale_parts.append(f"Exception handling for {', '.join(exceptions)} needs testing")
        
        if not rationale_parts:
            rationale_parts.append("Basic functionality testing to ensure correctness")
        
        return ". ".join(rationale_parts) + "."


class CoverageAnalyzer:
    """Main coverage analysis orchestrator."""
    
    def __init__(self, root_path: str = "."):
        self.root_path = Path(root_path)
        self.gaps: List[CoverageGap] = []
        self.test_checker = TestExistenceChecker(self.root_path)
        self.test_generator = TestGenerator()
    
    def analyze_coverage_gaps(self) -> List[CoverageGap]:
        """Analyze test coverage gaps."""
        print("🔍 Analyzing test coverage gaps...")
        
        python_files = [f for f in self.root_path.rglob("*.py") 
                       if not self._is_test_file(f) and not self._should_skip_file(f)]
        
        for file_path in python_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    source_code = f.read()
                
                analyzer = FunctionAnalyzer(str(file_path), source_code)
                analyzer.visit(ast.parse(source_code))
                
                for func_info in analyzer.functions:
                    gaps = self._analyze_function_coverage(func_info, file_path)
                    self.gaps.extend(gaps)
                
            except Exception as e:
                print(f"❌ Error analyzing {file_path}: {e}")
                continue
        
        return self.gaps
    
    def _is_test_file(self, file_path: Path) -> bool:
        """Check if file is a test file."""
        file_str = str(file_path)
        return any(pattern in file_str for pattern in ['test_', '_test.py', '/tests/', '\\tests\\'])
    
    def _should_skip_file(self, file_path: Path) -> bool:
        """Check if file should be skipped."""
        skip_patterns = [
            '__pycache__', '.git', 'venv', 'env', 'node_modules',
            '.pytest_cache', '.mypy_cache', 'migrations', '__init__.py'
        ]
        
        return any(pattern in str(file_path) for pattern in skip_patterns)
    
    def _analyze_function_coverage(self, func_info: Dict, file_path: Path) -> List[CoverageGap]:
        """Analyze coverage gaps for a specific function."""
        gaps = []
        
        function_name = func_info['name']
        class_name = func_info['class_name']
        
        # Check if tests exist
        existing_tests = self.test_checker.find_tests_for_function(function_name, class_name)
        
        if not existing_tests:
            # No tests found
            gap = CoverageGap(
                file_path=str(file_path),
                function_name=function_name,
                line_number=func_info['line_number'],
                gap_type='untested_function',
                severity=self._determine_severity(func_info),
                suggested_test=self._generate_basic_test_suggestion(func_info),
                explanation=f"Function '{function_name}' has no test coverage"
            )
            gaps.append(gap)
        
        # Check for specific coverage gaps even if some tests exist
        if func_info['raises'] and not self._has_exception_tests(existing_tests):
            gap = CoverageGap(
                file_path=str(file_path),
                function_name=function_name,
                line_number=func_info['line_number'],
                gap_type='untested_exception',
                severity='medium',
                suggested_test=self._generate_exception_test_suggestion(func_info),
                explanation=f"Exception handling not tested for {', '.join(func_info['raises'])}"
            )
            gaps.append(gap)
        
        if func_info['branches'] > 2 and not self._has_branch_tests(existing_tests):
            gap = CoverageGap(
                file_path=str(file_path),
                function_name=function_name,
                line_number=func_info['line_number'],
                gap_type='untested_branch',
                severity='high' if func_info['complexity'] == 'high' else 'medium',
                suggested_test=self._generate_branch_test_suggestion(func_info),
                explanation=f"Branching logic with {func_info['branches']} branches not fully tested"
            )
            gaps.append(gap)
        
        return gaps
    
    def _determine_severity(self, func_info: Dict) -> str:
        """Determine severity of missing test coverage."""
        complexity = func_info['complexity']
        branches = func_info['branches']
        exceptions = len(func_info['raises'])
        
        if complexity == 'high' or branches > 5 or exceptions > 2:
            return 'critical'
        elif complexity == 'medium' or branches > 2 or exceptions > 0:
            return 'high'
        else:
            return 'medium'
    
    def _generate_basic_test_suggestion(self, func_info: Dict) -> str:
        """Generate basic test suggestion."""
        suggestion = self.test_generator.generate_test_for_function(func_info)
        return suggestion.test_code
    
    def _generate_exception_test_suggestion(self, func_info: Dict) -> str:
        """Generate exception test suggestion."""
        function_name = func_info['name']
        exceptions = func_info['raises']
        
        lines = []
        for exception in exceptions:
            lines.extend([
                f"def test_{function_name}_{exception.lower()}():",
                f'    """Test {exception} is properly raised."""',
                f"    with pytest.raises({exception}):",
                f"        # TODO: Set up conditions that trigger {exception}",
                f"        {function_name}(invalid_input)",
                ""
            ])
        
        return "\n".join(lines)
    
    def _generate_branch_test_suggestion(self, func_info: Dict) -> str:
        """Generate branch coverage test suggestion."""
        function_name = func_info['name']
        
        return f"""
def test_{function_name}_all_branches():
    \"\"\"Test all branching paths in {function_name}.\"\"\"
    # TODO: Test each conditional branch
    # Branch 1: Test when condition A is True
    # Branch 2: Test when condition A is False
    # Branch 3: Test edge cases for each branch
    pass
"""
    
    def _has_exception_tests(self, existing_tests: List[str]) -> bool:
        """Check if exception tests exist."""
        # Simple heuristic - look for pytest.raises or assertRaises in test names
        return any('exception' in test.lower() or 'error' in test.lower() or 'raises' in test.lower() 
                  for test in existing_tests)
    
    def _has_branch_tests(self, existing_tests: List[str]) -> bool:
        """Check if branch tests exist."""
        # Simple heuristic - multiple tests suggest branch coverage
        return len(existing_tests) > 2
    
    def generate_test_files(self, gaps: List[CoverageGap], output_dir: Optional[str] = None) -> None:
        """Generate test files for coverage gaps."""
        if not gaps:
            print("✅ No coverage gaps found!")
            return
        
        output_path = Path(output_dir) if output_dir else self.root_path / "generated_tests"
        output_path.mkdir(exist_ok=True)
        
        # Group gaps by file
        gaps_by_file = {}
        for gap in gaps:
            file_key = Path(gap.file_path).stem
            if file_key not in gaps_by_file:
                gaps_by_file[file_key] = []
            gaps_by_file[file_key].append(gap)
        
        for file_key, file_gaps in gaps_by_file.items():
            print(f"🧪 Generating tests for {file_key}...")
            
            test_file_content = self._generate_test_file_content(file_gaps)
            test_file_path = output_path / f"test_{file_key}.py"
            
            with open(test_file_path, 'w', encoding='utf-8') as f:
                f.write(test_file_content)
            
            print(f"   ✅ Generated {test_file_path}")
    
    def _generate_test_file_content(self, gaps: List[CoverageGap]) -> str:
        """Generate complete test file content."""
        lines = [
            "# Generated test file for coverage gaps",
            "# TODO: Review and customize these tests for your specific needs",
            "",
            "import pytest",
            "from unittest.mock import Mock, patch",
            "",
            "# TODO: Add appropriate imports for your modules",
            "",
        ]
        
        for gap in gaps:
            lines.extend([
                f"# Coverage gap: {gap.gap_type} for {gap.function_name}",
                f"# Severity: {gap.severity}",
                f"# {gap.explanation}",
                gap.suggested_test,
                ""
            ])
        
        return "\n".join(lines)
    
    def generate_report(self, gaps: List[CoverageGap]) -> str:
        """Generate coverage analysis report."""
        if not gaps:
            return "# 🧪 Test Coverage Analysis Report\n\n✅ Excellent test coverage! No significant gaps found."
        
        report = ["# 🧪 Test Coverage Analysis Report", ""]
        
        # Summary
        critical = len([g for g in gaps if g.severity == 'critical'])
        high = len([g for g in gaps if g.severity == 'high'])
        medium = len([g for g in gaps if g.severity == 'medium'])
        
        by_type = {}
        for gap in gaps:
            by_type[gap.gap_type] = by_type.get(gap.gap_type, 0) + 1
        
        report.extend([
            f"## 📊 Summary",
            f"- **Total Coverage Gaps**: {len(gaps)}",
            f"- **Critical**: {critical} (complex functions with no tests)",
            f"- **High**: {high} (important functions missing tests)",
            f"- **Medium**: {medium} (functions with partial coverage)",
            "",
            f"### Gap Types",
        ])
        
        for gap_type, count in by_type.items():
            gap_type_formatted = gap_type.replace('_', ' ').title()
            report.append(f"- **{gap_type_formatted}**: {count}")
        
        report.append("")
        
        # Detailed gaps
        report.extend([
            "## 🎯 Coverage Gaps Details",
            ""
        ])
        
        for i, gap in enumerate(sorted(gaps, key=lambda x: {'critical': 0, 'high': 1, 'medium': 2, 'low': 3}[x.severity]), 1):
            severity_emoji = {
                'critical': '🔴',
                'high': '🟠',
                'medium': '🟡', 
                'low': '⚪'
            }.get(gap.severity, '⚪')
            
            gap_type_formatted = gap.gap_type.replace('_', ' ').title()
            
            report.extend([
                f"### {i}. {gap.function_name}() - {gap_type_formatted} {severity_emoji}",
                f"**File**: `{gap.file_path}:{gap.line_number}`",
                f"**Issue**: {gap.explanation}",
                "",
                f"**Suggested Test**:",
                f"```python",
                gap.suggested_test.strip(),
                f"```",
                "",
                "---",
                ""
            ])
        
        # Best practices
        report.extend([
            "## 💡 Testing Best Practices",
            "",
            "### Coverage Goals",
            "- **Unit Tests**: Aim for 80-90% line coverage",
            "- **Branch Coverage**: Test all conditional paths",  
            "- **Exception Coverage**: Test error conditions",
            "- **Edge Cases**: Test boundary conditions",
            "",
            "### Testing Strategy",
            "1. **Start with Critical Functions**: Focus on high-severity gaps first",
            "2. **Test Public APIs**: Ensure all public methods are tested",
            "3. **Mock Dependencies**: Use mocks for external dependencies",
            "4. **Test Edge Cases**: Include boundary and error conditions",
            "5. **Maintain Tests**: Keep tests updated with code changes",
            "",
            "### Tools and Commands",
            "```bash",
            "# Run tests with coverage",
            "pytest --cov=your_module --cov-report=html",
            "",
            "# Generate coverage report",
            "coverage run -m pytest",
            "coverage report",
            "coverage html",
            "```",
            ""
        ])
        
        return "\n".join(report)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Analyze test coverage and generate tests")
    parser.add_argument("--path", "-p", default=".", help="Path to analyze")
    parser.add_argument("--output", "-o", help="Output file for report")
    parser.add_argument("--generate", "-g", action="store_true", 
                       help="Generate test files for coverage gaps")
    parser.add_argument("--test-dir", "-t", default="generated_tests",
                       help="Directory for generated test files")
    parser.add_argument("--framework", "-f", choices=['pytest', 'unittest'], 
                       default='pytest', help="Test framework to use")
    
    args = parser.parse_args()
    
    analyzer = CoverageAnalyzer(args.path)
    gaps = analyzer.analyze_coverage_gaps()
    
    if args.generate:
        analyzer.generate_test_files(gaps, args.test_dir)
    
    report = analyzer.generate_report(gaps)
    
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"📝 Report saved to {args.output}")
    else:
        print(report)
    
    return len(gaps)


if __name__ == "__main__":
    exit_code = main()
    exit(min(exit_code, 127))