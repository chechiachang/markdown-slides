#!/usr/bin/env bash
set -euo pipefail

readonly REPO_URL="https://github.com/chechiachang/markdown-slides.git"
readonly SKILL_NAME="markdown-slides-sync"
readonly SKILL_REL_PATH="skills/${SKILL_NAME}"

usage() {
  cat <<'EOF'
Usage:
  sync_markdown_slides.sh <command> [options]

Commands:
  install-skill  Install skills/markdown-slides-sync into local ./skills
  sync-talk      Sync upstream talk/*.md into local ./markdown-slides
  bootstrap      Run install-skill then sync-talk

Options:
  --repo-root <path>  Target repository root (default: .)
  --source-repo-url <url-or-path> Source repo URL/path (default: https://github.com/chechiachang/markdown-slides.git)
  --skills-dir <path> Skills destination (default: <repo-root>/skills)
  --output-dir <path> Talk destination (default: <repo-root>/markdown-slides)
  --force             Replace existing installed skill directory
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_git() {
  command -v git >/dev/null 2>&1 || die "git is required"
}

clone_sparse() {
  local repo_url="$1"
  local clone_dir="$2"
  shift 2
  git clone --depth=1 --filter=blob:none --sparse "$repo_url" "$clone_dir" >/dev/null 2>&1
  git -C "$clone_dir" sparse-checkout set "$@"
}

copy_talk_files() {
  local source_talk_dir="$1"
  local output_dir="$2"
  local copied=0
  local source_file

  mkdir -p "$output_dir"
  shopt -s nullglob
  for source_file in "$source_talk_dir"/*.md; do
    cp "$source_file" "$output_dir/"
    copied=$((copied + 1))
  done
  shopt -u nullglob

  [ "$copied" -gt 0 ] || die "no .md files found in upstream talk directory"
  printf 'Synced %d talk file(s) to %s\n' "$copied" "$output_dir"
}

main() {
  require_git
  [ "$#" -ge 1 ] || {
    usage
    exit 1
  }

  local command="$1"
  shift

  local repo_root
  repo_root="$(pwd)"
  local source_repo_url="$REPO_URL"
  local skills_dir=""
  local output_dir=""
  local force=0

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --repo-root)
        [ "$#" -ge 2 ] || die "--repo-root requires a value"
        repo_root="$2"
        shift 2
        ;;
      --skills-dir)
        [ "$#" -ge 2 ] || die "--skills-dir requires a value"
        skills_dir="$2"
        shift 2
        ;;
      --source-repo-url)
        [ "$#" -ge 2 ] || die "--source-repo-url requires a value"
        source_repo_url="$2"
        shift 2
        ;;
      --output-dir)
        [ "$#" -ge 2 ] || die "--output-dir requires a value"
        output_dir="$2"
        shift 2
        ;;
      --force)
        force=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "unknown option: $1"
        ;;
    esac
  done

  [ -d "$repo_root" ] || die "repo root does not exist: $repo_root"
  [ -n "$skills_dir" ] || skills_dir="$repo_root/skills"
  [ -n "$output_dir" ] || output_dir="$repo_root/markdown-slides"

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  case "$command" in
    install-skill)
      mkdir -p "$skills_dir"
      local dest_skill_dir="$skills_dir/$SKILL_NAME"
      if [ -e "$dest_skill_dir" ]; then
        if [ "$force" -eq 1 ]; then
          rm -rf "$dest_skill_dir"
        else
          die "destination exists: $dest_skill_dir (use --force to replace)"
        fi
      fi

      clone_sparse "$source_repo_url" "$tmp_dir/repo" "$SKILL_REL_PATH"
      local src_skill_dir="$tmp_dir/repo/$SKILL_REL_PATH"
      [ -d "$src_skill_dir" ] || die "source skill path not found: $SKILL_REL_PATH"
      cp -R "$src_skill_dir" "$dest_skill_dir"
      printf 'Installed skill to %s\n' "$dest_skill_dir"
      ;;
    sync-talk)
      clone_sparse "$source_repo_url" "$tmp_dir/repo" "talk"
      copy_talk_files "$tmp_dir/repo/talk" "$output_dir"
      ;;
    bootstrap)
      mkdir -p "$skills_dir"
      local dest_bootstrap_skill="$skills_dir/$SKILL_NAME"
      if [ -e "$dest_bootstrap_skill" ]; then
        if [ "$force" -eq 1 ]; then
          rm -rf "$dest_bootstrap_skill"
        else
          die "destination exists: $dest_bootstrap_skill (use --force to replace)"
        fi
      fi

      clone_sparse "$source_repo_url" "$tmp_dir/repo" "$SKILL_REL_PATH" "talk"
      local src_bootstrap_skill="$tmp_dir/repo/$SKILL_REL_PATH"
      [ -d "$src_bootstrap_skill" ] || die "source skill path not found: $SKILL_REL_PATH"
      cp -R "$src_bootstrap_skill" "$dest_bootstrap_skill"
      printf 'Installed skill to %s\n' "$dest_bootstrap_skill"

      copy_talk_files "$tmp_dir/repo/talk" "$output_dir"
      ;;
    *)
      usage
      die "unknown command: $command"
      ;;
  esac
}

main "$@"
