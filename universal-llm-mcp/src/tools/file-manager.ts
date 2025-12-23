/**
 * Universal LLM MCP - Dosya Yönetimi ve Versiyon Kontrolü
 * Diff view, geri alma, dosya kilitleme
 */

import * as fs from 'fs';
import * as path from 'path';
import { createHash } from 'crypto';

export interface FileVersion {
    hash: string;
    content: string;
    timestamp: Date;
    author?: string;
}

export interface FileLock {
    path: string;
    lockedBy: string;
    lockedAt: Date;
}

export class FileManager {
    private versions: Map<string, FileVersion[]> = new Map();
    private locks: Map<string, FileLock> = new Map();
    private maxVersions = 50;
    private baseDir: string;

    constructor(baseDir?: string) {
        this.baseDir = baseDir || process.cwd();
        console.log('[FileManager] Başlatıldı:', this.baseDir);
    }

    /**
     * Dosya oku
     */
    readFile(filePath: string): string {
        const fullPath = path.resolve(this.baseDir, filePath);
        return fs.readFileSync(fullPath, 'utf-8');
    }

    /**
     * Dosya yaz (versiyon kaydı ile)
     */
    writeFile(filePath: string, content: string, author?: string): void {
        const fullPath = path.resolve(this.baseDir, filePath);

        // Kilidi kontrol et
        const lock = this.locks.get(fullPath);
        if (lock && lock.lockedBy !== author) {
            throw new Error(`Dosya kilitli: ${lock.lockedBy} tarafından`);
        }

        // Mevcut versiyonu kaydet
        if (fs.existsSync(fullPath)) {
            this.saveVersion(fullPath, fs.readFileSync(fullPath, 'utf-8'), author);
        }

        // Dizini oluştur
        const dir = path.dirname(fullPath);
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }

