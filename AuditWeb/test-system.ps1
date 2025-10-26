# Script para testar a instalação do sistema de auditoria

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "TESTE DO SISTEMA DE AUDITORIA" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$allTestsPassed = $true

# Teste 1: Docker instalado
Write-Host "[1/5] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "  ? Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "  ? Docker NÃO encontrado!" -ForegroundColor Red
    $allTestsPassed = $false
}

Write-Host ""

# Teste 2: Container rodando
Write-Host "[2/5] Verificando container PostgreSQL..." -ForegroundColor Yellow
$containerRunning = docker ps --filter "name=auditlog_postgres" --format "{{.Names}}"
if ($containerRunning) {
    Write-Host "  ? Container 'auditlog_postgres' está rodando" -ForegroundColor Green
    
    # Teste adicional: verificar saúde do container
    $containerHealth = docker inspect --format='{{.State.Health.Status}}' auditlog_postgres 2>$null
    if ($containerHealth -eq "healthy") {
        Write-Host "  ? Container está saudável" -ForegroundColor Green
    }
} else {
    Write-Host "  ? Container NÃO está rodando!" -ForegroundColor Red
    Write-Host "  Execute: .\start-docker.ps1" -ForegroundColor Yellow
    $allTestsPassed = $false
}

Write-Host ""

# Teste 3: Banco de dados acessível
Write-Host "[3/5] Testando conexão com banco de dados..." -ForegroundColor Yellow
try {
  $result = docker exec auditlog_postgres psql -U audituser -d AuditLogDB -t -c "SELECT 1" 2>$null
    if ($result -match "1") {
        Write-Host "  ? Conexão com banco de dados OK" -ForegroundColor Green
    } else {
        Write-Host "  ? Não foi possível conectar ao banco" -ForegroundColor Red
        $allTestsPassed = $false
    }
} catch {
    Write-Host "  ? Erro ao testar conexão" -ForegroundColor Red
    $allTestsPassed = $false
}

Write-Host ""

# Teste 4: Tabela e dados
Write-Host "[4/5] Verificando tabela e dados..." -ForegroundColor Yellow
try {
    $count = docker exec auditlog_postgres psql -U audituser -d AuditLogDB -t -c "SELECT COUNT(*) FROM audit_logs" 2>$null
    $count = $count.Trim()
    
if ($count -gt 0) {
        Write-Host "  ? Tabela 'audit_logs' existe" -ForegroundColor Green
        Write-Host "  ? Total de registros: $count" -ForegroundColor Green
        
    if ($count -eq 100000) {
    Write-Host "  ? 100.000 registros de teste carregados!" -ForegroundColor Green
        } elseif ($count -lt 100000) {
            Write-Host "  ? Apenas $count registros encontrados (esperado: 100.000)" -ForegroundColor Yellow
       Write-Host "    O banco ainda pode estar carregando dados..." -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ? Tabela vazia ou não existe" -ForegroundColor Red
        $allTestsPassed = $false
    }
} catch {
    Write-Host "  ? Erro ao verificar dados" -ForegroundColor Red
    $allTestsPassed = $false
}

Write-Host ""

# Teste 5: Arquivos do projeto
Write-Host "[5/5] Verificando arquivos do projeto..." -ForegroundColor Yellow

$requiredFiles = @(
  "..\WebApplication1\Controllers\AuditController.cs",
    "..\WebApplication1\Models\AuditLog.cs",
    "..\WebApplication1\Models\DataTablesModels.cs",
    "..\WebApplication1\Repositories\AuditLogRepository.cs",
    "..\WebApplication1\Views\Audit\Index.cshtml",
    "..\WebApplication1\Web.config",
    "..\WebApplication1\packages.config",
    "docker-compose.yml",
    "init-db.sql"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ? $file" -ForegroundColor Green
    } else {
Write-Host "  ? $file (NÃO ENCONTRADO)" -ForegroundColor Red
        $missingFiles += $file
        $allTestsPassed = $false
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan

if ($allTestsPassed) {
    Write-Host "? TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Sistema pronto para uso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Cyan
    Write-Host "1. Abra a solução no Visual Studio" -ForegroundColor White
    Write-Host "2. Execute o projeto (F5)" -ForegroundColor White
 Write-Host "3. Acesse o menu 'Auditoria'" -ForegroundColor White
    Write-Host ""
    
    # Mostrar algumas estatísticas
    Write-Host "Estatísticas do banco:" -ForegroundColor Cyan
try {
        Write-Host ""
        docker exec auditlog_postgres psql -U audituser -d AuditLogDB -c "SELECT severity, COUNT(*) as total FROM audit_logs GROUP BY severity ORDER BY total DESC;"
    } catch {
  # Silenciar erro
    }
  
} else {
    Write-Host "? ALGUNS TESTES FALHARAM!" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, verifique os erros acima e corrija antes de prosseguir." -ForegroundColor Yellow
    Write-Host ""
    
if ($missingFiles.Count -gt 0) {
     Write-Host "Arquivos faltando:" -ForegroundColor Yellow
  foreach ($file in $missingFiles) {
    Write-Host "  - $file" -ForegroundColor Red
 }
        Write-Host ""
    }
  
    Write-Host "Comandos úteis para debug:" -ForegroundColor Cyan
    Write-Host "  Ver logs do Docker: docker logs auditlog_postgres" -ForegroundColor White
  Write-Host "  Reiniciar Docker: docker-compose restart" -ForegroundColor White
    Write-Host "  Recriar container: docker-compose down && docker-compose up -d" -ForegroundColor White
    Write-Host ""
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
