# Script para verificar e corrigir dependências do Npgsql

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "VERIFICAÇÃO DE DEPENDÊNCIAS NPGSQL" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "..\WebApplication1"
$binPath = "$projectPath\bin"

Write-Host "Verificando DLLs na pasta bin..." -ForegroundColor Yellow
Write-Host ""

$requiredDlls = @{
    "Npgsql.dll" = "4.1.14"
    "System.Threading.Tasks.Extensions.dll" = "4.5.4"
    "System.Buffers.dll" = "4.5.1"
    "System.Memory.dll" = "4.5.5"
    "System.ValueTuple.dll" = "4.5.0"
    "System.Runtime.CompilerServices.Unsafe.dll" = "6.0.0"
}

$missingDlls = @()
$foundDlls = @()

foreach ($dll in $requiredDlls.Keys) {
    $dllPath = Get-ChildItem -Path $binPath -Filter $dll -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($dllPath) {
        Write-Host "  ? $dll" -ForegroundColor Green
 $foundDlls += $dll
    } else {
        Write-Host "  ? $dll (NÃO ENCONTRADO)" -ForegroundColor Red
        $missingDlls += $dll
    }
}

Write-Host ""

if ($missingDlls.Count -gt 0) {
    Write-Host "??  ATENÇÃO: DLLs faltando!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Solução: Restaurar pacotes NuGet" -ForegroundColor Cyan
Write-Host ""
    Write-Host "Opções:" -ForegroundColor Yellow
    Write-Host "  1. Visual Studio: Botão direito na solução > 'Restore NuGet Packages'" -ForegroundColor White
    Write-Host "  2. Package Manager Console: Update-Package -reinstall" -ForegroundColor White
    Write-Host "  3. Execute: .\install-packages.ps1" -ForegroundColor White
    Write-Host ""
  
    $restore = Read-Host "Deseja tentar restaurar os pacotes agora? (S/N)"
    
    if ($restore -eq "S" -or $restore -eq "s") {
   Write-Host ""
   Write-Host "Restaurando pacotes NuGet..." -ForegroundColor Yellow
    
        # Encontrar nuget.exe
        $nugetExe = Get-ChildItem -Path "C:\Program Files*" -Filter "nuget.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        
   if (-not $nugetExe) {
            Write-Host "Baixando NuGet.exe..." -ForegroundColor Yellow
   $nugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
            $nugetExe = ".\nuget.exe"
            Invoke-WebRequest -Uri $nugetUrl -OutFile $nugetExe
        }
        
        Write-Host "Executando restore..." -ForegroundColor Yellow
        & $nugetExe.FullName restore "..\WebApplication1\packages.config" -PackagesDirectory "..\packages"
    
        Write-Host ""
    Write-Host "? Restore concluído!" -ForegroundColor Green
    Write-Host "Reconstrua o projeto no Visual Studio (Clean + Build)" -ForegroundColor Yellow
    }
} else {
 Write-Host "? Todas as DLLs necessárias estão presentes!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "VERIFICANDO WEB.CONFIG" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$webConfig = "$projectPath\Web.config"
$webConfigContent = Get-Content $webConfig -Raw

$bindingRedirects = @{
  "System.Threading.Tasks.Extensions" = "4.2.0.1"
    "System.Buffers" = "4.0.3.0"
    "System.Memory" = "4.0.1.2"
    "System.ValueTuple" = "4.0.3.0"
    "System.Runtime.CompilerServices.Unsafe" = "6.0.0.0"
}

Write-Host "Verificando binding redirects:" -ForegroundColor Yellow
Write-Host ""

foreach ($assembly in $bindingRedirects.Keys) {
    if ($webConfigContent -match $assembly) {
      Write-Host "  ? $assembly configurado" -ForegroundColor Green
    } else {
  Write-Host "  ? $assembly NÃO configurado" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "TESTANDO CONEXÃO COM POSTGRESQL" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$containerStatus = docker ps --filter "name=auditlog_postgres" --format "{{.Status}}"

if ($containerStatus) {
    Write-Host "? Container PostgreSQL está rodando" -ForegroundColor Green
    Write-Host "   Status: $containerStatus" -ForegroundColor Gray
    
    Write-Host ""
    Write-Host "Testando conexão..." -ForegroundColor Yellow
    
    $testQuery = "SELECT COUNT(*) FROM audit_logs;"
    $result = docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB -t -c $testQuery 2>&1
    
    if ($LASTEXITCODE -eq 0) {
   Write-Host "? Conexão bem-sucedida!" -ForegroundColor Green
        Write-Host "   Registros no banco: $($result.Trim())" -ForegroundColor Gray
    } else {
        Write-Host "? Erro ao conectar no banco" -ForegroundColor Red
    }
} else {
    Write-Host "? Container PostgreSQL não está rodando" -ForegroundColor Red
    Write-Host "   Execute: .\start-docker.ps1" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "RESUMO" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

if ($missingDlls.Count -eq 0 -and $containerStatus) {
    Write-Host "? Sistema pronto para uso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Cyan
    Write-Host "  1. Abra o Visual Studio" -ForegroundColor White
    Write-Host "  2. Limpe a solução (Build > Clean Solution)" -ForegroundColor White
  Write-Host "  3. Reconstrua (Build > Rebuild Solution)" -ForegroundColor White
    Write-Host "  4. Execute (F5)" -ForegroundColor White
 Write-Host "  5. Acesse /Audit" -ForegroundColor White
} else {
    Write-Host "??  Ações necessárias:" -ForegroundColor Yellow
    Write-Host ""
    
    if ($missingDlls.Count -gt 0) {
        Write-Host "  - Restaurar pacotes NuGet" -ForegroundColor Red
    }
    
    if (-not $containerStatus) {
  Write-Host "  - Iniciar container PostgreSQL (.\start-docker.ps1)" -ForegroundColor Red
    }
}

Write-Host ""
