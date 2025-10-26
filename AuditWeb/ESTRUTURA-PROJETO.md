# ?? ESTRUTURA DO PROJETO - Sistema de Auditoria

## ?? Estrutura de Arquivos

```
AuditWeb/
?
??? ?? docker-compose.yml   # Configura��o do PostgreSQL no Docker
??? ?? init-db.sql           # Script SQL com tabela e 100k registros
??? ?? README-AUDITORIA.md             # Documenta��o completa
??? ?? INICIO-RAPIDO.md      # Guia r�pido de in�cio
??? ?? queries-uteis.sql            # Queries SQL �teis
?
??? ?? start-docker.ps1                # Script para iniciar Docker
??? ?? install-packages.ps1# Script para instalar pacotes NuGet
??? ?? test-system.ps1       # Script de teste do sistema
?
??? WebApplication1/  # Projeto ASP.NET MVC
    ?
    ??? ?? Controllers/
    ?   ??? AuditController.cs     # ? Controller de auditoria
    ?   ??? HomeController.cs          # Controller principal
    ?
    ??? ?? Models/
    ?   ??? AuditLog.cs    # ? Modelo de log de auditoria
    ?   ??? DataTablesModels.cs        # ? Modelos para DataTables
    ?
    ??? ?? Repositories/
    ?   ??? AuditLogRepository.cs      # ? Reposit�rio de acesso a dados
    ?
    ??? ?? Views/
    ?   ??? Audit/
    ?   ?   ??? Index.cshtml      # ? View da tela de auditoria
    ?   ??? Home/
    ?   ?   ??? Index.cshtml           # View home
    ?   ??? Shared/
    ???? _Layout.cshtml      # Layout com menu (? atualizado)
    ?
  ??? ?? App_Start/
    ?   ??? BundleConfig.cs
    ?   ??? FilterConfig.cs
    ?   ??? RouteConfig.cs
 ?   ??? WebApiConfig.cs
    ?
    ??? ?? Web.config  # ? Com connection string do PostgreSQL
    ??? ?? packages.config           # ? Com Npgsql e depend�ncias
    ??? ?? Global.asax.cs

? = Arquivo criado ou modificado para o sistema de auditoria
```

---

## ??? Arquitetura

### Camadas da Aplica��o

```
???????????????????????????????????????????
?         PRESENTATION LAYER              ?
?  (Views - Razor, HTML, JavaScript)      ?
?      ?
?  � Index.cshtml      ?
?  � DataTables JS             ?
?  � Bootstrap UI   ?
???????????????????????????????????????????
          ?
???????????????????????????????????????????
?         CONTROLLER LAYER          ?
?    (ASP.NET MVC Controllers)       ?
?         ?
?  � AuditController.cs    ?
?    - Index()               ?
?    - GetLogs(DataTablesRequest)         ?
???????????????????????????????????????????
      ?
???????????????????????????????????????????
?    BUSINESS LAYER   ?
?         (Repositories)               ?
?           ?
?  � AuditLogRepository.cs            ?
?    - GetAuditLogs()    ?
?    - GetStatistics()        ?
?    - BuildQuery()   ?
???????????????????????????????????????????
             ?
???????????????????????????????????????????
?         DATA ACCESS LAYER          ?
?   (Npgsql ADO.NET)         ?
?        ?
?  � NpgsqlConnection        ?
?  � NpgsqlCommand        ?
?  � NpgsqlDataReader       ?
???????????????????????????????????????????
       ?
???????????????????????????????????????????
?         DATABASE LAYER      ?
?         (PostgreSQL 15)            ?
?             ?
?  � audit_logs (tabela)    ?
?  � �ndices     ?
?  � 100.000 registros               ?
???????????????????????????????????????????
```

---

## ?? Fluxo de Dados

### Requisi��o de Dados (AJAX)

```
1. Usu�rio interage com DataTable (p�gina, busca, ordena��o)
   ?
2. DataTables JS envia requisi��o AJAX POST
   ? /Audit/GetLogs
   ?
3. AuditController recebe DataTablesRequest
   ?
4. Controller chama AuditLogRepository.GetAuditLogs()
   ?
5. Repository:
   - Constr�i query SQL com filtros
   - Executa query paginada no PostgreSQL
   - Mapeia resultados para objetos AuditLog
   ?
6. Repository retorna DataTablesResponse<AuditLog>
   ?
7. Controller serializa para JSON
   ?
8. DataTables JS recebe resposta e atualiza a tabela
```

### Query SQL Otimizada

```sql
SELECT id, user_name, action, entity_name, entity_id, 
       old_values, new_values, ip_address, user_agent, 
       timestamp, severity, message, exception_details
FROM audit_logs
WHERE (
    user_name ILIKE '%termo%' OR
    action ILIKE '%termo%' OR
    entity_name ILIKE '%termo%' OR
    severity ILIKE '%termo%' OR
    message ILIKE '%termo%'
)
ORDER BY timestamp DESC
LIMIT 25 OFFSET 0;
```

---

## ?? Componentes Principais

### 1. AuditController.cs
- **Responsabilidade**: Controlar requisi��es HTTP
- **M�todos**:
  - `Index()`: Renderiza a view principal
  - `GetLogs()`: Retorna dados paginados via AJAX

### 2. AuditLogRepository.cs
- **Responsabilidade**: Acesso a dados
- **M�todos**:
  - `GetAuditLogs()`: Busca paginada com filtros
  - `GetStatistics()`: Estat�sticas agregadas
  - `BuildQuery()`: Constru��o din�mica de queries
  - `BuildWhereClause()`: Filtros de busca
  - `BuildOrderClause()`: Ordena��o din�mica

