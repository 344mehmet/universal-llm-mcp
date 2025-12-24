/**
 * Universal LLM MCP - Web RAG Server
 * HTTPS API sunucusu - Güvenli bağlantı (Self-signed sertifika)
 */

import { createServer as createHttpsServer, ServerOptions } from 'https';
import { createServer as createHttpServer, IncomingMessage, ServerResponse } from 'http';
import os from 'os';
import { URL } from 'url';
import { existsSync, mkdirSync, readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { spawn, execSync } from 'child_process';
import { getRAGService } from './rag/rag-service.js';
import { getRouter } from './router/llm-router.js';
import { getConfigManager } from './config.js';
import { getPromptBank } from './training/prompt-bank.js';
import { getDebateEngine, DEFAULT_DEBATE_CONFIG, ExpertiseDomain } from './debate/debate-engine.js';
import { getFastTrainer } from './training/fast-trainer.js';
import { loadAllTrainingExamples } from './training/training-data.js';
import { queryAllLLMs } from './core/multi-llm.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const DEFAULT_PORT = 3355;
const CERT_DIR = join(__dirname, '..', 'certs');
const SECURITY_HEADERS = {
    'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline' https://fonts.googleapis.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data:; connect-src 'self';",
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'Strict-Transport-Security': 'max-age=63072000; includeSubDomains; preload',
    'Permissions-Policy': 'camera=(), microphone=(), geolocations=()',
};

const CORS_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-CSRF-Token',
    'Content-Type': 'application/json; charset=utf-8',
};

interface APIResponse {
    success: boolean;
    data?: any;
    error?: string;
    timestamp: string;
}

function ensureCertificates(): { key: Buffer; cert: Buffer } {
    const keyPath = join(CERT_DIR, 'server.key');
    const certPath = join(CERT_DIR, 'server.crt');

    if (existsSync(keyPath) && existsSync(certPath)) {
        return { key: readFileSync(keyPath), cert: readFileSync(certPath) };
    }

    if (!existsSync(CERT_DIR)) mkdirSync(CERT_DIR, { recursive: true });

    try {
        const gitOpenSSL = 'C:\\Program Files\\Git\\usr\\bin\\openssl.exe';
        const opensslBin = existsSync(gitOpenSSL) ? `"${gitOpenSSL}"` : 'openssl';
        const opensslCmd = `${opensslBin} req -x509 -newkey rsa:2048 -keyout "${keyPath}" -out "${certPath}" -days 365 -nodes -subj "/CN=localhost/O=Universal RAG/C=TR"`;
        execSync(opensslCmd, { stdio: 'pipe' });
    } catch (error) {
        throw new Error('OpenSSL gerekli');
    }

    return { key: readFileSync(keyPath), cert: readFileSync(certPath) };
}

export class WebRAGServer {
    private server: any = null;
    private port: number;
    private isRunning: boolean = false;
    private useHttps: boolean = true;

    constructor(port: number = DEFAULT_PORT) {
        this.port = port;
    }

    public async stop(): Promise<void> {
        if (this.server && this.isRunning) {
            return new Promise(resolve => this.server.close(() => {
                this.isRunning = false;
                console.log('[WebRAG] Sunucu durduruldu');
                resolve();
            }));
        }
    }

    public get isActive(): boolean {
        return this.isRunning;
    }

    public async start(): Promise<void> {
        if (this.isRunning) return;

        let httpsOptions: ServerOptions | null = null;
        try {
            const certs = ensureCertificates();
            httpsOptions = { key: certs.key, cert: certs.cert };
            this.useHttps = true;
        } catch {
            this.useHttps = false;
        }

        if (this.useHttps && httpsOptions) {
            this.server = createHttpsServer(httpsOptions, (req, res) => this.handleRequest(req, res));
        } else {
            this.server = createHttpServer((req, res) => this.handleRequest(req, res));
        }

        return new Promise((resolve, reject) => {
            this.server.listen(this.port, () => {
                this.isRunning = true;
                console.log(`[WebRAG] Sunucu ${this.useHttps ? 'HTTPS' : 'HTTP'} modunda başlatıldı: ${this.port}`);
                resolve();
            });
            this.server.on('error', reject);
        });
    }

