#!/bin/bash

# Script para compactar e criptografar pasta
# Uso: ./backup.sh <pasta_origem>
# Exemplo: ./backup.sh Pessoal

# Verificar se o parâmetro foi fornecido
if [ $# -eq 0 ]; then
    echo "❌ Erro: Você deve especificar a pasta de origem!"
    echo "Uso: $0 <pasta_origem>"
    echo "Exemplo: $0 Pessoal"
    exit 1
fi

# Configurações
PASTA_ORIGEM="$1"
ARQUIVO_SAIDA="${PASTA_ORIGEM}_backup_$(date +%Y%m%d_%H%M%S)"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Script de Backup Criptografado ===${NC}"
echo "Pasta: $PASTA_ORIGEM"
echo "Arquivo de saída: $ARQUIVO_SAIDA.tar.gz.gpg"
echo

# Verificar se a pasta existe
if [ ! -d "$PASTA_ORIGEM" ]; then
    echo -e "${RED}❌ Erro: Pasta '$PASTA_ORIGEM' não encontrada!${NC}"
    exit 1
fi

# Verificar se o GPG está instalado
if ! command -v gpg &> /dev/null; then
    echo -e "${RED}❌ Erro: GPG não está instalado!${NC}"
    echo "Instale com:"
    echo "  macOS: brew install gnupg"
    echo "  Ubuntu/Debian: sudo apt install gnupg"
    echo "  Windows: choco install gnupg"
    exit 1
fi

echo -e "${YELLOW}📦 Compactando pasta '$PASTA_ORIGEM'...${NC}"

# Configurar GPG para funcionar em scripts
export GPG_TTY=$(tty)

# Solicitar senha antecipadamente
echo -e "${YELLOW}🔐 Digite a senha para criptografia:${NC}"
read -s PASSWORD
echo

# Compactar e criptografar em uma única operação
if tar czf - "$PASTA_ORIGEM"/ | gpg --batch --yes --symmetric --cipher-algo AES256 --armor --pinentry-mode loopback --passphrase "$PASSWORD" --output "$ARQUIVO_SAIDA.tar.gz.gpg"; then
    echo -e "${GREEN}✅ Backup criado com sucesso!${NC}"
    echo -e "${GREEN}📁 Arquivo: $ARQUIVO_SAIDA.tar.gz.gpg${NC}"
    
    # Mostrar tamanho do arquivo
    if [ -f "$ARQUIVO_SAIDA.tar.gz.gpg" ]; then
        TAMANHO=$(ls -lh "$ARQUIVO_SAIDA.tar.gz.gpg" | awk '{print $5}')
        echo -e "${GREEN}📊 Tamanho: $TAMANHO${NC}"
    fi
    
    # Limpar a senha da memória
    unset PASSWORD
    
    echo
    echo -e "${YELLOW}Para descriptografar use:${NC}"
    echo "gpg --batch --pinentry-mode loopback --decrypt '$ARQUIVO_SAIDA.tar.gz.gpg' | tar xzf -"
    
else
    echo -e "${RED}❌ Erro durante o backup!${NC}"
    # Limpar a senha da memória em caso de erro
    unset PASSWORD
    exit 1
fi

echo -e "${GREEN}🎉 Processo concluído!${NC}"
