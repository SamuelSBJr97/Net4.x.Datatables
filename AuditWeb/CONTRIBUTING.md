# ?? GUIA DE CONTRIBUIÇÃO - Sistema de Auditoria

## ?? Bem-vindo!

Este guia ajudará você a contribuir ou evoluir este projeto de forma organizada e profissional.

---

## ?? Como Contribuir

### 1. ?? Fluxo de Trabalho

```
1. Entenda o código existente
   ?? Leia ESTRUTURA-PROJETO.md
   ?? Veja DIAGRAMA-VISUAL.md
   ?? Execute o projeto localmente

2. Crie uma branch para sua feature
   ?? git checkout -b feature/nome-da-feature

3. Faça suas alterações
   ?? Siga os padrões do projeto
   ?? Comente código complexo
   ?? Mantenha consistência

4. Teste suas alterações
   ?? Build sem erros
   ?? Testes funcionais
   ?? Verifique performance

5. Documente as mudanças
   ?? Atualize README se necessário
   ?? Comente código novo
   ?? Adicione exemplos

6. Commit e push
   ?? git commit -m "feat: descrição clara"
```

---

## ??? Ideias de Melhorias

### ?? Prioridade Alta

#### 1. **Sistema de Autenticação**
```csharp
// Implementar ASP.NET Identity
// Localização sugerida: WebApplication1/Controllers/AccountController.cs

[Authorize]
public class AuditController : Controller
{
    // Apenas usuários autenticados podem acessar
}
```

**Arquivos a criar:**
- `Models/ApplicationUser.cs`
- `Controllers/AccountController.cs`
- `Views/Account/Login.cshtml`
- `Views/Account/Register.cshtml`

**Referências:**
- https://docs.microsoft.com/aspnet/identity

---

#### 2. **Sistema de Autorização (Roles)**
```csharp
// Diferentes níveis de acesso
[Authorize(Roles = "Admin,Auditor")]
public ActionResult Index()
{
    // Código existente
}

[Authorize(Roles = "Admin")]
public ActionResult Delete(int id)
{
    // Apenas admins podem deletar
}
```

**Roles sugeridas:**
- `Admin`: Acesso total
- `Auditor`: Leitura de logs
- `Manager`: Leitura + Estatísticas
- `User`: Visualização limitada

---

#### 3. **Exportação de Dados**
```csharp
// Exportar para Excel, PDF, CSV
public ActionResult Export(string format, DataTablesRequest filters)
{
    switch(format)
    {
        case "excel":
            return ExportToExcel(filters);
        case "pdf":
  return ExportToPdf(filters);
        case "csv":
      return ExportToCsv(filters);
    }
}
```

**Pacotes sugeridos:**
- EPPlus (Excel)
- iTextSharp (PDF)
- CsvHelper (CSV)

**UI:**
```html
<button class="btn btn-success" onclick="exportData('excel')">
    <i class="fas fa-file-excel"></i> Excel
</button>
```

---

### ?? Prioridade Média

#### 4. **Filtros Avançados**
```html
<!-- Adicionar na view Index.cshtml -->
<div class="filters-panel">
    <label>Data Inicial:</label>
    <input type="date" id="dateFrom" />
    
    <label>Data Final:</label>
    <input type="date" id="dateTo" />
    
    <label>Severidade:</label>
    <select id="severity" multiple>
        <option>Info</option>
     <option>Warning</option>
 <option>Error</option>
        <option>Critical</option>
    </select>
    
    <label>Usuário:</label>
    <select id="user"></select>
    
    <button onclick="applyFilters()">Filtrar</button>
</div>
```

**Backend:**
```csharp
public class AdvancedFilters
{
    public DateTime? DateFrom { get; set; }
    public DateTime? DateTo { get; set; }
    public List<string> Severities { get; set; }
    public string UserName { get; set; }
}
```

---

