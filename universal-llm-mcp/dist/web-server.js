/**
 * Universal LLM MCP - Web RAG Server
 * HTTPS API sunucusu - Güvenli bağlantı (Self-signed sertifika)
 * Tüm tarayıcılarda çalışır (CORS etkin)
 */
import { createServer as createHttpsServer } from 'https';
import { createServer as createHttpServer } from 'http';
import { URL } from 'url';
import { existsSync, mkdirSync, readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';
import { getRAGService } from './rag/rag-service.js';
import { getRouter } from './router/llm-router.js';
import { getPromptBank } from './training/prompt-bank.js';
import { getDebateEngine, DEFAULT_DEBATE_CONFIG } from './debate/debate-engine.js';
import { getFastTrainer } from './training/fast-trainer.js';
import { loadAllTrainingExamples } from './training/training-data.js';
import { queryAllLLMs } from './core/multi-llm.js';
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
// Sunucu yapılandırması
const DEFAULT_PORT = 3355;
const CERT_DIR = join(__dirname, '..', 'certs');
const CORS_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Content-Type': 'application/json; charset=utf-8',
};
/**
 * Self-signed sertifika oluştur (yoksa)
 */
function ensureCertificates() {
    const keyPath = join(CERT_DIR, 'server.key');
    const certPath = join(CERT_DIR, 'server.crt');
    // Sertifikalar varsa oku
    if (existsSync(keyPath) && existsSync(certPath)) {
        return {
            key: readFileSync(keyPath),
            cert: readFileSync(certPath),
        };
    }
    // Dizin oluştur
    if (!existsSync(CERT_DIR)) {
        mkdirSync(CERT_DIR, { recursive: true });
    }
    console.log('[HTTPS] Self-signed sertifika oluşturuluyor...');
    try {
        // Windows'ta Git ile gelen OpenSSL'i dene
        const gitOpenSSL = 'C:\\Program Files\\Git\\usr\\bin\\openssl.exe';
        const opensslBin = existsSync(gitOpenSSL) ? `"${gitOpenSSL}"` : 'openssl';
        // OpenSSL ile sertifika oluştur
        const opensslCmd = `${opensslBin} req -x509 -newkey rsa:2048 -keyout "${keyPath}" -out "${certPath}" -days 365 -nodes -subj "/CN=localhost/O=Universal RAG/C=TR"`;
        execSync(opensslCmd, { stdio: 'pipe' });
        console.log('[HTTPS] ✓ Sertifika oluşturuldu: ' + CERT_DIR);
    }
    catch (error) {
        // OpenSSL yoksa HTTP kullan
        console.log('[HTTPS] OpenSSL bulunamadı, basit HTTP kullanılacak.');
        throw new Error('OpenSSL gerekli');
    }
    return {
        key: readFileSync(keyPath),
        cert: readFileSync(certPath),
    };
}
/**
 * Web RAG Sunucusu (HTTPS)
 */
