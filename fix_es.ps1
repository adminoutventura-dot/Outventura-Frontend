$file = 'e:\Users\NTTN\Desktop\Outventura\Outventura-Frontend\lib\l10n\app_localizations_es.dart'
$lines = Get-Content $file
$idx = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "myActivitiesBtn") {
        $idx = $i
        break
    }
}
if ($idx -ge 0) {
    $before = $lines[0..$idx]
    $after = $lines[($idx+1)..($lines.Count-1)]
    $all = $before + "" + "  @override" + "  String get guideReservationsBtn => 'Reservas como Guía';" + $after
    $all | Out-File -FilePath $file -Encoding UTF8
    Write-Host "Done"
} else {
    Write-Host "Pattern not found"
}
