#!/usr/bin/env bash
set -euo pipefail

WORDLIST_DIR="./wordlist"
WORDS_COUNT=24

# Verificações básicas
if [ ! -d "$WORDLIST_DIR" ]; then
  echo "Erro: diretório '$WORDLIST_DIR' não encontrado."
  exit 1
fi

# Seleciona um arquivo aleatório (CSPRNG)
WORDLIST_FILE=$(find "$WORDLIST_DIR" -type f \
  | shuf --random-source=/dev/urandom -n 1)

if [ -z "$WORDLIST_FILE" ]; then
  echo "Erro: nenhuma wordlist encontrada."
  exit 1
fi

# Conta linhas válidas
TOTAL_LINES=$(grep -v '^\s*$' "$WORDLIST_FILE" | wc -l)

if [ "$TOTAL_LINES" -lt "$WORDS_COUNT" ]; then
  echo "Erro: a wordlist tem menos de $WORDS_COUNT palavras."
  exit 1
fi

echo "Wordlist escolhida:"
echo "  $WORDLIST_FILE"
echo
echo "24 palavras geradas (número da linha original):"
echo

# Numera o arquivo inteiro, remove linhas vazias, sorteia
nl -ba "$WORDLIST_FILE" \
  | grep -vE '^\s*[0-9]+\s*$' \
  | shuf --random-source=/dev/urandom -n "$WORDS_COUNT"
