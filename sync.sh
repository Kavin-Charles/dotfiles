#!/bin/bash
cd /home/kavin/Projects/dotfiles

if [ -z "$(git status --porcelain)" ]; then
    exit 0
fi

git add -A
git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main
