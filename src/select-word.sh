#!/usr/bin/env bash
set -euo pipefail

WORDLIST_DIR="./wordlist"

# --- validações ---
if [[ ! -d "$WORDLIST_DIR" ]]; then
  echo "Erro: diretório '$WORDLIST_DIR' não encontrado."
  exit 1
fi

mapfile -t FILES < <(find "$WORDLIST_DIR" -type f 2>/dev/null | sort)
if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Erro: nenhuma wordlist encontrada em '$WORDLIST_DIR'."
  exit 1
fi

# --- menu de seleção ---
echo "Selecione a wordlist:"
for i in "${!FILES[@]}"; do
  printf "  [%d] %s\n" "$((i+1))" "${FILES[$i]}"
done

echo
read -r -p "Digite o número da opção: " PICK

if ! [[ "$PICK" =~ ^[0-9]+$ ]] || (( PICK < 1 || PICK > ${#FILES[@]} )); then
  echo "Erro: opção inválida."
  exit 1
fi

WORDLIST_FILE="${FILES[$((PICK-1))]}"

# --- carrega wordlist preservando NUMERO DA LINHA ORIGINAL ---
declare -A WORD_BY_ORIG_LINE=()
declare -a ORIG_LINES=() # só para exibir faixa válida
orig=0
while IFS= read -r line || [[ -n "$line" ]]; do
  orig=$((orig+1))
  # remove espaços nas pontas
  trimmed="$line"
  trimmed="${trimmed#"${trimmed%%[![:space:]]*}"}"
  trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

  # ignora vazias
  [[ -z "$trimmed" ]] && continue

  WORD_BY_ORIG_LINE["$orig"]="$trimmed"
  ORIG_LINES+=("$orig")
done < "$WORDLIST_FILE"

if [[ ${#ORIG_LINES[@]} -eq 0 ]]; then
  echo "Erro: wordlist selecionada não possui linhas válidas (não vazias)."
  exit 1
fi

MIN_LINE="${ORIG_LINES[0]}"
MAX_LINE="${ORIG_LINES[${#ORIG_LINES[@]}-1]}"

echo
echo "Wordlist selecionada:"
echo "  $WORDLIST_FILE"
echo
echo "Digite números de linha (da linha ORIGINAL do arquivo)."
echo "Dicas:"
echo "  - Você pode digitar 1 número por vez, ou vários separados por espaço."
echo "  - 'q' para sair."
echo
echo "Faixa de linhas com conteúdo (não vazias): $MIN_LINE .. $MAX_LINE"
echo

# --- loop interativo ---
while true; do
  read -r -p "> " INPUT || true

  # sair
  if [[ "$INPUT" == "q" || "$INPUT" == "quit" || "$INPUT" == "exit" ]]; then
    echo "Encerrado."
    break
  fi

  # vazio: continua
  [[ -z "${INPUT//[[:space:]]/}" ]] && continue

  # processa múltiplos tokens
  for tok in $INPUT; do
    if ! [[ "$tok" =~ ^[0-9]+$ ]]; then
      echo "Inválido: '$tok' (use apenas números, ou 'q' para sair)."
      continue
    fi

    if [[ -n "${WORD_BY_ORIG_LINE[$tok]+x}" ]]; then
      printf "Linha %s -> %s\n" "$tok" "${WORD_BY_ORIG_LINE[$tok]}"
    else
      echo "Linha $tok -> (sem palavra: linha vazia ou inexistente na wordlist)"
    fi
  done
done
