#!/usr/bin/env python3
"""
Complexity Reduction Utility
Identifies and reduces cyclomatic complexity in code through automated refactoring.
"""

import ast
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple, Union
import argparse


@dataclass
class ComplexityIssue:
    """Represents a complexity issue in code."""
    file_path: str
    function_name: str
    line_number: int
    complexity: int
    threshold: int
    issue_type: str  # 'nested_conditions', 'long_if_chain', 'complex_loop', 'deep_nesting'
    suggested_refactoring: str
    confidence: float


@dataclass
class RefactoringStrategy:
    """Strategy for reducing complexity."""
    strategy_type: str
    original_code: str
    refactored_code: str
    explanation: str
    complexity_reduction: int


class ComplexityCalculator(ast.NodeVisitor):
    """Calculates cyclomatic complexity of functions."""
    
    def __init__(self):
        self.complexity = 0
        self.nesting_level = 0
        self.max_nesting = 0
        self.condition_chains = []
        
    def reset(self):
        """Reset calculator for new function."""
        self.complexity = 1  # Base complexity
        self.nesting_level = 0
        self.max_nesting = 0
        self.condition_chains = []
    
    def visit_If(self, node: ast.If) -> None:
        """Count if statements and track nesting."""
        self.complexity += 1
        self.nesting_level += 1
        self.max_nesting = max(self.max_nesting, self.nesting_level)
        
        # Track condition chains
        if hasattr(node, 'orelse') and node.orelse and isinstance(node.orelse[0], ast.If):
            self.condition_chains.append(('if_elif_chain', node.lineno))
        
        self.generic_visit(node)
        self.nesting_level -= 1
    
    def visit_For(self, node: ast.For) -> None:
        """Count for loops."""
        self.complexity += 1
        self.nesting_level += 1
        self.max_nesting = max(self.max_nesting, self.nesting_level)
        self.generic_visit(node)
        self.nesting_level -= 1
    
    def visit_While(self, node: ast.While) -> None:
        """Count while loops."""
        self.complexity += 1
        self.nesting_level += 1
        self.max_nesting = max(self.max_nesting, self.nesting_level)
        self.generic_visit(node)
        self.nesting_level -= 1
    
    def visit_ExceptHandler(self, node: ast.ExceptHandler) -> None:
        """Count exception handlers."""
        self.complexity += 1
        self.generic_visit(node)
    
    def visit_With(self, node: ast.With) -> None:
        """Count with statements."""
        self.complexity += 1
        self.nesting_level += 1
        self.max_nesting = max(self.max_nesting, self.nesting_level)
        self.generic_visit(node)
        self.nesting_level -= 1
    
    def visit_BoolOp(self, node: ast.BoolOp) -> None:
        """Count boolean operations (and, or)."""
        # Each additional condition in boolean expression adds complexity
        additional_conditions = len(node.values) - 1
        self.complexity += additional_conditions
        self.generic_visit(node)
    
    def get_complexity_metrics(self) -> Dict[str, int]:
        """Get comprehensive complexity metrics."""
        return {
            'cyclomatic_complexity': self.complexity,
            'max_nesting_level': self.max_nesting,
            'condition_chains': len(self.condition_chains)
        }


