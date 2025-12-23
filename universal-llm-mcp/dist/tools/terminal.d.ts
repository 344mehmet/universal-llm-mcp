/**
 * Universal LLM MCP - Entegre Terminal
 * Web tabanlı terminal emülatörü
 */
import { ChildProcess } from 'child_process';
import { EventEmitter } from 'events';
export interface TerminalSession {
    id: string;
    process: ChildProcess;
    output: string[];
    cwd: string;
    isRunning: boolean;
}
export declare class TerminalManager extends EventEmitter {
    private sessions;
    private maxOutputLines;
    constructor();
    /**
     * Yeni terminal oturumu oluştur
     */
    createSession(cwd?: string): string;
    /**
     * Komut çalıştır
     */
    runCommand(sessionId: string, command: string): Promise<string>;
    /**
     * Tek seferlik komut çalıştır
     */
    exec(command: string, cwd?: string): Promise<{
        stdout: string;
        stderr: string;
        code: number;
    }>;
    /**
     * Oturum çıktısını al
     */
    getOutput(sessionId: string): string[];
    /**
     * Oturumu kapat
     */
    closeSession(sessionId: string): void;
    /**
     * Tüm oturumları listele
     */
    listSessions(): Array<{
        id: string;
        cwd: string;
        isRunning: boolean;
    }>;
}
export declare function getTerminalManager(): TerminalManager;
//# sourceMappingURL=terminal.d.ts.map