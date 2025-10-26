# ?? GUIA DE CONTRIBUI��O - Sistema de Auditoria

## ?? Bem-vindo!

Este guia ajudar� voc� a contribuir ou evoluir este projeto de forma organizada e profissional.

---

## ?? Como Contribuir

### 1. ?? Fluxo de Trabalho

```
1. Entenda o c�digo existente
   ?? Leia ESTRUTURA-PROJETO.md
   ?? Veja DIAGRAMA-VISUAL.md
   ?? Execute o projeto localmente

2. Crie uma branch para sua feature
   ?? git checkout -b feature/nome-da-feature

3. Fa�a suas altera��es
   ?? Siga os padr�es do projeto
   ?? Comente c�digo complexo
   ?? Mantenha consist�ncia

4. Teste suas altera��es
   ?? Build sem erros
   ?? Testes funcionais
   ?? Verifique performance

5. Documente as mudan�as
   ?? Atualize README se necess�rio
   ?? Comente c�digo novo
   ?? Adicione exemplos

6. Commit e push
   ?? git commit -m "feat: descri��o clara"
```

---

## ??? Ideias de Melhorias

### ?? Prioridade Alta

#### 1. **Sistema de Autentica��o**
```csharp
// Implementar ASP.NET Identity
// Localiza��o sugerida: WebApplication1/Controllers/AccountController.cs

[Authorize]
public class AuditController : Controller
{
    // Apenas usu�rios autenticados podem acessar
}
```

**Arquivos a criar:**
- `Models/ApplicationUser.cs`
- `Controllers/AccountController.cs`
- `Views/Account/Login.cshtml`
- `Views/Account/Register.cshtml`

**Refer�ncias:**
- https://docs.microsoft.com/aspnet/identity

---

#### 2. **Sistema de Autoriza��o (Roles)**
```csharp
// Diferentes n�veis de acesso
[Authorize(Roles = "Admin,Auditor")]
public ActionResult Index()
{
    // C�digo existente
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
- `Manager`: Leitura + Estat�sticas
- `User`: Visualiza��o limitada

---

#### 3. **Exporta��o de Dados**
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

### ?? Prioridade M�dia

#### 4. **Filtros Avan�ados**
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
    
    <label>Usu�rio:</label>
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

#### 5. **Dashboard com Gr�ficos**
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
// Gr�fico de pizza - Severidade
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

#### 6. **Visualiza��o de Detalhes (Modal)**
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
 <dt class="col-3">Usu�rio:</dt>
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

**Documenta��o Swagger:**
```csharp
// Instalar: Swashbuckle
config.EnableSwagger(c => 
{
    c.SingleApiVersion("v1", "Audit API");
}).EnableSwaggerUi();
```

---

#### 9. **Testes Unit�rios**
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

#### 10. **Arquivamento Autom�tico**
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

## ?? Padr�es de C�digo

### Nomenclatura

```csharp
// Classes: PascalCase
public class AuditLogRepository { }

// M�todos: PascalCase
public void GetAuditLogs() { }

// Vari�veis locais: camelCase
var auditLog = new AuditLog();

// Constantes: UPPER_CASE
private const string CONNECTION_STRING_NAME = "AuditLogDB";

