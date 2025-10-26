# ?? TROUBLESHOOTING - Guia de Solução de Problemas

## ?? Diagnóstico Rápido

Antes de tudo, execute o script de testes:

```powershell
.\test-system.ps1
```

Este script verifica automaticamente os 5 pontos mais comuns de falha.

---

## ?? Problemas Comuns e Soluções

### ?? Problema 1: Docker não está instalado

#### Sintomas
```
docker : O termo 'docker' não é reconhecido como nome de cmdlet
```

#### Solução
1. Baixe o Docker Desktop: https://www.docker.com/products/docker-desktop
2. Instale seguindo o wizard
3. Reinicie o computador
4. Abra o Docker Desktop
5. Aguarde até ver "Docker Desktop is running"
6. Execute novamente: `.\start-docker.ps1`

---

### ?? Problema 2: Docker não está rodando

#### Sintomas
```
error during connect: This error may indicate that the docker daemon is not running
```

#### Solução
1. Abra o Docker Desktop
2. Aguarde 30-60 segundos
3. Verifique o ícone na bandeja do sistema
4. Deve mostrar "Docker Desktop is running"
5. Execute novamente: `.\start-docker.ps1`

#### Solução Alternativa (Windows)
```powershell
# Iniciar serviço do Docker
Start-Service docker

# Ou através de serviços do Windows
services.msc
# Procure por "Docker Desktop Service" e inicie
```

---

### ?? Problema 3: Porta 5432 já está em uso

#### Sintomas
```
Error: bind: address already in use
Port 5432 is already allocated
```

#### Diagnóstico
```powershell
# Verificar o que está usando a porta 5432
netstat -ano | findstr :5432
```

#### Solução 1: Parar o PostgreSQL local
```powershell
# Se você tem PostgreSQL instalado localmente
Stop-Service postgresql-x64-*

# Ou através de serviços
services.msc
# Procure por "PostgreSQL" e pare
```

#### Solução 2: Mudar a porta do Docker
Edite `docker-compose.yml`:
```yaml
ports:
  - "5433:5432"  # Mude 5432 para 5433 (ou outra porta livre)
```

E atualize `Web.config`:
```xml
<add name="AuditLogDB" 
     connectionString="Host=localhost;Port=5433;Database=AuditLogDB;..." />
```

---

### ?? Problema 4: Container não inicia

#### Sintomas
```
Container exited with code 1
```

#### Diagnóstico
```powershell
# Ver logs do container
docker logs auditlog_postgres

# Ver logs em tempo real
docker logs -f auditlog_postgres
```

#### Soluções Comuns

**A) Volumes corrompidos**
```powershell
# Parar e remover tudo (ATENÇÃO: Remove dados!)
docker-compose down -v

# Recriar
docker-compose up -d
```

**B) Permissões de arquivo**
```powershell
# Verificar se init-db.sql existe e é legível
Test-Path init-db.sql

# Recriar o arquivo se necessário
```

**C) Memória insuficiente**
```powershell
# Docker Desktop > Settings > Resources
# Aumentar Memory para pelo menos 2 GB
```

---

### ?? Problema 5: Dados não foram inseridos (menos de 100k registros)

#### Sintomas
```
Total de registros: 0
ou
Total de registros: < 100000
```

#### Diagnóstico
```powershell
# Verificar se o script ainda está rodando
docker logs -f auditlog_postgres

# Procure por linhas como:
# NOTICE: Inseridos 10000 registros
# NOTICE: Inseridos 20000 registros
# ...
```

#### Solução 1: Aguardar Completar
A inserção de 100k registros pode levar 2-5 minutos. Seja paciente!

#### Solução 2: Recriar Container
```powershell
# Se travou, recrie
docker-compose down -v
docker-compose up -d

# Acompanhe o progresso
docker logs -f auditlog_postgres
```

#### Solução 3: Verificar Logs de Erro
```powershell
docker logs auditlog_postgres | Select-String -Pattern "ERROR"
```

---

### ?? Problema 6: Erro ao restaurar pacotes NuGet

