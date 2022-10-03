#!/usr/bin/env bash
# PKCI (get updates)
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

gh_tools=(
  GoogleContainerTools/kaniko
  sigstore/cosign
#  notaryproject/notary
  upx/upx
  robxu9/bash-static
  hadolint/hadolint
  christian-korneck/docker-pushrm
  stedolan/jq
  moparisthebest/static-curl
  google/go-containerregistry
  proctorlabs/templar
  XAMPPRocky/tokei
  mikefarah/yq
  hairyhenderson/gomplate
  kubernetes/kubernetes
  helm/helm
  aquasecurity/trivy
  stackrox/kube-linter
  controlplaneio/kubesec
  grafana/tanka
  jsonnet-bundler/jsonnet-bundler

  mirror/busybox
  ep76/docker-openssl-static
)

latest_gh_release() {
  basename "$(
    curl -sf -o/dev/null -w '%{redirect_url}' \
      "https://github.com/$1/releases/latest"
  )" | \
  prepare_version_number
}

latest_gh_tag() {
  curl -sfL "https://api.github.com/repos/$1/tags" | \
  jq -er '.[0].name' | \
  prepare_version_number
}

prepare_version_number() {
  sed -e 's/^\(v\|jq-\)\.\{0,1\}//' -e 's/_/./g'
}

latest_gr_version() {
  local version
  version=$(latest_gh_release "$1")
  if [ "$version" == releases ]; then
    latest_gh_tag "$1"
  else
    echo "$version"
  fi
}

for item in "${gh_tools[@]}"; do
  printf '%s: %s\n' "$(basename "$item")" "$(latest_gr_version "$item")"
done

# Notary not have latest release in GitHub
printf '%s: %s\n' notary "$(latest_gh_tag notaryproject/notary)"
