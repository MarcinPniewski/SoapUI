# === Konfiguracja ===
$SoapUIHome = "C:\SoapUI-5.8.0"
$ProjectFile = "..\project\Testy_aplikacji_testowej.xml"
$ReportDir = "..\reports"
$MockName = "Zaślepka aplikacji testowej"
$MockPort = 8089
$KodZadania = if ($args.Count -ge 1) { $args[0] } else { "zadanie_1" }

# === Uruchomienie mocka ===
Write-Host ">>> Uruchamiam MockService '$MockName' na porcie $MockPort..."
$mockProcess = Start-Process -FilePath "$SoapUIHome\bin\mockservicerunner.bat" `
    -ArgumentList "-m `"$MockName`"", "-p", "$MockPort", "`"$ProjectFile`"" `
    -PassThru -WindowStyle Hidden

# === Oczekiwanie na uruchomienie mocka ===
Write-Host ">>> Czekam 3 sekundy aż mock się uruchomi..."
Start-Sleep -Seconds 3

# === Uruchomienie testów ===
Write-Host ">>> Uruchamiam testy z kodem: $KodZadania"
& "$SoapUIHome\bin\testrunner.bat" `
    "-Dsoapui.cli=true" `
    "-Dkod=$KodZadania" `
    '-s"Aplikacja testowa"' `
    '-c"statusZadania"' `
    "-r" "-j" "-f$ReportDir" `
    "$ProjectFile"

# === Zatrzymanie mocka ===
Write-Host ">>> Zatrzymuję mock..."
if ($mockProcess -and !$mockProcess.HasExited) {
    Stop-Process -Id $mockProcess.Id -Force
    Write-Host ">>> Mock zatrzymany (PID: $($mockProcess.Id))"
} else {
    Write-Host "!!! Nie znaleziono procesu mocka – być może już zakończony."
}

Write-Host ">>> Gotowe."