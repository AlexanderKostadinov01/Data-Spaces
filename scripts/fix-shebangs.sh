#!/bin/bash
for f in ./scripts/*.sh; do
  if ! head -n 1 "$f" | grep -q '^#!'; then
    echo "Fixing $f"
    (echo '#!/bin/bash'; cat "$f") > "$f.new" && mv "$f.new" "$f"
  fi
done