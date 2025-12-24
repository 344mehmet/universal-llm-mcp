const fs = require('fs');

const content = fs.readFileSync('config.json', 'utf-8');
console.log('File length:', content.length);
console.log('Char at position 100:', content.charCodeAt(100), '=', JSON.stringify(content.charAt(100)));

// Simulate config.ts regex
const cleaned = content
    .replace(/\/\/.*$/gm, '')
    .replace(/,\s*}/g, '}')
    .replace(/,\s*]/g, ']');

try {
    JSON.parse(cleaned);
    console.log('JSON VALID after regex!');
} catch (e) {
    console.log('Error after regex:', e.message);
    console.log('Around position 100:', JSON.stringify(cleaned.substring(95, 115)));
}

try {
    JSON.parse(content);
    console.log('JSON VALID without regex!');
} catch (e) {
    console.log('Error without regex:', e.message);
}
