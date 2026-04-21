@echo off
chcp 65001 >nul
echo ============================================
echo  Baixando bandeiras das selecoes classificadas
echo ============================================
echo.

set FLAGS_DIR=assets\flags

echo [1/6] Turquia (TUR)...
curl -L -A "Mozilla/5.0" -o "%FLAGS_DIR%\tur.png" "https://flagpedia.net/data/flags/w320/tr.png"

echo [2/6] Suecia (SWE)...
curl -L -A "Mozilla/5.0" -o "%FLAGS_DIR%\swe.png" "https://flagpedia.net/data/flags/w320/se.png"

echo [3/6] Republica Tcheca (CZE)...
curl -L -A "Mozilla/5.0" -o "%FLAGS_DIR%\cze.png" "https://flagpedia.net/data/flags/w320/cz.png"

echo [4/6] Bosnia e Herzegovina (BIH)...
curl -L -A "Mozilla/5.0" -o "%FLAGS_DIR%\bih.png" "https://flagpedia.net/data/flags/w320/ba.png"

echo [5/6] Rep. Democratica do Congo (COD)...
curl -L -A "Mozilla/5.0" -o "%FLAGS_DIR%\cod.png" "https://flagpedia.net/data/flags/w320/cd.png"

echo [6/6] Iraque (IRQ)...
curl -L -A "Mozilla/5.0" -o "%FLAGS_DIR%\irq.png" "https://flagpedia.net/data/flags/w320/iq.png"

echo.
echo Verificando tamanhos...
dir "%FLAGS_DIR%\tur.png" "%FLAGS_DIR%\swe.png" "%FLAGS_DIR%\cze.png" "%FLAGS_DIR%\bih.png" "%FLAGS_DIR%\cod.png" "%FLAGS_DIR%\irq.png" | find ".png"

echo.
echo ============================================
echo  Concluido! Verifique os tamanhos acima.
echo  Esperado: cada arquivo maior que 5.000 bytes
echo ============================================
pause
