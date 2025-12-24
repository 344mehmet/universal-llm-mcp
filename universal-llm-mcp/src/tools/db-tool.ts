import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { getDb } from '../db/db-service.js';
import { z } from 'zod';

/**
 * Veritabanı Araçlarını Kaydet (Enterprise)
 */
export function registerDBTools(server: McpServer): void {
    const db = getDb();

    // Veritabanı Sorgulama Aracı
    server.tool(
        'db_sorgula',
        'Veritabanında SQL sorgusu (veya ilişkisel sorgu) çalıştır',
        {
            queryType: z.enum(['history', 'settings', 'documents']).describe('Sorgu tipi'),
            filter: z.string().optional().describe('Filtreleme kriteri (örn: sessionId)')
        },
        async ({ queryType, filter }) => {
            try {
                let data;
                switch (queryType) {
                    case 'history':
                        data = await db.getChatHistory(filter || '');
                        break;
                    case 'settings':
                        data = await db.getSettings();
                        break;
                    default:
                        data = 'Sorgu tipi desteklenmiyor.';
                }

                return {
                    content: [{
                        type: 'text',
                        text: `Sorgu Sonucu (${queryType}):\n` + JSON.stringify(data, null, 2)
                    }]
                };
            } catch (error) {
                return {
                    content: [{ type: 'text', text: `Hata: ${String(error)}` }],
                    isError: true
                };
            }
        }
    );
}
