const fs = require('fs');
const path = require('path');

// Fix store imports in test files
const fixes = [
  {
    file: 'src/__tests__/stores/admin-store.test.ts',
    from: "from '../../stores/admin.store'",
    to: "from '@/stores/admin-store'"
  },
  {
    file: 'src/__tests__/stores/settings-store.test.ts',
    from: "from '../../stores/settings.store'",
    to: "from '@/stores/settings-store'"
  }
];

fixes.forEach(fix => {
  const filePath = path.join(__dirname, fix.file);
  
  if (!fs.existsSync(filePath)) {
    console.log(`File not found: ${fix.file}`);
    return;
  }
  
  let content = fs.readFileSync(filePath, 'utf8');
  
  if (content.includes(fix.from)) {
    content = content.replace(new RegExp(fix.from.replace('.', '\\.'), 'g'), fix.to);
    fs.writeFileSync(filePath, content);
    console.log(`Fixed imports in: ${fix.file}`);
  } else {
    console.log(`Pattern not found in: ${fix.file}`);
  }
});

console.log('Done fixing store imports!');
