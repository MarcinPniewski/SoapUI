#!/bin/bash

# === Konfiguracja ===
SOAPUI_HOME="/Applications/SoapUI-5.8.0.app/Contents/java/app"
PROJECT_FILE="../project/Testy_aplikacji_testowej.xml"
REPORT_DIR="../reports"
MOCK_NAME="Zaślepka aplikacji testowej"
MOCK_PORT=8089
KOD_ZADANIA="${1:-zadanie_1}" #domyślny kod

# === Nazwy plików raportów ===
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$REPORT_DIR/soapui-console-$TIMESTAMP.txt"

# === Tworzenie katalogu raportów (jeśli nie istnieje) ===
mkdir -p "$REPORT_DIR"

# === Uruchomienie mocka ===
echo ">>> Uruchamiam MockService '$MOCK_NAME' na porcie $MOCK_PORT..."
"$SOAPUI_HOME/bin/mockservicerunner.sh" \
   -m "$MOCK_NAME" \
   -p "$MOCK_PORT" \
   "$PROJECT_FILE" &
MOCK_PID=$!

# === Oczekiwanie na uruchomienie mocka ===
echo ">>> Czekam 3 sekundy aż mock się uruchomi..."
sleep 3

# === Uruchomienie testów z logowaniem do pliku ===
echo ">>> Start testów z kodem: $KOD_ZADANIA"
"$SOAPUI_HOME/bin/testrunner.sh" \
   -Dsoapui.cli=true \
   -Dkod="$KOD_ZADANIA" \
   -s"Aplikacja testowa" \
   -c"statusZadania" \
   -r -j -f"$REPORT_DIR" \
   "$PROJECT_FILE" | tee "$LOG_FILE"

# === Zatrzymanie mocka ===
echo ">>> Zatrzymuję mock..."
MOCK_PID=$(ps aux | grep "[S]oapUIMockServiceRunner" | grep "$MOCK_NAME" | awk '{print $2}')
if [[ -n "$MOCK_PID" ]]; then
   kill "$MOCK_PID"
   echo ">>> Mock zatrzymany (PID: $MOCK_PID)"
else
   echo ">>> Nie znaleziono procesu mocka – być może już zakończony"
fi

# === Zmiana nazw raportów XML na zawierające znacznik czasu ===
RENAMED_COUNT=0
while IFS= read -r -d '' file; do
   base=$(basename "$file")
   new_name="${base%.xml}-$TIMESTAMP.xml"
   mv "$file" "$REPORT_DIR/$new_name"
   echo ">>> Zmieniono nazwę raportu: $base -> $new_name"
   ((RENAMED_COUNT++))
done < <(find "$REPORT_DIR" -maxdepth 1 -type f -name "TEST-Aplikacja_testowa.xml" -print0)

if [[ "$RENAMED_COUNT" -eq 0 ]]; then
   echo ">>> Nie znaleziono raportów XML do zmiany nazwy"
fi

# === Usunięcie logów z błędami FAILED ===
FAILED_LOGS_FILES_DELETED=$(find "$REPORT_DIR" -maxdepth 1 -type f -name "Aplikacja_testowa-statusZadania-Odpowiedź-*-FAILED.txt" -print -delete | wc -l)
if [[ "$FAILED_LOGS_FILES_DELETED" -gt 0 ]]; then
   echo ">>> Usunięto $FAILED_LOGS_FILES_DELETED log(ów) FAILED"
else
   echo ">>> Nie znaleziono logów FAILED do usunięcia"
fi

echo ">>> Zapisano log konsoli do: $LOG_FILE"

echo ">>> Koniec testów z kodem: $KOD_ZADANIA"
