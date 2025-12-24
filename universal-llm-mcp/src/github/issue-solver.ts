/**
 * GitHub Issue Solver - AI Developer Ordusu
 * 7/24 Otomatik Issue Çözücü
 */

import { Octokit } from '@octokit/rest';

export interface GitHubConfig {
    token: string;
    owner: string;
    repos: string[];
}

export interface Issue {
    id: number;
    number: number;
    title: string;
    body: string;
    labels: string[];
    state: string;
    repo: string;
    url: string;
    createdAt: string;
}

export interface Solution {
    issueNumber: number;
    analysis: string;
    suggestedFix: string;
    codeChanges: { file: string; content: string }[];
    confidence: number;
    estimatedTime: string;
}

/**
 * GitHub Issue Solver Servisi
 */
export class GitHubIssueSolver {
    private octokit: Octokit;
    private config: GitHubConfig;

    constructor(config: GitHubConfig) {
        this.config = config;
        this.octokit = new Octokit({ auth: config.token });
    }

    /**
     * Tüm açık issue'ları tara
     */
    async scanOpenIssues(): Promise<Issue[]> {
        const allIssues: Issue[] = [];

        for (const repo of this.config.repos) {
            try {
                const { data } = await this.octokit.issues.listForRepo({
                    owner: this.config.owner,
                    repo,
                    state: 'open',
                    per_page: 100,
                });

                const issues = data
                    .filter(issue => !issue.pull_request) // PR'ları hariç tut
                    .map(issue => ({
                        id: issue.id,
                        number: issue.number,
                        title: issue.title,
                        body: issue.body || '',
                        labels: issue.labels.map((l: any) =>
                            typeof l === 'string' ? l : l.name || ''
                        ),
                        state: issue.state,
                        repo,
                        url: issue.html_url,
                        createdAt: issue.created_at,
                    }));

                allIssues.push(...issues);
            } catch (error) {
                console.error(`[GitHubIssueSolver] ${repo} tarama hatası:`, error);
            }
        }

        return allIssues;
    }

    /**
     * Issue'yu analiz et ve çözüm öner
     */
    async analyzeIssue(issue: Issue, llmClient: any): Promise<Solution> {
        const prompt = `
Sen deneyimli bir yazılım geliştiricisisin. Aşağıdaki GitHub issue'yu analiz et ve çözüm öner:

## Issue Başlığı
${issue.title}

## Issue Açıklaması
${issue.body}

## Etiketler
${issue.labels.join(', ') || 'Yok'}

## Görevler:
1. Sorunu detaylı analiz et
2. Kök nedeni belirle
3. Çözüm öner (kod değişiklikleri dahil)
4. Tahmini çözüm süresini belirt
5. Güven seviyeni %0-100 arası belirt

JSON formatında yanıt ver:
{
    "analysis": "Detaylı analiz",
    "rootCause": "Kök neden",
    "suggestedFix": "Önerilen çözüm açıklaması",
    "codeChanges": [{"file": "dosya/yolu", "content": "değişiklik"}],
    "estimatedTime": "2 saat",
    "confidence": 85
}
`;

        try {
            const response = await llmClient.complete({
                messages: [{ role: 'user', content: prompt }],
                temperature: 0.3,
            });

            const result = JSON.parse(response.content);
            return {
                issueNumber: issue.number,
                ...result,
            };
        } catch (error) {
            console.error(`[GitHubIssueSolver] Analiz hatası:`, error);
            return {
                issueNumber: issue.number,
                analysis: 'Analiz başarısız',
                suggestedFix: '',
                codeChanges: [],
                confidence: 0,
                estimatedTime: 'Bilinmiyor',
            };
        }
    }

    /**
     * Branch oluştur
     */
    async createBranch(repo: string, branchName: string, baseBranch: string = 'main'): Promise<boolean> {
        try {
            // Base branch'ın SHA'sını al
            const { data: ref } = await this.octokit.git.getRef({
                owner: this.config.owner,
                repo,
                ref: `heads/${baseBranch}`,
            });

            // Yeni branch oluştur
            await this.octokit.git.createRef({
                owner: this.config.owner,
                repo,
                ref: `refs/heads/${branchName}`,
                sha: ref.object.sha,
            });

            return true;
        } catch (error) {
            console.error(`[GitHubIssueSolver] Branch oluşturma hatası:`, error);
            return false;
        }
    }

