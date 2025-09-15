#!/usr/bin/env python3
"""
Long Method Refactoring Tool
Identifies and refactors excessively long methods by extracting smaller, focused methods.
"""

import ast
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple, Union
from collections import defaultdict
import argparse


@dataclass
class LongMethodIssue:
    """Represents a long method that needs refactoring."""
    file_path: str
    class_name: Optional[str]
    method_name: str
    line_number: int
    line_count: int
    threshold: int
    suggested_extractions: List['MethodExtraction']
    severity: str  # 'critical', 'high', 'medium'


@dataclass
class MethodExtraction:
    """Suggested method extraction from long method."""
    extracted_method_name: str
    start_line: int
    end_line: int
    code_block: str
    purpose: str
    parameters: List[str]
    return_value: Optional[str]
    rationale: str


@dataclass
class CodeBlock:
    """Represents a logical block of code that can be extracted."""
    start_line: int
    end_line: int
    lines: List[str]
    variables_used: Set[str]
    variables_defined: Set[str]
    block_type: str  # 'loop', 'conditional', 'sequential', 'try_except'
    complexity_score: int


class CodeBlockAnalyzer(ast.NodeVisitor):
    """Analyzes code blocks within methods for extraction opportunities."""
    
    def __init__(self, source_lines: List[str], method_start_line: int):
        self.source_lines = source_lines
        self.method_start_line = method_start_line
        self.blocks: List[CodeBlock] = []
        self.current_block = None
        self.variable_uses = defaultdict(set)
        self.variable_definitions = defaultdict(set)
        self.nesting_level = 0
    
    def visit_For(self, node: ast.For) -> None:
        """Analyze for loops as potential extraction candidates."""
        self._analyze_block(node, 'loop')
    
    def visit_While(self, node: ast.While) -> None:
        """Analyze while loops as potential extraction candidates."""
        self._analyze_block(node, 'loop')
    
    def visit_If(self, node: ast.If) -> None:
        """Analyze if statements as potential extraction candidates."""
        # Only consider substantial if blocks
        if self._count_lines_in_node(node) > 5:
            self._analyze_block(node, 'conditional')
    
    def visit_Try(self, node: ast.Try) -> None:
        """Analyze try-except blocks as potential extraction candidates."""
        self._analyze_block(node, 'try_except')
    
    def visit_With(self, node: ast.With) -> None:
        """Analyze with statements as potential extraction candidates."""
        if self._count_lines_in_node(node) > 3:
            self._analyze_block(node, 'with_block')
    
    def _analyze_block(self, node: ast.AST, block_type: str) -> None:
        """Analyze a code block for extraction potential."""
        start_line = node.lineno
        end_line = getattr(node, 'end_lineno', node.lineno)
        
        if end_line - start_line < 3:  # Too small to extract
            return
        
        # Extract code lines
        code_lines = self.source_lines[start_line - 1:end_line]
        
        # Analyze variables
        variables_used = set()
        variables_defined = set()
        
        for child in ast.walk(node):
            if isinstance(child, ast.Name):
                if isinstance(child.ctx, ast.Store):
                    variables_defined.add(child.id)
                elif isinstance(child.ctx, ast.Load):
                    variables_used.add(child.id)
        
        # Calculate complexity score
        complexity_score = self._calculate_block_complexity(node)
        
        block = CodeBlock(
            start_line=start_line,
            end_line=end_line,
            lines=code_lines,
            variables_used=variables_used,
            variables_defined=variables_defined,
            block_type=block_type,
            complexity_score=complexity_score
        )
        
        self.blocks.append(block)
        self.generic_visit(node)
    
    def _count_lines_in_node(self, node: ast.AST) -> int:
        """Count number of lines in an AST node."""
        start = node.lineno
        end = getattr(node, 'end_lineno', node.lineno)
        return end - start + 1
    
    def _calculate_block_complexity(self, node: ast.AST) -> int:
        """Calculate complexity score for a code block."""
        complexity = 0
        
        for child in ast.walk(node):
            if isinstance(child, (ast.If, ast.For, ast.While, ast.Try)):
                complexity += 1
            elif isinstance(child, ast.Call):
                complexity += 1
            elif isinstance(child, ast.BoolOp):
                complexity += len(child.values) - 1
        
        return complexity


