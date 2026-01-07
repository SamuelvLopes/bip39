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
echo "24 palavras geradas:"
echo

# Seleciona e numera as palavras
grep -v '^\s*$' "$WORDLIST_FILE" \
  | shuf --random-source=/dev/urandom -n "$WORDS_COUNT" \
  | nl -w2 -s'. '
