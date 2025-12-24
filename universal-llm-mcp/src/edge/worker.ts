/// <reference types="@cloudflare/workers-types" />
import { drizzle } from 'drizzle-orm/d1';
import * as schema from '../db/schema.js';

/**
 * Cloudflare Worker - Edge API
 * KV (Cacching/Config) ve D1 (SQL) entegrasyonu örneği
 */

export interface Env {
    DB: D1Database;
    CONFIG_KV: KVNamespace;
    API_KEY: string;
}

export default {
    async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
        const url = new URL(request.url);
        const db = drizzle(env.DB, { schema });

        // 1. KV - Hızlı Yapılandırma Kontrolü (Edge Caching)
        const isMaintenance = await env.CONFIG_KV.get('maintenance_mode');
        if (isMaintenance === 'true') {
            return new Response('System Maintenance', { status: 503 });
        }

        // 2. D1 - SQL Sorgu Optimizasyonu (İndekslenmiş veri çekme)
        if (url.pathname === '/api/edge/stats') {
            const stats = await db.select().from(schema.settings).all();
            return Response.json({ success: true, data: stats });
        }

        // 3. Security - TLS & Header Kontrolü
        if (request.method === 'POST') {
            const token = request.headers.get('Authorization');
            if (token !== env.API_KEY) {
                return new Response('Unauthorized', { status: 401 });
            }
        }

        return new Response('Universal LLM Edge Platform Ready', { status: 200 });
    },
};