class MethodAnalyzer(ast.NodeVisitor):
    """Analyzes individual methods for refactoring opportunities."""
    
    def __init__(self, file_path: str, source_code: str, threshold: int = 50):
        self.file_path = file_path
        self.source_code = source_code
        self.source_lines = source_code.splitlines()
        self.threshold = threshold
        self.long_methods: List[LongMethodIssue] = []
        self.current_class = None
    
    def visit_ClassDef(self, node: ast.ClassDef) -> None:
        """Track current class context."""
        old_class = self.current_class
        self.current_class = node.name
        self.generic_visit(node)
        self.current_class = old_class
    
    def visit_FunctionDef(self, node: ast.FunctionDef) -> None:
        """Analyze method length and complexity."""
        method_lines = self._calculate_method_lines(node)
        
        if method_lines > self.threshold:
            # This is a long method
            extractions = self._analyze_extraction_opportunities(node)
            
            severity = self._determine_severity(method_lines, len(extractions))
            
            issue = LongMethodIssue(
                file_path=self.file_path,
                class_name=self.current_class,
                method_name=node.name,
                line_number=node.lineno,
                line_count=method_lines,
                threshold=self.threshold,
                suggested_extractions=extractions,
                severity=severity
            )
            
            self.long_methods.append(issue)
        
        self.generic_visit(node)
    
    def _calculate_method_lines(self, node: ast.FunctionDef) -> int:
        """Calculate the number of lines in a method."""
        start_line = node.lineno
        end_line = getattr(node, 'end_lineno', node.lineno)
        
        # Count non-empty, non-comment lines
        actual_lines = 0
        for line_num in range(start_line - 1, end_line):
            if line_num < len(self.source_lines):
                line = self.source_lines[line_num].strip()
                if line and not line.startswith('#'):
                    actual_lines += 1
        
        return actual_lines
    
    def _analyze_extraction_opportunities(self, node: ast.FunctionDef) -> List[MethodExtraction]:
        """Analyze opportunities for method extraction."""
        block_analyzer = CodeBlockAnalyzer(self.source_lines, node.lineno)
        block_analyzer.visit(node)
        
        extractions = []
        
        # Analyze each identified block
        for block in sorted(block_analyzer.blocks, key=lambda b: b.complexity_score, reverse=True):
            # Only suggest extraction for substantial blocks
            if len(block.lines) >= 5 and block.complexity_score > 2:
                extraction = self._create_method_extraction(block, node.name)
                extractions.append(extraction)
        
        # Look for sequential code patterns
        sequential_blocks = self._find_sequential_extraction_opportunities(node)
        extractions.extend(sequential_blocks)
        
        return extractions[:5]  # Limit to top 5 suggestions
    
    def _create_method_extraction(self, block: CodeBlock, parent_method: str) -> MethodExtraction:
        """Create method extraction suggestion from code block."""
        # Generate descriptive method name
        method_name = self._generate_method_name(block, parent_method)
        
        # Determine parameters based on variables used but not defined
        external_vars = block.variables_used - block.variables_defined
        parameters = list(external_vars)[:4]  # Limit parameters
        
        # Determine return value
        return_value = self._determine_return_value(block)
        
        # Generate rationale
        rationale = self._generate_extraction_rationale(block)
        
        return MethodExtraction(
            extracted_method_name=method_name,
            start_line=block.start_line,
            end_line=block.end_line,
            code_block='\n'.join(block.lines),
            purpose=block.block_type.replace('_', ' ').title() + ' logic',
            parameters=parameters,
            return_value=return_value,
            rationale=rationale
        )
    
    def _find_sequential_extraction_opportunities(self, node: ast.FunctionDef) -> List[MethodExtraction]:
        """Find sequential code blocks that can be extracted."""
        extractions = []
        
        # Look for groups of related statements
        current_group = []
        current_start = node.lineno
        
        for stmt in node.body:
            # Simple heuristic: group statements that are close together
            if hasattr(stmt, 'lineno') and current_group:
                line_gap = stmt.lineno - current_group[-1].lineno
                if line_gap > 3:  # New group
                    if len(current_group) >= 3:  # Group is substantial enough
                        extraction = self._create_sequential_extraction(
                            current_group, current_start, node.name
                        )
                        if extraction:
                            extractions.append(extraction)
                    
                    current_group = [stmt]
                    current_start = stmt.lineno
                else:
                    current_group.append(stmt)
            else:
                current_group.append(stmt)
        
        # Handle final group
        if len(current_group) >= 3:
            extraction = self._create_sequential_extraction(
                current_group, current_start, node.name
            )
            if extraction:
                extractions.append(extraction)
        
        return extractions
    
    def _create_sequential_extraction(self, statements: List[ast.AST], 
                                    start_line: int, parent_method: str) -> Optional[MethodExtraction]:
        """Create extraction for sequential statements."""
        if not statements:
            return None
        
        end_line = getattr(statements[-1], 'end_lineno', statements[-1].lineno)
        line_count = end_line - start_line + 1
        
        if line_count < 5:  # Too small
            return None
        
        # Extract code
        code_lines = self.source_lines[start_line - 1:end_line]
        
        # Generate method name based on statements
        method_name = self._generate_sequential_method_name(statements, parent_method)
        
        return MethodExtraction(
            extracted_method_name=method_name,
            start_line=start_line,
            end_line=end_line,
            code_block='\n'.join(code_lines),
            purpose='Sequential processing logic',
            parameters=['self'],  # Simplified
            return_value=None,
            rationale=f'Extract {len(statements)} related statements to improve readability'
        )
    
    def _generate_method_name(self, block: CodeBlock, parent_method: str) -> str:
        """Generate descriptive method name for extracted block."""
        base_names = {
            'loop': f'_{parent_method}_process_items',
            'conditional': f'_{parent_method}_handle_condition',
            'try_except': f'_{parent_method}_handle_errors',
            'with_block': f'_{parent_method}_with_context',
            'sequential': f'_{parent_method}_process_data'
        }
        
        base_name = base_names.get(block.block_type, f'_{parent_method}_extracted')
        
        # Look for keywords in the code to make it more specific
        code_text = '\n'.join(block.lines).lower()
        
        if 'validate' in code_text or 'check' in code_text:
            base_name = f'_{parent_method}_validate'
        elif 'format' in code_text or 'transform' in code_text:
            base_name = f'_{parent_method}_format'
        elif 'calculate' in code_text or 'compute' in code_text:
            base_name = f'_{parent_method}_calculate'
        elif 'save' in code_text or 'store' in code_text:
            base_name = f'_{parent_method}_save'
        elif 'load' in code_text or 'fetch' in code_text:
            base_name = f'_{parent_method}_load'
        
        return base_name
    
    def _generate_sequential_method_name(self, statements: List[ast.AST], parent_method: str) -> str:
        """Generate method name for sequential statements."""
        # Analyze statement types to determine purpose
        has_assignments = any(isinstance(stmt, ast.Assign) for stmt in statements)
        has_calls = any(isinstance(stmt, ast.Expr) and isinstance(stmt.value, ast.Call) 
                       for stmt in statements)
        has_conditions = any(isinstance(stmt, ast.If) for stmt in statements)
        
        if has_assignments and has_conditions:
            return f'_{parent_method}_setup_and_validate'
        elif has_assignments:
            return f'_{parent_method}_setup_variables'
        elif has_calls:
            return f'_{parent_method}_perform_operations'
        else:
            return f'_{parent_method}_extracted_logic'
    
    def _determine_return_value(self, block: CodeBlock) -> Optional[str]:
        """Determine what the extracted method should return."""
        # Simple heuristic: if block defines variables used later, return them
        if len(block.variables_defined) == 1:
            return list(block.variables_defined)[0]
        elif len(block.variables_defined) > 1:
            return f"({', '.join(list(block.variables_defined)[:3])})"
        
        return None
    
    def _generate_extraction_rationale(self, block: CodeBlock) -> str:
        """Generate rationale for method extraction."""
        rationales = {
            'loop': 'Extract loop logic to reduce complexity and improve readability',
            'conditional': 'Separate conditional logic for better maintainability',
            'try_except': 'Isolate error handling for cleaner exception management',
            'with_block': 'Extract context management for reusability',
            'sequential': 'Group related operations for better organization'
        }
        
        base_rationale = rationales.get(block.block_type, 'Extract for improved modularity')
        
        if block.complexity_score > 5:
            base_rationale += f' (high complexity: {block.complexity_score})'
        
        return base_rationale
    
    def _determine_severity(self, line_count: int, extraction_count: int) -> str:
        """Determine severity of long method issue."""
        if line_count > 150 or extraction_count > 3:
            return 'critical'
        elif line_count > 100 or extraction_count > 2:
            return 'high'
        else:
            return 'medium'