    /**
     * Dosya güncelle
     */
    async updateFile(
        repo: string,
        path: string,
        content: string,
        branch: string,
        message: string
    ): Promise<boolean> {
        try {
            // Mevcut dosyayı kontrol et
            let sha: string | undefined;
            try {
                const { data } = await this.octokit.repos.getContent({
                    owner: this.config.owner,
                    repo,
                    path,
                    ref: branch,
                });
                if ('sha' in data) {
                    sha = data.sha;
                }
            } catch {
                // Dosya mevcut değil, yeni oluşturulacak
            }

            await this.octokit.repos.createOrUpdateFileContents({
                owner: this.config.owner,
                repo,
                path,
                message,
                content: Buffer.from(content).toString('base64'),
                branch,
                sha,
            });

            return true;
        } catch (error) {
            console.error(`[GitHubIssueSolver] Dosya güncelleme hatası:`, error);
            return false;
        }
    }

    /**
     * Pull Request oluştur
     */
    async createPullRequest(
        repo: string,
        title: string,
        body: string,
        headBranch: string,
        baseBranch: string = 'main'
    ): Promise<number | null> {
        try {
            const { data } = await this.octokit.pulls.create({
                owner: this.config.owner,
                repo,
                title,
                body,
                head: headBranch,
                base: baseBranch,
            });

            return data.number;
        } catch (error) {
            console.error(`[GitHubIssueSolver] PR oluşturma hatası:`, error);
            return null;
        }
    }

    /**
     * Issue'ya yorum ekle
     */
    async commentOnIssue(repo: string, issueNumber: number, comment: string): Promise<boolean> {
        try {
            await this.octokit.issues.createComment({
                owner: this.config.owner,
                repo,
                issue_number: issueNumber,
                body: comment,
            });
            return true;
        } catch (error) {
            console.error(`[GitHubIssueSolver] Yorum ekleme hatası:`, error);
            return false;
        }
    }

    /**
     * Tam çözüm akışı
     */
    async solveIssue(issue: Issue, llmClient: any): Promise<boolean> {
        console.log(`🔧 Issue #${issue.number} çözülüyor: ${issue.title}`);

        // 1. Analiz et
        const solution = await this.analyzeIssue(issue, llmClient);

        if (solution.confidence < 50) {
            console.log(`⚠️ Düşük güven (%${solution.confidence}), manuel inceleme gerekli`);
            await this.commentOnIssue(
                issue.repo,
                issue.number,
                `🤖 **AI Analizi**\n\n${solution.analysis}\n\n⚠️ Güven seviyesi düşük (%${solution.confidence}), manuel inceleme önerilir.`
            );
            return false;
        }

        // 2. Branch oluştur
        const branchName = `ai-fix/issue-${issue.number}`;
        const branchCreated = await this.createBranch(issue.repo, branchName);
        if (!branchCreated) return false;

        // 3. Dosya değişiklikleri yap
        for (const change of solution.codeChanges) {
            await this.updateFile(
                issue.repo,
                change.file,
                change.content,
                branchName,
                `🤖 AI Fix: ${issue.title} (#${issue.number})`
            );
        }

        // 4. PR oluştur
        const prBody = `
## 🤖 AI Tarafından Oluşturuldu

### Issue Referansı
Fixes #${issue.number}

### Analiz
${solution.analysis}

### Yapılan Değişiklikler
${solution.suggestedFix}

### Güven Seviyesi
${solution.confidence}%

### Tahmini Süre
${solution.estimatedTime}

---
*Bu PR, AI Developer Ordusu tarafından otomatik olarak oluşturulmuştur.*
`;

        const prNumber = await this.createPullRequest(
            issue.repo,
            `🤖 AI Fix: ${issue.title}`,
            prBody,
            branchName
        );

        if (prNumber) {
            console.log(`✅ PR #${prNumber} oluşturuldu`);
            return true;
        }

        return false;
    }
}