#### Sintomas
```
Package 'Npgsql' is not found
Unable to resolve dependency
```

#### Solução 1: Limpar e Restaurar
```powershell
# No Visual Studio
# Tools > NuGet Package Manager > Package Manager Console

# Execute:
Update-Package -reinstall

# Ou
dotnet restore
```

#### Solução 2: Limpar Cache
```powershell
# Limpar cache do NuGet
dotnet nuget locals all --clear

# No Visual Studio
# Tools > Options > NuGet Package Manager > Clear All NuGet Cache(s)
```

#### Solução 3: Usar Script
```powershell
.\install-packages.ps1
```

#### Solução 4: Instalação Manual
No Visual Studio:
1. Tools > NuGet Package Manager > Manage NuGet Packages for Solution
2. Procure por "Npgsql"
3. Instale versão 4.1.14
4. Instale dependências se solicitado

---

### ?? Problema 7: Erro de compilação "Npgsql não encontrado"

#### Sintomas
```csharp
The type or namespace name 'Npgsql' could not be found
```

#### Solução 1: Verificar Referências
1. Solution Explorer
2. WebApplication1 > References
3. Verifique se "Npgsql" está listado
4. Se tiver ?? amarelo, clique direito > Remove
5. Tools > NuGet Package Manager > Install Npgsql

#### Solução 2: Rebuild
```powershell
# No Visual Studio
Build > Clean Solution
Build > Rebuild Solution
```

#### Solução 3: Verificar packages.config
Certifique-se que existe a linha:
```xml
<package id="Npgsql" version="4.1.14" targetFramework="net472" />
```

---

### ?? Problema 8: Erro 500 ao acessar /Audit

#### Sintomas
```
HTTP Error 500 - Internal Server Error
```

#### Diagnóstico
Veja os logs no Visual Studio (Output window) quando executar com F5.

#### Soluções Comuns

**A) Erro de conexão com banco**
```
Npgsql.NpgsqlException: Connection refused
```

Solução:
```powershell
# Verificar se PostgreSQL está rodando
docker ps

# Se não estiver, inicie
.\start-docker.ps1
```

**B) Connection string incorreta**
Verifique em `Web.config`:
```xml
<connectionStrings>
  <add name="AuditLogDB" 
       connectionString="Host=localhost;Port=5432;Database=AuditLogDB;Username=audituser;Password=Audit@123;Pooling=true;Maximum Pool Size=100;" 
   providerName="Npgsql" />
</connectionStrings>
```

**C) Tabela não existe**
```sql
-- Conectar ao PostgreSQL
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB

-- Verificar tabela
\dt

-- Deve mostrar: audit_logs

-- Se não existir, recrie o container
-- Exit psql: \q
docker-compose down -v
docker-compose up -d
```

---

### ?? Problema 9: DataTable não carrega dados

#### Sintomas
- Tabela mostra "Loading..." infinitamente
- Ou mostra "No data available"

#### Diagnóstico
Abra o Console do navegador (F12) e procure por erros.

#### Soluções Comuns

**A) Erro 404 - Rota não encontrada**
```
GET http://localhost:xxx/Audit/GetLogs 404 (Not Found)
```

Solução:
- Verifique se `AuditController.cs` existe
- Verifique se o método `GetLogs` existe e é `[HttpPost]`
- Rebuild a solução

**B) Erro 500 - Erro no servidor**
```
POST http://localhost:xxx/Audit/GetLogs 500 (Internal Server Error)
```

Solução:
- Veja o erro no Output window do Visual Studio
- Geralmente é erro de conexão com banco
- Verifique se PostgreSQL está rodando

**C) Erro de CORS (se usar API separada)**
```
Access-Control-Allow-Origin header is missing
```

Solução:
```csharp
// Em WebApiConfig.cs
config.EnableCors(new EnableCorsAttribute("*", "*", "*"));
```

**D) JSON inválido**
```
Unexpected token < in JSON at position 0
```

Solução:
- A resposta não é JSON (provavelmente HTML de erro)
- Verifique o método `GetLogs` no controller
- Certifique-se que retorna `JsonResult`

---