export class WebRAGServer {
    server = null;
    port;
    isRunning = false;
    useHttps = true;
    constructor(port = DEFAULT_PORT) {
        this.port = port;
    }
    /**
     * Sunucuyu başlat (HTTPS tercih edilir)
     */
    async start() {
        if (this.isRunning) {
            console.log('[WebRAG] Sunucu zaten çalışıyor');
            return;
        }
        let httpsOptions = null;
        // HTTPS sertifikalarını dene
        try {
            const certs = ensureCertificates();
            httpsOptions = {
                key: certs.key,
                cert: certs.cert,
            };
            this.useHttps = true;
        }
        catch (error) {
            console.log('[WebRAG] ⚠️ HTTPS kullanılamıyor, HTTP moduna geçiliyor');
            this.useHttps = false;
        }
        // Sunucu oluştur
        if (this.useHttps && httpsOptions) {
            this.server = createHttpsServer(httpsOptions, (req, res) => this.handleRequest(req, res));
        }
        else {
            this.server = createHttpServer((req, res) => this.handleRequest(req, res));
        }
        const protocol = this.useHttps ? 'https' : 'http';
        return new Promise((resolve, reject) => {
            this.server.listen(this.port, () => {
                this.isRunning = true;
                console.log('═══════════════════════════════════════════════');
                console.log('   🔒 Web RAG Server Başlatıldı (GÜVENLI)');
                console.log(`   📍 ${protocol}://localhost:${this.port}`);
                console.log('   🔓 CORS: Tüm originler kabul edilir');
                if (this.useHttps) {
                    console.log('   🛡️  SSL: Self-signed sertifika aktif');
                }
                console.log('═══════════════════════════════════════════════');
                console.log('');
                console.log('📚 API Endpoints:');
                console.log(`   POST /api/rag/add      - Bilgi ekle`);
                console.log(`   POST /api/rag/query    - RAG sorgula`);
                console.log(`   GET  /api/rag/list     - Bilgileri listele`);
                console.log(`   POST /api/chat         - Sohbet`);
                console.log(`   GET  /api/status       - Durum`);
                console.log(`   GET  /                 - Web Arayüzü`);
                console.log('');
                if (this.useHttps) {
                    console.log('⚠️  NOT: Tarayıcıda "Güvenli değil" uyarısı normal.');
                    console.log('         Self-signed sertifika kullanılıyor.');
                    console.log('');
                }
                resolve();
            });
            this.server.on('error', (error) => {
                console.error('[WebRAG] Sunucu hatası:', error);
                reject(error);
            });
        });
    }
    /**
     * Sunucuyu durdur
     */
    stop() {
        return new Promise((resolve) => {
            if (this.server && this.isRunning) {
                this.server.close(() => {
                    this.isRunning = false;
                    console.log('[WebRAG] Sunucu durduruldu');
                    resolve();
                });
            }
            else {
                resolve();
            }
        });
    }
    /**
     * HTTP isteğini işle
     */
    async handleRequest(req, res) {
        // CORS preflight
        if (req.method === 'OPTIONS') {
            res.writeHead(200, CORS_HEADERS);
            res.end();
            return;
        }
        const url = new URL(req.url || '/', `http://localhost:${this.port}`);
        const path = url.pathname;
        try {
            // Route
            if (path === '/' || path === '/index.html') {
                this.serveHTML(res);
            }
            else if (path === '/api/status') {
                await this.handleStatus(res);
            }
            else if (path === '/api/rag/add' && req.method === 'POST') {
                await this.handleRAGAdd(req, res);
            }
            else if (path === '/api/rag/query' && req.method === 'POST') {
                await this.handleRAGQuery(req, res);
            }
            else if (path === '/api/rag/list') {
                await this.handleRAGList(res);
            }
            else if (path === '/api/chat' && req.method === 'POST') {
                await this.handleChat(req, res);
            }
            else if (path === '/api/training/questions') {
                await this.handleTrainingQuestions(res);
            }
            else if (path === '/api/debate/start' && req.method === 'POST') {
                await this.handleDebateStart(req, res);
            }
            else if (path === '/api/debate/status') {
                await this.handleDebateStatus(res);
            }
            else if (path === '/api/debate/history') {
                await this.handleDebateHistory(res);
            }
            else if (path === '/api/training/start' && req.method === 'POST') {
                await this.handleTrainingStart(req, res);
            }
            else if (path === '/api/training/status') {
                await this.handleTrainingStatus(res);
            }
            else if (path === '/api/ask-all' && req.method === 'POST') {
                await this.handleAskAll(req, res);
            }
            else {
                this.sendResponse(res, 404, { success: false, error: 'Endpoint bulunamadi' });
            }
        }
        catch (error) {
            console.error('[WebRAG] İstek hatası:', error);
            this.sendResponse(res, 500, { success: false, error: String(error) });
        }
    }
    /**
     * JSON body parse
     */
    async parseBody(req) {
        return new Promise((resolve, reject) => {
            let body = '';
            req.on('data', chunk => body += chunk);
            req.on('end', () => {
                try {
                    resolve(body ? JSON.parse(body) : {});
                }
                catch (e) {
                    reject(new Error('Geçersiz JSON'));
                }
            });
            req.on('error', reject);
        });
    }
    /**
     * Yanıt gönder
     */
    sendResponse(res, status, data) {
        const response = {
            ...data,
            timestamp: new Date().toISOString(),
        };
        res.writeHead(status, CORS_HEADERS);
        res.end(JSON.stringify(response, null, 2));
    }
    /**
     * Durum endpoint'i
     */
    async handleStatus(res) {
        const ragService = getRAGService();
        const router = getRouter();
        const backendStatus = await router.checkAllBackends();
        const backends = {};
        for (const [name, status] of backendStatus) {
            backends[name] = {
                available: status.isAvailable,
                models: status.models,
            };
        }
        this.sendResponse(res, 200, {
            success: true,
            data: {
                status: 'running',
                rag: ragService.getStats(),
                backends,
                uptime: process.uptime(),
            },
        });
    }
    /**
     * RAG bilgi ekleme
     */
    async handleRAGAdd(req, res) {
        const body = await this.parseBody(req);
        if (!body.text || !body.source) {
            this.sendResponse(res, 400, { success: false, error: 'text ve source gerekli' });
            return;
        }
        const ragService = getRAGService();
        const result = await ragService.addDocument(body.text, body.source, body.category);
        this.sendResponse(res, result.success ? 200 : 500, {
            success: result.success,
            data: result,
        });
    }
    /**
     * RAG sorgulama
     */
    async handleRAGQuery(req, res) {
        const body = await this.parseBody(req);
        if (!body.question) {
            this.sendResponse(res, 400, { success: false, error: 'question gerekli' });
            return;
        }
        const ragService = getRAGService();
        const result = await ragService.query(body.question, {
            topK: body.topK,
            category: body.category,
        });
        this.sendResponse(res, 200, {
            success: true,
            data: result,
        });
    }
    /**
     * RAG bilgi listesi
     */
    async handleRAGList(res) {
        const ragService = getRAGService();
        const documents = ragService.listDocuments();
        const stats = ragService.getStats();
        this.sendResponse(res, 200, {
            success: true,
            data: {
                stats,
                documents,
            },
        });
    }
    /**
     * Sohbet endpoint'i
     */
    async handleChat(req, res) {
        const body = await this.parseBody(req);
        if (!body.message) {
            this.sendResponse(res, 400, { success: false, error: 'message gerekli' });
            return;
        }
        const router = getRouter();
        const response = await router.complete('chat', body.message, body.systemPrompt);
        this.sendResponse(res, 200, {
            success: true,
            data: {
                answer: response.content,
                model: response.model,
                tokensUsed: response.tokensUsed,
            },
        });
    }
    /**
     * Eğitim soruları
     */
    async handleTrainingQuestions(res) {
        const promptBank = getPromptBank();
        const stats = promptBank.getStats();
        const questions = promptBank.list(20);
        this.sendResponse(res, 200, {
            success: true,
            data: {
                stats,
                questions: questions.map(q => ({
                    id: q.id,
                    category: q.category,
                    difficulty: q.difficulty,
                    question: q.question,
                })),
            },
        });
    }
    /**
     * Tartışma başlat
     */
    async handleDebateStart(req, res) {
        const body = await this.parseBody(req);
        if (!body.topic) {
            this.sendResponse(res, 400, { success: false, error: 'topic gerekli' });
            return;
        }
        const debateEngine = getDebateEngine();
        // Yapılandırma
        const config = {
            topic: body.topic,
            maxTurns: body.maxTurns || DEFAULT_DEBATE_CONFIG.maxTurns || 3,
            domains: (body.domains || DEFAULT_DEBATE_CONFIG.domains),
            participants: body.participants || DEFAULT_DEBATE_CONFIG.participants || ['lmstudio', 'ollama'],
            synthesizeAtEnd: body.synthesize !== false,
        };
        try {
            // Async başlat (hemen yanıt ver)
            const debatePromise = debateEngine.startDebate(config);
            this.sendResponse(res, 200, {
                success: true,
                data: {
                    message: 'Tartışma başlatıldı',
                    topic: config.topic,
                    participants: config.participants,
                    maxTurns: config.maxTurns,
                    domains: config.domains,
                },
            });
            // Arka planda devam et
            await debatePromise;
        }
        catch (error) {
            this.sendResponse(res, 500, { success: false, error: String(error) });
        }
    }
    /**
     * Tartışma durumu
     */
    async handleDebateStatus(res) {
        const debateEngine = getDebateEngine();
        const status = debateEngine.getStatus();
        const currentDebate = debateEngine.getCurrentDebate();
        this.sendResponse(res, 200, {
            success: true,
            data: {
                ...status,
                currentDebate: currentDebate ? {
                    id: currentDebate.id,
                    topic: currentDebate.topic,
                    status: currentDebate.status,
                    turnCount: currentDebate.turns.length,
                    totalTokens: currentDebate.totalTokens,
                    turns: currentDebate.turns.map(t => ({
                        turnNumber: t.turnNumber,
                        speaker: t.speaker,
                        role: t.role,
                        content: t.content.substring(0, 200) + (t.content.length > 200 ? '...' : ''),
                    })),
                    synthesis: currentDebate.synthesis,
                } : null,
            },
        });
    }
    /**
     * Tartışma geçmişi
     */
    async handleDebateHistory(res) {
        const debateEngine = getDebateEngine();
        const history = debateEngine.getHistory(10);
        this.sendResponse(res, 200, {
            success: true,
            data: {
                count: history.length,
                debates: history.map(d => ({
                    id: d.id,
                    topic: d.topic,
                    status: d.status,
                    turnCount: d.turns.length,
                    synthesis: d.synthesis?.substring(0, 200),
                    startTime: d.startTime,
                    endTime: d.endTime,
                })),
            },
        });
    }
    /**
     * Egitim baslat
     */
    async handleTrainingStart(req, res) {
        const body = await this.parseBody(req);
        const trainer = getFastTrainer();
        // Ornekleri yukle
        const loaded = loadAllTrainingExamples();
        // Egitimi async baslat
        const batchSize = body.batchSize || 5;
        const epochs = body.epochs || 1;
        try {
            // Hemen yanit ver
            this.sendResponse(res, 200, {
                success: true,
                data: {
                    message: 'Egitim baslatildi',
                    examplesLoaded: loaded,
                    batchSize,
                    epochs,
                },
            });
            // Arka planda egit
            const metrics = await trainer.trainBatch({ batchSize, epochs });
            console.log('[Training] Tamamlandi:', metrics);
        }
        catch (error) {
            console.error('[Training] Hata:', error);
        }
    }
    /**
     * Egitim durumu
     */
    async handleTrainingStatus(res) {
        const trainer = getFastTrainer();
        const stats = trainer.getStats();
        this.sendResponse(res, 200, {
            success: true,
            data: {
                ...stats,
            },
        });
    }
    /**
     * Tum LLM'lere sor
     */
    async handleAskAll(req, res) {
        const body = await this.parseBody(req);
        if (!body.question) {
            this.sendResponse(res, 400, { success: false, error: 'question gerekli' });
            return;
        }
        try {
            const result = await queryAllLLMs(body.question, body.systemPrompt);
            this.sendResponse(res, 200, {
                success: true,
                data: {
                    question: result.question,
                    totalLatency: result.totalLatency,
                    responses: result.responses.map(r => ({
                        backend: r.backend,
                        model: r.model,
                        answer: r.answer,
                        latencyMs: r.latencyMs,
                        success: r.success,
                        error: r.error,
                    })),
                },
            });
        }
        catch (error) {
            this.sendResponse(res, 500, { success: false, error: String(error) });
        }
    }
    /**
     * Web arayuzu HTML
     */
    serveHTML(res) {
        const html = `<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🧠 Universal RAG Server</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            min-height: 100vh;
            color: #e4e4e7;
        }
        .container { max-width: 900px; margin: 0 auto; padding: 20px; }
        header {
            text-align: center;
            padding: 40px 0;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        h1 { font-size: 2.5em; margin-bottom: 10px; }
        h1 span { color: #818cf8; }
        .status {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(34, 197, 94, 0.2);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9em;
        }
        .status .dot {
            width: 10px;
            height: 10px;
            background: #22c55e;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        .sections { display: grid; gap: 20px; margin-top: 30px; }
        .card {
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 16px;
            padding: 24px;
        }
        .card h2 { margin-bottom: 16px; font-size: 1.2em; }
        .chat-box {
            background: rgba(0,0,0,0.3);
            border-radius: 12px;
            padding: 16px;
            height: 300px;
            overflow-y: auto;
            margin-bottom: 16px;
        }
        .message {
            margin-bottom: 12px;
            padding: 12px;
            border-radius: 12px;
            max-width: 80%;
        }
        .message.user {
            background: #4f46e5;
            margin-left: auto;
        }
        .message.bot {
            background: rgba(255,255,255,0.1);
        }
        .input-group {
            display: flex;
            gap: 10px;
        }
        input, textarea {
            flex: 1;
            padding: 12px 16px;
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: 12px;
            background: rgba(0,0,0,0.3);
            color: white;
            font-size: 1em;
        }
        input:focus, textarea:focus {
            outline: none;
            border-color: #818cf8;
        }
        button {
            padding: 12px 24px;
            background: linear-gradient(135deg, #6366f1, #8b5cf6);
            border: none;
            border-radius: 12px;
            color: white;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(99,102,241,0.3);
        }
        button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 16px;
        }
        .stat {
            text-align: center;
            padding: 16px;
            background: rgba(0,0,0,0.2);
            border-radius: 12px;
        }
        .stat .value {
            font-size: 2em;
            font-weight: bold;
            color: #818cf8;
        }
        .stat .label {
            font-size: 0.85em;
            opacity: 0.7;
        }
        #addForm textarea { height: 100px; resize: vertical; }
        .form-group { margin-bottom: 12px; }
        .form-group label { display: block; margin-bottom: 6px; opacity: 0.8; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🧠 Universal <span>RAG</span> Server</h1>
            <p style="opacity: 0.7; margin-bottom: 16px;">Yerel LLM + Retrieval Augmented Generation</p>
            <div class="status">
                <div class="dot"></div>
                <span id="statusText">Bağlanıyor...</span>
            </div>
        </header>

        <div class="sections">
            <!-- Sohbet - Tum LLM'ler -->
            <div class="card" style="grid-column: 1 / -1;">
                <h2>🤖 Sohbet - Tum LLM'ler</h2>
                <p style="opacity:0.7;margin-bottom:16px;">Sorunuz tum LLM'lere sorulur, her birinin yaniti canli yazilir. Gecmis silinmez.</p>
                <div class="chat-box" id="chatBox" style="max-height:500px;overflow-y:auto;"></div>
                <div class="input-group" style="margin-top:16px;">
                    <input type="text" id="chatInput" placeholder="Sorunuzu yazin..." onkeypress="if(event.key==='Enter')sendToAll()">
                    <button onclick="sendToAll()" id="sendBtn">🚀 Tum LLM'lere Sor</button>
                </div>
            </div>

            <!-- Istatistikler - Altta -->
            <div class="card" style="grid-column: 1 / -1;">
                <h2>📊 Istatistikler</h2>
                <div class="stats" id="statsPanel">
                    <div class="stat"><div class="value" id="statChunks">-</div><div class="label">Bilgi Parcasi</div></div>
                    <div class="stat"><div class="value" id="statSources">-</div><div class="label">Kaynak</div></div>
                    <div class="stat"><div class="value" id="statBackends">-</div><div class="label">Backend</div></div>
                    <div class="stat"><div class="value" id="statMessages">-</div><div class="label">Mesaj</div></div>
                    <div class="stat"><div class="value" id="statWords">-</div><div class="label">Kelime</div></div>
                    <div class="stat"><div class="value" id="statChars">-</div><div class="label">Karakter</div></div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const API_BASE = '';

        async function loadStatus() {
            try {
                const res = await fetch(API_BASE + '/api/status');
                const data = await res.json();
                if (data.success) {
                    document.getElementById('statusText').textContent = 'Calisiyor ✓';
                    document.getElementById('statChunks').textContent = data.data.rag.totalChunks;
                    document.getElementById('statSources').textContent = data.data.rag.sources;
                    const backends = Object.values(data.data.backends).filter(b => b.available).length;
                    document.getElementById('statBackends').textContent = backends;
                }
                // Sohbet istatistikleri
                updateChatStats();
            } catch (e) {
                document.getElementById('statusText').textContent = 'Baglanti Hatasi';
            }
        }

        function updateChatStats() {
            const history = JSON.parse(localStorage.getItem('chatHistory') || '[]');
            let messages = 0, words = 0, chars = 0;
            for (const msg of history) {
                if (msg.type === 'user') {
                    messages++;
                    words += msg.text.split(/\\s+/).length;
                    chars += msg.text.length;
                } else if (msg.responses) {
                    for (const r of msg.responses) {
                        if (r.answer) {
                            messages++;
                            words += r.answer.split(/\\s+/).length;
                            chars += r.answer.length;
                        }
                    }
                }
            }
            document.getElementById('statMessages').textContent = messages;
            document.getElementById('statWords').textContent = words;
            document.getElementById('statChars').textContent = chars;
        }

        function addMessage(text, isUser) {
            const box = document.getElementById('chatBox');
            const div = document.createElement('div');
            div.className = 'message ' + (isUser ? 'user' : 'bot');
            div.textContent = text;
            box.appendChild(div);
            box.scrollTop = box.scrollHeight;
        }

        // Kalici sohbet gecmisi
        let chatHistory = JSON.parse(localStorage.getItem('chatHistory') || '[]');

        function renderChat() {
            const chatBox = document.getElementById('chatBox');
            chatBox.innerHTML = chatHistory.map(msg => {
                if (msg.type === 'user') {
                    return '<div class="message user">👤 ' + msg.text + '</div>';
                } else {
                    let html = '<div style="margin-bottom:16px;">';
                    html += '<div style="opacity:0.6;margin-bottom:8px;">📝 Soru: ' + msg.question + '</div>';
                    for (const r of msg.responses) {
                        const status = r.success ? '✅' : '❌';
                        const color = r.success ? 'rgba(34,197,94,0.15)' : 'rgba(239,68,68,0.15)';
                        html += '<div class="message bot" style="background:' + color + ';margin-bottom:8px;">';
                        html += '<div style="font-weight:bold;">' + status + ' ' + r.backend.toUpperCase() + ' <span style="opacity:0.5;">(' + r.latencyMs + 'ms)</span></div>';
                        html += '<div style="white-space:pre-wrap;margin-top:8px;">' + (r.answer || r.error || 'Yanit yok') + '</div>';
                        html += '</div>';
                    }
                    html += '</div>';
                    return html;
                }
            }).join('');
            chatBox.scrollTop = chatBox.scrollHeight;
        }

        async function sendToAll() {
            const input = document.getElementById('chatInput');
            const btn = document.getElementById('sendBtn');
            const question = input.value.trim();
            if (!question) return;

            // Kullanici mesaji
            chatHistory.push({ type: 'user', text: question, time: new Date().toISOString() });
            renderChat();
            input.value = '';
            btn.disabled = true;
            btn.textContent = '⏳ LLM\\'ler dusunuyor...';

            try {
                const res = await fetch(API_BASE + '/api/ask-all', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ question })
                });
                const data = await res.json();

                if (data.success) {
                    chatHistory.push({
                        type: 'response',
                        question: question,
                        responses: data.data.responses,
                        totalLatency: data.data.totalLatency,
                        time: new Date().toISOString()
                    });
                } else {
                    chatHistory.push({
                        type: 'response',
                        question: question,
                        responses: [{ backend: 'sistem', success: false, error: data.error, latencyMs: 0 }],
                        time: new Date().toISOString()
                    });
                }
            } catch (e) {
                chatHistory.push({
                    type: 'response',
                    question: question,
                    responses: [{ backend: 'sistem', success: false, error: e.message, latencyMs: 0 }],
                    time: new Date().toISOString()
                });
            }

            // Kaydet ve goster
            localStorage.setItem('chatHistory', JSON.stringify(chatHistory));
            renderChat();
            btn.disabled = false;
            btn.textContent = '🚀 Tum LLM\\'lere Sor';
        }

        // Baslangic
        loadStatus();
        renderChat();
        setInterval(loadStatus, 30000);
    </script>
</body>
</html>`;
        res.writeHead(200, {
            ...CORS_HEADERS,
            'Content-Type': 'text/html; charset=utf-8',
        });
        res.end(html);
    }
    /**
     * Port bilgisi
     */
    getPort() {
        return this.port;
    }
    /**
     * Çalışıyor mu?
     */
    isActive() {
        return this.isRunning;
    }
}
// Export singleton factory
let webServerInstance = null;
export function getWebRAGServer(port) {
    if (!webServerInstance) {
        webServerInstance = new WebRAGServer(port);
    }
    return webServerInstance;
}
//# sourceMappingURL=web-server.js.map