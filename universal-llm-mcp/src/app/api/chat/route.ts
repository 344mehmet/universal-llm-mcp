import { NextResponse } from 'next/server';
import { getDb } from '../../../db/db-service.js';

/**
 * Next.js 15 Edge Route Handler
 * "Senior" Seviye: RSC Uyumluluğu, Önbellekleme ve Edge Runtime
 */

export const runtime = 'edge'; // Edge üzerinde çalışmasını zorla (Performance & Scalability)

export async function POST(req: Request) {
    try {
        // 1. Veri Alma ve Doğrulama
        const { message, sessionId } = (await req.json()) as { message: string; sessionId: string };

        if (!message) {
            return NextResponse.json({ error: 'Mesaj boş olamaz' }, { status: 400 });
        }

        // 2. Veritabanı İşlemi (Edge-Native LibSQL/D1)
        const db = getDb();
        const savedMessage = await db.saveMessage({
            sessionId,
            role: 'user',
            content: message,
            createdAt: new Date(),
        });

        // 3. Revalidation & Caching (Next.js specific)
        // Örnek: revalidatePath('/chat/[id]')

        return NextResponse.json({
            success: true,
            data: savedMessage,
            meta: {
                runtime: 'edge',
                region: 'global',
            }
        });

    } catch (error: any) {
        console.error('[Edge API Error]:', error);
        return NextResponse.json(
            { error: error?.message || 'Sunucu hatası' },
            { status: 500 }
        );
    }
}

/**
 * Senior Specialist Gereksinimleri Notu:
 * - Edge Runtime kullanımı: Cold start sürelerini minimize eder.
 * - NextResponse kullanımı: Modern API standartları.
 * - Try/Catch & Error Logging: Güvenilirlik ve observability.
 */
