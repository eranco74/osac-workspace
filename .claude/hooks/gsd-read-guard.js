#!/usr/bin/env node
// gsd-read-guard.js - Validate reads before writes
// Called before Write/Edit to ensure Claude has read files before modifying

const fs = require('fs');
const path = require('path');

// Read stdin (hook input JSON)
let input = '';
process.stdin.on('data', (chunk) => {
  input += chunk;
});

process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const filePath = data.file_path;

    // If file exists, check if it was read in this session
    // This is a simplified version - full implementation would track reads
    if (filePath && fs.existsSync(filePath)) {
      // For now, just pass - actual read tracking requires session state
      // A more complete implementation would use session cache
    }

    // No blocking - just exit cleanly
    process.exit(0);
  } catch (err) {
    // Don't block on errors
    process.exit(0);
  }
});
