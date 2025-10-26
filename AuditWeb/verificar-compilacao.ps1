# Script para verificar e corrigir problemas de compilação

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "VERIFICAÇÃO E CORREÇÃO DE COMPILAÇÃO" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "..\WebApplication1"
$projectFile = "$projectPath\WebApplication1.csproj"

# Verificar se o projeto existe
if (-not (Test-Path $projectFile)) {
    Write-Host "? Projeto não encontrado: $projectFile" -ForegroundColor Red
    exit 1
}

Write-Host "? Projeto encontrado" -ForegroundColor Green
Write-Host ""

# Lista de arquivos que devem existir
$requiredFiles = @{
    "Controllers\AuditController.cs" = "Controller de Auditoria"
  "Models\AuditLog.cs" = "Modelo AuditLog"
    "Models\DataTablesModels.cs" = "Modelos DataTables"
    "Repositories\AuditLogRepository.cs" = "Repository de Auditoria"
    "Views\Audit\Index.cshtml" = "View de Auditoria"
}

Write-Host "Verificando arquivos do projeto:" -ForegroundColor Yellow
Write-Host ""

$missingFiles = @()
$existingFiles = @()

foreach ($file in $requiredFiles.Keys) {
    $fullPath = Join-Path $projectPath $file
    if (Test-Path $fullPath) {
        Write-Host "  ? $file" -ForegroundColor Green
        $existingFiles += $file
    } else {
        Write-Host "  ? $file (NÃO ENCONTRADO)" -ForegroundColor Red
    $missingFiles += $file
    }
}

Write-Host ""

if ($missingFiles.Count -gt 0) {
    Write-Host "??  ATENÇÃO: Arquivos faltando!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Os seguintes arquivos devem ser criados:" -ForegroundColor Yellow
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
    Write-Host ""
}

# Verificar packages.config
Write-Host "Verificando packages.config..." -ForegroundColor Yellow
$packagesConfig = "$projectPath\packages.config"

if (Test-Path $packagesConfig) {
    $content = Get-Content $packagesConfig -Raw
    
    if ($content -match 'Npgsql') {
    Write-Host "  ? Npgsql está no packages.config" -ForegroundColor Green
 } else {
   Write-Host "  ? Npgsql NÃO está no packages.config" -ForegroundColor Red
    Write-Host "     Execute: .\install-packages.ps1" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ? packages.config não encontrado" -ForegroundColor Red
}

Write-Host ""

# Verificar Web.config
Write-Host "Verificando Web.config..." -ForegroundColor Yellow
$webConfig = "$projectPath\Web.config"

if (Test-Path $webConfig) {
    $content = Get-Content $webConfig -Raw
    
    if ($content -match 'AuditLogDB') {
   Write-Host "  ? Connection string 'AuditLogDB' encontrada" -ForegroundColor Green
    } else {
      Write-Host "  ? Connection string 'AuditLogDB' NÃO encontrada" -ForegroundColor Red
  Write-Host "     Adicione a connection string ao Web.config" -ForegroundColor Yellow
    }
    
    if ($content -match 'Npgsql') {
      Write-Host "  ? Provider Npgsql configurado" -ForegroundColor Green
    } else {
        Write-Host "  ??  Provider Npgsql pode não estar configurado" -ForegroundColor Yellow
  }
} else {
    Write-Host "  ? Web.config não encontrado" -ForegroundColor Red
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "INSTRUÇÕES DE CORREÇÃO" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Para corrigir erros de compilação no Visual Studio:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Restaurar Pacotes NuGet:" -ForegroundColor Cyan
Write-Host "   a) Botão direito na solução > 'Restore NuGet Packages'" -ForegroundColor White
Write-Host "   b) Ou execute: .\install-packages.ps1" -ForegroundColor White
Write-Host ""

Write-Host "2. Adicionar arquivos ao projeto:" -ForegroundColor Cyan
Write-Host "   a) Solution Explorer > Clique em 'Show All Files' (ícone no topo)" -ForegroundColor White
Write-Host "   b) Botão direito nas pastas Controllers, Models, Repositories, Views\Audit" -ForegroundColor White
Write-Host "   c) Selecione 'Include In Project'" -ForegroundColor White
Write-Host ""

Write-Host "3. Clean e Rebuild:" -ForegroundColor Cyan
Write-Host "   a) Build > Clean Solution" -ForegroundColor White
Write-Host "   b) Build > Rebuild Solution" -ForegroundColor White
Write-Host ""

Write-Host "4. Verificar referências:" -ForegroundColor Cyan
Write-Host "   a) Solution Explorer > WebApplication1 > References" -ForegroundColor White
Write-Host "   b) Procure por 'Npgsql'" -ForegroundColor White
Write-Host "   c) Se tiver ?? (amarelo), remova e reinstale o pacote" -ForegroundColor White
Write-Host ""

if ($missingFiles.Count -eq 0 -and (Test-Path $packagesConfig) -and (Test-Path $webConfig)) {
 Write-Host "? Estrutura básica está OK!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Agora:" -ForegroundColor Cyan
    Write-Host "  1. Abra o Visual Studio" -ForegroundColor White
    Write-Host "  2. Restore NuGet Packages" -ForegroundColor White
    Write-Host "  3. Include os arquivos no projeto" -ForegroundColor White
    Write-Host "  4. Build > Rebuild Solution" -ForegroundColor White
} else {
    Write-Host "??  Alguns arquivos ou configurações estão faltando" -ForegroundColor Yellow
    Write-Host "   Revise as mensagens acima" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Gerar relatório
Write-Host "Gerando relatório..." -ForegroundColor Yellow

$report = @"
# RELATÓRIO DE VERIFICAÇÃO - $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Arquivos do Projeto

### Existentes (?)
$($existingFiles | ForEach-Object { "- $_" } | Out-String)

### Faltando (?)
$($missingFiles | ForEach-Object { "- $_" } | Out-String)

## Configurações

- packages.config: $(if (Test-Path $packagesConfig) { "? Existe" } else { "? Não encontrado" })
- Web.config: $(if (Test-Path $webConfig) { "? Existe" } else { "? Não encontrado" })

## Próximos Passos

1. Restaurar pacotes NuGet
2. Incluir arquivos no projeto
3. Clean + Rebuild
4. Executar (F5)

## Documentação

Leia CORRECOES-COMPILACAO.md para detalhes completos.
"@

$report | Out-File "verificacao-compilacao.txt" -Encoding UTF8

Write-Host "? Relatório salvo em: verificacao-compilacao.txt" -ForegroundColor Green
Write-Host ""
