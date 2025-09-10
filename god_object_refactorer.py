#!/usr/bin/env python3
"""
God Object Refactoring Tool
Identifies and refactors God Object anti-patterns by breaking down large classes.
"""

import ast
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple, Union
from collections import defaultdict
import argparse


@dataclass
class RefactoringOpportunity:
    """Represents a refactoring opportunity for a God Object."""
    file_path: str
    class_name: str
    line_number: int
    class_size: int
    method_count: int
    responsibilities: List[str]
    suggested_breakdown: List['ClassSuggestion']
    severity: str  # 'critical', 'high', 'medium'


@dataclass
class ClassSuggestion:
    """Suggested new class to extract from God Object."""
    name: str
    responsibility: str
    methods: List[str]
    attributes: List[str]
    rationale: str


@dataclass
class MethodInfo:
    """Information about a method in a class."""
    name: str
    line_number: int
    line_count: int
    calls_methods: Set[str]
    accesses_attributes: Set[str]
    responsibility_cluster: Optional[str] = None


class ResponsibilityAnalyzer:
    """Analyzes class responsibilities and method clustering."""
    
    def __init__(self):
        self.responsibility_keywords = {
            'data_access': [
                'get', 'find', 'fetch', 'retrieve', 'load', 'read', 'query',
                'save', 'store', 'insert', 'update', 'delete', 'persist',
                'database', 'db', 'repo', 'repository', 'dao'
            ],
            'validation': [
                'validate', 'check', 'verify', 'ensure', 'confirm', 'test',
                'valid', 'invalid', 'error', 'exception', 'rule', 'constraint'
            ],
            'authentication': [
                'auth', 'login', 'logout', 'authenticate', 'authorize',
                'permission', 'role', 'access', 'token', 'session', 'user'
            ],
            'business_logic': [
                'calculate', 'compute', 'process', 'transform', 'convert',
                'business', 'rule', 'policy', 'workflow', 'logic'
            ],
            'formatting': [
                'format', 'render', 'display', 'show', 'present', 'view',
                'html', 'json', 'xml', 'csv', 'export', 'serialize'
            ],
            'communication': [
                'send', 'receive', 'notify', 'message', 'email', 'sms',
                'http', 'api', 'request', 'response', 'client', 'service'
            ],
            'file_handling': [
                'file', 'read', 'write', 'upload', 'download', 'path',
                'directory', 'folder', 'storage', 'filesystem'
            ],
            'logging': [
                'log', 'debug', 'info', 'warn', 'error', 'trace',
                'audit', 'monitor', 'track', 'record'
            ]
        }
    
    def analyze_method_responsibility(self, method_name: str, method_body: str) -> List[str]:
        """Determine the primary responsibilities of a method."""
        method_lower = method_name.lower()
        body_lower = method_body.lower()
        
        responsibilities = []
        
        for responsibility, keywords in self.responsibility_keywords.items():
            score = 0
            
            # Check method name
            for keyword in keywords:
                if keyword in method_lower:
                    score += 2
            
            # Check method body
            for keyword in keywords:
                score += body_lower.count(keyword)
            
            if score > 0:
                responsibilities.append((responsibility, score))
        
        # Return top responsibilities
        responsibilities.sort(key=lambda x: x[1], reverse=True)
        return [resp[0] for resp in responsibilities[:2]]
    
    def cluster_methods_by_responsibility(self, methods: List[MethodInfo], 
                                        source_code: str) -> Dict[str, List[MethodInfo]]:
        """Group methods by their primary responsibility."""
        clusters = defaultdict(list)
        
        for method in methods:
            # Extract method body from source code
            method_body = self._extract_method_body(method, source_code)
            responsibilities = self.analyze_method_responsibility(method.name, method_body)
            
            if responsibilities:
                primary_responsibility = responsibilities[0]
                method.responsibility_cluster = primary_responsibility
                clusters[primary_responsibility].append(method)
            else:
                # Default cluster for unclassified methods
                method.responsibility_cluster = 'utility'
                clusters['utility'].append(method)
        
        return dict(clusters)
    
    def _extract_method_body(self, method: MethodInfo, source_code: str) -> str:
        """Extract method body from source code."""
        lines = source_code.splitlines()
        start_line = method.line_number - 1
        end_line = min(start_line + method.line_count, len(lines))
        
        return '\n'.join(lines[start_line:end_line])


