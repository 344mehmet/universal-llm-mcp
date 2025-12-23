/**
 * Universal LLM MCP - Git Entegrasyonu
 * Clone, commit, push, pull, branch yönetimi
 */
import { spawn } from 'child_process';
export class GitManager {
    cwd;
    constructor(cwd) {
        this.cwd = cwd || process.cwd();
    }
    async exec(args) {
        return new Promise((resolve, reject) => {
            const proc = spawn('git', args, { cwd: this.cwd });
            let stdout = '';
            let stderr = '';
            proc.stdout?.on('data', (data) => { stdout += data.toString(); });
            proc.stderr?.on('data', (data) => { stderr += data.toString(); });
            proc.on('close', (code) => {
                if (code === 0) {
                    resolve(stdout.trim());
                }
                else {
                    reject(new Error(stderr || `Git error: ${code}`));
                }
            });
        });
    }
    /**
     * Repo klonla
     */
    async clone(url, directory) {
        const args = ['clone', url];
        if (directory)
            args.push(directory);
        return this.exec(args);
    }
    /**
     * Durum
     */
    async status() {
        const branch = await this.exec(['branch', '--show-current']);
        const statusOutput = await this.exec(['status', '--porcelain']);
        const staged = [];
        const modified = [];
        const untracked = [];
        for (const line of statusOutput.split('\n')) {
            if (!line)
                continue;
            const status = line.substring(0, 2);
            const file = line.substring(3);
            if (status.startsWith('A') || status.startsWith('M ')) {
                staged.push(file);
            }
            else if (status.includes('M')) {
                modified.push(file);
            }
            else if (status.startsWith('??')) {
                untracked.push(file);
            }
        }
        return { branch, ahead: 0, behind: 0, staged, modified, untracked };
    }
    /**
     * Stage
     */
    async add(files) {
        const fileList = Array.isArray(files) ? files : [files];
        await this.exec(['add', ...fileList]);
    }
    /**
     * Commit
     */
    async commit(message) {
        return this.exec(['commit', '-m', message]);
    }
    /**
     * Push
     */
    async push(remote, branch) {
        const args = ['push'];
        if (remote)
            args.push(remote);
        if (branch)
            args.push(branch);
        return this.exec(args);
    }
    /**
     * Pull
     */
    async pull(remote, branch) {
        const args = ['pull'];
        if (remote)
            args.push(remote);
        if (branch)
            args.push(branch);
        return this.exec(args);
    }
    /**
     * Branch listele
     */
    async listBranches() {
        const output = await this.exec(['branch', '-a']);
        return output.split('\n').map(b => b.trim().replace('* ', ''));
    }
    /**
     * Branch oluştur
     */
    async createBranch(name) {
        await this.exec(['branch', name]);
    }
    /**
     * Branch değiştir
     */
    async checkout(branch) {
        await this.exec(['checkout', branch]);
    }
    /**
     * Son commitler
     */
    async log(count = 10) {
        const output = await this.exec([
            'log',
            `-${count}`,
            '--pretty=format:%H|||%s|||%an|||%ai',
        ]);
        return output.split('\n').map(line => {
            const [hash, message, author, date] = line.split('|||');
            return { hash, message, author, date };
        });
    }
    /**
     * Diff
     */
    async diff(file) {
        const args = ['diff'];
        if (file)
            args.push(file);
        return this.exec(args);
    }
    /**
     * Init
     */
    async init() {
        await this.exec(['init']);
    }
    /**
     * Remote ekle
     */
    async addRemote(name, url) {
        await this.exec(['remote', 'add', name, url]);
    }
}
// Singleton
let gitInstance = null;
export function getGitManager(cwd) {
    if (!gitInstance || cwd) {
        gitInstance = new GitManager(cwd);
    }
    return gitInstance;
}
//# sourceMappingURL=git-manager.js.map