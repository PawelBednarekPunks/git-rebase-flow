# Git flow: zadania wybierane do wydania

To repozytorium jest przykładem przepływu **main-centric**. `main` jest bazą
nowych zadań i wydań, a `develop` służy do integracji i testów. Do wydania
trafiają **wybrane gałęzie zadaniowe**, nie cała zawartość `develop`. Nie jest
to klasyczny Git Flow, w którym `release/*` powstaje z `develop`.

```text
origin/main ──┬── feature/EF-1 ── PR ──> develop (testy)
              ├── feature/EF-2 ── PR ──> develop (testy)
              └── release/0.4 <── EF-1, EF-2 (wybrane zadania)
                       │
                       └── PR ──> main (produkcja)
                                      │
                                      └── synchronizacja develop
```

| Gałąź | Rola |
| --- | --- |
| `main` | Produkcja i baza dla nowych zadań oraz wydań. |
| `develop` | Środowisko integracyjne; może zawierać zadania niewchodzące do najbliższego wydania. |
| `feature/*`, `fix/*` | Zadania tworzone z aktualnego `origin/main`; zachowywane do czasu wydania. |
| `release/<wersja>` | Paczka utworzona z `origin/main`, zawierająca wyłącznie zakwalifikowane zadania. |

W tym repo istnieją `main` i `develop`, ale nie ma gałęzi `uat`. Jeśli projekt
ma dodatkowe środowisko UAT, sposób jego aktualizacji trzeba ustalić osobno;
nie należy domyślnie przenosić tu procedury z innego repozytorium.

## 1. Rozpoczęcie zadania

Przykładowe nazwy to `feature/EF-6`, `fix/EF-7` i `release/0.4`. W nowej
gałęzi pracuj z aktualnego stanu zdalnego `main`:

```bash
git fetch origin --prune
git switch --create feature/EF-6 origin/main
# Po wprowadzeniu zmian:
git add <zmienione-pliki>
git commit -m "feat(EF-6): add example"
git push --set-upstream origin feature/EF-6
```

Przed aktualizacją lub przepisywaniem historii sprawdź, czy nie masz
niezapisanych zmian (`git status`). Jeśli `git fetch` się nie powiódł, nie
zakładaj, że lokalne referencje odzwierciedlają stan serwera.

## 2. Integracja i testy na develop

Otwórz PR z `feature/EF-6` do `develop`. Po review i wymaganych kontrolach
scal PR (merge commit), przetestuj zadanie na środowisku DEV. Jeśli wymaga
poprawki, wprowadź ją na gałęzi zadaniowej i otwórz kolejny PR do `develop`.
**Nie usuwaj gałęzi zadaniowej po PR do `develop`**: będzie jeszcze potrzebna
do wydania. Samo przejście testów DEV nie oznacza zakwalifikowania do release.

Nie merguj `develop` do gałęzi zadaniowej: znalazłyby się na niej inne,
potencjalnie niewydane zadania. Przed dodaniem zadania do wydania zaktualizuj
je względem produkcji:

```bash
git fetch origin
git switch feature/EF-6
git rebase origin/main
# Jeśli gałąź została już wypchnięta i rebase zmienił jej historię:
git push --force-with-lease origin feature/EF-6
```

Rozwiąż konflikty i uruchom odpowiednie kontrole przed wypchnięciem. Rebase
opublikowanej gałęzi uzgodnij z osobami pracującymi na niej; jeśli jest
chroniona lub współdzielona, nie wymuszaj jej nadpisania.

## 3. Przygotowanie wydania

Osoba odpowiedzialna za wydanie tworzy `release/<wersja>` **z `origin/main`**:

```bash
git fetch origin --prune
git switch --create release/0.4 origin/main
git push --set-upstream origin release/0.4
```

Otwórz osobny PR z każdego zatwierdzonego zadania do `release/0.4`, np.
`feature/EF-6 -> release/0.4`. Po review i CI scal wyłącznie zadania należące
do paczki (merge commit; w historii tego repo `release/0.1` i `release/0.2`
łączą wybrane gałęzie zadaniowe). Nie otwieraj PR `develop -> release/*`.
Przetestuj całą paczkę; poprawki wprowadź na odpowiedniej gałęzi zadaniowej
lub gałęzi release i uwzględnij je później na `develop`.

## 4. Wydanie na produkcję

Otwórz PR `release/0.4 -> main`, przejdź review i CI, a następnie scal przez
merge commit. Po weryfikacji wdrożenia można oznaczyć dokładny commit
produkcyjny anotowanym tagiem (jeśli projekt używa tagów wersji):

```bash
git fetch origin --tags
git tag -a v0.4 origin/main -m "Release 0.4"
git push origin v0.4
```

Sprawdź, czy `origin/main` wskazuje właśnie zaakceptowane wydanie i czy tag
`v0.4` jeszcze nie istnieje. Nie przesuwaj istniejących tagów. W repozytorium
historyczne wydania nie mają tagów; powyższy krok jest opcjonalną konwencją
dla kolejnych wersji.

## 5. Synchronizacja develop i niewydanych zadań

Po wydaniu `develop` może nadal zawierać zadania, które nie weszły na
produkcję. Aby wrócić do stanu odpowiadającego `main`, osoba uprawniona:

1. Sprawdza, że kod niewydanych zadań pozostaje na ich gałęziach i nie
   zginą potrzebne poprawki wykonane bezpośrednio na `develop`.
2. Wstrzymuje równoległe PR i push na `develop`, zapisuje bieżący SHA zdalnej
   gałęzi oraz potwierdza SHA wydanego `main`.
3. Resetuje `develop` do wydanego `main` i wypycha zmianę z ochroną
   `--force-with-lease`, zgodnie z zasadami ochrony gałęzi w projekcie.
4. Aktualizuje niewydane gałęzie zadaniowe przez rebase na nowy `origin/main`
   i ponownie kieruje je do `develop` na kolejną turę testów.

Przykład **wyłącznie dla osoby uprawnionej, w zwykłym klonie bez lokalnych
zmian** (nie wykonuj w worktree, w którym `develop` jest zajęty):

```bash
git fetch origin
git switch develop
git reset --hard origin/main
git push --force-with-lease origin develop
```

`reset --hard` usuwa niezapisane zmiany w tym checkoutcie, a aktualizacja
`develop` przepisuje historię zdalną. `--force-with-lease` nie jest zamiennikiem
koordynacji z zespołem; jeśli gałąź jest chroniona, nie obchodź zabezpieczeń.
Nie resetuj ani nie wypychaj z wymuszeniem `main`.

## Zasady, których warto pilnować

- Nigdy nie promuj `develop` w całości do `main` ani do `release/*`.
- Po rebase zadania sprawdź zakres PR do release: nie mogą się w nim znaleźć
  commity innych, niewydanych zadań.
- Nie usuwaj niewydanej gałęzi zadaniowej tylko dlatego, że jej PR do
  `develop` został scalony.
- Wydanie może obejmować tylko część zadań przetestowanych na DEV.
- Przed synchronizacją `develop` zabezpiecz każdą zmianę, która ma przetrwać
  reset; utrzymanie historii `develop` nie zastępuje gałęzi zadaniowych.

### Przykład z historii repo

`release/0.1` powstało przez połączenie `feature/EF-1` i `feature/EF-2`,
`release/0.2` połączyło `feature/EF-3` i `feature/EF-4`, a `release/0.3`
zawierało `feature/EF-5`. Każde z tych wydań scalono do `main`. Historię
można obejrzeć lokalnie przez:

```bash
git log --all --graph --oneline --decorate
```
