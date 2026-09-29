#!/usr/bin/env bash

for pkg in home_space/*; do
  [[ -d "$pkg" && ! -L "$pkg" ]] || continue

  cat >"$pkg/.stow-local-ignore" <<'EOF'
^/\.stowignore$
^/\.stowrc$
^/(.*\/)?\.stowkeep$
EOF

  printf 'Обновлён: %s\n' "$pkg/.stow-local-ignore"
done
