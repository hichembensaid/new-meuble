# Script PowerShell pour telecharger Font Awesome 4.7.0
# Et l'installer dans le module ybc_blog_free

$baseUrl = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/fonts"
$destFolder = "d:\projets\new-meuble\modules\ybc_blog_free\views\fonts"

$files = @(
    "fontawesome-webfont.eot",
    "fontawesome-webfont.svg",
    "fontawesome-webfont.ttf",
    "fontawesome-webfont.woff",
    "fontawesome-webfont.woff2"
)

Write-Host "=====================================================`n" -ForegroundColor Cyan
Write-Host "Telechargement de Font Awesome 4.7.0`n" -ForegroundColor Cyan
Write-Host "=====================================================`n" -ForegroundColor Cyan

foreach ($file in $files) {
    $url = "$baseUrl/$file"
    $destPath = Join-Path $destFolder $file
    
    Write-Host "Telechargement de $file..." -ForegroundColor Yellow
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $destPath -UseBasicParsing
        Write-Host "  OK - $file telecharge avec succes" -ForegroundColor Green
    }
    catch {
        Write-Host "  ERREUR lors du telechargement de $file" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=====================================================`n" -ForegroundColor Cyan
Write-Host "Telechargement termine!`n" -ForegroundColor Cyan
Write-Host "=====================================================`n" -ForegroundColor Cyan
Write-Host "Les fichiers ont ete installes dans:`n" -ForegroundColor White
Write-Host "$destFolder`n" -ForegroundColor White
Write-Host "Actualisez maintenant votre page (Ctrl+F5)" -ForegroundColor Yellow