// Private fields: _camelCase
private readonly IAuditRepository _repository;
```

### Coment�rios

```csharp
/// <summary>
/// Obt�m logs de auditoria com pagina��o server-side
/// </summary>
/// <param name="request">Par�metros do DataTables</param>
/// <returns>Resposta com dados paginados</returns>
public DataTablesResponse<AuditLog> GetAuditLogs(DataTablesRequest request)
{
    // Coment�rio de linha �nica para l�gica espec�fica
var whereClause = BuildWhereClause(request, out var parameters);
 
    /* 
     * Coment�rio de m�ltiplas linhas
     * para explicar l�gica complexa
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
        // C�digo principal
    }
    catch (NpgsqlException ex)
    {
        // Log espec�fico para erros de banco
        Logger.Error($"Erro de banco de dados: {ex.Message}", ex);
        throw new DataAccessException("Erro ao acessar logs", ex);
  }
    catch (Exception ex)
    {
        // Log gen�rico
        Logger.Error($"Erro inesperado: {ex.Message}", ex);
        throw;
    }
}
```

---

## ?? Testando Suas Altera��es

### 1. Checklist de Testes

```
Build
?? [ ] Build sem erros
?? [ ] Build sem warnings cr�ticos
?? [ ] Pacotes NuGet restaurados

Funcionalidade
?? [ ] Feature funciona conforme esperado
?? [ ] Casos extremos testados (edge cases)
?? [ ] Valida��es funcionando
?? [ ] Mensagens de erro apropriadas

Performance
?? [ ] Queries otimizadas
?? [ ] Sem N+1 queries
?? [ ] �ndices adequados
?? [ ] Tempo de resposta < 500ms

UI/UX
?? [ ] Interface responsiva
?? [ ] Funciona em mobile
?? [ ] Sem erros no console
?? [ ] Feedback ao usu�rio

Seguran�a
?? [ ] Sem SQL injection
?? [ ] Valida��o de entrada
?? [ ] Autoriza��o adequada
?? [ ] Dados sens�veis protegidos

Documenta��o
?? [ ] README atualizado
?? [ ] Coment�rios no c�digo
?? [ ] Exemplos de uso
?? [ ] Changelog atualizado
```

### 2. Testes Manuais

```powershell
# 1. Teste b�sico
.\test-system.ps1

# 2. Teste de carga (opcional)
# Usar JMeter ou similar para 100+ requisi��es simult�neas

# 3. Teste de integra��o
# Verificar todos os fluxos principais
```

---

## ?? Estrutura de Commits

### Padr�o de Mensagens

```
tipo(escopo): descri��o curta

Descri��o mais detalhada se necess�rio.

Closes #123
```

### Tipos de Commit

```
feat: Nova funcionalidade
fix: Corre��o de bug
docs: Mudan�as na documenta��o
style: Formata��o, sem mudan�a de c�digo
refactor: Refatora��o de c�digo
test: Adi��o ou corre��o de testes
chore: Manuten��o, configura��o
perf: Melhorias de performance
```

### Exemplos

```bash
# Feature
git commit -m "feat(audit): adicionar exporta��o para Excel"

# Bug fix
git commit -m "fix(datatable): corrigir ordena��o por data"

# Documenta��o
git commit -m "docs(readme): adicionar se��o de troubleshooting"

# Performance
git commit -m "perf(repository): otimizar query de busca com �ndices"
```

---

## ?? Ferramentas Recomendadas

### Desenvolvimento
- **Visual Studio 2019+**: IDE principal
- **SQL Server Management Studio**: Ou Azure Data Studio para PostgreSQL
- **Postman**: Testar APIs
- **Git**: Controle de vers�o

### An�lise de C�digo
- **SonarLint**: An�lise est�tica
- **ReSharper**: Refatora��o e an�lise

### Performance
- **ANTS Performance Profiler**: Profiling .NET
- **pgAdmin**: Gerenciamento PostgreSQL
- **Seq**: Logging estruturado

### Testes
- **MSTest**: Unit tests
- **JMeter**: Testes de carga
- **Selenium**: Testes UI

---

## ?? Recursos �teis

### Documenta��o Oficial
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

### Vers�o 2.0 (Curto Prazo)
- [ ] Autentica��o e autoriza��o
- [ ] Exporta��o de dados (Excel/PDF/CSV)
- [ ] Filtros avan�ados (data range, multi-select)
- [ ] Modal de detalhes

### Vers�o 3.0 (M�dio Prazo)
- [ ] Dashboard com gr�ficos
- [ ] API REST completa
- [ ] Logs em tempo real (SignalR)
- [ ] Testes unit�rios e de integra��o

### Vers�o 4.0 (Longo Prazo)
- [ ] Migra��o para .NET 8
- [ ] Microservi�os
- [ ] Kubernetes deployment
- [ ] Elasticsearch para busca avan�ada
- [ ] Machine Learning para detec��o de anomalias

---

## ?? Boas Pr�ticas

### 1. **SOLID Principles**
- **S**ingle Responsibility
- **O**pen/Closed
- **L**iskov Substitution
- **I**nterface Segregation
- **D**ependency Inversion

### 2. **DRY (Don't Repeat Yourself)**
- Extrair c�digo duplicado
- Criar m�todos reutiliz�veis
- Usar heran�a quando apropriado

### 3. **KISS (Keep It Simple, Stupid)**
- Preferir solu��es simples
- Evitar over-engineering
- C�digo leg�vel > c�digo "esperto"

### 4. **YAGNI (You Aren't Gonna Need It)**
- Implementar apenas o necess�rio
- N�o antecipar requisitos futuros
- Refatorar quando necess�rio

---

## ?? Contato e Suporte

Para d�vidas, sugest�es ou contribui��es:

1. Abra uma issue no reposit�rio
2. Descreva detalhadamente o problema/sugest�o
3. Inclua prints ou logs se relevante
4. Aguarde feedback

---

## ? Checklist do Contribuidor

Antes de submeter sua contribui��o:

- [ ] C�digo segue os padr�es do projeto
- [ ] Build sem erros
- [ ] Testes passando
- [ ] Documenta��o atualizada
- [ ] Commits com mensagens claras
- [ ] C�digo revisado por voc� mesmo
- [ ] Performance adequada
- [ ] Seguran�a validada

---

**Obrigado por contribuir! ??**

*Juntos constru�mos um projeto melhor!*

---

**�ltima atualiza��o**: 2025  
**Vers�o**: 1.0
