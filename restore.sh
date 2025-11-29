#!/bin/bash

# Script para descriptografar backups
# Uso: ./restore.sh arquivo_backup.tar.gz.gpg

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Script de Restauração ===${NC}"

# Verificar se foi passado um arquivo
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Erro: Forneça o arquivo para descriptografar${NC}"
    echo "Uso: $0 arquivo_backup.tar.gz.gpg"
    echo
    echo "Arquivos disponíveis:"
    ls -la *.tar.gz.gpg 2>/dev/null || echo "Nenhum arquivo de backup encontrado"
    exit 1
fi

ARQUIVO_BACKUP="$1"

# Verificar se o arquivo existe
if [ ! -f "$ARQUIVO_BACKUP" ]; then
    echo -e "${RED}❌ Erro: Arquivo '$ARQUIVO_BACKUP' não encontrado!${NC}"
    exit 1
fi

echo "Arquivo: $ARQUIVO_BACKUP"
echo

# Configurar GPG para funcionar em scripts
export GPG_TTY=$(tty)

echo -e "${YELLOW}🔓 Descriptografando e extraindo...${NC}"
echo -e "${YELLOW}Digite a senha:${NC}"

# Descriptografar e extrair com verificação de erros
set -o pipefail

# Capturar stderr do GPG
GPG_OUTPUT=$(mktemp)
if gpg --decrypt "$ARQUIVO_BACKUP" 2>"$GPG_OUTPUT" | tar xzf - 2>&1; then
    # Verificar se houve erro de descriptografia
    if grep -q "decryption failed" "$GPG_OUTPUT"; then
        echo
        echo -e "${RED}❌ Erro: Senha incorreta!${NC}"
        rm -f "$GPG_OUTPUT"
        exit 1
    fi
    
    echo
    echo -e "${GREEN}✅ Restauração concluída com sucesso!${NC}"
    echo -e "${GREEN}📁 Arquivos extraídos no diretório atual${NC}"
    echo
    echo "Conteúdo restaurado:"
    ls -ld */ 2>/dev/null || echo "Arquivos extraídos."
else
    echo
    echo -e "${RED}❌ Erro durante a restauração!${NC}"
    if grep -q "decryption failed" "$GPG_OUTPUT"; then
        echo -e "${RED}Verifique se a senha está correta.${NC}"
    fi
    rm -f "$GPG_OUTPUT"
    exit 1
fi

rm -f "$GPG_OUTPUT"
set +o pipefail

echo -e "${GREEN}🎉 Processo concluído!${NC}"