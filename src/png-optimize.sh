#!/usr/bin/env bash
# PKCI (pre-commit png optimize)
#
# Pumped Kaniko Container Image or Pumped Kaniko for Continuous Integration
# =========================================================================
#
# License: MIT
# Copyright 2022 WoozyMasta <me@woozymasta.ru>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#
# =========================================================================
set -euo pipefail

for cmd in git pngquant optipng; do
  command -v $cmd &>/dev/null || {
    printf '\e[1;31m%s\e[m\n' "ERROR: You must install $cmd first!"
    exit 1
  }
done

git ls-files --others --modified --exclude-standard ||
  { echo 'nothing to do'; exit 0; }

for file in $(git ls-files --others --modified --exclude-standard -- *.png); do

  [ ! -f "$file" ] && continue

  size_b=$( stat --printf="%s" "$file" | numfmt --to=iec-i )
  printf '%s\e[1;33m%s\e[m\n' 'Optimize and Quantizes file: ' "$file"
  pngquant --force --speed 1 "$file"

  if [[ "$file" == *.drawio.png ]]; then
    file_optimized="${file%.drawio.png}.png"
    mv "${file%.png}-fs8.png" "$file_optimized"
  else
    file_optimized="$file"
    mv "${file%.png}-fs8.png" "$file_optimized"
  fi

  optipng -o5 -clobber -strip all "$file_optimized"
  size_a=$( stat --printf="%s" "$file_optimized" | numfmt --to=iec-i )
  opimized_log+=("$file_optimized" "$size_b" "$size_a")

done

printf 'File optimized: \e[34m%-30s \e[1;32m%s\e[m/\e[1;31m%s\e[m\n' \
  "${opimized_log[@]}"

printf '\n\e[1;32m%s\e[m\n' "Done."
