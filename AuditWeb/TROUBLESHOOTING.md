# ?? TROUBLESHOOTING - Guia de Solu��o de Problemas

## ?? Diagn�stico R�pido

Antes de tudo, execute o script de testes:

```powershell
.\test-system.ps1
```

Este script verifica automaticamente os 5 pontos mais comuns de falha.

---

## ?? Problemas Comuns e Solu��es

### ?? Problema 1: Docker n�o est� instalado

#### Sintomas
```
docker : O termo 'docker' n�o � reconhecido como nome de cmdlet
```

#### Solu��o
1. Baixe o Docker Desktop: https://www.docker.com/products/docker-desktop
2. Instale seguindo o wizard
3. Reinicie o computador
4. Abra o Docker Desktop
5. Aguarde at� ver "Docker Desktop is running"
6. Execute novamente: `.\start-docker.ps1`

---

### ?? Problema 2: Docker n�o est� rodando

#### Sintomas
```
error during connect: This error may indicate that the docker daemon is not running
```

#### Solu��o
1. Abra o Docker Desktop
2. Aguarde 30-60 segundos
3. Verifique o �cone na bandeja do sistema
4. Deve mostrar "Docker Desktop is running"
5. Execute novamente: `.\start-docker.ps1`

#### Solu��o Alternativa (Windows)
```powershell
# Iniciar servi�o do Docker
Start-Service docker

# Ou atrav�s de servi�os do Windows
services.msc
# Procure por "Docker Desktop Service" e inicie
```

---

### ?? Problema 3: Porta 5432 j� est� em uso

#### Sintomas
```
Error: bind: address already in use
Port 5432 is already allocated
```

#### Diagn�stico
```powershell
# Verificar o que est� usando a porta 5432
netstat -ano | findstr :5432
```

#### Solu��o 1: Parar o PostgreSQL local
```powershell
# Se voc� tem PostgreSQL instalado localmente
Stop-Service postgresql-x64-*

# Ou atrav�s de servi�os
services.msc
# Procure por "PostgreSQL" e pare
```

#### Solu��o 2: Mudar a porta do Docker
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

### ?? Problema 4: Container n�o inicia

#### Sintomas
```
Container exited with code 1
```

#### Diagn�stico
```powershell
# Ver logs do container
docker logs auditlog_postgres

# Ver logs em tempo real
docker logs -f auditlog_postgres
```

#### Solu��es Comuns

**A) Volumes corrompidos**
```powershell
# Parar e remover tudo (ATEN��O: Remove dados!)
docker-compose down -v

# Recriar
docker-compose up -d
```

**B) Permiss�es de arquivo**
```powershell
# Verificar se init-db.sql existe e � leg�vel
Test-Path init-db.sql

# Recriar o arquivo se necess�rio
```

**C) Mem�ria insuficiente**
```powershell
# Docker Desktop > Settings > Resources
# Aumentar Memory para pelo menos 2 GB
```

---

### ?? Problema 5: Dados n�o foram inseridos (menos de 100k registros)

#### Sintomas
```
Total de registros: 0
ou
Total de registros: < 100000
```

#### Diagn�stico
```powershell
# Verificar se o script ainda est� rodando
docker logs -f auditlog_postgres

# Procure por linhas como:
# NOTICE: Inseridos 10000 registros
# NOTICE: Inseridos 20000 registros
# ...
```

#### Solu��o 1: Aguardar Completar
A inser��o de 100k registros pode levar 2-5 minutos. Seja paciente!

#### Solu��o 2: Recriar Container
```powershell
# Se travou, recrie
docker-compose down -v
docker-compose up -d

# Acompanhe o progresso
docker logs -f auditlog_postgres
```

#### Solu��o 3: Verificar Logs de Erro
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

#### Solu��o 1: Limpar e Restaurar
```powershell
# No Visual Studio
# Tools > NuGet Package Manager > Package Manager Console

# Execute:
Update-Package -reinstall

# Ou
dotnet restore
```

