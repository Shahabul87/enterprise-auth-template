#!/usr/bin/env dart

// Flutter Test Monitor and Results Aggregator
// Monitors test execution, aggregates results, and provides real-time feedback

import 'dart:io';
import 'dart:convert';
import 'dart:async';

class TestMonitor {
  static const String resultsDir = 'test_results';
  static const String summaryFile = 'test_summary.json';

  final Map<String, TestResult> results = {};
  final DateTime startTime = DateTime.now();

  void run() async {
    print('🎯 Flutter Test Monitor Started');
    print('📊 Monitoring test results in: $resultsDir/');
    print('⏰ Started at: ${startTime.toIso8601String()}');
    print('=' * 50);

    // Create results directory if it doesn't exist
    await Directory(resultsDir).create(recursive: true);

    // Start monitoring
    await _startMonitoring();
  }

  Future<void> _startMonitoring() async {
    final dir = Directory(resultsDir);

    // Watch for new result files
    await for (final event in dir.watch(recursive: true)) {
      if (event.type == FileSystemEvent.create ||
          event.type == FileSystemEvent.modify) {

        final file = File(event.path);
        if (file.path.endsWith('.txt') && await file.exists()) {
          await _processResultFile(file);
        }
      }
    }
  }

  Future<void> _processResultFile(File file) async {
    try {
      final content = await file.readAsString();
      final fileName = file.uri.pathSegments.last;

      final result = _parseTestOutput(content, fileName);
      results[fileName] = result;

      _printProgress(result);
      await _updateSummary();

    } catch (e) {
      print('⚠️  Error processing ${file.path}: $e');
    }
  }

  TestResult _parseTestOutput(String content, String fileName) {
    final lines = content.split('\n');

    int passed = 0;
    int failed = 0;
    int skipped = 0;
    final List<String> failures = [];

    for (final line in lines) {
      if (line.contains('PASS')) {
        passed++;
      } else if (line.contains('FAIL')) {
        failed++;
        failures.add(line.trim());
      } else if (line.contains('SKIP')) {
        skipped++;
      }
    }

    // Extract folder name from file name
    final folderName = fileName.replaceAll(RegExp(r'_\d+\.txt$'), '');

    return TestResult(
      folder: folderName,
      passed: passed,
      failed: failed,
      skipped: skipped,
      failures: failures,
      timestamp: DateTime.now(),
    );
  }

  void _printProgress(TestResult result) {
    final icon = result.failed > 0 ? '❌' : '✅';
    final status = result.failed > 0 ? 'FAILED' : 'PASSED';

    print('$icon ${result.folder}: $status');
    print('   📊 Passed: ${result.passed}, Failed: ${result.failed}, Skipped: ${result.skipped}');

    if (result.failures.isNotEmpty && result.failures.length <= 3) {
      print('   💥 Failures:');
      for (final failure in result.failures.take(3)) {
        print('      - $failure');
      }
    }
    print('');
  }

  Future<void> _updateSummary() async {
    final summary = _generateSummary();
    final summaryPath = '$resultsDir/$summaryFile';

    await File(summaryPath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(summary)
    );
  }

  Map<String, dynamic> _generateSummary() {
    final totalPassed = results.values.fold(0, (sum, r) => sum + r.passed);
    final totalFailed = results.values.fold(0, (sum, r) => sum + r.failed);
    final totalSkipped = results.values.fold(0, (sum, r) => sum + r.skipped);

    final failedFolders = results.values
        .where((r) => r.failed > 0)
        .map((r) => r.folder)
        .toList();

    final duration = DateTime.now().difference(startTime);

    return {
      'summary': {
        'total_passed': totalPassed,
        'total_failed': totalFailed,
        'total_skipped': totalSkipped,
        'total_folders': results.length,
        'failed_folders': failedFolders,
        'success_rate': totalPassed + totalFailed > 0
            ? (totalPassed / (totalPassed + totalFailed) * 100).round()
            : 0,
        'duration_minutes': duration.inMinutes,
        'started_at': startTime.toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
      },
      'detailed_results': results.map((key, value) => MapEntry(key, {
        'folder': value.folder,
        'passed': value.passed,
        'failed': value.failed,
        'skipped': value.skipped,
        'failures': value.failures,
        'timestamp': value.timestamp.toIso8601String(),
      })),
    };
  }

  void printFinalSummary() {
    final summary = _generateSummary()['summary'] as Map<String, dynamic>;

    print('=' * 50);
    print('🏁 FINAL TEST SUMMARY');
    print('=' * 50);
    print('📊 Results:');
    print('   ✅ Passed: ${summary['total_passed']}');
    print('   ❌ Failed: ${summary['total_failed']}');
    print('   ⏭️  Skipped: ${summary['total_skipped']}');
    print('   📁 Folders tested: ${summary['total_folders']}');
    print('   📈 Success rate: ${summary['success_rate']}%');
    print('   ⏱️  Duration: ${summary['duration_minutes']} minutes');

    final failedFolders = summary['failed_folders'] as List;
    if (failedFolders.isNotEmpty) {
      print('\n❌ Failed folders:');
      for (final folder in failedFolders) {
        print('   - $folder');
      }
    }

    print('\n📁 Detailed results saved in: $resultsDir/$summaryFile');
  }
}

class TestResult {
  final String folder;
  final int passed;
  final int failed;
  final int skipped;
  final List<String> failures;
  final DateTime timestamp;

  TestResult({
    required this.folder,
    required this.passed,
    required this.failed,
    required this.skipped,
    required this.failures,
    required this.timestamp,
  });
}

void main(List<String> args) async {
  final monitor = TestMonitor();

  // Handle Ctrl+C gracefully
  ProcessSignal.sigint.watch().listen((signal) {
    print('\n\n🛑 Test monitoring stopped by user');
    monitor.printFinalSummary();
    exit(0);
  });

  try {
    await monitor.run();
  } catch (e) {
    print('💥 Monitor error: $e');
    monitor.printFinalSummary();
    exit(1);
  }
}