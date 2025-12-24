/**
 * AI Agent Orchestrator - 7/24 Developer Ordusu
 * Çoklu agent koordinasyonu ve zamanlama
 */

import { GitHubIssueSolver, GitHubConfig, Issue } from './issue-solver.js';

export interface AgentConfig {
    name: string;
    type: 'issue-solver' | 'code-reviewer' | 'doc-generator' | 'test-writer';
    priority: number;
    enabled: boolean;
}

export interface SchedulerConfig {
    scanIntervalMinutes: number;
    maxConcurrentAgents: number;
    workingHours: { start: number; end: number } | null; // null = 24/7
    retryDelayMinutes: number;
}

export interface AgentStats {
    issuesAnalyzed: number;
    issuesSolved: number;
    prsCreated: number;
    errors: number;
    lastRun: Date | null;
}

/**
 * Agent Orchestrator - Tüm AI agentları yönetir
 */
export class AgentOrchestrator {
    private issueSolver: GitHubIssueSolver;
    private schedulerConfig: SchedulerConfig;
    private agents: Map<string, AgentConfig>;
    private stats: AgentStats;
    private isRunning: boolean = false;
    private intervalId: NodeJS.Timeout | null = null;
    private llmClient: any;

    constructor(
        githubConfig: GitHubConfig,
        schedulerConfig: SchedulerConfig,
        llmClient: any
    ) {
        this.issueSolver = new GitHubIssueSolver(githubConfig);
        this.schedulerConfig = schedulerConfig;
        this.llmClient = llmClient;
        this.agents = new Map();
        this.stats = {
            issuesAnalyzed: 0,
            issuesSolved: 0,
            prsCreated: 0,
            errors: 0,
            lastRun: null,
        };

        // Varsayılan agentları kaydet
        this.registerAgent({
            name: 'issue-solver-primary',
            type: 'issue-solver',
            priority: 1,
            enabled: true,
        });
    }

    /**
     * Agent kaydet
     */
    registerAgent(config: AgentConfig): void {
        this.agents.set(config.name, config);
        console.log(`🤖 Agent kaydedildi: ${config.name} (${config.type})`);
    }

    /**
     * Çalışma saatleri kontrolü
     */
    private isWithinWorkingHours(): boolean {
        if (!this.schedulerConfig.workingHours) return true; // 24/7

        const now = new Date();
        const hour = now.getHours();
        const { start, end } = this.schedulerConfig.workingHours;

        return hour >= start && hour < end;
    }

    /**
     * Ana tarama döngüsü
     */
    private async runScanCycle(): Promise<void> {
        if (!this.isWithinWorkingHours()) {
            console.log('⏸️ Çalışma saatleri dışında, bekleniyor...');
            return;
        }

        console.log('🔍 Issue tarama başlatılıyor...');
        this.stats.lastRun = new Date();

        try {
            // Issue'ları tara
            const issues = await this.issueSolver.scanOpenIssues();
            console.log(`📋 ${issues.length} açık issue bulundu`);

            // Öncelik sırasına göre sırala (label'lara göre)
            const prioritizedIssues = this.prioritizeIssues(issues);

            // Eşzamanlı işlem limiti ile çöz
            const batch = prioritizedIssues.slice(0, this.schedulerConfig.maxConcurrentAgents);

            for (const issue of batch) {
                try {
                    this.stats.issuesAnalyzed++;
                    const solved = await this.issueSolver.solveIssue(issue, this.llmClient);

                    if (solved) {
                        this.stats.issuesSolved++;
                        this.stats.prsCreated++;
                    }
                } catch (error) {
                    this.stats.errors++;
                    console.error(`❌ Issue #${issue.number} hatası:`, error);
                }

                // Rate limiting için bekle
                await this.sleep(5000);
            }

        } catch (error) {
            this.stats.errors++;
            console.error('❌ Tarama döngüsü hatası:', error);
        }

        this.logStats();
    }

    /**
     * Issue'ları önceliklendir
     */
    private prioritizeIssues(issues: Issue[]): Issue[] {
        const priorityLabels: Record<string, number> = {
            'critical': 100,
            'bug': 80,
            'security': 90,
            'help wanted': 70,
            'good first issue': 60,
            'enhancement': 40,
            'documentation': 30,
        };

        return issues.sort((a, b) => {
            const aPriority = Math.max(...a.labels.map(l => priorityLabels[l.toLowerCase()] || 0));
            const bPriority = Math.max(...b.labels.map(l => priorityLabels[l.toLowerCase()] || 0));
            return bPriority - aPriority;
        });
    }

    /**
     * İstatistikleri logla
     */
    private logStats(): void {
        console.log('\n📊 Agent İstatistikleri:');
        console.log(`   Analiz edilen: ${this.stats.issuesAnalyzed}`);
        console.log(`   Çözülen: ${this.stats.issuesSolved}`);
        console.log(`   Oluşturulan PR: ${this.stats.prsCreated}`);
        console.log(`   Hatalar: ${this.stats.errors}`);
        console.log(`   Son çalışma: ${this.stats.lastRun?.toLocaleString() || 'Hiç'}\n`);
    }

    /**
     * Orkestrasyonu başlat (7/24)
     */
    start(): void {
        if (this.isRunning) {
            console.log('⚠️ Orchestrator zaten çalışıyor');
            return;
        }

        this.isRunning = true;
        console.log('🚀 AI Developer Ordusu başlatıldı - 7/24 aktif');
        console.log(`   Tarama aralığı: ${this.schedulerConfig.scanIntervalMinutes} dakika`);
        console.log(`   Maks eşzamanlı agent: ${this.schedulerConfig.maxConcurrentAgents}`);

        // İlk taramayı hemen yap
        this.runScanCycle();

        // Periyodik tarama başlat
        this.intervalId = setInterval(
            () => this.runScanCycle(),
            this.schedulerConfig.scanIntervalMinutes * 60 * 1000
        );
    }

    /**
     * Orkestrasyonu durdur
     */
    stop(): void {
        if (!this.isRunning) return;

        this.isRunning = false;
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }

        console.log('⏹️ AI Developer Ordusu durduruldu');
        this.logStats();
    }

    /**
     * İstatistikleri al
     */
    getStats(): AgentStats {
        return { ...this.stats };
    }

    /**
     * Sleep yardımcı fonksiyonu
     */
    private sleep(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// Kullanım örneği
export function createDeveloperArmy(
    githubToken: string,
    owner: string,
    repos: string[],
    llmClient: any
): AgentOrchestrator {
    const githubConfig: GitHubConfig = {
        token: githubToken,
        owner,
        repos,
    };

    const schedulerConfig: SchedulerConfig = {
        scanIntervalMinutes: 30, // Her 30 dakikada tara
        maxConcurrentAgents: 3,  // Aynı anda 3 issue
        workingHours: null,      // 7/24 çalış
        retryDelayMinutes: 5,
    };

    return new AgentOrchestrator(githubConfig, schedulerConfig, llmClient);
}
