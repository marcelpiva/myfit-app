#!/bin/bash

# =============================================================================
# Script para gerar screenshots da Play Store
# =============================================================================
# Uso: ./scripts/generate_playstore_screenshots.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SCREENSHOTS_DIR="$PROJECT_DIR/screenshots/playstore"
GOLDENS_DIR="$PROJECT_DIR/test/screenshots/goldens"

echo "=========================================="
echo "  MyFit - Gerador de Screenshots"
echo "=========================================="
echo ""

# Criar diretórios de saída
mkdir -p "$SCREENSHOTS_DIR/phone"
mkdir -p "$SCREENSHOTS_DIR/tablet_7"
mkdir -p "$SCREENSHOTS_DIR/tablet_10"

echo "📁 Diretórios criados em: $SCREENSHOTS_DIR"
echo ""

# Executar os testes de screenshot
echo "📸 Gerando screenshots..."
echo ""

cd "$PROJECT_DIR"

# Executar testes com update-goldens para gerar as imagens
flutter test test/screenshots/playstore_screenshots_test.dart --update-goldens

echo ""
echo "✅ Golden tests executados!"
echo ""

# Copiar screenshots para pasta final
echo "📋 Organizando screenshots..."

# Detectar pasta de goldens (macos ou ci)
if [ -d "$GOLDENS_DIR/macos" ]; then
    GOLDEN_SOURCE="$GOLDENS_DIR/macos"
elif [ -d "$GOLDENS_DIR/ci" ]; then
    GOLDEN_SOURCE="$GOLDENS_DIR/ci"
else
    GOLDEN_SOURCE="$GOLDENS_DIR"
fi

echo "   Fonte: $GOLDEN_SOURCE"

# Copiar arquivos de phone
if [ -d "$GOLDEN_SOURCE/playstore/phone" ]; then
    cp -r "$GOLDEN_SOURCE/playstore/phone/"* "$SCREENSHOTS_DIR/phone/" 2>/dev/null || true
    echo "   ✓ Screenshots de phone copiados"
fi

# Copiar arquivos de tablet_7
if [ -d "$GOLDEN_SOURCE/playstore/tablet_7" ]; then
    cp -r "$GOLDEN_SOURCE/playstore/tablet_7/"* "$SCREENSHOTS_DIR/tablet_7/" 2>/dev/null || true
    echo "   ✓ Screenshots de tablet 7\" copiados"
fi

# Copiar arquivos de tablet_10
if [ -d "$GOLDEN_SOURCE/playstore/tablet_10" ]; then
    cp -r "$GOLDEN_SOURCE/playstore/tablet_10/"* "$SCREENSHOTS_DIR/tablet_10/" 2>/dev/null || true
    echo "   ✓ Screenshots de tablet 10\" copiados"
fi

echo ""
echo "=========================================="
echo "  Screenshots gerados com sucesso!"
echo "=========================================="
echo ""
echo "📂 Localização: $SCREENSHOTS_DIR"
echo ""
echo "📱 Phone (1080x1920):"
ls -la "$SCREENSHOTS_DIR/phone/" 2>/dev/null || echo "   Nenhum arquivo"
echo ""

# Requisitos do Google Play
echo "=========================================="
echo "  Requisitos do Google Play"
echo "=========================================="
echo ""
echo "📱 Telefone:"
echo "   - Mínimo: 2 screenshots"
echo "   - Máximo: 8 screenshots"
echo "   - Proporção: 16:9 ou 9:16"
echo "   - Tamanho: min 320px, max 3840px"
echo "   - Formato: PNG ou JPEG (24-bit, sem alfa)"
echo ""
echo "📱 Tablet 7\"  (opcional)"
echo "📱 Tablet 10\" (opcional)"
echo ""
echo "🖼️ Feature Graphic:"
echo "   - Tamanho: 1024 x 500 px"
echo "   - Formato: PNG ou JPEG"
echo ""
echo "=========================================="

# Converter PNG para JPEG se necessário (Play Store às vezes prefere JPEG)
echo ""
read -p "Deseja converter screenshots para JPEG? (s/N): " convert_jpeg

if [[ "$convert_jpeg" =~ ^[Ss]$ ]]; then
    echo ""
    echo "🔄 Convertendo para JPEG..."

    for png_file in "$SCREENSHOTS_DIR/phone/"*.png; do
        if [ -f "$png_file" ]; then
            jpeg_file="${png_file%.png}.jpg"
            # Usar sips no macOS para converter
            sips -s format jpeg -s formatOptions 90 "$png_file" --out "$jpeg_file" 2>/dev/null || true
            echo "   ✓ $(basename "$jpeg_file")"
        fi
    done

    echo ""
    echo "✅ Conversão concluída!"
fi

echo ""
echo "🎉 Pronto! Faça upload dos screenshots em:"
echo "   https://play.google.com/console"
echo ""
