/**
 * Universal LLM MCP - Çoklu LLM Sorgulama
 * Tüm LLM'lere aynı soruyu sor, her birinin yanıtını göster
 */
export interface MultiLLMResponse {
    backend: string;
    model: string;
    answer: string;
    latencyMs: number;
    success: boolean;
    error?: string;
}
export interface MultiQueryResult {
    question: string;
    responses: MultiLLMResponse[];
    totalLatency: number;
    timestamp: Date;
}
/**
 * Tüm LLM'lere aynı soruyu sor
 */
export declare function queryAllLLMs(question: string, systemPrompt?: string): Promise<MultiQueryResult>;
//# sourceMappingURL=multi-llm.d.ts.map