        // Yaz
        fs.writeFileSync(fullPath, content, 'utf-8');
    }

    /**
     * Versiyon kaydet
     */
    private saveVersion(filePath: string, content: string, author?: string): void {
        const hash = createHash('md5').update(content).digest('hex');

        const versions = this.versions.get(filePath) || [];

        // Aynı hash varsa kaydetme
        if (versions.length > 0 && versions[versions.length - 1].hash === hash) {
            return;
        }

        versions.push({
            hash,
            content,
            timestamp: new Date(),
            author,
        });

        // Maksimum versiyon sayısını aş
        if (versions.length > this.maxVersions) {
            versions.shift();
        }

        this.versions.set(filePath, versions);
    }

    /**
     * Versiyon geçmişi
     */
    getHistory(filePath: string): Array<{ hash: string; timestamp: Date; author?: string }> {
        const fullPath = path.resolve(this.baseDir, filePath);
        const versions = this.versions.get(fullPath) || [];
        return versions.map(v => ({
            hash: v.hash,
            timestamp: v.timestamp,
            author: v.author,
        }));
    }

    /**
     * Versiyona geri dön
     */
    revertToVersion(filePath: string, hash: string): string {
        const fullPath = path.resolve(this.baseDir, filePath);
        const versions = this.versions.get(fullPath) || [];

        const version = versions.find(v => v.hash === hash);
        if (!version) {
            throw new Error(`Versiyon bulunamadı: ${hash}`);
        }

        // Mevcut versiyonu kaydet
        if (fs.existsSync(fullPath)) {
            this.saveVersion(fullPath, fs.readFileSync(fullPath, 'utf-8'), 'revert');
        }

        // Geri al
        fs.writeFileSync(fullPath, version.content, 'utf-8');
        return version.content;
    }

    /**
     * Diff hesapla (basit satır bazlı)
     */
    diff(filePath: string, versionHash?: string): string[] {
        const fullPath = path.resolve(this.baseDir, filePath);
        const current = fs.existsSync(fullPath) ? fs.readFileSync(fullPath, 'utf-8') : '';

        let previous = '';
        const versions = this.versions.get(fullPath) || [];

        if (versionHash) {
            const v = versions.find(v => v.hash === versionHash);
            previous = v?.content || '';
        } else if (versions.length > 0) {
            previous = versions[versions.length - 1].content;
        }

        const currentLines = current.split('\n');
        const previousLines = previous.split('\n');
        const diffResult: string[] = [];

        const maxLines = Math.max(currentLines.length, previousLines.length);
        for (let i = 0; i < maxLines; i++) {
            const curr = currentLines[i] || '';
            const prev = previousLines[i] || '';

            if (curr !== prev) {
                if (prev) diffResult.push(`- ${i + 1}: ${prev}`);
                if (curr) diffResult.push(`+ ${i + 1}: ${curr}`);
            }
        }

        return diffResult;
    }

    /**
     * Dosya kilitle
     */
    lockFile(filePath: string, lockedBy: string): void {
        const fullPath = path.resolve(this.baseDir, filePath);

        const existing = this.locks.get(fullPath);
        if (existing && existing.lockedBy !== lockedBy) {
            throw new Error(`Dosya zaten kilitli: ${existing.lockedBy}`);
        }

        this.locks.set(fullPath, {
            path: fullPath,
            lockedBy,
            lockedAt: new Date(),
        });
    }

    /**
     * Kilit aç
     */
    unlockFile(filePath: string, unlockedBy: string): void {
        const fullPath = path.resolve(this.baseDir, filePath);

        const lock = this.locks.get(fullPath);
        if (lock && lock.lockedBy !== unlockedBy) {
            throw new Error(`Kilidi açma yetkisi yok`);
        }

        this.locks.delete(fullPath);
    }

    /**
     * Kilitli dosyaları listele
     */
    getLockedFiles(): FileLock[] {
        return Array.from(this.locks.values());
    }

    /**
     * Dosya ara
     */
    search(pattern: string, directory?: string): Array<{ path: string; line: number; content: string }> {
        const searchDir = directory ? path.resolve(this.baseDir, directory) : this.baseDir;
        const results: Array<{ path: string; line: number; content: string }> = [];
        const regex = new RegExp(pattern, 'gi');

        const searchRecursive = (dir: string) => {
            const files = fs.readdirSync(dir);

            for (const file of files) {
                const fullPath = path.join(dir, file);
                const stat = fs.statSync(fullPath);

                if (stat.isDirectory()) {
                    if (!file.startsWith('.') && file !== 'node_modules' && file !== 'dist') {
                        searchRecursive(fullPath);
                    }
                } else if (stat.isFile()) {
                    try {
                        const content = fs.readFileSync(fullPath, 'utf-8');
                        const lines = content.split('\n');

                        lines.forEach((line, idx) => {
                            if (regex.test(line)) {
                                results.push({
                                    path: path.relative(this.baseDir, fullPath),
                                    line: idx + 1,
                                    content: line.trim(),
                                });
                            }
                        });
                    } catch {
                        // Binary dosyaları atla
                    }
                }
            }
        };

        searchRecursive(searchDir);
        return results.slice(0, 100); // Max 100 sonuç
    }

    /**
     * ZIP olarak dışa aktar
     */
    async exportZip(outputPath: string): Promise<string> {
        // Basit tar.gz - gerçek projede archiver kullanılır
        const { exec } = await import('child_process');
        const { promisify } = await import('util');
        const execAsync = promisify(exec);

        const zipPath = outputPath || path.join(this.baseDir, `export_${Date.now()}.zip`);

        try {
            await execAsync(`powershell Compress-Archive -Path "${this.baseDir}\\*" -DestinationPath "${zipPath}" -Force`);
            return zipPath;
        } catch (error) {
            throw new Error(`ZIP oluşturulamadı: ${error}`);
        }
    }
}

// Singleton
let fileManagerInstance: FileManager | null = null;

export function getFileManager(baseDir?: string): FileManager {
    if (!fileManagerInstance) {
        fileManagerInstance = new FileManager(baseDir);
    }
    return fileManagerInstance;
}
