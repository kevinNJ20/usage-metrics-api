# Script pour démarrer l'application avec le runtime Mule téléchargé par Maven
Write-Host "Démarrage de l'application avec le runtime Mule..." -ForegroundColor Cyan

$jarFile = "target\usage-metrics-api-1.0.0-SNAPSHOT-mule-application.jar"
$runtimePath = "target\build-dependencies\mule-framework-latest-bundle-1.2.1"

if (-not (Test-Path $jarFile)) {
    Write-Host "ERREUR: Le package JAR n'existe pas. Exécutez d'abord: mvn clean package" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $runtimePath)) {
    Write-Host "ERREUR: Le runtime Mule n'a pas été téléchargé. Exécutez d'abord: mvn clean package" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  ATTENTION" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Le plugin mule-maven-plugin 4.6.0 ne supporte pas le goal 'run'." -ForegroundColor White
Write-Host ""
Write-Host "Pour démarrer l'application localement, utilisez:" -ForegroundColor White
Write-Host "  1. Anypoint Studio (Recommandé)" -ForegroundColor Green
Write-Host "  2. Runtime Mule Standalone" -ForegroundColor Green
Write-Host ""
Write-Host "Package créé: $jarFile" -ForegroundColor Cyan
Write-Host "Taille: $([math]::Round((Get-Item $jarFile).Length / 1MB, 2)) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour utiliser Anypoint Studio:" -ForegroundColor Yellow
Write-Host "  1. File > Import > Existing Maven Projects" -ForegroundColor White
Write-Host "  2. Sélectionnez ce répertoire" -ForegroundColor White
Write-Host "  3. Clic droit sur le projet > Run As > Mule Application" -ForegroundColor White
Write-Host ""

