#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! "$1" =~ ^[1-4]$ ]]; then
    printf 'Użycie: bash training/start.sh <numer 1-4>\n' >&2
    exit 2
fi

scenario=$1
lab=$(mktemp -d "${TMPDIR:-/tmp}/gitflow-lab.XXXXXX")
repo="$lab/repo"
git init -q -b main "$repo"
git -C "$repo" config user.name "Gitflow Lab"
git -C "$repo" config user.email "gitflow-lab@example.invalid"
printf '%s\n' "$scenario" > "$lab/.gitflow-lab"
printf 'base version\n' > "$repo/app.txt"
git -C "$repo" add app.txt
git -C "$repo" commit -qm "base: initial application"

commit() {
    git -C "$repo" add .
    git -C "$repo" commit -qm "$1"
}

case "$scenario" in
    1)
        git -C "$repo" switch -qc feature/EF-101
        printf 'EF-101 selected\n' > "$repo/selected.txt"
        commit "feat(EF-101): add selected change"
        git -C "$repo" switch -q main
        git -C "$repo" switch -qc feature/EF-102
        printf 'EF-102 not ready\n' > "$repo/unreleased.txt"
        commit "feat(EF-102): add unreleased change"
        git -C "$repo" switch -qc develop main
        git -C "$repo" merge -q --no-ff feature/EF-101 -m "Merge EF-101 into develop"
        git -C "$repo" merge -q --no-ff feature/EF-102 -m "Merge EF-102 into develop"
        git -C "$repo" switch -qc release/1.0.0 main
        ;;
    2)
        printf 'timeout=10\nretry=0\n' > "$repo/config.ini"
        commit "base: add configuration"
        git -C "$repo" switch -qc feature/EF-103
        printf 'timeout=20\nretry=2\n' > "$repo/config.ini"
        commit "feat(EF-103): add retry policy"
        git -C "$repo" switch -q main
        printf 'timeout=30\nretry=0\n' > "$repo/config.ini"
        commit "fix: increase production timeout"
        git -C "$repo" switch -q feature/EF-103
        ;;
    3)
        git -C "$repo" switch -qc release/1.1.0
        printf 'first candidate\n' > "$repo/candidate.txt"
        commit "release: initial UAT candidate"
        git -C "$repo" tag -a u1.1.0 -m "UAT 1.1.0"
        git -C "$repo" switch -qc release/1.1.1
        printf 'fixed candidate\n' > "$repo/candidate.txt"
        commit "fix: correct candidate after UAT"
        ;;
    4)
        git -C "$repo" switch -qc release/1.2.0
        printf 'release payload 1.2.0\n' > "$repo/app.txt"
        commit "release: prepare 1.2.0"
        git -C "$repo" tag -a u1.2.0 -m "UAT 1.2.0"
        mkdir -p "$lab/artifacts" "$lab/deployments"
        git -C "$repo" show u1.2.0:app.txt > "$lab/artifacts/u1.2.0.bundle"
        cp "$lab/artifacts/u1.2.0.bundle" "$lab/deployments/uat.bundle"
        git -C "$repo" switch -q main
        git -C "$repo" merge -q --no-ff release/1.2.0 -m "Merge release 1.2.0 into main"
        ;;
esac

printf '%s\n' "$lab"