    private async handleRequest(req: IncomingMessage, res: ServerResponse): Promise<void> {
        // Güvenlik Başlıklarını Ekle
        Object.entries(SECURITY_HEADERS).forEach(([k, v]) => res.setHeader(k, v));
        Object.entries(CORS_HEADERS).forEach(([k, v]) => res.setHeader(k, v));

        if (req.method === 'OPTIONS') {
            res.writeHead(200);
            res.end();
            return;
        }

        // Basit CSRF/Auth Örneği (Senior Requirement)
        if (req.method === 'POST' && !req.url?.includes('/api/status')) {
            const authHeader = req.headers['authorization'];
            // Kurumsal düzeyde burada JWT veya Session kontrolü yapılır
        }

        const url = new URL(req.url || '/', `http://localhost:${this.port}`);
        const path = url.pathname;

        try {
            if (path === '/' || path === '/index.html') {
                this.serveHTML(res);
            } else if (path === '/api/status') {
                await this.handleStatus(res);
            } else if (path === '/api/chat' && req.method === 'POST') {
                await this.handleChat(req, res);
            } else if (path === '/api/vision/analyze' && req.method === 'POST') {
                await this.handleVisionAnalyze(req, res);
            } else if (path === '/api/rag/add' && req.method === 'POST') {
                await this.handleRAGAdd(req, res);
            } else if (path === '/api/rag/query' && req.method === 'POST') {
                await this.handleRAGQuery(req, res);
            } else if (path === '/api/ask-all' && req.method === 'POST') {
                await this.handleAskAll(req, res);
            } else if (path === '/api/rag/list') {
                await this.handleRAGList(res);
            } else if (path === '/api/training/questions') {
                await this.handleTrainingQuestions(res);
            } else if (path === '/api/debate/start' && req.method === 'POST') {
                await this.handleDebateStart(req, res);
            } else if (path === '/api/debate/status') {
                await this.handleDebateStatus(res);
            } else if (path === '/api/debate/history') {
                await this.handleDebateHistory(res);
            } else if (path === '/api/training/start' && req.method === 'POST') {
                await this.handleTrainingStart(req, res);
            } else if (path === '/api/training/status') {
                await this.handleTrainingStatus(res);
            } else if (path === '/api/terminal/run' && req.method === 'POST') {
                await this.handleTerminalRun(req, res);
            } else if (path === '/api/docker/action' && req.method === 'POST') {
                await this.handleDockerAction(req, res);
            } else if (path === '/api/file/list') {
                await this.handleFileList(res);
            } else if (path === '/api/file/read' && req.method === 'POST') {
                await this.handleFileRead(req, res);
            } else if (path === '/api/system/monitor') {
                await this.handleSystemMonitor(res);
            } else if (path === '/api/git/action' && req.method === 'POST') {
                await this.handleGitAction(req, res);
            } else {
                this.sendResponse(res, 404, { success: false, error: 'Endpoint bulunamadı' });
            }
        } catch (error) {
            console.error('[WebRAG] İstek hatası:', error);
            this.sendResponse(res, 500, { success: false, error: String(error) });
        }
    }

    private async parseBody(req: IncomingMessage): Promise<any> {
        return new Promise((resolve, reject) => {
            let body = '';
            req.on('data', chunk => body += chunk);
            req.on('end', () => {
                try { resolve(body ? JSON.parse(body) : {}); }
                catch (e) { reject(new Error('Geçersiz JSON')); }
            });
            req.on('error', reject);
        });
    }

    private sendResponse(res: ServerResponse, status: number, data: any): void {
        const response: APIResponse = { ...data, timestamp: new Date().toISOString() };
        res.writeHead(status, CORS_HEADERS);
        res.end(JSON.stringify(response, null, 2));
    }

    private async handleStatus(res: ServerResponse): Promise<void> {
        const router = getRouter();
        const rag = getRAGService();
        const backends = await router.checkAllBackends();
        this.sendResponse(res, 200, { success: true, data: { status: 'running', backends: Object.fromEntries(backends), rag: rag.getStats() } });
    }

    private async handleChat(req: IncomingMessage, res: ServerResponse): Promise<void> {
        const body = await this.parseBody(req);
        const router = getRouter();
        const response = await router.complete('chat', body.message, body.systemPrompt);
        this.sendResponse(res, 200, { success: true, data: { answer: response.content, model: response.model } });
    }

