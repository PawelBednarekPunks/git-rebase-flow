#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 || ! "$1" =~ ^[1-4]$ || ! -d "$2/repo/.git" ]]; then
    printf 'Użycie: bash training/check.sh <numer 1-4> <ścieżka-laboratorium>\n' >&2
    exit 2
fi

scenario=$1
lab=$2
repo="$lab/repo"

fail() {
    printf 'DO POPRAWY: %s\n' "$1" >&2
    exit 1
}

if [[ ! -f "$lab/.gitflow-lab" || $(cat "$lab/.gitflow-lab") != "$scenario" ]]; then
    fail "Podaj katalog laboratorium utworzony dla scenariusza $scenario."
fi

case "$scenario" in
    1)
        git -C "$repo" merge-base --is-ancestor main release/1.0.0 ||
            fail "Release musi wywodzić się z main."
        git -C "$repo" merge-base --is-ancestor feature/EF-101 release/1.0.0 ||
            fail "Wybrane zadanie EF-101 nie zostało scalone do release."
        if git -C "$repo" merge-base --is-ancestor feature/EF-102 release/1.0.0; then
            fail "Do release trafiło niewybrane zadanie EF-102."
        fi
        [[ $(git -C "$repo" diff --name-only main release/1.0.0) == "selected.txt" ]] ||
            fail "Release powinien zmieniać względem main tylko selected.txt."
        [[ $(git -C "$repo" show release/1.0.0:selected.txt) == "EF-101 selected" ]] ||
            fail "Zawartość selected.txt różni się od przetestowanej zmiany."
        ;;
    2)
        git -C "$repo" merge-base --is-ancestor main feature/EF-103 ||
            fail "Zrebazuj feature/EF-103 na aktualny main."
        [[ $(git -C "$repo" show feature/EF-103:config.ini) == $'timeout=30\nretry=2' ]] ||
            fail "Zachowaj timeout=30 z main oraz retry=2 z zadania."
        ;;
    3)
        [[ $(git -C "$repo" log -1 --format=%s 'u1.1.0^{commit}') == \
            "release: initial UAT candidate" ]] ||
            fail "Nie przesuwaj starego taga u1.1.0."
        [[ $(git -C "$repo" cat-file -t refs/tags/u1.1.1 2>/dev/null) == "tag" ]] ||
            fail "Utwórz anotowany tag u1.1.1."
        [[ $(git -C "$repo" rev-parse 'u1.1.1^{commit}') == \
            $(git -C "$repo" rev-parse release/1.1.1) ]] ||
            fail "Tag u1.1.1 musi wskazywać poprawionego kandydata."
        ;;
    4)
        git -C "$repo" merge-base --is-ancestor u1.2.0 main ||
            fail "Kandydat UAT musi być przodkiem main."
        git -C "$repo" diff --quiet u1.2.0 main ||
            fail "Drzewo plików main musi być identyczne z kandydatem UAT."
        [[ $(git -C "$repo" cat-file -t refs/tags/p1.2.0 2>/dev/null) == "tag" ]] ||
            fail "Utwórz anotowany tag p1.2.0."
        [[ $(git -C "$repo" rev-parse 'p1.2.0^{commit}') == \
            $(git -C "$repo" rev-parse main) ]] ||
            fail "Tag p1.2.0 musi wskazywać commit main."
        [[ -f "$lab/deployments/prod.bundle" ]] ||
            fail "Brakuje artefaktu na PROD: deployments/prod.bundle."
        cmp -s <(git -C "$repo" show u1.2.0:app.txt) "$lab/artifacts/u1.2.0.bundle" ||
            fail "Zapisany artefakt nie odpowiada kandydatowi oznaczonemu u1.2.0."
        cmp -s "$lab/artifacts/u1.2.0.bundle" "$lab/deployments/uat.bundle" ||
            fail "Artefakt UAT nie zgadza się z zapisanym kandydatem."
        cmp -s "$lab/artifacts/u1.2.0.bundle" "$lab/deployments/prod.bundle" ||
            fail "Na PROD musi trafić ten sam artefakt co na UAT."
        ;;
esac

[[ -z $(git -C "$repo" status --porcelain) ]] ||
    fail "Zapisz lub odrzuć niezacommitowane zmiany w repo ćwiczeniowym."

printf 'OK: scenariusz %s ukończony.\n' "$scenario"