class ComplexityAnalyzer(ast.NodeVisitor):
    """Analyzes code complexity and suggests improvements."""
    
    def __init__(self, file_path: str, source_code: str):
        self.file_path = file_path
        self.source_code = source_code
        self.source_lines = source_code.splitlines()
        self.issues: List[ComplexityIssue] = []
        self.complexity_calculator = ComplexityCalculator()
    
    def visit_FunctionDef(self, node: ast.FunctionDef) -> None:
        """Analyze function complexity."""
        # Calculate complexity
        self.complexity_calculator.reset()
        self.complexity_calculator.visit(node)
        
        metrics = self.complexity_calculator.get_complexity_metrics()
        complexity = metrics['cyclomatic_complexity']
        max_nesting = metrics['max_nesting_level']
        
        # Check if complexity exceeds threshold
        if complexity > 10:  # Standard threshold
            issue_type = self._determine_complexity_type(node, metrics)
            refactoring_suggestion = self._generate_refactoring_suggestion(
                node, issue_type, metrics
            )
            
            issue = ComplexityIssue(
                file_path=self.file_path,
                function_name=node.name,
                line_number=node.lineno,
                complexity=complexity,
                threshold=10,
                issue_type=issue_type,
                suggested_refactoring=refactoring_suggestion,
                confidence=self._calculate_confidence(issue_type, complexity)
            )
            
            self.issues.append(issue)
        
        self.generic_visit(node)
    
    def _determine_complexity_type(self, node: ast.FunctionDef, metrics: Dict[str, int]) -> str:
        """Determine the primary type of complexity issue."""
        complexity = metrics['cyclomatic_complexity']
        max_nesting = metrics['max_nesting_level']
        condition_chains = metrics['condition_chains']
        
        # Analyze the function body to determine complexity type
        function_code = ast.unparse(node)
        
        if max_nesting > 4:
            return 'deep_nesting'
        elif condition_chains > 2:
            return 'long_if_chain'
        elif 'for' in function_code and 'if' in function_code:
            return 'complex_loop'
        else:
            return 'nested_conditions'
    
    def _generate_refactoring_suggestion(self, node: ast.FunctionDef, 
                                       issue_type: str, metrics: Dict) -> str:
        """Generate specific refactoring suggestions."""
        suggestions = {
            'deep_nesting': self._suggest_guard_clauses_and_extraction(node),
            'long_if_chain': self._suggest_strategy_pattern_or_dispatch(node),
            'complex_loop': self._suggest_loop_extraction_and_filtering(node),
            'nested_conditions': self._suggest_condition_consolidation(node)
        }
        
        return suggestions.get(issue_type, self._suggest_general_refactoring(node))
    
    def _suggest_guard_clauses_and_extraction(self, node: ast.FunctionDef) -> str:
        """Suggest guard clauses and method extraction for deep nesting."""
        return f"""
# Refactoring Strategy: Guard Clauses and Method Extraction

def {node.name}_refactored(self, *args, **kwargs):
    # Use guard clauses to reduce nesting
    if not condition_1:
        return early_return_value
    
    if not condition_2:
        return another_early_return
    
    # Extract complex logic into separate methods
    result = self._handle_main_logic(args)
    return self._process_result(result)

def _handle_main_logic(self, args):
    # Extracted main logic here
    pass

def _process_result(self, result):
    # Extracted result processing here
    pass
"""
    
    def _suggest_strategy_pattern_or_dispatch(self, node: ast.FunctionDef) -> str:
        """Suggest strategy pattern or dispatch table for long if chains."""
        return f"""
# Refactoring Strategy: Strategy Pattern or Dispatch Table

# Option 1: Dispatch Table
def {node.name}_refactored(self, condition_value):
    handlers = {{
        'case1': self._handle_case1,
        'case2': self._handle_case2,
        'case3': self._handle_case3,
    }}
    
    handler = handlers.get(condition_value, self._handle_default)
    return handler()

# Option 2: Strategy Pattern
class {node.name.title()}Strategy:
    def execute(self):
        raise NotImplementedError

class Case1Strategy({node.name.title()}Strategy):
    def execute(self):
        # Handle case 1
        pass

def {node.name}_refactored(self, strategy):
    return strategy.execute()
"""
    
    def _suggest_loop_extraction_and_filtering(self, node: ast.FunctionDef) -> str:
        """Suggest loop extraction and filtering for complex loops."""
        return f"""
# Refactoring Strategy: Loop Extraction and Filtering

def {node.name}_refactored(self, items):
    # Extract filtering logic
    filtered_items = self._filter_items(items)
    
    # Extract processing logic
    processed_items = []
    for item in filtered_items:
        processed_item = self._process_single_item(item)
        if processed_item:
            processed_items.append(processed_item)
    
    return processed_items

def _filter_items(self, items):
    # Extracted filtering logic
    return [item for item in items if self._meets_criteria(item)]

def _process_single_item(self, item):
    # Extracted single item processing
    pass

def _meets_criteria(self, item):
    # Extracted criteria checking
    return True  # Your condition here
"""
    
    def _suggest_condition_consolidation(self, node: ast.FunctionDef) -> str:
        """Suggest condition consolidation for nested conditions."""
        return f"""
# Refactoring Strategy: Condition Consolidation

def {node.name}_refactored(self, *args, **kwargs):
    # Consolidate related conditions
    if self._is_valid_input(args) and self._has_permission(kwargs):
        return self._execute_main_logic(args, kwargs)
    
    return self._handle_invalid_state()

def _is_valid_input(self, args):
    # Consolidate input validation conditions
    return condition1 and condition2 and condition3

def _has_permission(self, kwargs):
    # Consolidate permission conditions
    return perm_condition1 or perm_condition2

def _execute_main_logic(self, args, kwargs):
    # Main business logic here
    pass
"""
    
    def _suggest_general_refactoring(self, node: ast.FunctionDef) -> str:
        """General refactoring suggestions."""
        return f"""
# General Refactoring Strategies:

1. **Extract Methods**: Break down complex logic into smaller, focused methods
2. **Use Early Returns**: Implement guard clauses to reduce nesting
3. **Simplify Conditions**: Use boolean methods to make conditions more readable
4. **Apply Design Patterns**: Consider Strategy, State, or Command patterns

def {node.name}_refactored(self, *args, **kwargs):
    if not self._preconditions_met(args, kwargs):
        return self._handle_invalid_input()
    
    result = self._perform_core_logic(args, kwargs)
    return self._format_result(result)
"""
    
    def _calculate_confidence(self, issue_type: str, complexity: int) -> float:
        """Calculate confidence in refactoring suggestion."""
        base_confidence = {
            'deep_nesting': 0.9,
            'long_if_chain': 0.8,
            'complex_loop': 0.7,
            'nested_conditions': 0.6
        }.get(issue_type, 0.5)
        
        # Adjust based on complexity level
        if complexity > 20:
            return min(base_confidence + 0.1, 1.0)
        elif complexity > 15:
            return base_confidence
        else:
            return max(base_confidence - 0.1, 0.3)


