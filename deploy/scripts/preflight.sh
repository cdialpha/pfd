#!/usr/bin/env bash
set -euo pipefail 
shopt -s inherit_errexit
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
load_env

require() {
    local missing=() 
    local cmd 
    for cmd in "$@"; do 
      command -v -- "$cmd" &> /dev/null || missing+=("$cmd")
    done
    if ((${#missing[@]} > 0 )); then
        die "missing required dep(s): ${missing[*]}"
    fi 
}

check_files() {
    local files=(cluster-config.yaml)
    for file in "${files[@]}"; do
        if [ ! -e "$file" ]; then
            echo "Error: Required file or directory '$file' is missing." >&2
            exit 1
        fi
    done
}

main(){
    check_files
    mise install
    require kind kubectl helm cilium openssl
    ok "preflight complete"
}

main

# optional: extract version numbers from mise and export them as env vars
# mise ls | while read tool version _; do 
#     varname="${tool//-/_}" 
#     export "$varname"="$version"
#     echo "$varname=$version"
# done 