### ?? Problema 10: Página demora muito para carregar

#### Sintomas
- Loading > 5 segundos
- Timeout errors

#### Diagnóstico
```sql
-- Verificar performance das queries
EXPLAIN ANALYZE SELECT * FROM audit_logs LIMIT 25;
```

#### Soluções

**A) Índices ausentes**
```sql
-- Verificar índices
SELECT indexname FROM pg_indexes WHERE tablename = 'audit_logs';

-- Deve mostrar 5 índices
-- Se não, recrie o banco
```

**B) Muitos registros sem LIMIT**
```csharp
// Certifique-se que o Repository usa LIMIT
var query = $@"
    SELECT ...
    FROM audit_logs
    LIMIT @limit OFFSET @offset";
```

**C) Connection pooling desabilitado**
```xml
<!-- Em Web.config, certifique-se que tem: -->
connectionString="...;Pooling=true;Maximum Pool Size=100;..."
```

**D) PostgreSQL com poucos recursos**
```powershell
# Docker Desktop > Settings > Resources
# Aumentar CPU e Memory
```

---

### ?? Problema 11: Erro "Unable to connect to database"

#### Sintomas
```
Npgsql.NpgsqlException: Unable to connect to any of the specified Postgres hosts
```

#### Checklist de Diagnóstico

```powershell
# 1. Container está rodando?
docker ps
# Deve mostrar auditlog_postgres

# 2. PostgreSQL está acessível?
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB -c "SELECT 1"
# Deve retornar: 1

# 3. Porta está acessível do host?
Test-NetConnection -ComputerName localhost -Port 5432

# 4. Firewall bloqueando?
# Windows Defender Firewall > Allow an app
# Adicione Docker Desktop

# 5. Connection string correta?
# Veja Web.config
```

---

### ?? Problema 12: Estatísticas não aparecem no Dashboard

#### Sintomas
- Cards mostram 0 ou valores incorretos

#### Solução 1: Verificar Dados
```powershell
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB -c "SELECT COUNT(*) FROM audit_logs;"
```

#### Solução 2: Verificar Método GetStatistics
```csharp
// Em AuditLogRepository.cs
public Dictionary<string, int> GetStatistics()
{
    // Adicione logging para debug
var stats = new Dictionary<string, int>();
    // ...
    return stats;
}
```

#### Solução 3: Verificar View
```csharp
// Em Index.cshtml
@if (ViewBag.Statistics != null)
{
    var stats = ViewBag.Statistics as Dictionary<string, int>;
    // Verifique se stats não é null
}
```

---

## ?? Ferramentas de Diagnóstico

### 1. Logs do Docker
```powershell
# Ver todos os logs
docker logs auditlog_postgres

# Últimas 50 linhas
docker logs --tail 50 auditlog_postgres

# Seguir em tempo real
docker logs -f auditlog_postgres

# Logs com timestamp
docker logs -t auditlog_postgres
```

### 2. Logs do Visual Studio
```
Visual Studio > View > Output
Select "Show output from:" > Build / Debug / etc.
```

### 3. Logs do PostgreSQL
```sql
-- Conectar ao PostgreSQL
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB

-- Ver configurações de log
SHOW log_destination;
SHOW log_directory;

-- Ver logs recentes (se configurado)
SELECT * FROM pg_stat_activity;
```

### 4. Console do Navegador
```
F12 > Console
Procure por erros em vermelho
```

### 5. Network do Navegador
```
F12 > Network
Filtre por "XHR" ou "Fetch"
Veja requisições AJAX
Verifique Status Code e Response
```

---

## ?? Scripts de Teste

### Teste 1: Conexão Básica
```powershell
# PowerShell
Test-NetConnection -ComputerName localhost -Port 5432
```

### Teste 2: Query Direta
```powershell
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB -c "SELECT COUNT(*) FROM audit_logs;"
```

### Teste 3: Performance
```sql
-- No psql
\timing on
SELECT * FROM audit_logs LIMIT 1000;
-- Deve ser < 100ms
```

### Teste 4: Índices
```sql
SELECT 
  schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'audit_logs';
```

