# Kayzid flutter_launcher_icons o kaygeneri les icones dyal Android, iOS o web.
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
Set-Location (Split-Path $PSScriptRoot)
flutter pub add --dev flutter_launcher_icons
dart run flutter_launcher_icons
Write-Host "Salina." -ForegroundColor Green