#### 5. **Dashboard com Gráficos**
```html
<!-- Usar Chart.js ou Highcharts -->
<div class="row">
    <div class="col-md-6">
        <canvas id="severityChart"></canvas>
 </div>
    <div class="col-md-6">
        <canvas id="activityChart"></canvas>
    </div>
</div>

<script>
// Gráfico de pizza - Severidade
var ctx = document.getElementById('severityChart').getContext('2d');
var chart = new Chart(ctx, {
    type: 'pie',
    data: {
        labels: ['Info', 'Warning', 'Error', 'Critical'],
  datasets: [{
         data: [71000, 28000, 800, 200]
        }]
    }
});
</script>
```

**Backend:**
```csharp
public JsonResult GetChartData()
{
    var data = _repository.GetStatisticsForChart();
return Json(data);
}
```

---

#### 6. **Visualização de Detalhes (Modal)**
```html
<!-- Modal para exibir detalhes completos -->
<div class="modal" id="detailsModal">
 <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
       <h5>Detalhes do Log #<span id="logId"></span></h5>
   </div>
            <div class="modal-body">
         <dl class="row">
 <dt class="col-3">Usuário:</dt>
        <dd class="col-9" id="userName"></dd>
           
     <dt class="col-3">Valores Antigos:</dt>
      <dd class="col-9"><pre id="oldValues"></pre></dd>
        
   <dt class="col-3">Valores Novos:</dt>
     <dd class="col-9"><pre id="newValues"></pre></dd>
        </dl>
      </div>
        </div>
    </div>
</div>
```

---

### ?? Prioridade Baixa

#### 7. **Logs em Tempo Real (SignalR)**
```csharp
// Hub para logs em tempo real
public class AuditLogHub : Hub
{
    public async Task SendNewLog(AuditLog log)
    {
        await Clients.All.SendAsync("ReceiveLog", log);
    }
}

// Cliente JavaScript
connection.on("ReceiveLog", function(log) {
    // Adiciona nova linha na tabela
    addRowToDataTable(log);
    showNotification("Novo log recebido!");
});
```

---

#### 8. **API REST**
```csharp
// WebApplication1/Controllers/Api/AuditApiController.cs
[RoutePrefix("api/audit")]
public class AuditApiController : ApiController
{
  [HttpGet]
    [Route("logs")]
    public IHttpActionResult GetLogs([FromUri] DataTablesRequest request)
    {
        var response = _repository.GetAuditLogs(request);
 return Ok(response);
    }
    
    [HttpGet]
    [Route("logs/{id}")]
    public IHttpActionResult GetLog(int id)
  {
        var log = _repository.GetLogById(id);
        if (log == null)
      return NotFound();
      return Ok(log);
    }
    
    [HttpPost]
    [Route("logs")]
    public IHttpActionResult CreateLog([FromBody] AuditLog log)
  {
        _repository.InsertLog(log);
  return Created($"api/audit/logs/{log.Id}", log);
 }
}
```

**Documentação Swagger:**
```csharp
// Instalar: Swashbuckle
config.EnableSwagger(c => 
{
    c.SingleApiVersion("v1", "Audit API");
}).EnableSwaggerUi();
```

---

#### 9. **Testes Unitários**
```csharp
// WebApplication1.Tests/Repositories/AuditLogRepositoryTests.cs
[TestClass]
public class AuditLogRepositoryTests
{
    private AuditLogRepository _repository;
    
    [TestInitialize]
    public void Setup()
    {
        _repository = new AuditLogRepository();
    }
    
    [TestMethod]
    public void GetAuditLogs_ShouldReturnPaginatedResults()
    {
        // Arrange
        var request = new DataTablesRequest
    {
         Start = 0,
    Length = 10
  };
   
        // Act
     var response = _repository.GetAuditLogs(request);
        
        // Assert
        Assert.IsNotNull(response);
      Assert.AreEqual(10, response.Data.Count);
        Assert.IsTrue(response.RecordsTotal > 0);
    }
}
```

---

