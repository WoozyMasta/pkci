#!/usr/bin/env bash
# PKCI (build helper)
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
# shellcheck source=/dev/null

set -aeuo pipefail
: "${PROJECT_NAME:=PKCI}"
: "${PROJECT_VERSION:=}"
: "${PROJECT_DESCRIPTION:=Pumped Kaniko Container Image for Continuous Integration}"
: "${PROJECT_AUTHOR:=WoozyMasta <me@woozymasta.ru>}"
: "${PROJECT_TYPES:=slim,normal,extra}"
: "${PROJECT_DOCKERFILE_TEMPLATE:=src/Dockerfile.j2}"
: "${PROJECT_README_TEMPLATE:=src/README.md.j2}"
: "${PROJECT_README_TEMPLATE_RU:=src/README-ru.md.j2}"
: "${PROJECT_VERSIONS:=versions.env}"
: "${PROJECT_UPX_ENABLED:=true}"
set +a

fail() { >&2 printf '\e[0;31mERROR\e[m: %s\n' "$*"; exit 1; }
info() { printf '\e[0;32mINFO\e[m: %s\n' "$*"; }

command -v podman &>/dev/null && cri=podman
command -v docker &>/dev/null && cri=docker
for cmd in templar $cri jq; do
  command -v $cmd &>/dev/null || fail "<$cmd> not found, install it first"
done

[ -r ./env ] && . ./env

if [ -r "$PROJECT_VERSIONS" ]; then
  set -a
  . "$PROJECT_VERSIONS"
  set +a
fi

for type in ${PROJECT_TYPES//,/ }; do
  name=${PROJECT_NAME,,}
  if [ "$type" == 'normal' ]; then
    file=Dockerfile
    image=$name:latest
    [ -n "$PROJECT_VERSION" ] && image_v=$name:$PROJECT_VERSION
  else
    file=Dockerfile.$type
    image=$name:$type-latest
    [ -n "$PROJECT_VERSION" ] && image_v=$name:$type-$PROJECT_VERSION
  fi

  PROJECT_TYPE=$type templar -t "$PROJECT_DOCKERFILE_TEMPLATE" -o $file ||
    fail "Cant render <$PROJECT_DOCKERFILE_TEMPLATE> for project type <$type>"
  info "Template rendered to file <$file> for project type <$type>"

  $cri build -f $file -t "$image" . ||
    fail "$cri cant build image <$image> from file <$file>"

  [ -n "${image_v:-}" ] && $cri tag "$image" "$image_v"

  size=$(
    $cri inspect "$image" 2>/dev/null | jq .[].Size | numfmt --to=iec ||
      fail "$cri cant inspect image <$image>"
  )
  reports+=("$size" "$image ${image_v:-}")

  declare PKCI_${type^^}_IMAGE_SIZE="$size"
  export PKCI_${type^^}_IMAGE_SIZE

  info "Container image <$image> ($size) build succes"
done

templar -t "$PROJECT_README_TEMPLATE" -o README.md ||
  fail "Cant render README.md from template <$PROJECT_README_TEMPLATE>"
templar -t "$PROJECT_README_TEMPLATE_RU" -o README-ru.md ||
  fail "Cant render README-ru.md from template <$PROJECT_README_TEMPLATE_RU>"
info "README.md rendered"

[ -x ./src/png-optimize.sh ] && ./src/png-optimize.sh

printf '\t\e[1;34m%-5s\e[m image: %s\n' "${reports[@]}"
info Done
