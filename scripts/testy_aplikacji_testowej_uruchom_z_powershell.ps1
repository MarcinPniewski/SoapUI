# === Konfiguracja ===
$SoapUIHome   = "C:\SoapUI-5.8.0"
$ProjectFile  = "..\project\Testy_aplikacji_testowej.xml"
$ReportDir    = "..\reports"
$MockName     = "Zaślepka aplikacji testowej"
$MockPort     = 8089
$KodZadania   = if ($args.Count -ge 1) { $args[0] } else { "zadanie_1" }

# === Nazwy plików raportów ===
$Timestamp    = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile      = Join-Path $ReportDir "soapui-console-$Timestamp.txt"

# === Tworzenie katalogu raportów (jeśli nie istnieje) ===
if (-not (Test-Path $ReportDir)) {
    New-Item -ItemType Directory -Path $ReportDir | Out-Null
}

# === Uruchomienie mocka ===
Write-Host ">>> Uruchamiam MockService '$MockName' na porcie $MockPort..."
$mockProcess = Start-Process -FilePath "$SoapUIHome\bin\mockservicerunner.bat" `
    -ArgumentList "-m `"$MockName`"", "-p", "$MockPort", "`"$ProjectFile`"" `
    -PassThru -WindowStyle Hidden

# === Oczekiwanie na uruchomienie mocka ===
Write-Host ">>> Czekam 3 sekundy aż mock się uruchomi..."
Start-Sleep -Seconds 3

# === Uruchomienie testów i zapis logu ===
Write-Host ">>> Start testów z kodem: $KodZadania"
& "$SoapUIHome\bin\testrunner.bat" `
    "-Dsoapui.cli=true" `
    "-Dkod=$KodZadania" `
    '-s"Aplikacja testowa"' `
    '-c"statusZadania"' `
    "-r" "-j" "-f$ReportDir" `
    "$ProjectFile" | Tee-Object -FilePath $LogFile

# === Zatrzymanie mocka ===
Write-Host ">>> Zatrzymuję mock..."
if ($mockProcess -and !$mockProcess.HasExited) {
    Stop-Process -Id $mockProcess.Id -Force
    Write-Host ">>> Mock zatrzymany (PID: $($mockProcess.Id))"
} else {
    Write-Host ">>> Nie znaleziono procesu mocka – być może już zakończony"
}

# === Zmiana nazw raportów XML na zawierające znacznik czasu ===
$renamed = 0
Get-ChildItem -Path $ReportDir -Filter "TEST-Aplikacja_testowa.xml" | ForEach-Object {
    $newName = "$($_.BaseName)-$Timestamp$($_.Extension)"
    Rename-Item -Path $_.FullName -NewName $newName
    Write-Host ">>> Zmieniono nazwę raportu: $($_.Name) -> $newName"
    $renamed++
}
if ($renamed -eq 0) {
    Write-Host ">>> Nie znaleziono raportów XML do zmiany nazwy"
}

# === Usunięcie logów z błędami FAILED ===
$failedLogs = Get-ChildItem -Path $ReportDir -Filter "Aplikacja_testowa-statusZadania-Odpowiedź-*-FAILED.txt"
if ($failedLogs.Count -gt 0) {
    $failedLogs | Remove-Item -Force
    Write-Host ">>> Usunięto $($failedLogs.Count) log(ów) FAILED"
} else {
    Write-Host ">>> Nie znaleziono logów FAILED do usunięcia"
}

Write-Host ">>> Zapisano log konsoli do: $LogFile"

Write-Host ">>> Koniec testów z kodem: $KodZadania"