class GodObjectDetector(ast.NodeVisitor):
    """Detects God Objects and analyzes their structure."""
    
    def __init__(self, file_path: str, source_code: str):
        self.file_path = file_path
        self.source_code = source_code
        self.source_lines = source_code.splitlines()
        self.god_objects: List[RefactoringOpportunity] = []
        self.responsibility_analyzer = ResponsibilityAnalyzer()
    
    def visit_ClassDef(self, node: ast.ClassDef) -> None:
        """Analyze classes for God Object patterns."""
        class_info = self._analyze_class(node)
        
        # Determine if this is a God Object
        if self._is_god_object(class_info):
            refactoring_opportunity = self._create_refactoring_opportunity(node, class_info)
            self.god_objects.append(refactoring_opportunity)
        
        self.generic_visit(node)
    
    def _analyze_class(self, node: ast.ClassDef) -> Dict:
        """Comprehensive class analysis."""
        methods = []
        attributes = set()
        class_size = (node.end_lineno or node.lineno) - node.lineno + 1
        
        # Analyze methods
        for child in node.body:
            if isinstance(child, ast.FunctionDef):
                method_info = self._analyze_method(child, node)
                methods.append(method_info)
            
            # Collect class attributes
            elif isinstance(child, ast.Assign):
                for target in child.targets:
                    if isinstance(target, ast.Name):
                        attributes.add(target.id)
        
        # Analyze method interactions and responsibilities
        method_clusters = self.responsibility_analyzer.cluster_methods_by_responsibility(
            methods, self.source_code
        )
        
        return {
            'name': node.name,
            'line_number': node.lineno,
            'size': class_size,
            'methods': methods,
            'method_count': len(methods),
            'attributes': attributes,
            'method_clusters': method_clusters,
            'responsibilities': list(method_clusters.keys())
        }
    
    def _analyze_method(self, method_node: ast.FunctionDef, class_node: ast.ClassDef) -> MethodInfo:
        """Analyze individual method."""
        method_size = (method_node.end_lineno or method_node.lineno) - method_node.lineno + 1
        
        # Find method calls and attribute accesses
        calls_methods = set()
        accesses_attributes = set()
        
        for node in ast.walk(method_node):
            if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute):
                if isinstance(node.func.value, ast.Name) and node.func.value.id == 'self':
                    calls_methods.add(node.func.attr)
            
            elif isinstance(node, ast.Attribute):
                if isinstance(node.value, ast.Name) and node.value.id == 'self':
                    accesses_attributes.add(node.attr)
        
        return MethodInfo(
            name=method_node.name,
            line_number=method_node.lineno,
            line_count=method_size,
            calls_methods=calls_methods,
            accesses_attributes=accesses_attributes
        )
    
    def _is_god_object(self, class_info: Dict) -> bool:
        """Determine if class exhibits God Object characteristics."""
        # Criteria for God Object
        size_threshold = 500  # lines
        method_threshold = 20  # methods
        responsibility_threshold = 4  # distinct responsibilities
        
        return (
            class_info['size'] > size_threshold or
            class_info['method_count'] > method_threshold or
            len(class_info['responsibilities']) > responsibility_threshold
        )
    
    def _create_refactoring_opportunity(self, node: ast.ClassDef, class_info: Dict) -> RefactoringOpportunity:
        """Create refactoring opportunity from God Object analysis."""
        # Determine severity
        size = class_info['size']
        method_count = class_info['method_count']
        
        if size > 1000 or method_count > 50:
            severity = 'critical'
        elif size > 750 or method_count > 30:
            severity = 'high'
        else:
            severity = 'medium'
        
        # Generate suggested breakdown
        suggested_breakdown = self._generate_class_suggestions(class_info)
        
        return RefactoringOpportunity(
            file_path=self.file_path,
            class_name=class_info['name'],
            line_number=class_info['line_number'],
            class_size=class_info['size'],
            method_count=class_info['method_count'],
            responsibilities=class_info['responsibilities'],
            suggested_breakdown=suggested_breakdown,
            severity=severity
        )
    
    def _generate_class_suggestions(self, class_info: Dict) -> List[ClassSuggestion]:
        """Generate suggestions for breaking down the God Object."""
        suggestions = []
        method_clusters = class_info['method_clusters']
        
        for responsibility, methods in method_clusters.items():
            if len(methods) >= 2:  # Only suggest if multiple methods
                # Generate class name
                class_name = self._generate_class_name(class_info['name'], responsibility)
                
                # Collect methods and their accessed attributes
                method_names = [method.name for method in methods]
                accessed_attributes = set()
                for method in methods:
                    accessed_attributes.update(method.accesses_attributes)
                
                suggestion = ClassSuggestion(
                    name=class_name,
                    responsibility=responsibility.replace('_', ' ').title(),
                    methods=method_names,
                    attributes=list(accessed_attributes),
                    rationale=self._generate_rationale(responsibility, methods)
                )
                suggestions.append(suggestion)
        
        return suggestions
    
    def _generate_class_name(self, original_name: str, responsibility: str) -> str:
        """Generate appropriate class name for extracted responsibility."""
        base_name = original_name.replace('Manager', '').replace('Service', '').replace('Handler', '')
        
        responsibility_names = {
            'data_access': f'{base_name}Repository',
            'validation': f'{base_name}Validator',
            'authentication': f'{base_name}AuthService',
            'business_logic': f'{base_name}BusinessLogic',
            'formatting': f'{base_name}Formatter',
            'communication': f'{base_name}NotificationService',
            'file_handling': f'{base_name}FileHandler',
            'logging': f'{base_name}Logger',
            'utility': f'{base_name}Utils'
        }
        
        return responsibility_names.get(responsibility, f'{base_name}{responsibility.title()}')
    
    def _generate_rationale(self, responsibility: str, methods: List[MethodInfo]) -> str:
        """Generate rationale for extracting this responsibility."""
        rationales = {
            'data_access': 'Separates data access logic following Repository pattern',
            'validation': 'Isolates validation logic for better testability',
            'authentication': 'Centralizes authentication/authorization concerns',
            'business_logic': 'Focuses on core business rules and operations',
            'formatting': 'Handles data presentation and formatting concerns',
            'communication': 'Manages external communication and notifications',
            'file_handling': 'Handles file operations and storage concerns',
            'logging': 'Centralizes logging and monitoring functionality',
            'utility': 'Groups utility methods for reusability'
        }
        
        base_rationale = rationales.get(responsibility, 'Groups related functionality')
        method_count = len(methods)
        
        return f"{base_rationale}. Contains {method_count} related methods."