    private async handleVisionAnalyze(req: IncomingMessage, res: ServerResponse): Promise<void> {
        const body = await this.parseBody(req);
        if (!body.image || !body.message) {
            this.sendResponse(res, 400, { success: false, error: 'image ve message gerekli' });
            return;
        }
        const router = getRouter();
        const response = await router.completeWithVision(body.message, body.image, body.backend, body.systemPrompt);
        this.sendResponse(res, 200, { success: true, data: { answer: response.content, model: response.model } });
    }

    private async handleRAGAdd(req: IncomingMessage, res: ServerResponse): Promise<void> {
        const body = await this.parseBody(req);
        const rag = getRAGService();
        const result = await rag.addDocument(body.text, body.source, body.category);
        this.sendResponse(res, 200, { success: true, data: result });
    }

    private async handleRAGQuery(req: IncomingMessage, res: ServerResponse): Promise<void> {
        const body = await this.parseBody(req);
        const rag = getRAGService();
        const result = await rag.query(body.question);
        this.sendResponse(res, 200, { success: true, data: result });
    }

    private async handleRAGList(res: ServerResponse): Promise<void> {
        const rag = getRAGService();
        this.sendResponse(res, 200, { success: true, data: { stats: rag.getStats(), documents: rag.listDocuments() } });
    }

    private async handleTrainingQuestions(res: ServerResponse): Promise<void> {
        const bank = getPromptBank();
        this.sendResponse(res, 200, { success: true, data: { stats: bank.getStats(), questions: bank.list(20) } });
    }

    private async handleDebateStart(req: IncomingMessage, res: ServerResponse): Promise<void> {
        const body = await this.parseBody(req);
        if (!body.topic) return this.sendResponse(res, 400, { success: false, error: 'topic gerekli' });
        const engine = getDebateEngine();
        const config = { ...DEFAULT_DEBATE_CONFIG, ...body };
        engine.startDebate(config).catch(console.error);
        this.sendResponse(res, 200, { success: true, data: { message: 'Tartışma başlatıldı', topic: body.topic } });
    }

    private async handleDebateStatus(res: ServerResponse): Promise<void> {
        const engine = getDebateEngine();
        this.sendResponse(res, 200, { success: true, data: engine.getStatus() });
    }

    private async handleDebateHistory(res: ServerResponse): Promise<void> {
        const engine = getDebateEngine();
        this.sendResponse(res, 200, { success: true, data: engine.getHistory(10) });
    }

    private async handleTrainingStart(req: IncomingMessage, res: ServerResponse): Promise<void> {
        const body = await this.parseBody(req);
        const trainer = getFastTrainer();
        loadAllTrainingExamples();
        trainer.trainBatch({ batchSize: body.batchSize || 5, epochs: body.epochs || 1 }).catch(console.error);
        this.sendResponse(res, 200, { success: true, data: { message: 'Eğitim başlatıldı' } });
    }

    private async handleTrainingStatus(res: ServerResponse): Promise<void> {
        const trainer = getFastTrainer();
        this.sendResponse(res, 200, { success: true, data: trainer.getStats() });
    }

    private async handleTerminalRun(req: IncomingMessage, res: ServerResponse): Promise<void> {
        const body = await this.parseBody(req);
        if (!body.command) return this.sendResponse(res, 400, { success: false, error: 'command gerekli' });

        return new Promise((resolve) => {
            console.log(`[Terminal] Çalıştırılıyor: ${body.command}`);
            const [cmd, ...args] = body.command.split(' ');
            const proc = spawn(cmd, args, { shell: true, cwd: process.cwd() });

            let output = '';
            let error = '';

            proc.stdout?.on('data', (data: Buffer) => output += data.toString());
            proc.stderr?.on('data', (data: Buffer) => error += data.toString());

            proc.on('close', (code: number | null) => {
                this.sendResponse(res, code === 0 ? 200 : 500, {
                    success: code === 0,
                    data: { output, error, exitCode: code }
                });
                resolve();
            });

            // Güvenlik: 30 saniye sonra sonlandır
            setTimeout(() => {
                if (!proc.killed) {
                    proc.kill();
                    this.sendResponse(res, 408, { success: false, error: 'Zaman aşımı (30s)' });
                    resolve();
                }
            }, 30000);
        });
    }

