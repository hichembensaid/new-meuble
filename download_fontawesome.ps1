# Script PowerShell pour télécharger Font Awesome 4.7.0
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

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Téléchargement de Font Awesome 4.7.0" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($file in $files) {
    $url = "$baseUrl/$file"
    $destPath = Join-Path $destFolder $file
    
    Write-Host "Téléchargement de $file..." -ForegroundColor Yellow
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $destPath -UseBasicParsing
        Write-Host "  ✓ $file téléchargé avec succès" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Erreur lors du téléchargement de $file" -ForegroundColor Red
        Write-Host "    $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Téléchargement terminé!" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Les fichiers ont été installés dans:" -ForegroundColor White
Write-Host $destFolder -ForegroundColor White
Write-Host ""
Write-Host "Actualisez maintenant votre page (Ctrl+F5)" -ForegroundColor Yellow
