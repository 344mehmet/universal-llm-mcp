/**
 * Universal LLM MCP - Dosya Yönetimi ve Versiyon Kontrolü
 * Diff view, geri alma, dosya kilitleme
 */
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
export declare class FileManager {
    private versions;
    private locks;
    private maxVersions;
    private baseDir;
    constructor(baseDir?: string);
    /**
     * Dosya oku
     */
    readFile(filePath: string): string;
    /**
     * Dosya yaz (versiyon kaydı ile)
     */
    writeFile(filePath: string, content: string, author?: string): void;
    /**
     * Versiyon kaydet
     */
    private saveVersion;
    /**
     * Versiyon geçmişi
     */
    getHistory(filePath: string): Array<{
        hash: string;
        timestamp: Date;
        author?: string;
    }>;
    /**
     * Versiyona geri dön
     */
    revertToVersion(filePath: string, hash: string): string;
    /**
     * Diff hesapla (basit satır bazlı)
     */
    diff(filePath: string, versionHash?: string): string[];
    /**
     * Dosya kilitle
     */
    lockFile(filePath: string, lockedBy: string): void;
    /**
     * Kilit aç
     */
    unlockFile(filePath: string, unlockedBy: string): void;
    /**
     * Kilitli dosyaları listele
     */
    getLockedFiles(): FileLock[];
    /**
     * Dosya ara
     */
    search(pattern: string, directory?: string): Array<{
        path: string;
        line: number;
        content: string;
    }>;
    /**
     * ZIP olarak dışa aktar
     */
    exportZip(outputPath: string): Promise<string>;
}
export declare function getFileManager(baseDir?: string): FileManager;
//# sourceMappingURL=file-manager.d.ts.map