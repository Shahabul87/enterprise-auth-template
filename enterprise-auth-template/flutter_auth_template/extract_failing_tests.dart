#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 Extracting failing test files from Flutter test suite...\n');

  final failingFiles = <String, List<String>>{};
  final errorCategories = <String, List<String>>{
    'Compilation Errors': [],
    'Type Cast Errors': [],
    'Missing Properties': [],
    'Test Assertion Failures': [],
    'Network/Service Errors': [],
    'Other Runtime Errors': []
  };

  try {
    // Run flutter test and capture output
    final result = await Process.run('flutter', ['test', '--reporter=compact']);
    final output = result.stderr.toString() + result.stdout.toString();

    // Parse the output to extract failing tests
    final lines = output.split('\n');
    String? currentFile;

    for (final line in lines) {
      // Extract file path from test lines
      if (line.contains('/test/') && line.contains('.dart')) {
        final regex = RegExp(r'/test/[^:]+\.dart');
        final match = regex.firstMatch(line);
        if (match != null) {
          currentFile = match.group(0)?.replaceFirst('/test/', '');
        }
      }

      // Categorize errors
      if (line.contains('Error:') || line.contains('[E]') || line.contains('Failed') || line.contains('FAIL')) {
        if (currentFile != null) {
          failingFiles.putIfAbsent(currentFile, () => []).add(line.trim());

          // Categorize the error
          if (line.contains('No named parameter') || line.contains("isn't defined for the type")) {
            errorCategories['Missing Properties']!.add('$currentFile: ${line.trim()}');
          } else if (line.contains('type') && line.contains('is not a subtype of type')) {
            errorCategories['Type Cast Errors']!.add('$currentFile: ${line.trim()}');
          } else if (line.contains('Error:') && !line.contains('[E]')) {
            errorCategories['Compilation Errors']!.add('$currentFile: ${line.trim()}');
          } else if (line.contains('Expected:') || line.contains('Actual:')) {
            errorCategories['Test Assertion Failures']!.add('$currentFile: ${line.trim()}');
          } else if (line.contains('Network') || line.contains('ServerException') || line.contains('API')) {
            errorCategories['Network/Service Errors']!.add('$currentFile: ${line.trim()}');
          } else {
            errorCategories['Other Runtime Errors']!.add('$currentFile: ${line.trim()}');
          }
        }
      }
    }

    // Generate report
    print('📊 FLUTTER TEST FAILURE ANALYSIS REPORT');
    print('=' * 50);
    print('Total failing test files: ${failingFiles.length}');
    print('');

    // Print failing files
    print('📁 FAILING TEST FILES:');
    print('-' * 25);
    int index = 1;
    for (final file in failingFiles.keys.toList()..sort()) {
      print('$index. $file');
      index++;
    }
    print('');

    // Print error categories
    print('🏷️ ERROR CATEGORIES:');
    print('-' * 20);
    for (final category in errorCategories.keys) {
      final errors = errorCategories[category]!;
      if (errors.isNotEmpty) {
        print('\n$category (${errors.length} errors):');
        for (int i = 0; i < errors.length && i < 5; i++) {
          print('  • ${errors[i]}');
        }
        if (errors.length > 5) {
          print('  ... and ${errors.length - 5} more errors');
        }
      }
    }

    print('\n🎯 SUMMARY BY ERROR TYPE:');
    print('-' * 25);
    errorCategories.forEach((category, errors) {
      if (errors.isNotEmpty) {
        print('• $category: ${errors.length} errors');
      }
    });

    print('\n📝 RECOMMENDATIONS:');
    print('-' * 15);
    if (errorCategories['Missing Properties']!.isNotEmpty) {
      print('• Fix model property mismatches in notification_models.dart');
    }
    if (errorCategories['Type Cast Errors']!.isNotEmpty) {
      print('• Review API response parsing and null safety');
    }
    if (errorCategories['Compilation Errors']!.isNotEmpty) {
      print('• Fix compilation errors before running tests');
    }

  } catch (e) {
    print('❌ Error running analysis: $e');
  }
}