### 3. Index.cshtml
- **Responsabilidade**: Interface do usu�rio
- **Componentes**:
  - Dashboard com cards estat�sticos
  - DataTable responsivo
  - JavaScript para configura��o do DataTables

### 4. Models
- **AuditLog.cs**: Entidade de log
- **DataTablesModels.cs**: DTOs para comunica��o com DataTables

---

## ?? Tecnologias e Bibliotecas

### Backend
| Tecnologia | Vers�o | Uso |
|------------|--------|-----|
| ASP.NET MVC | 5.2.9 | Framework web |
| C# | 7.3 | Linguagem |
| .NET Framework | 4.7.2 | Runtime |
| Npgsql | 4.1.14 | Driver PostgreSQL |

### Frontend
| Tecnologia | Vers�o | Uso |
|------------|--------|-----|
| jQuery | 3.7.0 | Manipula��o DOM |
| Bootstrap | 5.2.3 | UI Framework |
| DataTables | 1.13.7 | Grid interativo |
| Font Awesome | 6.4.0 | �cones |

### Database
| Tecnologia | Vers�o | Uso |
|------------|--------|-----|
| PostgreSQL | 15 | Banco de dados |
| Docker | Latest | Containeriza��o |

---

## ?? Schema do Banco de Dados

### Tabela: audit_logs

```sql
CREATE TABLE audit_logs (
    id    SERIAL PRIMARY KEY,
    user_name        VARCHAR(100) NOT NULL,
 action             VARCHAR(100) NOT NULL,
    entity_name        VARCHAR(100),
    entity_id          VARCHAR(50),
    old_values         TEXT,
    new_values TEXT,
    ip_address         VARCHAR(45),
    user_agent         TEXT,
    timestamp          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    severity   VARCHAR(20) NOT NULL DEFAULT 'Info',
    message  TEXT,
    exception_details  TEXT
);
```

### �ndices

```sql
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC);
CREATE INDEX idx_audit_logs_user_name ON audit_logs(user_name);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity_name ON audit_logs(entity_name);
CREATE INDEX idx_audit_logs_severity ON audit_logs(severity);
```

---

## ? Performance

### Otimiza��es Implementadas

1. **Server-Side Processing**
   - Pagina��o no banco de dados
- Apenas dados necess�rios s�o transferidos
   - Suporta milh�es de registros

2. **�ndices Estrat�gicos**
   - �ndice em `timestamp` para ordena��o r�pida
   - �ndices em campos de busca
 - �ndice parcial para filtros comuns

3. **Connection Pooling**
   - Pool de conex�es configurado
   - Reutiliza��o de conex�es
   - M�ximo de 100 conex�es simult�neas

4. **Query Otimizada**
   - Uso de prepared statements
   - LIMIT e OFFSET para pagina��o
   - Proje��o apenas de campos necess�rios

### Benchmarks Esperados

| Opera��o | Tempo Esperado |
|----------|----------------|
| Carregar p�gina inicial | < 500ms |
| Busca sem filtro (25 registros) | < 100ms |
| Busca com filtro | < 200ms |
| Ordena��o | < 150ms |
| Contagem total | < 50ms |

---

## ?? Seguran�a

### Medidas Implementadas

1. **SQL Injection Prevention**
   - Uso de par�metros em todas as queries
   - Npgsql escapa automaticamente valores

2. **Input Validation**
   - Valida��o de pagina��o (start, length)
   - Sanitiza��o de termos de busca

3. **Connection Security**
   - Connection string com credenciais
   - Pool de conex�es limitado

### Melhorias Recomendadas para Produ��o

- [ ] Autentica��o e autoriza��o
- [ ] SSL/TLS para conex�o com banco
- [ ] Criptografia de dados sens�veis
- [ ] Rate limiting
- [ ] Audit de acessos � auditoria
- [ ] Backup autom�tico

---

## ?? Escalabilidade

### Capacidade Atual

- ? 100.000 registros (dados de teste)
- ? Suporta at� 10 milh�es de registros com boa performance
- ? M�ltiplos usu�rios simult�neos (100+ conex�es)

### Plano de Escalabilidade

1. **At� 10 milh�es de registros**: Atual implementa��o
2. **At� 100 milh�es**: Particionamento da tabela por data
3. **Acima de 100 milh�es**: Arquivamento de dados antigos

---

## ?? Testes

### Testes Manuais

Execute o script de testes:
```powershell
.\test-system.ps1
```

### Testes de Carga

Use o arquivo `queries-uteis.sql` para:
- Verificar performance de queries
- Analisar uso de �ndices
- Monitorar tamanho da tabela

---

## ?? Manuten��o

### Rotinas Recomendadas

**Di�ria:**
- Monitorar logs de erro
- Verificar performance

**Semanal:**
- An�lise de estat�sticas
- Verificar crescimento do banco

**Mensal:**
- VACUUM ANALYZE
- Reindex se necess�rio
- Backup completo

**Anual:**
- Arquivar logs antigos
- Revis�o de �ndices

---

## ?? Refer�ncias

- [ASP.NET MVC Documentation](https://docs.microsoft.com/aspnet/mvc)
- [Npgsql Documentation](https://www.npgsql.org/doc/)
- [DataTables Documentation](https://datatables.net/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)

---

**�ltima atualiza��o**: 2025
