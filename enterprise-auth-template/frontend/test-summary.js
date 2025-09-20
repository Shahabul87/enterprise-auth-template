#!/usr/bin/env node

const { execSync } = require('child_process');

console.log('Running test suite and collecting results...\n');

try {
  const output = execSync('npm test -- --listTests --silent 2>&1', { encoding: 'utf8' });
  const testFiles = output.trim().split('\n').filter(f => f.includes('.test.'));
  console.log(`Total test files found: ${testFiles.length}`);

  // Run tests with silent option to get just the summary
  console.log('\nRunning tests...\n');
  try {
    execSync('npm test -- --passWithNoTests --silent', {
      encoding: 'utf8',
      stdio: 'inherit'
    });
  } catch (testError) {
    // Tests may fail but we still want to see the output
    console.log('Some tests failed, but continuing...');
  }
} catch (error) {
  console.error('Error running tests:', error.message);
}