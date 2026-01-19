const { execSync } = require('child_process');

try {
    console.log('Fetching migration list...');
    // Force width to ensure no truncation? CLI might not respect it but let's try
    const output = execSync('npx supabase migration list', { encoding: 'utf-8' });

    const lines = output.split('\n');
    const versionsToRepair = [];

    // Parse output to find Local versions that are not on Remote
    // Format: " <Version> | <Remote> | <Time>"
    // We need lines where Local is present (vers) and Remote is empty or different?
    // Actually the output format is fixed width.

    console.log('Parsing migrations...');
    lines.forEach(line => {
        // Skip headers and separators
        if (line.includes('Local') || line.includes('----')) return;

        const parts = line.trim().split('|').map(s => s.trim());
        if (parts.length < 2) return;

        const local = parts[0];
        const remote = parts[1];

        if (local && (!remote || remote === '')) {
            versionsToRepair.push(local);
        }
    });

    if (versionsToRepair.length === 0) {
        console.log('No migrations to repair.');
        process.exit(0);
    }

    console.log(`Found ${versionsToRepair.length} migrations to repair.`);

    // Repair in batches or one by one
    // supabase migration repair --status applied <version>
    // We can pass multiple? CLI docs say: <version>... 
    // Let's try passing all at once to save time

    const versionList = versionsToRepair.join(' ');
    const cmd = `npx supabase migration repair --status applied ${versionList}`;

    console.log('Running repair command...');
    // console.log(cmd); // Debug if needed

    execSync(cmd, { stdio: 'inherit' });

    console.log('Success! History repaired.');

} catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
}
