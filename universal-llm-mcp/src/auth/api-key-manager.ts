/**
 * Universal LLM MCP - API Key Manager
 * Kullanıcı tier yönetimi ve rate limiting
 */

import { createHash, randomBytes } from 'crypto';
import * as fs from 'fs';
import * as path from 'path';

// Tier tanımları
export type UserTier = 'owner' | 'pro' | 'basic' | 'free';

export interface APIKeyInfo {
    key: string;
    email: string;
    tier: UserTier;
    dailyLimit: number;
    usedToday: number;
    lastReset: string;
    createdAt: string;
    models: string[];
}

export interface TierConfig {
    dailyLimit: number;
    models: string[];
    priceUSD: number;
}

// Tier yapılandırması
export const TIER_CONFIG: Record<UserTier, TierConfig> = {
    owner: {
        dailyLimit: -1, // Sınırsız
        models: ['all'],
        priceUSD: 0,
    },
    pro: {
        dailyLimit: 10000,
        models: ['all'],
        priceUSD: 20,
    },
    basic: {
        dailyLimit: 1000,
        models: ['ollama', 'gemini', 'groq'],
        priceUSD: 5,
    },
    free: {
        dailyLimit: 100,
        models: ['ollama'],
        priceUSD: 0,
    },
};

// Owner email listesi
const OWNER_EMAILS = ['344mehmet@gmail.com'];

/**
 * API Key Manager Sınıfı
 */
export class APIKeyManager {
    private keysFilePath: string;
    private keys: Map<string, APIKeyInfo>;

    constructor(storagePath: string = './data') {
        this.keysFilePath = path.join(storagePath, 'api-keys.json');
        this.keys = new Map();
        this.loadKeys();
    }

    /**
     * Kayıtlı anahtarları yükle
     */
    private loadKeys(): void {
        try {
            if (fs.existsSync(this.keysFilePath)) {
                const data = JSON.parse(fs.readFileSync(this.keysFilePath, 'utf-8'));
                this.keys = new Map(Object.entries(data));
            }
        } catch (error) {
            console.error('[APIKeyManager] Key yükleme hatası:', error);
        }
    }

    /**
     * Anahtarları kaydet
     */
    private saveKeys(): void {
        try {
            const dir = path.dirname(this.keysFilePath);
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
            const data = Object.fromEntries(this.keys);
            fs.writeFileSync(this.keysFilePath, JSON.stringify(data, null, 2));
        } catch (error) {
            console.error('[APIKeyManager] Key kaydetme hatası:', error);
        }
    }

    /**
     * Yeni API key oluştur
     */
    generateKey(email: string, tier?: UserTier): APIKeyInfo {
        // Owner kontrolü
        const actualTier = OWNER_EMAILS.includes(email) ? 'owner' : (tier || 'free');
        const tierConfig = TIER_CONFIG[actualTier];

        const key = 'mcp_' + randomBytes(32).toString('hex');

        const keyInfo: APIKeyInfo = {
            key,
            email,
            tier: actualTier,
            dailyLimit: tierConfig.dailyLimit,
            usedToday: 0,
            lastReset: new Date().toISOString().split('T')[0],
            createdAt: new Date().toISOString(),
            models: tierConfig.models,
        };

        this.keys.set(key, keyInfo);
        this.saveKeys();

        return keyInfo;
    }

    /**
     * API key doğrula
     */
    validateKey(key: string): APIKeyInfo | null {
        const keyInfo = this.keys.get(key);
        if (!keyInfo) return null;

        // Günlük reset kontrolü
        const today = new Date().toISOString().split('T')[0];
        if (keyInfo.lastReset !== today) {
            keyInfo.usedToday = 0;
            keyInfo.lastReset = today;
            this.saveKeys();
        }

        return keyInfo;
    }

    /**
     * Kullanım kaydı
     */
    recordUsage(key: string, tokens: number = 1): boolean {
        const keyInfo = this.keys.get(key);
        if (!keyInfo) return false;

        // Sınırsız ise (-1) her zaman izin ver
        if (keyInfo.dailyLimit === -1) {
            keyInfo.usedToday += tokens;
            this.saveKeys();
            return true;
        }

        // Limit kontrolü
        if (keyInfo.usedToday + tokens > keyInfo.dailyLimit) {
            return false; // Limit aşıldı
        }

        keyInfo.usedToday += tokens;
        this.saveKeys();
        return true;
    }

    /**
     * Model erişim kontrolü
     */
    canAccessModel(key: string, model: string): boolean {
        const keyInfo = this.keys.get(key);
        if (!keyInfo) return false;

        // 'all' ise her modele erişim var
        if (keyInfo.models.includes('all')) return true;

        // Spesifik model kontrolü
        return keyInfo.models.some(m => model.toLowerCase().includes(m.toLowerCase()));
    }

    /**
     * Kullanım istatistikleri
     */
    getUsageStats(key: string): { used: number; limit: number; remaining: number } | null {
        const keyInfo = this.keys.get(key);
        if (!keyInfo) return null;

        const limit = keyInfo.dailyLimit === -1 ? Infinity : keyInfo.dailyLimit;
        const remaining = limit === Infinity ? Infinity : Math.max(0, limit - keyInfo.usedToday);

        return {
            used: keyInfo.usedToday,
            limit,
            remaining,
        };
    }

    /**
     * Tier yükseltme
     */
    upgradeTier(key: string, newTier: UserTier): boolean {
        const keyInfo = this.keys.get(key);
        if (!keyInfo) return false;

        const tierConfig = TIER_CONFIG[newTier];
        keyInfo.tier = newTier;
        keyInfo.dailyLimit = tierConfig.dailyLimit;
        keyInfo.models = tierConfig.models;

        this.saveKeys();
        return true;
    }

    /**
     * Email ile key bul
     */
    findByEmail(email: string): APIKeyInfo | null {
        for (const keyInfo of this.keys.values()) {
            if (keyInfo.email === email) {
                return keyInfo;
            }
        }
        return null;
    }
}

// Singleton instance
let instance: APIKeyManager | null = null;

export function getAPIKeyManager(storagePath?: string): APIKeyManager {
    if (!instance) {
        instance = new APIKeyManager(storagePath);
    }
    return instance;
}
