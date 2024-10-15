#!/usr/bin/env bash
# Usage: $0 [-v] [-q] <targetfile> [-s tool] tool [arguments ...]

verbose=1
if [[ "$1" == "-v" ]]; then
    verbose=2
    shift
fi
if [[ "$1" == "-q" ]]; then
    verbose=0
    shift
fi

file="${1%.*}"
if [[ "$2" == "-s" ]]; then
    stage="$3"
    shift 3
else
    stage="$2"
    shift 1
fi

report() {
    status="$1"
    if [[ "$verbose" -eq 1 ]]; then
        [[ "$status" -eq 0 ]] && res="\e[32mOK\e[0m" || res="\e[31mFAIL\e[0m"
        printf "${file}: \e[35m${stage}\e[0m ... ${res}\n" 1>&2
    fi
    exit "$status"
}

if [[ -z "$TRACE_FILE" ]]; then
    if [[ "$1" == "!" ]]; then
        shift
        ! "$@"
    else
        "$@"
    fi
    report "$?"
fi

tmp=$(mktemp)
trap 'rm -f $tmp' EXIT
set -o pipefail
if [[ "$1" == "!" ]]; then
    shift
    ! "$@"
else
    "$@"
fi > >(tee -a "$tmp") 2> >(tee -a "$tmp" 1>&2)
status="$?"
if [[ -n "$TRACE_FILE" ]]; then
    echo "$file $stage $status" >>"$TRACE_FILE"
    if [[ "$status" -ne 0 ]]; then
        tail -16 "$tmp" | while read -r line; do
            echo "$file $stage $line" >>"$TRACE_FILE"
        done
    fi
fi
[[ "$verbose" -gt 1 || "$status" -ne 0 ]] && cat "$tmp"
report "$?"
