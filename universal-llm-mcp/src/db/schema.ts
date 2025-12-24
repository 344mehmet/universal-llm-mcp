import { sqliteTable, text, integer, index } from 'drizzle-orm/sqlite-core';

/**
 * Cloudflare D1 & SQLite uyumlu profesyonel veritabanı şeması
 */

// Sohbet Oturumları
export const chatSessions = sqliteTable('chat_sessions', {
    id: text('id').primaryKey(),
    userId: text('user_id').notNull(),
    title: text('title').notNull(),
    createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
    updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
}, (table: any) => ({
    userIndex: index('user_idx').on(table.userId),
}));

// Mesaj Geçmişi
export const messages = sqliteTable('messages', {
    id: integer('id').primaryKey({ autoIncrement: true }),
    sessionId: text('session_id').references(() => chatSessions.id),
    role: text('role', { enum: ['user', 'assistant', 'system'] }).notNull(),
    content: text('content').notNull(),
    model: text('model'),
    tokens: integer('tokens'),
    latency: integer('latency'),
    createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
}, (table: any) => ({
    sessionIndex: index('session_idx').on(table.sessionId),
}));

// RAG Dokümanları (Gelişmiş)
export const documents = sqliteTable('documents', {
    id: text('id').primaryKey(),
    title: text('title').notNull(),
    content: text('content').notNull(),
    metadata: text('metadata'), // JSON string
    category: text('category'),
    embedding: text('embedding'), // Vektör (D1/SQLite için blob veya string)
    createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});

// Sistem Ayarları (KV alternatifi)
export const settings = sqliteTable('settings', {
    key: text('key').primaryKey(),
    value: text('value').notNull(),
    updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
