# Kayn deploy dyal Firestore rules, o kaybda l app f l web (port 8080) b hot reload.
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
Set-Location (Split-Path $PSScriptRoot)
if ($args -contains '-deploy') { firebase deploy --only firestore:rules --project masarif-3120 }
flutter pub get
flutter run -d web-server --web-port 8080 --web-hostname localhost
