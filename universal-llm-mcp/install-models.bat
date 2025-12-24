@echo off
REM ========================================
REM Universal MCP - Ollama Model Kurulum Scripti
REM 16GB VRAM ve 32GB RAM için optimize edilmiş
REM ========================================

echo.
echo ========================================
echo    OLLAMA MODEL KURULUM SCRIPTI
echo    16GB VRAM Optimizasyonlu
echo ========================================
echo.

REM Ollama kontrolü
where ollama >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [HATA] Ollama bulunamadi!
    echo Lutfen https://ollama.com adresinden Ollama yukleyin.
    pause
    exit /b 1
)

echo [INFO] Ollama bulundu. Modeller indiriliyor...
echo.

REM ========================================
REM TEMEL MODELLER (Mutlaka indir)
REM ========================================
echo [1/6] Llama 3.1 8B indiriliyor (5GB VRAM)...
ollama pull llama3.1:8b-q4_K_M

echo [2/6] Qwen2.5 Coder 14B indiriliyor (8GB VRAM)...
ollama pull qwen2.5-coder:14b-q4_K_M

echo [3/6] DeepSeek R1 8B indiriliyor (5GB VRAM)...
ollama pull deepseek-r1:8b

REM ========================================
REM BÜYÜK MODELLER (16GB VRAM tam kullanir)
REM ========================================
echo [4/6] Gemma3 27B indiriliyor (14GB VRAM)...
echo [UYARI] Bu model buyuk, indirme biraz zaman alabilir.
ollama pull gemma3:27b-q4_K_M

echo [5/6] Qwen3 30B indiriliyor (16GB VRAM)...
echo [UYARI] Bu model en buyuk, GPU'yu tam kullanir.
ollama pull qwen3:30b-q4_K_M

REM ========================================
REM EMBEDDING MODEL (RAG icin)
REM ========================================
echo [6/6] Nomic Embed Text indiriliyor (RAG icin)...
ollama pull nomic-embed-text

echo.
echo ========================================
echo    KURULUM TAMAMLANDI!
echo ========================================
echo.
echo Yuklenen modeller:
ollama list
echo.
echo [BILGI] Modelleri test etmek icin:
echo   ollama run llama3.1:8b-q4_K_M
echo.
pause
