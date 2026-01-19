const fs = require('fs');
const path = require('path');

const filePath = '/home/data/dev_react/awcms-dev/awcms/supabase/migrations/20260104102020_remote_schema.sql';

if (!fs.existsSync(filePath)) {
    console.error('File not found:', filePath);
    process.exit(1);
}

let content = fs.readFileSync(filePath, 'utf8');

console.log('Commenting out all potentially duplicate objects (Constraints, Indexes, Triggers, RLS, Policies)...');

const patterns = [
    // Constraints
    /ALTER TABLE ONLY "public"\."([^"]+)"\s+ADD CONSTRAINT "([^"]+)" (PRIMARY KEY|UNIQUE|CHECK|FOREIGN KEY)/g,
    /ALTER TABLE ONLY "public"\."([^"]+)"\n\s+ADD CONSTRAINT "([^"]+)" (PRIMARY KEY|UNIQUE|CHECK|FOREIGN KEY)/g,

    // Indexes
    /CREATE INDEX "([^"]+)" ON "public"\."([^"]+)"/g,
    /CREATE UNIQUE INDEX "([^"]+)" ON "public"\."([^"]+)"/g,

    // Triggers
    /CREATE TRIGGER "([^"]+)"/g,

    // RLS (ALTER TABLE ... ENABLE ROW LEVEL SECURITY)
    /ALTER TABLE "public"\."([^"]+)" ENABLE ROW LEVEL SECURITY/g,

    // Policies (CREATE POLICY)
    /CREATE POLICY "([^"]+)" ON "public"\."([^"]+)"/g,

    // Sequence ownership
    /ALTER SEQUENCE "public"\."([^"]+)" OWNED BY/g
];

patterns.forEach((pattern, index) => {
    content = content.replace(pattern, (match) => {
        // console.log(`Fixing match for pattern ${index}`);
        return `-- Duplicate Object Fix --\n-- ${match.replace(/\n/g, '\n-- ')}`;
    });
});

fs.writeFileSync(filePath, content);
console.log('Done.');
