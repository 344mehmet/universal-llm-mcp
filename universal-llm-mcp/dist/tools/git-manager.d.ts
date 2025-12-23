/**
 * Universal LLM MCP - Git Entegrasyonu
 * Clone, commit, push, pull, branch yönetimi
 */
export interface GitStatus {
    branch: string;
    ahead: number;
    behind: number;
    staged: string[];
    modified: string[];
    untracked: string[];
}
export declare class GitManager {
    private cwd;
    constructor(cwd?: string);
    private exec;
    /**
     * Repo klonla
     */
    clone(url: string, directory?: string): Promise<string>;
    /**
     * Durum
     */
    status(): Promise<GitStatus>;
    /**
     * Stage
     */
    add(files: string | string[]): Promise<void>;
    /**
     * Commit
     */
    commit(message: string): Promise<string>;
    /**
     * Push
     */
    push(remote?: string, branch?: string): Promise<string>;
    /**
     * Pull
     */
    pull(remote?: string, branch?: string): Promise<string>;
    /**
     * Branch listele
     */
    listBranches(): Promise<string[]>;
    /**
     * Branch oluştur
     */
    createBranch(name: string): Promise<void>;
    /**
     * Branch değiştir
     */
    checkout(branch: string): Promise<void>;
    /**
     * Son commitler
     */
    log(count?: number): Promise<Array<{
        hash: string;
        message: string;
        author: string;
        date: string;
    }>>;
    /**
     * Diff
     */
    diff(file?: string): Promise<string>;
    /**
     * Init
     */
    init(): Promise<void>;
    /**
     * Remote ekle
     */
    addRemote(name: string, url: string): Promise<void>;
}
export declare function getGitManager(cwd?: string): GitManager;
//# sourceMappingURL=git-manager.d.ts.map