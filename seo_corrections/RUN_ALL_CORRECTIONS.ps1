## EXÉCUTION DES CORRECTIONS SEO — Ordre à respecter

## Prérequis : s'assurer que le serveur MySQL tourne

$mysql = "C:\wamp64-332\bin\mysql\mysql8.2.0\bin\mysql.exe"
$dir = "D:\projets\new-meuble\seo_corrections"

Write-Host "=== BACKUP de la DB avant corrections ===" -ForegroundColor Yellow
$date = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "D:\projets\new-meuble\seo_corrections\backup_before_seo_$date.sql"
$mysqldump = "C:\wamp64-332\bin\mysql\mysql8.2.0\bin\mysqldump.exe"
& $mysqldump -u root -P 3307 meuble2_db > $backupFile
Write-Host "Backup créé : $backupFile" -ForegroundColor Green

Write-Host ""
Write-Host "=== Script 01 : Fix link_rewrite produits ===" -ForegroundColor Cyan
& $mysql -u root -P 3307 meuble2_db -e "SOURCE $dir\01_fix_link_rewrite_produits.sql" 2>&1

Write-Host ""
Write-Host "=== Script 02 : Fix doublons d'URLs ===" -ForegroundColor Cyan
& $mysql -u root -P 3307 meuble2_db -e "SOURCE $dir\02_fix_doublons_urls.sql" 2>&1

Write-Host ""
Write-Host "=== Script 03 : Fix catégories ===" -ForegroundColor Cyan
& $mysql -u root -P 3307 meuble2_db -e "SOURCE $dir\03_fix_categories.sql" 2>&1

Write-Host ""
Write-Host "=== Script 04 : Fix méta pages système ===" -ForegroundColor Cyan
& $mysql -u root -P 3307 meuble2_db -e "SOURCE $dir\04_fix_meta_pages_systeme.sql" 2>&1

Write-Host ""
Write-Host "=== Script 05 : Fix meta titles/descriptions ===" -ForegroundColor Cyan
& $mysql -u root -P 3307 meuble2_db -e "SOURCE $dir\05_fix_meta_titles_descriptions.sql" 2>&1

Write-Host ""
Write-Host "=== Script 06 : Supprimer H1 dans descriptions ===" -ForegroundColor Cyan
& $mysql -u root -P 3307 meuble2_db -e "SOURCE $dir\06_fix_h1_dans_descriptions.sql" 2>&1

Write-Host ""
Write-Host "=== Script 08 : Fix noms produits ===" -ForegroundColor Cyan
& $mysql -u root -P 3307 meuble2_db -e "SOURCE $dir\08_fix_noms_produits.sql" 2>&1

Write-Host ""
Write-Host "=== Script 09 : Rapport SEO final ===" -ForegroundColor Cyan
& $mysql -u root -P 3307 meuble2_db -e "SOURCE $dir\09_config_seo_et_rapport.sql" 2>&1

Write-Host ""
Write-Host "=== TERMINÉ ===" -ForegroundColor Green
Write-Host "⚠️  N'oubliez pas d'exécuter le script 07 pour générer les redirections 301 avant la mise en prod !" -ForegroundColor Yellow
