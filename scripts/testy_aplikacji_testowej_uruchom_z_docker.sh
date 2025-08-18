#!/bin/bash

# === Zmienne środowiskowe ===
source ./versions.env

# === Konfiguracja ===
SOAPUI_HOME="/opt/SoapUI-$SOAPUI_VERSION"
PROJECT_FILE="/opt/tests/SoapUI/project/Testy_aplikacji_testowej.xml"
REPORT_DIR="/opt/reports"
MOCK_NAME="Zaślepka aplikacji testowej"
MOCK_PORT=8089
KOD_ZADANIA="${1:-zadanie_1}" #domyślny kod

# === Nazwy plików raportów ===
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$REPORT_DIR/soapui-console-$TIMESTAMP.txt"
HTML_REPORT="$REPORT_DIR/soapui-report-$TIMESTAMP.html"

# === Tworzenie katalogu raportów (jeśli nie istnieje) ===
mkdir -p "$REPORT_DIR"

# === Uruchomienie testów z logowaniem do pliku ===
echo ">>> Start testów z kodem: $KOD_ZADANIA"
"$SOAPUI_HOME/bin/testrunner.sh" \
   -Dsoapui.cli=true \
   -Dkod="$KOD_ZADANIA" \
   -s"Aplikacja testowa" \
   -c"statusZadania" \
   -r -j -f"$REPORT_DIR" \
   "$PROJECT_FILE" | tee "$LOG_FILE"

# === Konwersja raportów XML do HTML ===
if command -v xunit-viewer >/dev/null 2>&1; then
   xunit-viewer -n --results="$REPORT_DIR" --output="$HTML_REPORT"
   echo ">>> Wygenerowano raport HTML: $HTML_REPORT"
   
   # === Usunięcie plików XML z raportem (TEST-*.xml) ===
   XML_FILES_DELETED=$(find "$REPORT_DIR" -maxdepth 1 -type f -name "TEST-*.xml" -print -delete | wc -l)
   if [[ "$XML_FILES_DELETED" -gt 0 ]]; then
      echo ">>> Usunięto $XML_FILES_DELETED plik(ów) JUnit XML z raportem"
   fi
else
   echo ">>> Nie znaleziono 'xunit-viewer' – pominięto konwersję HTML"
fi

# === Usunięcie logów FAILED (Aplikacja_testowa-statusZadania-Odpowiedź-*-FAILED.txt) ===
FAILED_LOGS_FILES_DELETED=$(find "$REPORT_DIR" -maxdepth 1 -type f -name "Aplikacja_testowa-statusZadania-Odpowiedź-*-FAILED.txt" -print -delete | wc -l)
if [[ "$FAILED_LOGS_FILES_DELETED" -gt 0 ]]; then
   echo ">>> Usunięto $FAILED_LOGS_FILES_DELETED log(ów) FILED"
else
   echo ">>> Nie znaleziono logów FAILED do usunięcia"
fi

echo ">>> Zapisano log konsoli do: $LOG_FILE"

echo ">>> Koniec testów z kodem: $KOD_ZADANIA"
