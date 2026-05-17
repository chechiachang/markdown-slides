---
name: markdown-slides-sync
description: Install and update the markdown-slides sync skill in a repository, and fetch `talk/*.md` from `https://github.com/chechiachang/markdown-slides.git` into `./markdown-slides`. Use when a repository needs local copies of the markdown-slides talk templates/checklists or needs this skill installed under `./skills`.
---

# Markdown Slides Sync

Use this skill to install itself into `./skills` and to sync upstream talk markdown files into `./markdown-slides`.

## Source And Targets

- Upstream repository: `https://github.com/chechiachang/markdown-slides.git`
- Upstream files: `talk/*.md`
- Local talk destination default: `./markdown-slides`
- Local skill destination default: `./skills/markdown-slides-sync`

## Install Skill Into Another Repo

Run this from the other repository root:

```bash
tmp_dir="$(mktemp -d)"
git clone --depth=1 --filter=blob:none --sparse https://github.com/chechiachang/markdown-slides.git "$tmp_dir/repo"
git -C "$tmp_dir/repo" sparse-checkout set skills/markdown-slides-sync
mkdir -p ./skills
cp -R "$tmp_dir/repo/skills/markdown-slides-sync" ./skills/
rm -rf "$tmp_dir"
```

## Sync Talk Files

Run this from the target repository root after installing the skill:

```bash
./skills/markdown-slides-sync/scripts/sync_markdown_slides.sh sync-talk --repo-root .
```

## Script Commands

Use `./skills/markdown-slides-sync/scripts/sync_markdown_slides.sh <command> [options]`.

Commands:
- `install-skill`: Install `skills/markdown-slides-sync` from upstream into local `./skills`.
- `sync-talk`: Copy upstream `talk/*.md` into local `./markdown-slides`.
- `bootstrap`: Run `install-skill` then `sync-talk`.

Options:
- `--repo-root <path>`: Target repository root. Default is current directory.
- `--source-repo-url <url-or-path>`: Override source repository. Default is `https://github.com/chechiachang/markdown-slides.git`.
- `--skills-dir <path>`: Override skills destination. Default is `<repo-root>/skills`.
- `--output-dir <path>`: Override talk destination. Default is `<repo-root>/markdown-slides`.
- `--force`: Replace existing local skill directory on install.
