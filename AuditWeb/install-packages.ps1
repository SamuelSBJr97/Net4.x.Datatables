# Script para restaurar pacotes NuGet no projeto WebApplication1

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Instalando pacotes NuGet necess�rios" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Mudar para o diret�rio do projeto
$projectPath = "..\WebApplication1"
Set-Location $projectPath

Write-Host "Verificando NuGet..." -ForegroundColor Yellow

# Baixar nuget.exe se n�o existir
if (-not (Test-Path "nuget.exe")) {
    Write-Host "Baixando NuGet.exe..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "nuget.exe"
    Write-Host "NuGet.exe baixado com sucesso!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Restaurando pacotes NuGet..." -ForegroundColor Yellow

# Restaurar pacotes
.\nuget.exe restore packages.config -PackagesDirectory ..\packages

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "Pacotes restaurados com sucesso!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Pr�ximos passos:" -ForegroundColor Cyan
Write-Host "1. Abra a solu��o no Visual Studio" -ForegroundColor White
Write-Host "2. Reconstrua a solu��o (Build > Rebuild Solution)" -ForegroundColor White
Write-Host "3. Execute o projeto (F5)" -ForegroundColor White
Write-Host ""

# Voltar ao diret�rio original
Set-Location ..
