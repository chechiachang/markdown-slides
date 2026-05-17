#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/template/revealjs"
TARGET_DIR="${1:-./slides}"
TITLE="${2:-Markdown Slides}"

if [[ ! -d "${TEMPLATE_DIR}" ]]; then
  echo "Template directory not found: ${TEMPLATE_DIR}" >&2
  exit 1
fi

mkdir -p "${TARGET_DIR}"

if [[ -f "${TARGET_DIR}/slides.md" ]]; then
  echo "Refusing to overwrite existing file: ${TARGET_DIR}/slides.md" >&2
  exit 1
fi

sed "s/__TITLE__/${TITLE//\//\\/}/g" "${TEMPLATE_DIR}/slides.md" > "${TARGET_DIR}/slides.md"
sed "s/__TITLE__/${TITLE//\//\\/}/g" "${TEMPLATE_DIR}/index.html" > "${TARGET_DIR}/index.html"

echo "Created reveal.js markdown slide template at ${TARGET_DIR}"
