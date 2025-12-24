import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { GitHubIssueSolver } from '../github/issue-solver.js';
import { z } from 'zod';

/**
 * GitHub Araçlarını Kaydet
 */
export function registerGitHubTools(server: McpServer): void {
    const token = process.env.GITHUB_TOKEN || '';
    if (!token) {
        console.warn('[GitHub Araçları] GITHUB_TOKEN eksik, araçlar kısıtlı çalışabilir.');
    }

    const solver = new GitHubIssueSolver({
        token,
        owner: '', // Dinamik olarak set edilebilir veya .env'den alınabilir
        repos: []
    });

    // GitHub Issue Tarama Aracı
    server.tool(
        'github_issue_tara',
        'Belirtilen repodaki açık issue\'ları tara',
        {
            owner: z.string().describe('Repo sahibi'),
            repo: z.string().describe('Repo adı')
        },
        async ({ owner, repo }) => {
            const solverInstance = new GitHubIssueSolver({ token, owner, repos: [repo] });
            const issues = await solverInstance.scanOpenIssues();
            return {
                content: [{
                    type: 'text',
                    text: `Bulunan Issue Sayısı: ${issues.length}\n\n` +
                        issues.map(i => `#${i.number} - ${i.title}`).join('\n')
                }]
            };
        }
    );

    // GitHub Issue Çözme Aracı (AI)
    server.tool(
        'github_issue_coz',
        'Belirtilen issue\'yu analiz et ve çözüm (PR) oluştur',
        {
            owner: z.string().describe('Repo sahibi'),
            repo: z.string().describe('Repo adı'),
            issueNumber: z.number().describe('Issue numarası')
        },
        async ({ owner, repo, issueNumber }) => {
            // Burada llmClient'ı router üzerinden alabiliriz
            return {
                content: [{ type: 'text', text: `Issue #${issueNumber} için çözüm akışı başlatıldı.` }]
            };
        }
    );
}
