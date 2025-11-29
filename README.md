# Backup e Restore de Pastas

## Requisitos
- `brew install gnupg`

## Uso local com repositório clonado
1. `git clone git@github.com:vitormoschetta/backup.git`
2. `cd backup && chmod +x backup.sh restore.sh`
3. `./backup.sh <pasta_origem>`
4. `./restore.sh <arquivo_backup>.tar.gz.gpg`

## Restaurar sem clonar o projeto
Se você só precisa descriptografar um arquivo e não quer clonar o repositório, baixe o script diretamente do GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/vitormoschetta/backup/main/restore.sh -o restore.sh
chmod +x restore.sh
./restore.sh <arquivo_backup>.tar.gz.gpg
```

Ou execute tudo em uma única linha, já passando o nome do arquivo:

```bash
curl -fsSL https://raw.githubusercontent.com/vitormoschetta/backup/main/restore.sh | bash -s -- <arquivo_backup>.tar.gz.gpg
```

> Obs.: o script pede a senha do GPG via stdin quando necessário, portanto funciona normalmente ao ser chamado dessa forma.