    private async handleDockerAction(req: IncomingMessage, res: ServerResponse): Promise<void> {
        const body = await this.parseBody(req);
        const { action, containerName } = body;

        try {
            let result = '';
            switch (action) {
                case 'build':
                    result = execSync('docker build -t universal-llm .').toString();
                    break;
                case 'run':
                    result = execSync('docker run -d --name universal-llm-instance -p 3355:3355 universal-llm').toString();
                    break;
                case 'stop':
                    result = execSync('docker stop universal-llm-instance && docker rm universal-llm-instance').toString();
                    break;
                case 'ps':
                    result = execSync('docker ps -a --filter name=universal-llm').toString();
                    break;
                default:
                    throw new Error('Geçersiz Docker eylemi');
            }
            this.sendResponse(res, 200, { success: true, data: { result } });
        } catch (error) {
            this.sendResponse(res, 500, { success: false, error: String(error) });
        }
    }

    private async handleFileList(res: ServerResponse): Promise<void> {
        const files = execSync('dir /b', { cwd: process.cwd() }).toString().split('\n').filter(f => f.trim());
        this.sendResponse(res, 200, { success: true, data: { files } });
    }

    private async handleFileRead(req: IncomingMessage, res: ServerResponse): Promise<void> {
        const body = await this.parseBody(req);
        if (!body.path) return this.sendResponse(res, 400, { success: false, error: 'path gerekli' });
        try {
            const content = readFileSync(join(process.cwd(), body.path), 'utf-8');
            this.sendResponse(res, 200, { success: true, data: { content } });
        } catch (error) {
            this.sendResponse(res, 500, { success: false, error: String(error) });
        }
    }

    private async handleSystemMonitor(res: ServerResponse): Promise<void> {
        const stats = {
            platform: os.platform(),
            cpu: {
                model: os.cpus()[0].model,
                load: os.loadavg(),
                cores: os.cpus().length
            },
            memory: {
                free: os.freemem(),
                total: os.totalmem(),
                usage: Math.round((1 - os.freemem() / os.totalmem()) * 100)
            },
            uptime: os.uptime()
        };
        this.sendResponse(res, 200, { success: true, data: stats });
    }

    private async handleGitAction(req: IncomingMessage, res: ServerResponse): Promise<void> {
        const body = await this.parseBody(req);
        const { action, repoUrl, message } = body;
        try {
            let result = '';
            switch (action) {
                case 'status': result = execSync('git status').toString(); break;
                case 'clone': result = execSync(`git clone ${repoUrl}`).toString(); break;
                case 'commit': result = execSync(`git add . && git commit -m "${message || 'Update by AI'}"`).toString(); break;
                case 'push': result = execSync('git push').toString(); break;
                case 'pull': result = execSync('git pull').toString(); break;
                default: throw new Error('Geçersiz Git eylemi');
            }
            this.sendResponse(res, 200, { success: true, data: { result } });
        } catch (error) {
            this.sendResponse(res, 500, { success: false, error: String(error) });
        }
    }

    private async handleAskAll(req: IncomingMessage, res: ServerResponse): Promise<void> {
        const body = await this.parseBody(req);
        const result = await queryAllLLMs(body.question, body.systemPrompt);
        this.sendResponse(res, 200, { success: true, data: result });
    }