class AutoRefactorer:
    """Automatically applies simple complexity reductions."""
    
    def __init__(self, source_code: str):
        self.source_code = source_code
        self.source_lines = source_code.splitlines()
    
    def apply_guard_clause_refactoring(self, function_node: ast.FunctionDef) -> str:
        """Apply guard clause refactoring to reduce nesting."""
        # This is a simplified implementation
        # In practice, this would require more sophisticated AST manipulation
        
        function_code = self._extract_function_code(function_node)
        
        # Look for simple patterns that can be converted to guard clauses
        refactored_code = self._convert_nested_ifs_to_guards(function_code)
        
        return refactored_code
    
    def _extract_function_code(self, function_node: ast.FunctionDef) -> str:
        """Extract function code from AST node."""
        start_line = function_node.lineno - 1
        end_line = (function_node.end_lineno or function_node.lineno) - 1
        
        return '\n'.join(self.source_lines[start_line:end_line + 1])
    
    def _convert_nested_ifs_to_guards(self, function_code: str) -> str:
        """Convert nested if statements to guard clauses."""
        lines = function_code.split('\n')
        refactored_lines = []
        
        # This is a simplified heuristic-based approach
        # Real implementation would need more sophisticated parsing
        
        in_function = False
        indent_level = 0
        
        for line in lines:
            stripped = line.strip()
            
            if stripped.startswith('def '):
                in_function = True
                refactored_lines.append(line)
                continue
            
            if not in_function:
                refactored_lines.append(line)
                continue
            
            # Simple pattern: if negative condition with return
            if 'if not' in stripped and any(keyword in stripped for keyword in ['return', 'raise']):
                # This looks like it could be a guard clause
                refactored_lines.append(line)
            elif 'if ' in stripped and indent_level > 4:  # Deeply nested if
                # Suggest this could be converted to guard clause
                comment = ' ' * (len(line) - len(line.lstrip())) + '# Consider guard clause: if not condition: return'
                refactored_lines.append(comment)
                refactored_lines.append(line)
            else:
                refactored_lines.append(line)
        
        return '\n'.join(refactored_lines)


