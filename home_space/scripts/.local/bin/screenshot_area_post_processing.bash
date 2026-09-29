#!/bin/bash
set -euo pipefail
declare -r file="$HOME/Pictures/shot_$(date +%s).png"
grim -g "$(slurp)" "$file" && swappy -f "$file"