---

## ?? Comandos de Emergência

### Reset Completo (CUIDADO: Remove todos os dados!)
```powershell
# Parar e remover tudo
docker-compose down -v

# Remover imagem (opcional)
docker rmi postgres:15-alpine

# Recriar do zero
docker-compose up -d

# Aguardar ~5 minutos para inserção dos dados
docker logs -f auditlog_postgres
```

### Rebuild Completo do Projeto
```powershell
# No Visual Studio
# Build > Clean Solution
# Build > Rebuild Solution

# Ou via PowerShell (se tiver MSBuild no PATH)
msbuild /t:Clean
msbuild /t:Rebuild
```

### Reinstalar Todos os Pacotes
```powershell
.\install-packages.ps1

# Ou no Package Manager Console
Update-Package -reinstall
```

---

## ?? Checklist de Diagnóstico Completo

Use este checklist quando nada mais funcionar:

```
Infraestrutura
?? [ ] Docker Desktop instalado
?? [ ] Docker Desktop rodando
?? [ ] Porta 5432 livre
?? [ ] Container auditlog_postgres UP
?? [ ] PostgreSQL respondendo
?? [ ] 100.000 registros inseridos

Projeto
?? [ ] Visual Studio 2019+
?? [ ] .NET Framework 4.7.2
?? [ ] Solução abre sem erros
?? [ ] Pacotes NuGet restaurados
?? [ ] Build sem erros
?? [ ] Todos os arquivos presentes

Configuração
?? [ ] Web.config com connection string
?? [ ] packages.config com Npgsql
?? [ ] AuditController existe
?? [ ] AuditLogRepository existe
?? [ ] View Audit/Index.cshtml existe
?? [ ] Menu tem link "Auditoria"

Conexão
?? [ ] Connection string correta
?? [ ] Credenciais corretas
?? [ ] Porta correta
?? [ ] Firewall não está bloqueando
?? [ ] Teste de conexão OK

Runtime
?? [ ] Aplicação inicia (F5)
?? [ ] Página inicial carrega
?? [ ] Menu "Auditoria" visível
?? [ ] Página /Audit carrega
?? [ ] Dashboard mostra números
?? [ ] DataTable mostra dados
```

---

## ?? Dicas para Evitar Problemas

### 1. Sempre use os scripts
```powershell
# Ao invés de comandos manuais
.\start-docker.ps1
.\install-packages.ps1
.\test-system.ps1
```

### 2. Aguarde a inicialização completa
```powershell
# Depois de docker-compose up
# AGUARDE até ver:
# "Inserção completa: 100.000 registros criados"
```

### 3. Mantenha o Docker Desktop aberto
- Não feche o Docker Desktop enquanto usa a aplicação
- Configure para iniciar com o Windows

### 4. Use o Visual Studio corretamente
- Sempre faça Build antes de executar
- Use F5 (com debug) na primeira vez
- Veja erros no Output window

### 5. Verifique versões
```powershell
docker --version    # >= 20.10
dotnet --version    # Framework 4.7.2
```

---

## ?? Recursos Adicionais

### Documentação Oficial
- [Docker Docs](https://docs.docker.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Npgsql Docs](https://www.npgsql.org/doc/)
- [ASP.NET MVC](https://docs.microsoft.com/aspnet/mvc)

### Comunidades
- [Stack Overflow](https://stackoverflow.com/questions/tagged/postgresql)
- [Docker Forums](https://forums.docker.com/)
- [Reddit r/PostgreSQL](https://reddit.com/r/PostgreSQL)

---

## ?? Suporte

Se nenhuma solução acima funcionou:

1. Execute `.\test-system.ps1` e copie o output
2. Execute `docker logs auditlog_postgres` e copie os logs
3. Tire prints de erros do Visual Studio
4. Abra uma issue com todas essas informações

---

**Última atualização**: 2025  
**Versão**: 1.0

**Lembre-se**: 90% dos problemas são resolvidos por:
1. Reiniciar o Docker Desktop
2. Rebuild da solução
3. Aguardar a inserção completa dos dados
