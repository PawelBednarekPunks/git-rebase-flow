# Laboratorium Gitflow: sytuacje brzegowe

Ćwiczenia uruchamiają **osobne lokalne repozytoria** w katalogu tymczasowym.
Nie dotykają historii ani gałęzi repo onboardingowego, nie korzystają z
sieci i niczego nie wypychają. Wystarczą Git i Bash. Każde zadanie można
powtórzyć, uruchamiając `start.sh` ponownie; zostanie utworzony nowy katalog.
Katalogów laboratorium skrypty nie usuwają automatycznie.

W katalogu repo onboardingowego uruchom:

```bash
LAB=$(bash training/start.sh 1)
echo "$LAB"
git -C "$LAB/repo" log --all --graph --oneline --decorate
# Rozwiąż zadanie, a potem:
bash training/check.sh 1 "$LAB"
```

`LAB` to ścieżka do izolowanego katalogu. Dla każdego kolejnego zadania
ustaw nowe `LAB=$(bash training/start.sh NUMER)`; wywołuj polecenia Gita
przez `git -C "$LAB/repo" ...` albo przejdź do tego repo w osobnym terminalu.
`check.sh` **niczego nie zmienia**: zwraca `OK` lub konkretny warunek do
poprawy. Nie wykonuj poniższych operacji na prawdziwym projekcie.

## 1. DEV zawiera zadanie niewchodzące do wydania

**Stan:** `main` to produkcja; `develop` ma `EF-101` i `EF-102`. Pusta gałąź
`release/1.0.0` pochodzi z `main`. Do wydania wybrano wyłącznie `EF-101`.

**Twoje zadanie:** scal `feature/EF-101` do `release/1.0.0`. Nie dołączaj
`develop` ani `EF-102`. Sprawdź listę zmienionych plików względem `main`.

```bash
LAB=$(bash training/start.sh 1)
git -C "$LAB/repo" log --all --graph --oneline --decorate
# Wykonaj merge w repo ćwiczeniowym.
bash training/check.sh 1 "$LAB"
```

<details>
<summary>Podpowiedź</summary>

Użyj `git -C "$LAB/repo" switch release/1.0.0`, a potem merge wybranej
gałęzi zadaniowej. `git diff --name-only main release/1.0.0` pokaże zakres
wydania.

</details>

<details>
<summary>Rozwiązanie (otwórz po próbie)</summary>

```bash
git -C "$LAB/repo" switch release/1.0.0
git -C "$LAB/repo" merge --no-ff feature/EF-101 -m "Merge EF-101 into release"
git -C "$LAB/repo" diff --name-only main release/1.0.0
bash training/check.sh 1 "$LAB"
```

</details>

## 2. Konflikt po zmianie main

**Stan:** na `main` timeout wynosi `30`, a zadanie `EF-103` powstało
wcześniej ze zmianą timeoutu i dodaniem retry. Aktualizacja feature z `main`
spowoduje konflikt w `config.ini`.

**Twoje zadanie:** zrebazuj `feature/EF-103` na `main`. Zachowaj decyzję
produkcyjną `timeout=30` i zmianę zadania `retry=2`. Dokończ rebase i zapisz
rozwiązanie w commicie.

```bash
LAB=$(bash training/start.sh 2)
git -C "$LAB/repo" rebase main
# Konflikt jest oczekiwany; rozwiąż go w "$LAB/repo/config.ini".
bash training/check.sh 2 "$LAB"
```

<details>
<summary>Podpowiedź</summary>

Po edycji pliku wykonaj `git -C "$LAB/repo" add config.ini` i
`GIT_EDITOR=true git -C "$LAB/repo" rebase --continue`. `GIT_EDITOR=true`
pozwoli zachować poprzedni komunikat commita bez otwierania edytora.

</details>

<details>
<summary>Rozwiązanie (otwórz po próbie)</summary>

Plik `config.ini` po rozwiązaniu konfliktu powinien zawierać dokładnie:

```ini
timeout=30
retry=2
```

Zapisz go, wykonaj `git -C "$LAB/repo" add config.ini`, następnie
`GIT_EDITOR=true git -C "$LAB/repo" rebase --continue` i ponów checker.

</details>

## 3. Kandydat UAT wymaga poprawki po otagowaniu

**Stan:** `u1.1.0` jest anotowanym tagiem pierwszego kandydata. Poprawka
jest już na `release/1.1.1`; starsza gałąź `release/1.1.0` pozostaje
zachowana.

**Twoje zadanie:** oznacz poprawionego kandydata nowym anotowanym tagiem
`u1.1.1`, nie przesuwając `u1.1.0`. Sprawdź SHA obu tagów.

```bash
LAB=$(bash training/start.sh 3)
git -C "$LAB/repo" log --graph --all --oneline --decorate
# Dodaj tag na poprawionym kandydacie.
bash training/check.sh 3 "$LAB"
```

<details>
<summary>Podpowiedź</summary>

`git tag -a <nazwa> <commit> -m <opis>` tworzy anotowany tag; podaj
`release/1.1.1` jako commit. `git rev-parse 'u1.1.0^{commit}'` pokazuje
commit starego taga, a nie obiekt adnotacji.

</details>

<details>
<summary>Rozwiązanie (otwórz po próbie)</summary>

```bash
git -C "$LAB/repo" tag -a u1.1.1 release/1.1.1 -m "UAT 1.1.1"
git -C "$LAB/repo" rev-parse 'u1.1.0^{commit}' 'u1.1.1^{commit}'
bash training/check.sh 3 "$LAB"
```

</details>

## 4. UAT i PROD: różne commity, ten sam artefakt

**Stan:** `u1.2.0` oznacza kandydata UAT. `main` zawiera ten sam kod po
merge commicie, lecz ma inne SHA. Artefakt po UAT jest zapisany w
`$LAB/artifacts/u1.2.0.bundle` oraz wdrożony w
`$LAB/deployments/uat.bundle`. Nie ma jeszcze tagu produkcyjnego ani
artefaktu na PROD.

**Twoje zadanie:** sprawdź przodka i zgodność drzew, utwórz anotowany tag
`p1.2.0` na `main`, a do `deployments/prod.bundle` przenieś **ten sam**
artefakt. Nie buduj go ponownie z `main`.

```bash
LAB=$(bash training/start.sh 4)
git -C "$LAB/repo" log --graph --all --oneline --decorate
# Sprawdź kandydata, utwórz tag i promuj artefakt.
bash training/check.sh 4 "$LAB"
```

<details>
<summary>Podpowiedź</summary>

`git merge-base --is-ancestor u1.2.0 main` i
`git diff --exit-code u1.2.0 main` muszą zakończyć się powodzeniem.
Przeniesienie artefaktu można wykonać przez `cp` z katalogu `artifacts`;
`cmp` porówna zawartość UAT i PROD.

</details>

<details>
<summary>Rozwiązanie (otwórz po próbie)</summary>

```bash
git -C "$LAB/repo" merge-base --is-ancestor u1.2.0 main
git -C "$LAB/repo" diff --exit-code u1.2.0 main
git -C "$LAB/repo" tag -a p1.2.0 main -m "Production 1.2.0"
cp "$LAB/artifacts/u1.2.0.bundle" "$LAB/deployments/prod.bundle"
cmp "$LAB/deployments/uat.bundle" "$LAB/deployments/prod.bundle"
bash training/check.sh 4 "$LAB"
```

</details>

Po ukończeniu odpowiedz sobie: dlaczego nie wystarcza równość drzew plików
`u1.2.0` i `p1.2.0`, jeśli pipeline na PROD buduje artefakt od nowa?
