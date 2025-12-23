/**
 * Universal LLM MCP - Entegre Terminal
 * Web tabanlı terminal emülatörü
 */

import { spawn, ChildProcess } from 'child_process';
import { EventEmitter } from 'events';

export interface TerminalSession {
    id: string;
    process: ChildProcess;
    output: string[];
    cwd: string;
    isRunning: boolean;
}

export class TerminalManager extends EventEmitter {
    private sessions: Map<string, TerminalSession> = new Map();
    private maxOutputLines = 1000;

    constructor() {
        super();
        console.log('[Terminal] Manager başlatıldı');
    }

    /**
     * Yeni terminal oturumu oluştur
     */
    createSession(cwd?: string): string {
        const id = `term_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`;
        const workDir = cwd || process.cwd();

        const shell = process.platform === 'win32' ? 'powershell.exe' : '/bin/bash';
        const proc = spawn(shell, [], {
            cwd: workDir,
            env: process.env,
            shell: true,
        });

        const session: TerminalSession = {
            id,
            process: proc,
            output: [],
            cwd: workDir,
            isRunning: true,
        };

        proc.stdout?.on('data', (data) => {
            const text = data.toString();
            session.output.push(text);
            if (session.output.length > this.maxOutputLines) {
                session.output.shift();
            }
            this.emit('output', { id, text, type: 'stdout' });
        });

        proc.stderr?.on('data', (data) => {
            const text = data.toString();
            session.output.push(text);
            this.emit('output', { id, text, type: 'stderr' });
        });

        proc.on('close', (code) => {
            session.isRunning = false;
            this.emit('close', { id, code });
        });

        this.sessions.set(id, session);
        console.log(`[Terminal] Oturum oluşturuldu: ${id}`);

        return id;
    }

    /**
     * Komut çalıştır
     */
    async runCommand(sessionId: string, command: string): Promise<string> {
        const session = this.sessions.get(sessionId);
        if (!session) {
            throw new Error(`Oturum bulunamadı: ${sessionId}`);
        }

        return new Promise((resolve, reject) => {
            let output = '';

            const onData = (data: { id: string; text: string }) => {
                if (data.id === sessionId) {
                    output += data.text;
                }
            };

            this.on('output', onData);

            session.process.stdin?.write(command + '\n');

            // Çıktıyı bekle
            setTimeout(() => {
                this.off('output', onData);
                resolve(output);
            }, 2000);
        });
    }

    /**
     * Tek seferlik komut çalıştır
     */
    async exec(command: string, cwd?: string): Promise<{ stdout: string; stderr: string; code: number }> {
        return new Promise((resolve) => {
            const shell = process.platform === 'win32' ? 'powershell.exe' : '/bin/bash';
            const args = process.platform === 'win32' ? ['-Command', command] : ['-c', command];

            const proc = spawn(shell, args, {
                cwd: cwd || process.cwd(),
                env: process.env,
            });

            let stdout = '';
            let stderr = '';

            proc.stdout?.on('data', (data) => { stdout += data.toString(); });
            proc.stderr?.on('data', (data) => { stderr += data.toString(); });

            proc.on('close', (code) => {
                resolve({ stdout, stderr, code: code || 0 });
            });
        });
    }

    /**
     * Oturum çıktısını al
     */
    getOutput(sessionId: string): string[] {
        return this.sessions.get(sessionId)?.output || [];
    }

    /**
     * Oturumu kapat
     */
    closeSession(sessionId: string): void {
        const session = this.sessions.get(sessionId);
        if (session) {
            session.process.kill();
            this.sessions.delete(sessionId);
            console.log(`[Terminal] Oturum kapatıldı: ${sessionId}`);
        }
    }

    /**
     * Tüm oturumları listele
     */
    listSessions(): Array<{ id: string; cwd: string; isRunning: boolean }> {
        return Array.from(this.sessions.values()).map(s => ({
            id: s.id,
            cwd: s.cwd,
            isRunning: s.isRunning,
        }));
    }
}

// Singleton
let terminalInstance: TerminalManager | null = null;

export function getTerminalManager(): TerminalManager {
    if (!terminalInstance) {
        terminalInstance = new TerminalManager();
    }
    return terminalInstance;
}