#### Solu��o 2: Limpar Cache
```powershell
# Limpar cache do NuGet
dotnet nuget locals all --clear

# No Visual Studio
# Tools > Options > NuGet Package Manager > Clear All NuGet Cache(s)
```

#### Solu��o 3: Usar Script
```powershell
.\install-packages.ps1
```

#### Solu��o 4: Instala��o Manual
No Visual Studio:
1. Tools > NuGet Package Manager > Manage NuGet Packages for Solution
2. Procure por "Npgsql"
3. Instale vers�o 4.1.14
4. Instale depend�ncias se solicitado

---

### ?? Problema 7: Erro de compila��o "Npgsql n�o encontrado"

#### Sintomas
```csharp
The type or namespace name 'Npgsql' could not be found
```

#### Solu��o 1: Verificar Refer�ncias
1. Solution Explorer
2. WebApplication1 > References
3. Verifique se "Npgsql" est� listado
4. Se tiver ?? amarelo, clique direito > Remove
5. Tools > NuGet Package Manager > Install Npgsql

#### Solu��o 2: Rebuild
```powershell
# No Visual Studio
Build > Clean Solution
Build > Rebuild Solution
```

#### Solu��o 3: Verificar packages.config
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

#### Diagn�stico
Veja os logs no Visual Studio (Output window) quando executar com F5.

#### Solu��es Comuns

**A) Erro de conex�o com banco**
```
Npgsql.NpgsqlException: Connection refused
```

Solu��o:
```powershell
# Verificar se PostgreSQL est� rodando
docker ps

# Se n�o estiver, inicie
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

**C) Tabela n�o existe**
```sql
-- Conectar ao PostgreSQL
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB

-- Verificar tabela
\dt

-- Deve mostrar: audit_logs

-- Se n�o existir, recrie o container
-- Exit psql: \q
docker-compose down -v
docker-compose up -d
```

---

### ?? Problema 9: DataTable n�o carrega dados

#### Sintomas
- Tabela mostra "Loading..." infinitamente
- Ou mostra "No data available"

#### Diagn�stico
Abra o Console do navegador (F12) e procure por erros.

#### Solu��es Comuns

**A) Erro 404 - Rota n�o encontrada**
```
GET http://localhost:xxx/Audit/GetLogs 404 (Not Found)
```

Solu��o:
- Verifique se `AuditController.cs` existe
- Verifique se o m�todo `GetLogs` existe e � `[HttpPost]`
- Rebuild a solu��o

**B) Erro 500 - Erro no servidor**
```
POST http://localhost:xxx/Audit/GetLogs 500 (Internal Server Error)
```

Solu��o:
- Veja o erro no Output window do Visual Studio
- Geralmente � erro de conex�o com banco
- Verifique se PostgreSQL est� rodando

**C) Erro de CORS (se usar API separada)**
```
Access-Control-Allow-Origin header is missing
```

Solu��o:
```csharp
// Em WebApiConfig.cs
config.EnableCors(new EnableCorsAttribute("*", "*", "*"));
```

**D) JSON inv�lido**
```
Unexpected token < in JSON at position 0
```

Solu��o:
- A resposta n�o � JSON (provavelmente HTML de erro)
- Verifique o m�todo `GetLogs` no controller
- Certifique-se que retorna `JsonResult`

---

### ?? Problema 10: P�gina demora muito para carregar

#### Sintomas
- Loading > 5 segundos
- Timeout errors

#### Diagn�stico
```sql
-- Verificar performance das queries
EXPLAIN ANALYZE SELECT * FROM audit_logs LIMIT 25;
```

#### Solu��es

**A) �ndices ausentes**
```sql
-- Verificar �ndices
SELECT indexname FROM pg_indexes WHERE tablename = 'audit_logs';

-- Deve mostrar 5 �ndices
-- Se n�o, recrie o banco
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

#### Checklist de Diagn�stico

```powershell
# 1. Container est� rodando?
docker ps
# Deve mostrar auditlog_postgres

# 2. PostgreSQL est� acess�vel?
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB -c "SELECT 1"
# Deve retornar: 1

# 3. Porta est� acess�vel do host?
Test-NetConnection -ComputerName localhost -Port 5432

# 4. Firewall bloqueando?
# Windows Defender Firewall > Allow an app
# Adicione Docker Desktop

# 5. Connection string correta?
# Veja Web.config
```

