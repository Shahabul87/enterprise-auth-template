#!/usr/bin/env python3
"""
Flutter Test Coverage Analysis
Analyzes implementation files and corresponding test files to identify missing tests
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Set, Tuple

class FlutterTestAnalyzer:
    def __init__(self, flutter_root: str):
        self.flutter_root = Path(flutter_root)
        self.lib_path = self.flutter_root / "lib"
        self.test_path = self.flutter_root / "test"

    def get_implementation_files(self) -> List[Path]:
        """Get all Dart implementation files from lib directory"""
        files = []
        for file_path in self.lib_path.rglob("*.dart"):
            # Skip generated files
            if not (file_path.name.endswith('.g.dart') or file_path.name.endswith('.freezed.dart')):
                files.append(file_path)
        return sorted(files)

    def get_test_files(self) -> Dict[str, Path]:
        """Get all test files and create a mapping"""
        test_files = {}
        for file_path in self.test_path.rglob("*.dart"):
            # Skip mock files
            if not file_path.name.endswith('.mocks.dart'):
                # Normalize test file name
                test_name = file_path.name.replace('_test.dart', '.dart')
                test_files[test_name] = file_path
        return test_files

    def get_expected_test_path(self, impl_file: Path) -> str:
        """Generate expected test file path for an implementation file"""
        relative_path = impl_file.relative_to(self.lib_path)
        test_name = relative_path.name.replace('.dart', '_test.dart')

        # Different test directories based on file type
        if str(relative_path).startswith('presentation/pages'):
            return f"test/presentation/pages/{relative_path.parent.name}/{test_name}"
        elif str(relative_path).startswith('presentation/widgets'):
            return f"test/presentation/widgets/{test_name.replace('_test.dart', '')}/{test_name}"
        elif str(relative_path).startswith('presentation/providers'):
            return f"test/providers/{test_name}"
        elif str(relative_path).startswith('data/'):
            return f"test/{relative_path.parent}/{test_name}"
        elif str(relative_path).startswith('domain/'):
            return f"test/unit/{relative_path.parent}/{test_name}"
        elif str(relative_path).startswith('core/'):
            return f"test/core/{relative_path.parent.name}/{test_name}"
        elif str(relative_path).startswith('services/'):
            return f"test/services/{test_name}"
        else:
            return f"test/{relative_path.parent}/{test_name}"

    def analyze_coverage(self) -> Tuple[List[Dict], List[Dict], Dict]:
        """Analyze test coverage and return missing tests, existing tests, and stats"""
        impl_files = self.get_implementation_files()
        test_files = self.get_test_files()

        missing_tests = []
        existing_tests = []

        # Category-wise tracking
        categories = {
            'core': {'total': 0, 'tested': 0, 'missing': []},
            'data': {'total': 0, 'tested': 0, 'missing': []},
            'domain': {'total': 0, 'tested': 0, 'missing': []},
            'presentation': {'total': 0, 'tested': 0, 'missing': []},
            'services': {'total': 0, 'tested': 0, 'missing': []},
            'app': {'total': 0, 'tested': 0, 'missing': []},
            'other': {'total': 0, 'tested': 0, 'missing': []}
        }

        for impl_file in impl_files:
            relative_path = impl_file.relative_to(self.lib_path)
            file_name = impl_file.name

            # Determine category
            category = 'other'
            if str(relative_path).startswith('core/'):
                category = 'core'
            elif str(relative_path).startswith('data/'):
                category = 'data'
            elif str(relative_path).startswith('domain/'):
                category = 'domain'
            elif str(relative_path).startswith('presentation/'):
                category = 'presentation'
            elif str(relative_path).startswith('services/'):
                category = 'services'
            elif str(relative_path).startswith('app/'):
                category = 'app'

            categories[category]['total'] += 1

            # Check if test exists
            test_exists = False
            test_paths = []

            # Check multiple possible test locations
            possible_test_names = [
                file_name,  # Direct match
                file_name.replace('.dart', '_test.dart'),
                file_name.replace('.dart', '_simple_test.dart'),
                file_name.replace('.dart', '_comprehensive_test.dart')
            ]

            for test_name in possible_test_names:
                if test_name.replace('_test.dart', '.dart').replace('_simple_test.dart', '.dart').replace('_comprehensive_test.dart', '.dart') in test_files:
                    test_exists = True
                    test_paths.append(str(test_files[test_name.replace('_test.dart', '.dart').replace('_simple_test.dart', '.dart').replace('_comprehensive_test.dart', '.dart')]))
                    break

            # Also check by scanning all test files for partial matches
            if not test_exists:
                base_name = file_name.replace('.dart', '')
                for test_file_path in self.test_path.rglob("*.dart"):
                    if base_name in test_file_path.name and '_test.dart' in test_file_path.name:
                        test_exists = True
                        test_paths.append(str(test_file_path))
                        break

            file_info = {
                'file': str(relative_path),
                'category': category,
                'priority': self.get_priority(relative_path),
                'expected_test_path': self.get_expected_test_path(impl_file),
                'actual_test_paths': test_paths
            }

            if test_exists:
                categories[category]['tested'] += 1
                existing_tests.append(file_info)
            else:
                categories[category]['missing'].append(str(relative_path))
                missing_tests.append(file_info)

        return missing_tests, existing_tests, categories

    def get_priority(self, file_path: Path) -> str:
        """Determine priority level for test creation"""
        path_str = str(file_path)

        # High priority
        if any(x in path_str for x in ['auth', 'security', 'service', 'repository', 'use_case']):
            return 'HIGH'

        # Medium priority
        elif any(x in path_str for x in ['provider', 'model', 'api', 'network', 'storage']):
            return 'MEDIUM'

        # Low priority
        elif any(x in path_str for x in ['widget', 'page', 'screen', 'theme', 'constant']):
            return 'LOW'

        return 'MEDIUM'

    def generate_report(self) -> str:
        """Generate comprehensive test coverage report"""
        missing_tests, existing_tests, categories = self.analyze_coverage()

        report = []
        report.append("# Flutter Test Coverage Analysis Report")
        report.append("=" * 50)
        report.append("")

        # Summary statistics
        total_files = sum(cat['total'] for cat in categories.values())
        total_tested = sum(cat['tested'] for cat in categories.values())
        total_missing = len(missing_tests)
        coverage_percent = (total_tested / total_files * 100) if total_files > 0 else 0

        report.append("## Summary Statistics")
        report.append(f"Total Implementation Files: {total_files}")
        report.append(f"Files with Tests: {total_tested}")
        report.append(f"Files Missing Tests: {total_missing}")
        report.append(f"Test Coverage: {coverage_percent:.1f}%")
        report.append("")

        # Category breakdown
        report.append("## Coverage by Category")
        report.append("| Category | Total | Tested | Missing | Coverage % |")
        report.append("|----------|-------|---------|---------|------------|")

        for cat_name, cat_data in categories.items():
            if cat_data['total'] > 0:
                coverage = (cat_data['tested'] / cat_data['total'] * 100)
                report.append(f"| {cat_name.capitalize()} | {cat_data['total']} | {cat_data['tested']} | {len(cat_data['missing'])} | {coverage:.1f}% |")

        report.append("")

        # Missing tests by priority
        report.append("## Missing Tests by Priority")
        report.append("")

        for priority in ['HIGH', 'MEDIUM', 'LOW']:
            priority_missing = [test for test in missing_tests if test['priority'] == priority]
            if priority_missing:
                report.append(f"### {priority} Priority ({len(priority_missing)} files)")
                report.append("")
                for test in priority_missing:
                    report.append(f"- **{test['file']}**")
                    report.append(f"  - Category: {test['category']}")
                    report.append(f"  - Expected test: `{test['expected_test_path']}`")
                    report.append("")

        # Missing tests by category
        report.append("## Missing Tests by Category")
        report.append("")

        for cat_name, cat_data in categories.items():
            if cat_data['missing']:
                report.append(f"### {cat_name.capitalize()} ({len(cat_data['missing'])} missing)")
                report.append("")
                for missing_file in cat_data['missing']:
                    report.append(f"- {missing_file}")
                report.append("")

        # Detailed missing files list
        report.append("## Detailed Missing Test Files")
        report.append("")

        for i, test in enumerate(missing_tests, 1):
            report.append(f"{i}. **{test['file']}**")
            report.append(f"   - Priority: {test['priority']}")
            report.append(f"   - Category: {test['category']}")
            report.append(f"   - Create test at: `{test['expected_test_path']}`")
            report.append("")

        # Recommendations
        report.append("## Recommendations")
        report.append("")
        report.append("1. **Start with HIGH priority files** - Focus on auth, security, and core services")
        report.append("2. **Create missing unit tests** - Especially for data services and repositories")
        report.append("3. **Add widget tests** - For complex UI components")
        report.append("4. **Integration tests** - For critical user flows")
        report.append("")

        # Test creation commands
        report.append("## Test File Creation Commands")
        report.append("")
        report.append("```bash")
        for test in missing_tests[:10]:  # Show first 10 as examples
            test_dir = os.path.dirname(test['expected_test_path'])
            report.append(f"mkdir -p {test_dir}")
            report.append(f"touch {test['expected_test_path']}")
        report.append("```")
        report.append("")

        return "\n".join(report)

def main():
    flutter_root = "../flutter_auth_template"
    analyzer = FlutterTestAnalyzer(flutter_root)
    report = analyzer.generate_report()

    # Write report to file
    with open("flutter_test_coverage_report.md", "w") as f:
        f.write(report)

    print(report)

if __name__ == "__main__":
    main()