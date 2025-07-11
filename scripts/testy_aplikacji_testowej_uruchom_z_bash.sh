#!/bin/bash

# === Konfiguracja ===
SOAPUI_HOME="/Applications/SoapUI-5.8.0.app/Contents/java/app"
PROJECT_FILE="../project/Testy_aplikacji_testowej.xml"
REPORT_DIR="../reports"
MOCK_NAME="Zaślepka aplikacji testowej"
MOCK_PORT=8089
KOD_ZADANIA="${1:-zadanie_1}" #domyślny kod

# === Uruchomienie mocka ===
echo ">>> Uruchamiam MockService '$MOCK_NAME' na porcie $MOCK_PORT..."
"$SOAPUI_HOME/bin/mockservicerunner.sh" \
  -m "$MOCK_NAME" \
  -p $MOCK_PORT \
  "$PROJECT_FILE" &
MOCK_PID=$!

# === Oczekiwanie na uruchomienie mocka ===
echo ">>> Czekam 3 sekundy aż mock się uruchomi..."
sleep 3

# === Uruchomienie testów ===
echo ">>> Uruchamiam testy z kodem: $KOD_ZADANIA"
"$SOAPUI_HOME/bin/testrunner.sh" \
  -Dsoapui.cli=true \
  -Dkod=$KOD_ZADANIA \
  -s"Aplikacja testowa" \
  -c"statusZadania" \
  -r -j -f"$REPORT_DIR" \
  "$PROJECT_FILE"

# === Zatrzymanie mocka ===
echo ">>> Zatrzymuję mock..."
MOCK_PID=$(ps aux | grep "[S]oapUIMockServiceRunner" | grep "$MOCK_NAME" | awk '{print $2}')
if [ -n "$MOCK_PID" ]; then
  kill "$MOCK_PID"
  echo ">>> Mock zatrzymany (PID: $MOCK_PID)"
else
  echo "!!! Nie znaleziono procesu mocka – być może już zakończony."
fi

echo ">>> Gotowe."