class ComplexityReducer:
    """Main class for complexity analysis and reduction."""
    
    def __init__(self, root_path: str = "."):
        self.root_path = Path(root_path)
        self.issues: List[ComplexityIssue] = []
    
    def analyze(self) -> List[ComplexityIssue]:
        """Analyze codebase for complexity issues."""
        print("🔍 Analyzing code complexity...")
        
        python_files = list(self.root_path.rglob("*.py"))
        
        for file_path in python_files:
            if self._should_skip_file(file_path):
                continue
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    source_code = f.read()
                
                analyzer = ComplexityAnalyzer(str(file_path), source_code)
                analyzer.visit(ast.parse(source_code))
                
                self.issues.extend(analyzer.issues)
                
            except Exception as e:
                print(f"❌ Error analyzing {file_path}: {e}")
                continue
        
        return self.issues
    
    def _should_skip_file(self, file_path: Path) -> bool:
        """Check if file should be skipped."""
        skip_patterns = [
            '__pycache__', '.git', 'venv', 'env', 'node_modules',
            '.pytest_cache', '.mypy_cache', 'migrations'
        ]
        
        return any(pattern in str(file_path) for pattern in skip_patterns)
    
    def generate_refactoring_files(self, issues: List[ComplexityIssue],
                                 output_dir: Optional[str] = None) -> None:
        """Generate refactored code files."""
        if not issues:
            print("✅ No complexity issues found!")
            return
        
        output_path = Path(output_dir) if output_dir else Path("refactored_functions")
        output_path.mkdir(exist_ok=True)
        
        # Group issues by file
        issues_by_file = {}
        for issue in issues:
            if issue.file_path not in issues_by_file:
                issues_by_file[issue.file_path] = []
            issues_by_file[issue.file_path].append(issue)
        
        for file_path, file_issues in issues_by_file.items():
            print(f"🔧 Refactoring functions in {file_path}...")
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    source_code = f.read()
                
                refactorer = AutoRefactorer(source_code)
                
                # Generate refactoring suggestions for each function
                refactored_content = self._generate_refactored_file(
                    source_code, file_issues, refactorer
                )
                
                # Write refactored file
                output_file = output_path / Path(file_path).name
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(refactored_content)
                
                print(f"   ✅ Generated {output_file}")
                
            except Exception as e:
                print(f"   ❌ Error refactoring {file_path}: {e}")
    
    def _generate_refactored_file(self, source_code: str, 
                                issues: List[ComplexityIssue],
                                refactorer: AutoRefactorer) -> str:
        """Generate refactored version of file."""
        lines = source_code.split('\n')
        refactored_lines = []
        
        # Add header comment
        refactored_lines.extend([
            "# This file has been refactored to reduce complexity",
            "# Original functions with high complexity have suggested improvements",
            "",
            "# Complexity issues found:",
        ])
        
        for issue in issues:
            refactored_lines.append(f"# - {issue.function_name}(): {issue.complexity} complexity")
        
        refactored_lines.extend(["", ""])
        
        # Add original code with refactoring suggestions
        current_line = 0
        for issue in sorted(issues, key=lambda x: x.line_number):
            # Add lines before the complex function
            while current_line < issue.line_number - 1:
                refactored_lines.append(lines[current_line])
                current_line += 1
            
            # Add refactoring suggestion as comment
            refactored_lines.extend([
                "",
                f"# COMPLEXITY ISSUE: {issue.function_name}() has complexity {issue.complexity}",
                f"# Issue Type: {issue.issue_type}",
                f"# Confidence: {issue.confidence:.1%}",
                f"# Suggested Refactoring:",
                ""
            ])
            
            # Add the refactoring suggestion
            suggestion_lines = issue.suggested_refactoring.strip().split('\n')
            for suggestion_line in suggestion_lines:
                refactored_lines.append(f"# {suggestion_line}")
            
            refactored_lines.extend([
                "",
                "# Original function (consider refactoring):",
                ""
            ])
        
        # Add remaining lines
        while current_line < len(lines):
            refactored_lines.append(lines[current_line])
            current_line += 1
        
        return '\n'.join(refactored_lines)
    
    def generate_report(self, issues: List[ComplexityIssue]) -> str:
        """Generate complexity analysis report."""
        if not issues:
            return "# 🔧 Complexity Analysis Report\n\n✅ No high complexity functions found!"
        
        report = ["# 🔧 Complexity Reduction Report", ""]
        
        # Summary
        critical = len([i for i in issues if i.complexity > 20])
        high = len([i for i in issues if 15 < i.complexity <= 20])
        medium = len([i for i in issues if 10 < i.complexity <= 15])
        
        avg_complexity = sum(i.complexity for i in issues) / len(issues)
        
        report.extend([
            f"## 📊 Summary",
            f"- **Total Complex Functions**: {len(issues)}",
            f"- **Critical Complexity (>20)**: {critical}",
            f"- **High Complexity (15-20)**: {high}",
            f"- **Medium Complexity (10-15)**: {medium}",
            f"- **Average Complexity**: {avg_complexity:.1f}",
            ""
        ])
        
        # Detailed issues
        report.extend([
            "## 🎯 Complexity Issues",
            ""
        ])
        
        for i, issue in enumerate(sorted(issues, key=lambda x: x.complexity, reverse=True), 1):
            complexity_emoji = "🔴" if issue.complexity > 20 else "🟠" if issue.complexity > 15 else "🟡"
            
            report.extend([
                f"### {i}. {issue.function_name}() {complexity_emoji}",
                f"**File**: `{issue.file_path}:{issue.line_number}`",
                f"**Complexity**: {issue.complexity} (threshold: {issue.threshold})",
                f"**Issue Type**: {issue.issue_type.replace('_', ' ').title()}",
                f"**Refactoring Confidence**: {issue.confidence:.1%}",
                "",
                f"**Suggested Approach**:",
                f"```python",
                issue.suggested_refactoring.strip(),
                f"```",
                "",
                "---",
                ""
            ])
        
        # Best practices
        report.extend([
            "## 💡 Complexity Reduction Best Practices",
            "",
            "### Cyclomatic Complexity Guidelines",
            "- **1-4**: Simple function, minimal risk",
            "- **5-7**: More complex, low risk",  
            "- **8-10**: Complex, moderate risk",
            "- **11+**: Very complex, high risk - refactor recommended",
            "",
            "### Refactoring Techniques",
            "1. **Extract Method**: Break large functions into smaller ones",
            "2. **Guard Clauses**: Use early returns to reduce nesting",
            "3. **Strategy Pattern**: Replace complex conditionals with polymorphism",
            "4. **Decompose Conditional**: Extract complex conditions into methods",
            "5. **Replace Nested Conditional with Guard Clauses**",
            "",
            "### Tools and Metrics",
            "- Use static analysis tools (pylint, flake8, radon)",
            "- Set complexity limits in CI/CD pipelines",
            "- Regular code reviews focusing on complexity",
            "- Refactor when adding new features to complex functions",
            ""
        ])
        
        return "\n".join(report)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Analyze and reduce code complexity")
    parser.add_argument("--path", "-p", default=".", help="Path to analyze")
    parser.add_argument("--output", "-o", help="Output file for report")
    parser.add_argument("--refactor", "-r", action="store_true",
                       help="Generate refactored code files")
    parser.add_argument("--output-dir", "-d", default="refactored_functions",
                       help="Directory for refactored code files")
    parser.add_argument("--threshold", "-t", type=int, default=10,
                       help="Complexity threshold (default: 10)")
    
    args = parser.parse_args()
    
    reducer = ComplexityReducer(args.path)
    issues = reducer.analyze()
    
    # Filter by threshold
    filtered_issues = [i for i in issues if i.complexity > args.threshold]
    
    if args.refactor:
        reducer.generate_refactoring_files(filtered_issues, args.output_dir)
    
    report = reducer.generate_report(filtered_issues)
    
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"📝 Report saved to {args.output}")
    else:
        print(report)
    
    return len(filtered_issues)


if __name__ == "__main__":
    exit_code = main()
    exit(min(exit_code, 127))