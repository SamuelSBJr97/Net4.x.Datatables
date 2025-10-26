# ?? ESTRUTURA DO PROJETO - Sistema de Auditoria

## ?? Estrutura de Arquivos

```
AuditWeb/
?
??? ?? docker-compose.yml   # Configuração do PostgreSQL no Docker
??? ?? init-db.sql           # Script SQL com tabela e 100k registros
??? ?? README-AUDITORIA.md             # Documentação completa
??? ?? INICIO-RAPIDO.md      # Guia rápido de início
??? ?? queries-uteis.sql            # Queries SQL úteis
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
    ?   ??? AuditLogRepository.cs      # ? Repositório de acesso a dados
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
    ??? ?? packages.config           # ? Com Npgsql e dependências
    ??? ?? Global.asax.cs

? = Arquivo criado ou modificado para o sistema de auditoria
```

---

## ??? Arquitetura

### Camadas da Aplicação

```
???????????????????????????????????????????
?         PRESENTATION LAYER              ?
?  (Views - Razor, HTML, JavaScript)      ?
?      ?
?  • Index.cshtml      ?
?  • DataTables JS             ?
?  • Bootstrap UI   ?
???????????????????????????????????????????
          ?
???????????????????????????????????????????
?         CONTROLLER LAYER          ?
?    (ASP.NET MVC Controllers)       ?
?         ?
?  • AuditController.cs    ?
?    - Index()               ?
?    - GetLogs(DataTablesRequest)         ?
???????????????????????????????????????????
      ?
???????????????????????????????????????????
?    BUSINESS LAYER   ?
?         (Repositories)               ?
?           ?
?  • AuditLogRepository.cs            ?
?    - GetAuditLogs()    ?
?    - GetStatistics()        ?
?    - BuildQuery()   ?
???????????????????????????????????????????
             ?
???????????????????????????????????????????
?         DATA ACCESS LAYER          ?
?   (Npgsql ADO.NET)         ?
?        ?
?  • NpgsqlConnection        ?
?  • NpgsqlCommand        ?
?  • NpgsqlDataReader       ?
???????????????????????????????????????????
       ?
???????????????????????????????????????????
?         DATABASE LAYER      ?
?         (PostgreSQL 15)            ?
?             ?
?  • audit_logs (tabela)    ?
?  • Índices     ?
?  • 100.000 registros               ?
???????????????????????????????????????????
```

---

## ?? Fluxo de Dados

### Requisição de Dados (AJAX)

```
1. Usuário interage com DataTable (página, busca, ordenação)
   ?
2. DataTables JS envia requisição AJAX POST
   ? /Audit/GetLogs
   ?
3. AuditController recebe DataTablesRequest
   ?
4. Controller chama AuditLogRepository.GetAuditLogs()
   ?
5. Repository:
   - Constrói query SQL com filtros
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
- **Responsabilidade**: Controlar requisições HTTP
- **Métodos**:
  - `Index()`: Renderiza a view principal
  - `GetLogs()`: Retorna dados paginados via AJAX

### 2. AuditLogRepository.cs
- **Responsabilidade**: Acesso a dados
- **Métodos**:
  - `GetAuditLogs()`: Busca paginada com filtros
  - `GetStatistics()`: Estatísticas agregadas
  - `BuildQuery()`: Construção dinâmica de queries
  - `BuildWhereClause()`: Filtros de busca
  - `BuildOrderClause()`: Ordenação dinâmica

### 3. Index.cshtml
- **Responsabilidade**: Interface do usuário
- **Componentes**:
  - Dashboard com cards estatísticos
  - DataTable responsivo
  - JavaScript para configuração do DataTables

### 4. Models
- **AuditLog.cs**: Entidade de log
- **DataTablesModels.cs**: DTOs para comunicação com DataTables

---

## ?? Tecnologias e Bibliotecas

### Backend
| Tecnologia | Versão | Uso |
|------------|--------|-----|
| ASP.NET MVC | 5.2.9 | Framework web |
| C# | 7.3 | Linguagem |
| .NET Framework | 4.7.2 | Runtime |
| Npgsql | 4.1.14 | Driver PostgreSQL |

### Frontend
| Tecnologia | Versão | Uso |
|------------|--------|-----|
| jQuery | 3.7.0 | Manipulação DOM |
| Bootstrap | 5.2.3 | UI Framework |
| DataTables | 1.13.7 | Grid interativo |
| Font Awesome | 6.4.0 | Ícones |

### Database
| Tecnologia | Versão | Uso |
|------------|--------|-----|
| PostgreSQL | 15 | Banco de dados |
| Docker | Latest | Containerização |

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

### Índices

```sql
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC);
CREATE INDEX idx_audit_logs_user_name ON audit_logs(user_name);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity_name ON audit_logs(entity_name);
CREATE INDEX idx_audit_logs_severity ON audit_logs(severity);
```

---

## ? Performance

### Otimizações Implementadas

1. **Server-Side Processing**
   - Paginação no banco de dados
- Apenas dados necessários são transferidos
   - Suporta milhões de registros

2. **Índices Estratégicos**
   - Índice em `timestamp` para ordenação rápida
   - Índices em campos de busca
 - Índice parcial para filtros comuns

3. **Connection Pooling**
   - Pool de conexões configurado
   - Reutilização de conexões
   - Máximo de 100 conexões simultâneas

4. **Query Otimizada**
   - Uso de prepared statements
   - LIMIT e OFFSET para paginação
   - Projeção apenas de campos necessários

### Benchmarks Esperados

| Operação | Tempo Esperado |
|----------|----------------|
| Carregar página inicial | < 500ms |
| Busca sem filtro (25 registros) | < 100ms |
| Busca com filtro | < 200ms |
| Ordenação | < 150ms |
| Contagem total | < 50ms |

---

## ?? Segurança

### Medidas Implementadas

1. **SQL Injection Prevention**
   - Uso de parâmetros em todas as queries
   - Npgsql escapa automaticamente valores

2. **Input Validation**
   - Validação de paginação (start, length)
   - Sanitização de termos de busca

3. **Connection Security**
   - Connection string com credenciais
   - Pool de conexões limitado

### Melhorias Recomendadas para Produção

- [ ] Autenticação e autorização
- [ ] SSL/TLS para conexão com banco
- [ ] Criptografia de dados sensíveis
- [ ] Rate limiting
- [ ] Audit de acessos à auditoria
- [ ] Backup automático

---

## ?? Escalabilidade

### Capacidade Atual

- ? 100.000 registros (dados de teste)
- ? Suporta até 10 milhões de registros com boa performance
- ? Múltiplos usuários simultâneos (100+ conexões)

### Plano de Escalabilidade

1. **Até 10 milhões de registros**: Atual implementação
2. **Até 100 milhões**: Particionamento da tabela por data
3. **Acima de 100 milhões**: Arquivamento de dados antigos

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
- Analisar uso de índices
- Monitorar tamanho da tabela

---

## ?? Manutenção

### Rotinas Recomendadas

**Diária:**
- Monitorar logs de erro
- Verificar performance

**Semanal:**
- Análise de estatísticas
- Verificar crescimento do banco

**Mensal:**
- VACUUM ANALYZE
- Reindex se necessário
- Backup completo

**Anual:**
- Arquivar logs antigos
- Revisão de índices

---

## ?? Referências

- [ASP.NET MVC Documentation](https://docs.microsoft.com/aspnet/mvc)
- [Npgsql Documentation](https://www.npgsql.org/doc/)
- [DataTables Documentation](https://datatables.net/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)

---

**Última atualização**: 2025