#### 10. **Arquivamento Automático**
```csharp
// Job para arquivar logs antigos
public class ArchiveOldLogsJob
{
    public void Execute()
    {
        var cutoffDate = DateTime.Now.AddYears(-1);
        
 // Mover para tabela de arquivo
        using (var connection = new NpgsqlConnection(_connString))
        {
         connection.Open();
         
// Copiar para arquivo
         var copyCmd = @"
    INSERT INTO audit_logs_archive 
             SELECT * FROM audit_logs 
 WHERE timestamp < @cutoffDate";
            
        using (var cmd = new NpgsqlCommand(copyCmd, connection))
          {
 cmd.Parameters.AddWithValue("@cutoffDate", cutoffDate);
      cmd.ExecuteNonQuery();
         }
            
 // Deletar originais
            var deleteCmd = @"
            DELETE FROM audit_logs 
 WHERE timestamp < @cutoffDate";
            
        using (var cmd = new NpgsqlCommand(deleteCmd, connection))
 {
     cmd.Parameters.AddWithValue("@cutoffDate", cutoffDate);
      cmd.ExecuteNonQuery();
       }
    }
  }
}
```

**Agendar com Hangfire:**
```csharp
RecurringJob.AddOrUpdate(
    () => new ArchiveOldLogsJob().Execute(),
    Cron.Monthly);
```

---

## ?? Padrões de Código

### Nomenclatura

```csharp
// Classes: PascalCase
public class AuditLogRepository { }

// Métodos: PascalCase
public void GetAuditLogs() { }

// Variáveis locais: camelCase
var auditLog = new AuditLog();

// Constantes: UPPER_CASE
private const string CONNECTION_STRING_NAME = "AuditLogDB";

// Private fields: _camelCase
private readonly IAuditRepository _repository;
```

### Comentários

```csharp
/// <summary>
/// Obtém logs de auditoria com paginação server-side
/// </summary>
/// <param name="request">Parâmetros do DataTables</param>
/// <returns>Resposta com dados paginados</returns>
public DataTablesResponse<AuditLog> GetAuditLogs(DataTablesRequest request)
{
    // Comentário de linha única para lógica específica
var whereClause = BuildWhereClause(request, out var parameters);
 
    /* 
     * Comentário de múltiplas linhas
     * para explicar lógica complexa
     */
    return ExecuteQuery(whereClause, parameters);
}
```

### Tratamento de Erros

```csharp
public DataTablesResponse<AuditLog> GetAuditLogs(DataTablesRequest request)
{
    try
    {
        // Código principal
    }
    catch (NpgsqlException ex)
    {
        // Log específico para erros de banco
        Logger.Error($"Erro de banco de dados: {ex.Message}", ex);
        throw new DataAccessException("Erro ao acessar logs", ex);
  }
    catch (Exception ex)
    {
        // Log genérico
        Logger.Error($"Erro inesperado: {ex.Message}", ex);
        throw;
    }
}
```

---

## ?? Testando Suas Alterações

### 1. Checklist de Testes

```
Build
?? [ ] Build sem erros
?? [ ] Build sem warnings críticos
?? [ ] Pacotes NuGet restaurados

Funcionalidade
?? [ ] Feature funciona conforme esperado
?? [ ] Casos extremos testados (edge cases)
?? [ ] Validações funcionando
?? [ ] Mensagens de erro apropriadas

Performance
?? [ ] Queries otimizadas
?? [ ] Sem N+1 queries
?? [ ] Índices adequados
?? [ ] Tempo de resposta < 500ms

UI/UX
?? [ ] Interface responsiva
?? [ ] Funciona em mobile
?? [ ] Sem erros no console
?? [ ] Feedback ao usuário

Segurança
?? [ ] Sem SQL injection
?? [ ] Validação de entrada
?? [ ] Autorização adequada
?? [ ] Dados sensíveis protegidos

Documentação
?? [ ] README atualizado
?? [ ] Comentários no código
?? [ ] Exemplos de uso
?? [ ] Changelog atualizado
```

### 2. Testes Manuais

```powershell
# 1. Teste básico
.\test-system.ps1

# 2. Teste de carga (opcional)
# Usar JMeter ou similar para 100+ requisições simultâneas

# 3. Teste de integração
# Verificar todos os fluxos principais
```

---

## ?? Estrutura de Commits

### Padrão de Mensagens

```
tipo(escopo): descrição curta

Descrição mais detalhada se necessário.

Closes #123
```

### Tipos de Commit

```
feat: Nova funcionalidade
fix: Correção de bug
docs: Mudanças na documentação
style: Formatação, sem mudança de código
refactor: Refatoração de código
test: Adição ou correção de testes
chore: Manutenção, configuração
perf: Melhorias de performance
```

