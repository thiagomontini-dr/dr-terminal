#!/usr/bin/env bash
#
# seed-zoxide.sh
# Popula o banco do zoxide com as pastas-pai indicadas e suas subpastas
# de primeiro nivel, para que os atalhos de "cd por trecho do nome" ja
# funcionem em uma maquina nova sem precisar visitar cada pasta manualmente.
#
# Uso:
#   ./seed-zoxide.sh                       # usa as pastas padrao (abaixo)
#   ./seed-zoxide.sh Projects Work ~/dev   # usa as pastas informadas
#
# As pastas podem ser relativas a HOME (ex.: "Projects") ou caminhos
# absolutos (ex.: "/opt/apps"). Pastas inexistentes sao ignoradas.

set -euo pipefail

# Pastas-pai padrao (relativas a HOME). Sobrescreva passando argumentos.
DEFAULT_DIRS=(Projects Desktop Documents Downloads)

# Verifica se o zoxide esta instalado.
if ! command -v zoxide >/dev/null 2>&1; then
  echo "Erro: zoxide nao encontrado no PATH." >&2
  echo "Instale em https://github.com/ajeetdsouza/zoxide e tente novamente." >&2
  exit 1
fi

# Define a lista de pastas-pai: argumentos da linha de comando ou padrao.
if [ "$#" -gt 0 ]; then
  parents=("$@")
else
  parents=("${DEFAULT_DIRS[@]}")
fi

registered=0
skipped=0

for entry in "${parents[@]}"; do
  # Resolve caminho: absoluto usa como esta; relativo assume dentro de HOME.
  case "$entry" in
    /*) base="$entry" ;;
    ~*) base="${entry/#\~/$HOME}" ;;
    *)  base="$HOME/$entry" ;;
  esac

  if [ ! -d "$base" ]; then
    echo "IGNORADA  $base (nao existe)"
    skipped=$((skipped + 1))
    continue
  fi

  # Registra a propria pasta-pai.
  zoxide add "$base"
  registered=$((registered + 1))

  # Registra cada subpasta de primeiro nivel, exceto ocultas.
  while IFS= read -r sub; do
    zoxide add "$sub"
    registered=$((registered + 1))
  done < <(find "$base" -mindepth 1 -maxdepth 1 -type d ! -name '.*')

  echo "OK        $base"
done

echo ""
echo "Concluido: $registered pastas registradas, $skipped pastas-pai ignoradas."
echo "Total atual no banco do zoxide: $(zoxide query --list | wc -l | tr -d ' ')"