class RefactoredCodeGenerator:
    """Generates refactored code with extracted methods."""
    
    def __init__(self, source_code: str):
        self.source_code = source_code
        self.source_lines = source_code.splitlines()
    
    def generate_refactored_method(self, issue: LongMethodIssue) -> str:
        """Generate refactored version of a long method."""
        lines = []
        
        # Add header comment
        lines.extend([
            f"# Refactored version of {issue.method_name}()",
            f"# Original: {issue.line_count} lines -> Refactored with {len(issue.suggested_extractions)} extracted methods",
            ""
        ])
        
        # Generate extracted methods first
        for i, extraction in enumerate(issue.suggested_extractions, 1):
            lines.extend([
                f"# Extracted Method {i}",
                self._generate_extracted_method_code(extraction),
                ""
            ])
        
        # Generate refactored main method
        lines.extend([
            "# Refactored Main Method",
            self._generate_main_method_refactored(issue),
            ""
        ])
        
        return '\n'.join(lines)
    
    def _generate_extracted_method_code(self, extraction: MethodExtraction) -> str:
        """Generate code for an extracted method."""
        lines = []
        
        # Method signature
        params = ['self'] + extraction.parameters if extraction.parameters else ['self']
        param_str = ', '.join(params)
        
        lines.extend([
            f"def {extraction.extracted_method_name}({param_str}):",
            f'    """',
            f'    {extraction.purpose}',
            f'    ',
            f'    Extracted from original method.',
            f'    {extraction.rationale}',
            f'    """'
        ])
        
        # Method body - indent the original code
        code_lines = extraction.code_block.split('\n')
        for line in code_lines:
            if line.strip():
                lines.append(f"    {line}")
            else:
                lines.append("")
        
        # Add return statement if needed
        if extraction.return_value:
            lines.append(f"    return {extraction.return_value}")
        
        return '\n'.join(lines)
    
    def _generate_main_method_refactored(self, issue: LongMethodIssue) -> str:
        """Generate refactored version of the main method."""
        lines = []
        
        # Original method signature (simplified)
        lines.extend([
            f"def {issue.method_name}_refactored(self, *args, **kwargs):",
            f'    """',
            f'    Refactored version of {issue.method_name}.',
            f'    ',
            f'    Broken down from {issue.line_count} lines into smaller, focused methods.',
            f'    """'
        ])
        
        # Call extracted methods in logical order
        for extraction in issue.suggested_extractions:
            method_call = f"self.{extraction.extracted_method_name}()"
            
            if extraction.return_value:
                lines.append(f"    {extraction.return_value} = {method_call}")
            else:
                lines.append(f"    {method_call}")
        
        lines.extend([
            "",
            "    # TODO: Add any remaining logic and proper return statement",
            "    # TODO: Update method calls to use appropriate parameters",
            "    pass"
        ])
        
        return '\n'.join(lines)