class RefactoringCodeGenerator:
    """Generates refactored code from God Object analysis."""
    
    def __init__(self, source_code: str):
        self.source_code = source_code
        self.source_lines = source_code.splitlines()
    
    def generate_refactored_classes(self, opportunity: RefactoringOpportunity) -> Dict[str, str]:
        """Generate code for extracted classes."""
        extracted_classes = {}
        
        # Parse original class
        tree = ast.parse(self.source_code)
        original_class = self._find_class_node(tree, opportunity.class_name)
        
        if not original_class:
            return extracted_classes
        
        # Generate each suggested class
        for suggestion in opportunity.suggested_breakdown:
            class_code = self._generate_single_class(original_class, suggestion)
            extracted_classes[suggestion.name] = class_code
        
        # Generate slimmed-down original class
        remaining_class = self._generate_remaining_class(original_class, opportunity.suggested_breakdown)
        extracted_classes[f"{opportunity.class_name}Slim"] = remaining_class
        
        return extracted_classes
    
    def _find_class_node(self, tree: ast.AST, class_name: str) -> Optional[ast.ClassDef]:
        """Find class node by name."""
        for node in ast.walk(tree):
            if isinstance(node, ast.ClassDef) and node.name == class_name:
                return node
        return None
    
    def _generate_single_class(self, original_class: ast.ClassDef, suggestion: ClassSuggestion) -> str:
        """Generate code for a single extracted class."""
        lines = [
            f"class {suggestion.name}:",
            f'    """',
            f'    {suggestion.rationale}',
            f'    Extracted from {original_class.name} to handle {suggestion.responsibility.lower()}.',
            f'    """',
            ""
        ]
        
        # Add constructor if attributes are needed
        if suggestion.attributes:
            lines.extend([
                "    def __init__(self):",
                "        # Initialize extracted attributes"
            ])
            for attr in suggestion.attributes:
                lines.append(f"        self.{attr} = None  # TODO: Initialize properly")
            lines.append("")
        
        # Extract methods
        for method_name in suggestion.methods:
            method_code = self._extract_method_code(original_class, method_name)
            if method_code:
                lines.extend(method_code)
                lines.append("")
        
        return "\n".join(lines)
    
    def _extract_method_code(self, class_node: ast.ClassDef, method_name: str) -> List[str]:
        """Extract method code from original class."""
        for child in class_node.body:
            if isinstance(child, ast.FunctionDef) and child.name == method_name:
                start_line = child.lineno - 1
                end_line = (child.end_lineno or child.lineno) - 1
                
                method_lines = self.source_lines[start_line:end_line + 1]
                
                # Add TODO comments for potential issues
                if any('self.' in line for line in method_lines):
                    method_lines.insert(1, "        # TODO: Review attribute access after refactoring")
                
                return method_lines
        
        return []
    
    def _generate_remaining_class(self, original_class: ast.ClassDef, 
                                 extracted_suggestions: List[ClassSuggestion]) -> str:
        """Generate slimmed-down version of original class."""
        extracted_methods = set()
        for suggestion in extracted_suggestions:
            extracted_methods.update(suggestion.methods)
        
        lines = [
            f"class {original_class.name}Slim:",
            f'    """',
            f'    Refactored version of {original_class.name} with responsibilities extracted.',
            f'    """',
            ""
        ]
        
        # Keep only non-extracted methods
        for child in original_class.body:
            if isinstance(child, ast.FunctionDef) and child.name not in extracted_methods:
                method_code = self._extract_method_code(original_class, child.name)
                if method_code:
                    lines.extend(method_code)
                    lines.append("")
        
        # Add composition relationships
        lines.extend([
            "    def __init__(self):",
            "        # Initialize extracted service dependencies"
        ])
        
        for suggestion in extracted_suggestions:
            var_name = suggestion.name.lower().replace(original_class.name.lower(), '')
            lines.append(f"        self.{var_name} = {suggestion.name}()")
        
        return "\n".join(lines)