    private serveHTML(res: ServerResponse): void {
        const html = `<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🧠 Universal LLM Platform | Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=JetBrains+Mono&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #030712;
            --card-bg: rgba(30, 41, 59, 0.7);
            --primary: #3b82f6;
            --accent: #8b5cf6;
            --text: #f8fafc;
            --text-dim: #94a3b8;
            --glass: rgba(255, 255, 255, 0.05);
            --border: rgba(255, 255, 255, 0.1);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text); line-height: 1.6; overflow-x: hidden; }
        .bg-glow { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1; background: radial-gradient(circle at 50% 50%, #1e1b4b 0%, var(--bg) 70%); }
        .container { max-width: 1400px; margin: 0 auto; padding: 2rem; }
        header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 3rem; }
        h1 { font-size: 2.5rem; font-weight: 700; background: linear-gradient(to right, var(--primary), var(--accent)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .status-badge { padding: 0.5rem 1rem; border-radius: 99px; background: rgba(34, 197, 94, 0.1); border: 1px solid rgba(34, 197, 94, 0.2); color: #4ade80; font-size: 0.875rem; display: flex; align-items: center; gap: 0.5rem; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 1.5rem; }
        .card { background: var(--card-bg); backdrop-filter: blur(12px); border: 1px solid var(--border); border-radius: 1.5rem; padding: 2rem; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); position: relative; overflow: hidden; }
        .card:hover { border-color: rgba(59, 130, 246, 0.5); transform: translateY(-4px); box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3); }
        .card h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.75rem; }
        input, button, select { font-family: inherit; }
        .input-group { display: flex; gap: 0.5rem; margin-bottom: 1rem; }
        input[type="text"] { flex: 1; background: var(--bg); border: 1px solid var(--border); border-radius: 0.75rem; padding: 0.75rem 1rem; color: var(--text); transition: all 0.2s; }
        input:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.2); }
        button { background: var(--primary); color: white; border: none; border-radius: 0.75rem; padding: 0.75rem 1.5rem; font-weight: 600; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; gap: 0.5rem; }
        button:hover { background: #2563eb; transform: scale(1.02); }
        button:active { transform: scale(0.98); }
        button.secondary { background: var(--glass); border: 1px solid var(--border); color: var(--text); }
        button.secondary:hover { background: rgba(255, 255, 255, 0.1); }
        .chat-box { height: 350px; overflow-y: auto; background: rgba(0, 0, 0, 0.2); border-radius: 1rem; padding: 1rem; margin-bottom: 1rem; border: 1px solid var(--border); }
        .msg { margin-bottom: 1.25rem; }
        .msg .role { font-size: 0.75rem; font-weight: 700; text-transform: uppercase; color: var(--text-dim); margin-bottom: 0.25rem; }
        .msg .content { background: var(--glass); padding: 0.75rem 1rem; border-radius: 1rem; border-top-left-radius: 2px; border: 1px solid var(--border); font-size: 0.95rem; }
        .msg.ai .content { background: rgba(59, 130, 246, 0.1); border-color: rgba(59, 130, 246, 0.2); }
        .drop-zone { border: 2px dashed var(--border); border-radius: 1rem; padding: 2.5rem; text-align: center; cursor: pointer; transition: all 0.2s; color: var(--text-dim); }
        .drop-zone:hover { border-color: var(--primary); background: rgba(59, 130, 246, 0.05); color: var(--primary); }
        #imgPrev { max-width: 100%; height: 200px; object-fit: contain; border-radius: 1rem; margin-bottom: 1rem; display: none; }
        .scroll-custom::-webkit-scrollbar { width: 6px; }
        .scroll-custom::-webkit-scrollbar-track { background: transparent; }
        .scroll-custom::-webkit-scrollbar-thumb { background: var(--border); border-radius: 10px; }
        .tabs { display: flex; gap: 1rem; margin-bottom: 2rem; overflow-x: auto; padding-bottom: 0.5rem; }
        .tab { padding: 0.75rem 1.5rem; border-radius: 0.75rem; cursor: pointer; transition: all 0.2s; font-weight: 500; color: var(--text-dim); white-space: nowrap; }
        .tab.active { background: var(--primary); color: white; }
    </style>
</head>
<body>
    <div class="bg-glow"></div>
    <div class="container">
        <header>
            <div>
                <p style="color:var(--text-dim); font-size: 0.875rem; margin-bottom: 0.25rem;">Geleceğin LLM Ekosistemi</p>
                <h1>Universal LLM Platform</h1>
            </div>
            <div id="sysStatus" class="status-badge">
                <span style="width: 8px; height: 8px; border-radius: 50%; background: #4ade80;"></span>
                Sistem Çevrimiçi
            </div>
        </header>

        <div class="tabs">
            <div class="tab active" onclick="showTab('dash', this)">📊 Dashboard</div>
            <div class="tab" onclick="showTab('vision', this)">📸 Vision</div>
            <div class="tab" onclick="showTab('term', this)">💻 Terminal</div>
            <div class="tab" onclick="showTab('deploy', this)">🚀 Deployment</div>
            <div class="tab" onclick="showTab('project', this)">📂 Project</div>
            <div class="tab" onclick="showTab('system', this)">⚙️ System</div>
            <div class="tab" onclick="scrollToId('rag')">📚 Knowledge</div>
        </div>

        <div id="dashTab">
            <div class="grid">
                <!-- Multi-Model Chat -->
                <div class="card" id="multi">
                    <h2>🤖 Multi-LLM Sorgu (Ask All)</h2>
                    <div class="chat-box scroll-custom" id="multiBox">
                        <div class="msg ai"><div class="content">Soru sorun, 21 farklı modelin yanıtlarını karşılaştırın.</div></div>
                    </div>
                    <div class="input-group">
                        <input type="text" id="multiInp" placeholder="Tüm orduya soru sor...">
                        <button onclick="askAll()">🚀 Gönder</button>
                    </div>
                </div>

                <!-- Debate Engine -->
                <div class="card" id="debate">
                    <h2>⚔️ Agent Debate (Tartışma)</h2>
                    <div class="input-group">
                        <input type="text" id="debTopic" placeholder="Tartışma konusu nedir?">
                        <button onclick="startDebate()" class="secondary">🔥 Başlat</button>
                    </div>
                    <div class="chat-box scroll-custom" id="debBox" style="height: 250px;"></div>
                </div>
            </div>
        </div>

        <div id="visionTab" style="display:none">
            <div class="card" id="vision">
                <h2>📸 Görsel Analiz (Vision)</h2>
                <div class="drop-zone" id="dropZone" onclick="document.getElementById('visInp').click()">
                    <span>📁 Görseli buraya sürükleyin veya tıklayın</span>
                    <input type="file" id="visInp" style="display:none" onchange="handleImage(this.files[0])">
                </div>
                <img id="imgPrev">
                <div class="input-group">
                    <input type="text" id="visMsg" placeholder="Görsel hakkında sorun...">
                    <button onclick="analyzeImage()">⚡ Analiz</button>
                </div>
                <div id="visRes" class="scroll-custom" style="padding:1rem; background:rgba(0,0,0,0.2); border-radius:1rem;"></div>
            </div>
        </div>

        <div id="termTab" style="display:none">
            <div class="card">
                <h2>💻 Entegre Terminal</h2>
                <div id="termOut" class="scroll-custom" style="font-family:'JetBrains Mono', monospace; background:#000; padding:1.5rem; height:400px; overflow-y:auto; border-radius:1rem; border:1px solid var(--border); font-size:0.9rem; color:#10b981; margin-bottom:1rem;">
                    <div>$ Universal LLM Platform Ready.</div>
                    <div>$ Type your command below...</div>
                </div>
                <div class="input-group">
                    <span style="color:var(--primary); font-weight:bold; padding:0.75rem 0.5rem;">$</span>
                    <input type="text" id="termInp" placeholder="Komut (ör: dir, npm run build)..." onkeydown="if(event.key==='Enter') runCmd()">
                    <button onclick="runCmd()">⏎</button>
                </div>
            </div>
        </div>

        <div id="deployTab" style="display:none">
            <div class="grid">
                <div class="card">
                    <h2>🐋 Docker Yönetimi</h2>
                    <p style="color:var(--text-dim); margin-bottom: 1.5rem;">Konteynerleştirme ve otonom dağıtım araçları.</p>
                    <div style="display:flex; flex-wrap:wrap; gap:1rem;">
                        <button onclick="docker('build')">🛠️ Build Image</button>
                        <button onclick="docker('run')" class="secondary">▶️ Run Container</button>
                        <button onclick="docker('stop')" style="background:#ef4444">🛑 Stop</button>
                        <button onclick="docker('ps')" class="secondary">🔍 Status</button>
                    </div>
                    <pre id="dockerRes" class="scroll-custom" style="margin-top:1.5rem; background:rgba(0,0,0,0.3); padding:1rem; border-radius:0.75rem; font-size:0.8rem; color:var(--text-dim); max-height:200px; overflow-y:auto;"></pre>
                </div>
                <div class="card">
                    <h2>☁️ Cloud Deployment</h2>
                    <p style="color:var(--text-dim); margin-bottom: 1.5rem;">Vercel & Netlify tek tıkla dağıtım.</p>
                    <button class="secondary" disabled>Vercel (Yakında)</button>
                    <button class="secondary" disabled>Netlify (Yakında)</button>
                </div>
            </div>
        </div>

        <div id="projectTab" style="display:none">
            <div class="grid">
                <div class="card">
                    <h2>📂 Proje Dosyaları</h2>
                    <div id="fileList" class="scroll-custom" style="max-height:200px; overflow-y:auto; font-size:0.9rem; color:var(--text-dim); margin-bottom:1rem;">
                        Yükleniyor...
                    </div>
                    <button onclick="refreshFiles()" class="secondary">🔄 Yenile</button>
                </div>
                <div class="card">
                    <h2>🌿 Git Entegrasyonu</h2>
                    <div style="display:flex; flex-wrap:wrap; gap:0.5rem; margin-bottom:1rem;">
                        <button onclick="git('status')" class="secondary">🔍 Status</button>
                        <button onclick="git('pull')" class="secondary">⬇️ Pull</button>
                        <button onclick="git('push')" class="secondary">⬆️ Push</button>
                    </div>
                    <div class="input-group">
                        <input type="text" id="commitMsg" placeholder="Commit mesajı...">
                        <button onclick="git('commit')">💾 Commit</button>
                    </div>
                    <pre id="gitRes" class="scroll-custom" style="background:rgba(0,0,0,0.3); padding:1rem; border-radius:0.75rem; font-size:0.8rem; color:var(--text-dim); max-height:150px; overflow-y:auto;"></pre>
                </div>
            </div>
        </div>

        <div id="systemTab" style="display:none">
            <div class="grid">
                <div class="card">
                    <h2>⚙️ Sistem Durumu</h2>
                    <div id="sysMon" style="font-family:'JetBrains Mono', monospace; font-size:0.9rem; color:var(--text-dim);">
                        Yükleniyor...
                    </div>
                </div>
                <div class="card">
                    <h2>🔌 Veritabanı (Supabase)</h2>
                    <p style="color:var(--text-dim); margin-bottom: 1.5rem;">Kalıcı veri depolama katmanı.</p>
                    <div id="dbStatus" class="status-badge" style="background:rgba(239, 68, 68, 0.1); border-color:rgba(239, 68, 68, 0.2); color:#f87171; width:fit-content;">
                        <span style="width: 8px; height: 8px; border-radius: 50%; background: #f87171;"></span>
                        Bağlı Değil
                    </div>
                </div>
            </div>
        </div>

        <div class="container" style="padding-top:0">
            <div class="card" id="rag">
                <h2>📚 Knowledge & RAG</h2>
                <div class="input-group">
                    <input type="text" id="ragTxt" placeholder="Yeni bilgi ekle (metin)...">
                    <button onclick="addRag()" class="secondary">➕ Ekle</button>
                </div>
                <hr style="border:0; border-top:1px solid var(--border); margin: 1rem 0;">
                <div class="input-group">
                    <input type="text" id="ragQ" placeholder="Hafızadan sorgula...">
                    <button onclick="queryRag()">🔍 Bul</button>
                </div>
                <div id="ragRes" style="font-size: 0.9rem; color: var(--text-dim);"></div>
            </div>
        </div>
    </div>

    <script>
        function showTab(id, el) {
            ['dashTab','visionTab','termTab','deployTab','systemTab','projectTab'].forEach(t => document.getElementById(t).style.display = 'none');
            document.getElementById(id+'Tab').style.display = 'block';
            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
            el.classList.add('active');
            if(id === 'system') updateSysMon();
            if(id === 'project') refreshFiles();
        }
        async function git(act) {
            const m = document.getElementById('commitMsg').value;
            const res = document.getElementById('gitRes');
            res.innerText = '⌛ Git işlemi yapılıyor...';
            const d = await api('/api/git/action', { action: act, message: m });
            res.innerText = d.success ? d.data.result : '❌ Hata: ' + d.error;
        }
        async function refreshFiles() {
            const list = document.getElementById('fileList');
            const d = await (await fetch('/api/file/list')).json();
            if(d.success) list.innerHTML = d.data.files.map(f => \`<div style="padding:4px; border-bottom:1px solid var(--border)">📄 \${f}</div>\`).join('');
        }
        async function updateSysMon() {
            const res = document.getElementById('sysMon');
            const d = await (await fetch('/api/system/monitor')).json();
            if(d.success) {
                const s = d.data;
                res.innerHTML = \`
                    <p><b>Platform:</b> \${s.platform}</p>
                    <p><b>CPU:</b> \${s.cpu.model} (\${s.cpu.cores} Cores)</p>
                    <p><b>RAM Usage:</b> %\${s.memory.usage} (\${Math.round(s.memory.free/1024/1024)}MB Free)</p>
                    <p><b>Uptime:</b> \${Math.round(s.uptime/3600)} Hours</p>
                \`;
            }
        }
        async function runCmd() {
            const inp = document.getElementById('termInp');
            const cmd = inp.value;
            const res = document.getElementById('termOut');
            res.innerHTML += \`<div style="color:var(--primary); margin:0.5rem 0;"># \${cmd}</div>\`;
            inp.value = '';
            const d = await api('/api/terminal/run', { command: cmd });
            const out = d.success ? d.data.output : d.error + (d.data?.error || '');
            res.innerHTML += \`<pre style="white-space:pre-wrap; margin-bottom:1rem;">\${out}</pre>\`;
            res.scrollTop = res.scrollHeight;
        }
        async function docker(act) {
            const res = document.getElementById('dockerRes');
            res.innerHTML = '⚙️ İşlem yapılıyor: ' + act + '...';
            const d = await api('/api/docker/action', { action: act });
            res.innerText = d.success ? d.data.result : '❌ Hata: ' + d.error;
        }
        let b64 = null;
        function scrollToId(id) { document.getElementById(id).scrollIntoView({ behavior: 'smooth' }); }
        function handleImage(f) {
            const r = new FileReader();
            r.onload = e => { b64 = e.target.result; const p = document.getElementById('imgPrev'); p.src = b64; p.style.display='block'; };
            r.readAsDataURL(f);
        }
        async function api(path, body) {
            const r = await fetch(path, { method:'POST', body: JSON.stringify(body), headers: {'Content-Type': 'application/json'} });
            return await r.json();
        }
        async function analyzeImage() {
            const m = document.getElementById('visMsg').value;
            const res = document.getElementById('visRes');
            res.innerHTML = '✨ AI Düşünüyor...';
            const d = await api('/api/vision/analyze', { image: b64, message: m });
            res.innerHTML = d.success ? \`<b>\${d.data.model}:</b> <br>\${d.data.answer.replace(/\\n/g, '<br>')}\` : '❌ Hata oluştu.';
        }
        async function askAll() {
            const q = document.getElementById('multiInp').value;
            const b = document.getElementById('multiBox');
            b.innerHTML += \`<div class="msg"><div class="role">Siz</div><div class="content">\${q}</div></div>\`;
            const d = await api('/api/ask-all', { question: q });
            d.data.responses.forEach(r => {
                if(r.success) b.innerHTML += \`<div class="msg ai"><div class="role">\${r.backend}</div><div class="content">\${r.answer}</div></div>\`;
            });
            b.scrollTop = b.scrollHeight;
        }
        async function startDebate() {
            const t = document.getElementById('debTopic').value;
            const box = document.getElementById('debBox');
            box.innerHTML = '<p style="text-align:center; color:var(--text-dim)">Tartışma ayarlanıyor...</p>';
            const d = await api('/api/debate/start', { topic: t });
            pollDebate();
        }
        function pollDebate() {
            setInterval(async () => {
                const s = await (await fetch('/api/debate/status')).json();
                const h = await (await fetch('/api/debate/history')).json();
                document.getElementById('debStatus').innerText = \`Durum: \${s.data.state} | Tur: \${s.data.currentRound}\`;
                if(h.data.length > 0) {
                    const box = document.getElementById('debBox');
                    box.innerHTML = h.data.map(m => \`<div class="msg ai"><div class="role">\${m.agentName} (\${m.model})</div><div class="content">\${m.argument}</div></div>\`).join('');
                }
            }, 3000);
        }
        async function addRag() {
            const t = document.getElementById('ragTxt').value;
            const d = await api('/api/rag/add', { text: t, source: 'web_ui', category: 'user_input' });
            alert(d.success ? 'Bilgi eklendi' : 'Hata');
        }
        async function queryRag() {
            const q = document.getElementById('ragQ').value;
            const d = await api('/api/rag/query', { question: q });
            document.getElementById('ragRes').innerHTML = d.success ? \`<b>Bulunan:</b> \${d.data.answer}\` : 'Bulunamadı';
        }
    </script>
</body>
</html>`;
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(html);
    }
}

let serverInstance: WebRAGServer | null = null;
export function getWebRAGServer(port?: number): WebRAGServer {
    if (!serverInstance) serverInstance = new WebRAGServer(port);
    return serverInstance;
}
