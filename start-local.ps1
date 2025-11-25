# Script de démarrage local de l'API Usage Metrics
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Démarrage de l'API Usage Metrics" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérification de Maven
Write-Host "[1/3] Vérification de Maven..." -ForegroundColor Yellow
$mvnVersion = mvn -version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR: Maven n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Maven détecté" -ForegroundColor Green
Write-Host ""

# Nettoyage et compilation
Write-Host "[2/3] Compilation et packaging du projet..." -ForegroundColor Yellow
mvn clean package -DskipTests
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR: La compilation a échoué" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Package créé avec succès" -ForegroundColor Green
Write-Host ""

# Vérification du package
$jarFile = "target\usage-metrics-api-1.0.0-SNAPSHOT-mule-application.jar"
if (-not (Test-Path $jarFile)) {
    Write-Host "ERREUR: Le fichier JAR n'a pas été créé" -ForegroundColor Red
    exit 1
}

Write-Host "[3/3] Démarrage de l'application..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  IMPORTANT" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Pour démarrer l'application Mule 4.10.1 localement:" -ForegroundColor White
Write-Host ""
Write-Host "Option 1 - Anypoint Studio (Recommandé):" -ForegroundColor Green
Write-Host "  1. Ouvrez le projet dans Anypoint Studio" -ForegroundColor White
Write-Host "  2. Clic droit sur le projet > Run As > Mule Application" -ForegroundColor White
Write-Host ""
Write-Host "Option 2 - Runtime Mule Standalone:" -ForegroundColor Green
Write-Host "  1. Téléchargez Mule Runtime 4.10.1 depuis Anypoint Platform" -ForegroundColor White
Write-Host "  2. Déployez le JAR dans le dossier apps/ du runtime" -ForegroundColor White
Write-Host "  3. Démarrez le runtime avec: bin\mule.bat" -ForegroundColor White
Write-Host ""
Write-Host "Option 3 - CloudHub Local:" -ForegroundColor Green
Write-Host "  Utilisez Anypoint Studio pour un déploiement local" -ForegroundColor White
Write-Host ""
Write-Host "Package créé: $jarFile" -ForegroundColor Cyan
Write-Host "Taille: $((Get-Item $jarFile).Length / 1MB) MB" -ForegroundColor Cyan
Write-Host ""
