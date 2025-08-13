# SoapUI - testy API

## Opis
Projekt zawiera testy API przygotowane w narzędziu SoapUI (wersja Open Source).  
Testy można uruchamiać zarówno w środowisku graficznym jak i z linii komend (CLI SoapUI).

W projekcie znajduje się MocService `Zaślepka aplikacji testowej` symulujący odpowiedzi GET przykładowej aplikacji testowej.  
Znajdujący się w projekcie TestCase `statusZadania` oczekuje podania nazwy zadania, dla którego symulowane są odpowiedzi.
Każde żądanie jest automatycznie walidowane pod kątem poprawności struktury odpowiedzi, obecności nagłówków, statusów i sygnatur błędów (`FAILED`, `Failures`, itp.).

W przypadku uruchomienia testu w środowisku graficznym log znajduje się w konsoli "script log".  
Dla zadania_2 symulującego błędną odpowiedź z aplikacji testowej wyświetlane jest okienko z podsumowaniem błędów a w konsoli znajdują się szczegóły zaprezentowane w taki sposób by nadawały się do skopiowania wprost do zgłoszenia dla dewelopera.

W przypadku uruchomienia testu z linii komend logi z przebiegu zostają umieszczone w katalogu `reports`.

## Struktura projektu
- `project/` – pliki projektów SoapUI (.xml)
  - `Testy_aplikacji_testowej.xml`
- `reports/` - raporty z wykonanych testów CLI
- `scripts/` – skrypty CLI do uruchamiania testów z lini komend
- `sources/` - pliki źródłowe wykorzystane w projekcie SoapUI

## Wymagania
- SoapUI 5.x
- Java 8+ (do uruchamiania testów z lini komend)
- system MacOS/Linux/Windows
- w skryptach uruchamiających dostosować zmienną `SOAPUI_HOME` zawierającą ścieżkę do SoapUI

## Uruchamianie testów CLI

### (MacOS/Linux)
```bash
cd scripts
./testy_aplikacji_testowej_uruchom_z_bash.sh zadanie_1
./testy_aplikacji_testowej_uruchom_z_bash.sh zadanie_2
./testy_aplikacji_testowej_uruchom_z_bash.sh zadanie_3
./testy_aplikacji_testowej_uruchom_z_bash.sh zadanie_4
```
Wynik testów pojawi się w terminalu oraz w raportach w katalogu `reports`.

### (Windows)
```powershell
cd scripts
.\testy_aplikacji_testowej_uruchom_z_powershell.ps1 zadanie_1
.\testy_aplikacji_testowej_uruchom_z_powershell.ps1 zadanie_2
.\testy_aplikacji_testowej_uruchom_z_powershell.ps1 zadanie_3
.\testy_aplikacji_testowej_uruchom_z_powershell.ps1 zadanie_4
```
Wynik testów pojawi się w terminalu oraz w raportach w katalogu `reports`.

### (Docker)
```bash
/opt/tests/SoapUI/scripts/testy_aplikacji_testowej_uruchom_z_docker.sh zadanie_1
/opt/tests/SoapUI/scripts/testy_aplikacji_testowej_uruchom_z_docker.sh zadanie_2
/opt/tests/SoapUI/scripts/testy_aplikacji_testowej_uruchom_z_docker.sh zadanie_3
/opt/tests/SoapUI/scripts/testy_aplikacji_testowej_uruchom_z_docker.sh zadanie_4
```
Wynik testów pojawi się w terminalu oraz w raportach w katalogu `/opt/reports`.

## Uruchamianie testów GUI
- zaimportować projekt z pliku .xml do SoapUI
- uruchomić MocService `Zaślepka aplikacji testowej`
- uruchomić TestCase `statusZadania` podając nazwę zadania w wyskakującym okienku
- przejrzeć logi w konsoli "script log"

## Licencja
To repozytorium udostępniane jest wyłącznie do celów testowych i edukacyjnych.  
Wszelkie inne formy użycia (modyfikacja, komercja, publikacja) są zabronione.  
Szczegóły w pliku [LICENSE.txt](./LICENSE.txt).