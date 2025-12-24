import { defineConfig } from 'drizzle-kit';

/**
 * Drizzle CLI yapılandırması - Gelişmiş Migration dökümleri için
 */
export default defineConfig({
    schema: './src/db/schema.ts',
    out: './drizzle',
    dialect: 'sqlite', // Modern v0.24+ sözdizimi
    dbCredentials: {
        url: 'file:./local.db',
    },
});
