# Script para iniciar o PostgreSQL no Docker

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Iniciando PostgreSQL com Docker" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se Docker está instalado
try {
    $dockerVersion = docker --version
    Write-Host "Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "ERRO: Docker não encontrado!" -ForegroundColor Red
    Write-Host "Por favor, instale o Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Verificar se Docker está rodando
try {
    docker ps | Out-Null
    Write-Host "Docker está rodando!" -ForegroundColor Green
} catch {
    Write-Host "ERRO: Docker não está rodando!" -ForegroundColor Red
    Write-Host "Por favor, inicie o Docker Desktop" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Parando containers anteriores (se existirem)..." -ForegroundColor Yellow
docker-compose down

Write-Host ""
Write-Host "Iniciando PostgreSQL..." -ForegroundColor Yellow
docker-compose up -d

Write-Host ""
Write-Host "Aguardando inicialização do banco de dados..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verificar se o container está rodando
$containerStatus = docker ps --filter "name=auditlog_postgres" --format "{{.Status}}"

if ($containerStatus) {
Write-Host ""
  Write-Host "=====================================" -ForegroundColor Green
    Write-Host "PostgreSQL iniciado com sucesso!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Status do container:" -ForegroundColor Cyan
  docker ps --filter "name=auditlog_postgres"
    
    Write-Host ""
    Write-Host "IMPORTANTE: O banco está inserindo 100.000 registros..." -ForegroundColor Yellow
    Write-Host "Isso pode levar alguns minutos. Aguarde antes de executar a aplicação." -ForegroundColor Yellow
  Write-Host ""
    Write-Host "Para acompanhar o progresso, execute:" -ForegroundColor Cyan
    Write-Host "  docker logs -f auditlog_postgres" -ForegroundColor White
    Write-Host ""
    Write-Host "Quando ver a mensagem 'Inserção completa: 100.000 registros criados'," -ForegroundColor Yellow
    Write-Host "o banco estará pronto para uso!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Informações de conexão:" -ForegroundColor Cyan
    Write-Host "  Host: localhost" -ForegroundColor White
    Write-Host "  Port: 5432" -ForegroundColor White
    Write-Host "  Database: AuditLogDB" -ForegroundColor White
    Write-Host "  Username: audituser" -ForegroundColor White
  Write-Host "  Password: Audit@123" -ForegroundColor White
    Write-Host ""
} else {
  Write-Host ""
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "ERRO: Container não iniciou!" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifique os logs com:" -ForegroundColor Yellow
    Write-Host "  docker logs auditlog_postgres" -ForegroundColor White
    Write-Host ""
}

Write-Host "Comandos úteis:" -ForegroundColor Cyan
Write-Host "  Parar o container: docker-compose down" -ForegroundColor White
Write-Host "  Ver logs: docker logs -f auditlog_postgres" -ForegroundColor White
Write-Host "  Acessar o PostgreSQL: docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB" -ForegroundColor White
Write-Host ""