### Exemplos

```bash
# Feature
git commit -m "feat(audit): adicionar exportação para Excel"

# Bug fix
git commit -m "fix(datatable): corrigir ordenação por data"

# Documentação
git commit -m "docs(readme): adicionar seção de troubleshooting"

# Performance
git commit -m "perf(repository): otimizar query de busca com índices"
```

---

## ?? Ferramentas Recomendadas

### Desenvolvimento
- **Visual Studio 2019+**: IDE principal
- **SQL Server Management Studio**: Ou Azure Data Studio para PostgreSQL
- **Postman**: Testar APIs
- **Git**: Controle de versão

### Análise de Código
- **SonarLint**: Análise estática
- **ReSharper**: Refatoração e análise

### Performance
- **ANTS Performance Profiler**: Profiling .NET
- **pgAdmin**: Gerenciamento PostgreSQL
- **Seq**: Logging estruturado

### Testes
- **MSTest**: Unit tests
- **JMeter**: Testes de carga
- **Selenium**: Testes UI

---

## ?? Recursos Úteis

### Documentação Oficial
- [ASP.NET MVC](https://docs.microsoft.com/aspnet/mvc)
- [Npgsql](https://www.npgsql.org/doc/)
- [PostgreSQL](https://www.postgresql.org/docs/)
- [DataTables](https://datatables.net/manual/)
- [Bootstrap](https://getbootstrap.com/docs/)

### Tutoriais
- [SOLID Principles](https://www.c-sharpcorner.com/UploadFile/damubetha/solid-principles-in-C-Sharp/)
- [Repository Pattern](https://docs.microsoft.com/en-us/aspnet/mvc/overview/older-versions/getting-started-with-ef-5-using-mvc-4/implementing-the-repository-and-unit-of-work-patterns-in-an-asp-net-mvc-application)
- [DataTables Server-Side](https://datatables.net/examples/server_side/)

---

## ?? Roadmap Futuro

### Versão 2.0 (Curto Prazo)
- [ ] Autenticação e autorização
- [ ] Exportação de dados (Excel/PDF/CSV)
- [ ] Filtros avançados (data range, multi-select)
- [ ] Modal de detalhes

### Versão 3.0 (Médio Prazo)
- [ ] Dashboard com gráficos
- [ ] API REST completa
- [ ] Logs em tempo real (SignalR)
- [ ] Testes unitários e de integração

### Versão 4.0 (Longo Prazo)
- [ ] Migração para .NET 8
- [ ] Microserviços
- [ ] Kubernetes deployment
- [ ] Elasticsearch para busca avançada
- [ ] Machine Learning para detecção de anomalias

---

## ?? Boas Práticas

### 1. **SOLID Principles**
- **S**ingle Responsibility
- **O**pen/Closed
- **L**iskov Substitution
- **I**nterface Segregation
- **D**ependency Inversion

### 2. **DRY (Don't Repeat Yourself)**
- Extrair código duplicado
- Criar métodos reutilizáveis
- Usar herança quando apropriado

### 3. **KISS (Keep It Simple, Stupid)**
- Preferir soluções simples
- Evitar over-engineering
- Código legível > código "esperto"

### 4. **YAGNI (You Aren't Gonna Need It)**
- Implementar apenas o necessário
- Não antecipar requisitos futuros
- Refatorar quando necessário

---

## ?? Contato e Suporte

Para dúvidas, sugestões ou contribuições:

1. Abra uma issue no repositório
2. Descreva detalhadamente o problema/sugestão
3. Inclua prints ou logs se relevante
4. Aguarde feedback

---

## ? Checklist do Contribuidor

Antes de submeter sua contribuição:

- [ ] Código segue os padrões do projeto
- [ ] Build sem erros
- [ ] Testes passando
- [ ] Documentação atualizada
- [ ] Commits com mensagens claras
- [ ] Código revisado por você mesmo
- [ ] Performance adequada
- [ ] Segurança validada

---

**Obrigado por contribuir! ??**

*Juntos construímos um projeto melhor!*

---

**Última atualização**: 2025  
**Versão**: 1.0
