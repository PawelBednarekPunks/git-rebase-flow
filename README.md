# Onboarding Gitflow

Repozytorium do nauki procesu pracy z gałęziami, selektywnymi wydaniami
oraz promocją zmian przez środowiska DEV, UAT/PREPROD i PROD. To **materiał
szkoleniowy**, nie aplikacja: nie wymaga `npm install`, uruchamiania serwera
ani dostępu do infrastruktury wdrożeniowej.

Zacznij od [przewodnika Gitflow](docs/gitflow.md): opisuje rolę `main`,
`develop`, gałęzi zadaniowych i release, PR, tagi, deploymenty oraz
sytuacje brzegowe. W tej kopii repo pipeline'y i środowiska są **opisanym
procesem docelowym**, a nie działającą konfiguracją CI/CD.

Po lekturze rozwiąż [laboratorium sytuacji brzegowych](docs/cwiczenia-gitflow.md):
cztery zadania w izolowanych repozytoriach, z podpowiedziami i skryptem
sprawdzającym wynik. Nie zmieniają tego repo ani zdalnych gałęzi.

## Przed rozpoczęciem

Potrzebujesz Gita i dostępu do odczytu tego repo na GitHubie. Komendy
poniżej wykonuj w swoim klonie; ćwiczenie niczego nie wypycha i nie zmienia
chronionych gałęzi. Jeśli pracujesz w worktree, używaj katalogu przypisanego
do sesji. Nie próbuj przełączać gałęzi już otwartej w innym worktree.

## Ćwiczenie: odczytaj prawdziwą historię wydania

Przejdź kroki w kolejności (ok. 10 minut):

1. Pobierz aktualne referencje i znajdź merge commity wydań na `main`:

   ```bash
   git fetch origin --prune
   git log --first-parent --oneline origin/main
   ```

2. Obejrzyj graf historii oraz wydanie `0.2`:

   ```bash
   git log --all --graph --oneline --decorate -30
   git show --first-parent --stat --oneline 339affb
   git log --oneline 339affb^1..339affb^2
   ```

   Pierwszy rodzic merge commita to poprzedni `main`; drugi wskazuje gałąź
   release. Ustal, które dwa zadania weszły do `0.2` i dlaczego nie należy
   dodawać całego `develop` do wydania.

3. Porównaj stan produkcyjny przed i po `0.2`, a potem sprawdź `0.3`:

   ```bash
   git diff --stat 339affb^1 339affb
   git show --first-parent --stat --oneline 8ea38c9
   ```

   Odpowiedź do samodzielnej weryfikacji: wydanie `0.2` obejmuje
   `feature/EF-3` i `feature/EF-4`; pierwsze dodało `3.tx`, drugie zmieniło
   ówczesny README. `feature/EF-5` weszło dopiero w `0.3`.

4. Przejdź przez [kroki przygotowania wydania](docs/gitflow.md#3-zbuduj-paczkę-release)
   i odpowiedz: skąd powstaje release, jaki PR trafia na DEV, jaki tag
   oznacza kandydata na UAT oraz dlaczego PROD używa tego samego artefaktu?
   Ćwiczenie jest **tylko do odczytu**; nie twórz ani nie wypychaj tagów.

Przykładowe pliki `.tx` widoczne w starszych commitach zostały usunięte z
bieżącej gałęzi, ale są zachowane w historii Gita na potrzeby tego ćwiczenia.
SHA przykładów pochodzą z dotychczasowej historii tego repo.

## Dalej w projekcie

Przed pracą w repozytorium aplikacji poproś opiekuna o dostęp, wskazanie
aktualnych środowisk i obowiązującej polityki PR. Ten materiał wyjaśnia
model pracy, ale nie nadaje uprawnień do resetowania `develop`, tagowania
wydań ani wdrożeń produkcyjnych.