class GodObjectRefactorer:
    """Main class for God Object detection and refactoring."""
    
    def __init__(self, root_path: str = "."):
        self.root_path = Path(root_path)
        self.opportunities: List[RefactoringOpportunity] = []
    
    def analyze(self) -> List[RefactoringOpportunity]:
        """Analyze codebase for God Objects."""
        print("🔍 Analyzing for God Object anti-patterns...")
        
        python_files = list(self.root_path.rglob("*.py"))
        
        for file_path in python_files:
            if self._should_skip_file(file_path):
                continue
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    source_code = f.read()
                
                detector = GodObjectDetector(str(file_path), source_code)
                detector.visit(ast.parse(source_code))
                
                self.opportunities.extend(detector.god_objects)
                
            except Exception as e:
                print(f"❌ Error analyzing {file_path}: {e}")
                continue
        
        return self.opportunities
    
    def _should_skip_file(self, file_path: Path) -> bool:
        """Check if file should be skipped."""
        skip_patterns = [
            '__pycache__', '.git', 'venv', 'env', 'node_modules',
            '.pytest_cache', '.mypy_cache', 'migrations'
        ]
        
        return any(pattern in str(file_path) for pattern in skip_patterns)
    
    def generate_refactored_code(self, opportunities: List[RefactoringOpportunity],
                               output_dir: Optional[str] = None) -> None:
        """Generate refactored code files."""
        if not opportunities:
            print("✅ No God Objects found to refactor!")
            return
        
        output_path = Path(output_dir) if output_dir else Path("refactored_classes")
        output_path.mkdir(exist_ok=True)
        
        for opportunity in opportunities:
            print(f"🔧 Refactoring {opportunity.class_name}...")
            
            try:
                with open(opportunity.file_path, 'r', encoding='utf-8') as f:
                    source_code = f.read()
                
                generator = RefactoringCodeGenerator(source_code)
                extracted_classes = generator.generate_refactored_classes(opportunity)
                
                # Write each extracted class to a file
                for class_name, class_code in extracted_classes.items():
                    class_file = output_path / f"{class_name.lower()}.py"
                    with open(class_file, 'w', encoding='utf-8') as f:
                        f.write(class_code)
                    
                    print(f"   ✅ Generated {class_file}")
                
            except Exception as e:
                print(f"   ❌ Error refactoring {opportunity.class_name}: {e}")
    
    def generate_report(self, opportunities: List[RefactoringOpportunity]) -> str:
        """Generate comprehensive God Object analysis report."""
        if not opportunities:
            return "# 🏗️ God Object Analysis Report\n\n✅ No God Object anti-patterns detected!"
        
        report = ["# 🏗️ God Object Refactoring Report", ""]
        
        # Summary
        critical = len([o for o in opportunities if o.severity == 'critical'])
        high = len([o for o in opportunities if o.severity == 'high'])
        medium = len([o for o in opportunities if o.severity == 'medium'])
        
        report.extend([
            f"## 📊 Summary",
            f"- **Total God Objects**: {len(opportunities)}",
            f"- **Critical**: {critical} (>1000 lines or >50 methods)",
            f"- **High**: {high} (>750 lines or >30 methods)",
            f"- **Medium**: {medium} (>500 lines or >20 methods)",
            ""
        ])
        
        # Detailed analysis
        report.extend([
            "## 🎯 God Object Details",
            ""
        ])
        
        for i, opportunity in enumerate(sorted(opportunities, 
                                            key=lambda x: x.class_size, reverse=True), 1):
            severity_emoji = {
                'critical': '🔴',
                'high': '🟠', 
                'medium': '🟡'
            }.get(opportunity.severity, '⚪')
            
            report.extend([
                f"### {i}. {opportunity.class_name} {severity_emoji}",
                f"**File**: `{opportunity.file_path}:{opportunity.line_number}`",
                f"**Size**: {opportunity.class_size} lines, {opportunity.method_count} methods",
                f"**Responsibilities**: {', '.join(opportunity.responsibilities)}",
                "",
                f"**Suggested Refactoring**:",
                ""
            ])
            
            for suggestion in opportunity.suggested_breakdown:
                report.extend([
                    f"- **{suggestion.name}**: {suggestion.responsibility}",
                    f"  - Methods: {', '.join(suggestion.methods[:5])}{'...' if len(suggestion.methods) > 5 else ''}",
                    f"  - Rationale: {suggestion.rationale}",
                    ""
                ])
            
            report.extend([
                "---",
                ""
            ])
        
        # Best practices
        report.extend([
            "## 💡 Refactoring Guidelines",
            "",
            "### Single Responsibility Principle",
            "- Each class should have one reason to change",
            "- Separate concerns into focused classes",
            "- Use composition over inheritance",
            "",
            "### Refactoring Steps",
            "1. **Identify Responsibilities**: Group methods by their primary purpose",
            "2. **Extract Classes**: Create focused classes for each responsibility", 
            "3. **Establish Relationships**: Use composition to connect classes",
            "4. **Update Dependencies**: Modify code that uses the original class",
            "5. **Test Thoroughly**: Ensure functionality remains intact",
            "",
            "### Common Extraction Patterns",
            "- **Repository Pattern**: Extract data access methods",
            "- **Strategy Pattern**: Extract algorithm/business logic variations",
            "- **Service Layer**: Extract business operations",
            "- **Factory Pattern**: Extract object creation logic",
            ""
        ])
        
        return "\n".join(report)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Detect and refactor God Object anti-patterns")
    parser.add_argument("--path", "-p", default=".", help="Path to analyze")
    parser.add_argument("--output", "-o", help="Output file for report")
    parser.add_argument("--refactor", "-r", action="store_true", 
                       help="Generate refactored code")
    parser.add_argument("--output-dir", "-d", default="refactored_classes",
                       help="Directory for refactored code files")
    
    args = parser.parse_args()
    
    refactorer = GodObjectRefactorer(args.path)
    opportunities = refactorer.analyze()
    
    if args.refactor:
        refactorer.generate_refactored_code(opportunities, args.output_dir)
    
    report = refactorer.generate_report(opportunities)
    
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"📝 Report saved to {args.output}")
    else:
        print(report)
    
    return len(opportunities)


if __name__ == "__main__":
    exit_code = main()
    exit(min(exit_code, 127))