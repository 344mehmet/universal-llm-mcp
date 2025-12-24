import { drizzle } from 'drizzle-orm/libsql';
import { createClient } from '@libsql/client';
import * as schema from './schema.js';

/**
 * Enterprise Veritabanı Servisi (DAL)
 * Singleton pattern ile tüm DB işlemlerini merkezi bir noktadan yönetir.
 */
export class DbService {
    private static instance: DbService;
    private db;

    private constructor() {
        const client = createClient({
            url: process.env.DATABASE_URL || 'file:local.db',
            authToken: process.env.DATABASE_AUTH_TOKEN, // Cloudflare D1/Turso için
        });
        this.db = drizzle(client, { schema });
    }

    public static getInstance(): DbService {
        if (!DbService.instance) {
            DbService.instance = new DbService();
        }
        return DbService.instance;
    }

    // --- Soyutlanmış Veri Erişim Metotları ---

    async getChatHistory(sessionId: string) {
        return await this.db.query.messages.findMany({
            where: (messages: any, { eq }: any) => eq(messages.sessionId, sessionId),
            orderBy: (messages: any, { asc }: any) => [asc(messages.createdAt)],
        });
    }

    async saveMessage(data: typeof schema.messages.$inferInsert) {
        return await this.db.insert(schema.messages).values({
            ...data,
            createdAt: new Date(),
        }).returning();
    }

    async createSession(data: typeof schema.chatSessions.$inferInsert) {
        return await this.db.insert(schema.chatSessions).values({
            ...data,
            createdAt: new Date(),
            updatedAt: new Date(),
        }).returning();
    }

    async getSettings() {
        return await this.db.select().from(schema.settings);
    }
}

export const getDb = () => DbService.getInstance();