---

### ?? Problema 12: Estat�sticas n�o aparecem no Dashboard

#### Sintomas
- Cards mostram 0 ou valores incorretos

#### Solu��o 1: Verificar Dados
```powershell
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB -c "SELECT COUNT(*) FROM audit_logs;"
```

#### Solu��o 2: Verificar M�todo GetStatistics
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

#### Solu��o 3: Verificar View
```csharp
// Em Index.cshtml
@if (ViewBag.Statistics != null)
{
    var stats = ViewBag.Statistics as Dictionary<string, int>;
    // Verifique se stats n�o � null
}
```

---

## ?? Ferramentas de Diagn�stico

### 1. Logs do Docker
```powershell
# Ver todos os logs
docker logs auditlog_postgres

# �ltimas 50 linhas
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

-- Ver configura��es de log
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
Veja requisi��es AJAX
Verifique Status Code e Response
```

---

## ?? Scripts de Teste

### Teste 1: Conex�o B�sica
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

### Teste 4: �ndices
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

## ?? Comandos de Emerg�ncia

### Reset Completo (CUIDADO: Remove todos os dados!)
```powershell
# Parar e remover tudo
docker-compose down -v

# Remover imagem (opcional)
docker rmi postgres:15-alpine

# Recriar do zero
docker-compose up -d

# Aguardar ~5 minutos para inser��o dos dados
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

## ?? Checklist de Diagn�stico Completo

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
?? [ ] Solu��o abre sem erros
?? [ ] Pacotes NuGet restaurados
?? [ ] Build sem erros
?? [ ] Todos os arquivos presentes

Configura��o
?? [ ] Web.config com connection string
?? [ ] packages.config com Npgsql
?? [ ] AuditController existe
?? [ ] AuditLogRepository existe
?? [ ] View Audit/Index.cshtml existe
?? [ ] Menu tem link "Auditoria"

Conex�o
?? [ ] Connection string correta
?? [ ] Credenciais corretas
?? [ ] Porta correta
?? [ ] Firewall n�o est� bloqueando
?? [ ] Teste de conex�o OK

Runtime
?? [ ] Aplica��o inicia (F5)
?? [ ] P�gina inicial carrega
?? [ ] Menu "Auditoria" vis�vel
?? [ ] P�gina /Audit carrega
?? [ ] Dashboard mostra n�meros
?? [ ] DataTable mostra dados
```

---

## ?? Dicas para Evitar Problemas

### 1. Sempre use os scripts
```powershell
# Ao inv�s de comandos manuais
.\start-docker.ps1
.\install-packages.ps1
.\test-system.ps1
```

### 2. Aguarde a inicializa��o completa
```powershell
# Depois de docker-compose up
# AGUARDE at� ver:
# "Inser��o completa: 100.000 registros criados"
```

### 3. Mantenha o Docker Desktop aberto
- N�o feche o Docker Desktop enquanto usa a aplica��o
- Configure para iniciar com o Windows

### 4. Use o Visual Studio corretamente
- Sempre fa�a Build antes de executar
- Use F5 (com debug) na primeira vez
- Veja erros no Output window

### 5. Verifique vers�es
```powershell
docker --version    # >= 20.10
dotnet --version    # Framework 4.7.2
```

---

## ?? Recursos Adicionais

### Documenta��o Oficial
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

Se nenhuma solu��o acima funcionou:

1. Execute `.\test-system.ps1` e copie o output
2. Execute `docker logs auditlog_postgres` e copie os logs
3. Tire prints de erros do Visual Studio
4. Abra uma issue com todas essas informa��es

---

**�ltima atualiza��o**: 2025  
**Vers�o**: 1.0

**Lembre-se**: 90% dos problemas s�o resolvidos por:
1. Reiniciar o Docker Desktop
2. Rebuild da solu��o
3. Aguardar a inser��o completa dos dados