class LongMethodRefactorer:
    """Main class for long method analysis and refactoring."""
    
    def __init__(self, root_path: str = ".", threshold: int = 50):
        self.root_path = Path(root_path)
        self.threshold = threshold
        self.issues: List[LongMethodIssue] = []
    
    def analyze(self) -> List[LongMethodIssue]:
        """Analyze codebase for long methods."""
        print(f"🔍 Analyzing for long methods (threshold: {self.threshold} lines)...")
        
        python_files = list(self.root_path.rglob("*.py"))
        
        for file_path in python_files:
            if self._should_skip_file(file_path):
                continue
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    source_code = f.read()
                
                analyzer = MethodAnalyzer(str(file_path), source_code, self.threshold)
                analyzer.visit(ast.parse(source_code))
                
                self.issues.extend(analyzer.long_methods)
                
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
    
    def generate_refactored_code(self, issues: List[LongMethodIssue],
                               output_dir: Optional[str] = None) -> None:
        """Generate refactored code files."""
        if not issues:
            print("✅ No long methods found!")
            return
        
        output_path = Path(output_dir) if output_dir else Path("refactored_methods")
        output_path.mkdir(exist_ok=True)
        
        for issue in issues:
            print(f"🔧 Refactoring {issue.method_name}() in {Path(issue.file_path).name}...")
            
            try:
                with open(issue.file_path, 'r', encoding='utf-8') as f:
                    source_code = f.read()
                
                generator = RefactoredCodeGenerator(source_code)
                refactored_code = generator.generate_refactored_method(issue)
                
                # Write refactored method
                output_file = output_path / f"{issue.method_name}_refactored.py"
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(refactored_code)
                
                print(f"   ✅ Generated {output_file}")
                
            except Exception as e:
                print(f"   ❌ Error refactoring {issue.method_name}: {e}")
    
    def generate_report(self, issues: List[LongMethodIssue]) -> str:
        """Generate long method analysis report."""
        if not issues:
            return f"# ✂️ Long Method Analysis Report\n\n✅ No methods exceed {self.threshold} lines!"
        
        report = ["# ✂️ Long Method Refactoring Report", ""]
        
        # Summary
        critical = len([i for i in issues if i.severity == 'critical'])
        high = len([i for i in issues if i.severity == 'high'])
        medium = len([i for i in issues if i.severity == 'medium'])
        
        avg_length = sum(i.line_count for i in issues) / len(issues)
        total_extractions = sum(len(i.suggested_extractions) for i in issues)
        
        report.extend([
            f"## 📊 Summary",
            f"- **Total Long Methods**: {len(issues)}",
            f"- **Critical (>150 lines)**: {critical}",
            f"- **High (>100 lines)**: {high}",
            f"- **Medium (>{self.threshold} lines)**: {medium}",
            f"- **Average Length**: {avg_length:.1f} lines",
            f"- **Suggested Extractions**: {total_extractions}",
            ""
        ])
        
        # Detailed issues
        report.extend([
            "## 🎯 Long Method Details",
            ""
        ])
        
        for i, issue in enumerate(sorted(issues, key=lambda x: x.line_count, reverse=True), 1):
            severity_emoji = {
                'critical': '🔴',
                'high': '🟠',
                'medium': '🟡'
            }.get(issue.severity, '⚪')
            
            class_prefix = f"{issue.class_name}." if issue.class_name else ""
            
            report.extend([
                f"### {i}. {class_prefix}{issue.method_name}() {severity_emoji}",
                f"**File**: `{issue.file_path}:{issue.line_number}`",
                f"**Length**: {issue.line_count} lines (threshold: {issue.threshold})",
                f"**Suggested Extractions**: {len(issue.suggested_extractions)}",
                ""
            ])
            
            if issue.suggested_extractions:
                report.append("**Extraction Opportunities**:")
                for j, extraction in enumerate(issue.suggested_extractions, 1):
                    report.extend([
                        f"{j}. **{extraction.extracted_method_name}** (lines {extraction.start_line}-{extraction.end_line})",
                        f"   - Purpose: {extraction.purpose}",
                        f"   - Rationale: {extraction.rationale}",
                        ""
                    ])
            
            report.extend([
                "---",
                ""
            ])
        
        # Best practices
        report.extend([
            "## 💡 Method Length Best Practices",
            "",
            "### Recommended Limits",
            "- **Ideal**: 10-20 lines per method",
            "- **Acceptable**: 20-50 lines per method",
            "- **Refactor**: >50 lines per method",
            "- **Critical**: >100 lines per method",
            "",
            "### Refactoring Techniques",
            "1. **Extract Method**: Move code blocks into separate methods",
            "2. **Decompose Conditional**: Extract complex conditions",
            "3. **Extract Loop**: Move loop logic to separate methods",
            "4. **Replace Method with Method Object**: For very complex methods",
            "5. **Parameterize Method**: Reduce duplication with parameters",
            "",
            "### Benefits of Shorter Methods",
            "- Improved readability and maintainability",
            "- Better testability (easier to unit test)",
            "- Reduced complexity and cognitive load",
            "- Enhanced reusability",
            "- Clearer intent and purpose",
            "",
            "### Refactoring Checklist",
            "- [ ] Extract logical blocks of 5+ lines",
            "- [ ] Give extracted methods descriptive names",
            "- [ ] Minimize method parameters (prefer <4)",
            "- [ ] Ensure single responsibility per method",
            "- [ ] Update tests after refactoring",
            ""
        ])
        
        return "\n".join(report)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Detect and refactor long methods")
    parser.add_argument("--path", "-p", default=".", help="Path to analyze")
    parser.add_argument("--output", "-o", help="Output file for report")
    parser.add_argument("--threshold", "-t", type=int, default=50,
                       help="Line count threshold for long methods")
    parser.add_argument("--refactor", "-r", action="store_true",
                       help="Generate refactored code files")
    parser.add_argument("--output-dir", "-d", default="refactored_methods",
                       help="Directory for refactored code files")
    
    args = parser.parse_args()
    
    refactorer = LongMethodRefactorer(args.path, args.threshold)
    issues = refactorer.analyze()
    
    if args.refactor:
        refactorer.generate_refactored_code(issues, args.output_dir)
    
    report = refactorer.generate_report(issues)
    
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"📝 Report saved to {args.output}")
    else:
        print(report)
    
    return len(issues)


if __name__ == "__main__":
    exit_code = main()
    exit(min(exit_code, 127))