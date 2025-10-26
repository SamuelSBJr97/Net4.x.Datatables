# Sistema de Auditoria de Logs com PostgreSQL e DataTables

Este projeto implementa um sistema completo de auditoria de logs usando ASP.NET MVC, PostgreSQL no Docker e DataTables para visualiza��o.

## ?? Funcionalidades

- ? Banco de dados PostgreSQL em container Docker
- ? 100.000 registros de teste pr�-carregados
- ? Interface responsiva com DataTables
- ? Pagina��o server-side para alta performance
- ? Busca e filtros em tempo real
- ? Dashboard com estat�sticas
- ? Suporte a m�ltiplos n�veis de severidade (Info, Warning, Error, Critical)

## ?? Pr�-requisitos

- Docker Desktop instalado e em execu��o
- Visual Studio 2019 ou superior
- .NET Framework 4.7.2

## ?? Instala��o e Configura��o

### 1. Iniciar o Docker com PostgreSQL

Navegue at� a pasta raiz do projeto e execute:

```bash
docker-compose up -d
```

Aguarde alguns minutos para que o banco de dados seja criado e os 100.000 registros sejam inseridos.

### 2. Verificar se o container est� rodando

```bash
docker ps
```

Voc� deve ver o container `auditlog_postgres` em execu��o.

### 3. Verificar os logs da inicializa��o

```bash
docker logs auditlog_postgres
```

Procure pela mensagem: `Inser��o completa: 100.000 registros criados`

### 4. Restaurar pacotes NuGet

No Visual Studio:
- Clique com bot�o direito na solu��o
- Selecione "Restore NuGet Packages"

Ou via linha de comando:

```bash
cd WebApplication1
nuget restore
```

### 5. Build e executar o projeto

- Pressione F5 no Visual Studio
- Ou use Ctrl+F5 para executar sem debug

### 6. Acessar a p�gina de Auditoria

Navegue at�: `http://localhost:[porta]/Audit`

Ou clique no menu "Auditoria" no topo da p�gina.

## ?? Estrutura do Banco de Dados

### Tabela: audit_logs

| Coluna | Tipo | Descri��o |
|--------|------|-----------|
| id | SERIAL | Identificador �nico |
| user_name | VARCHAR(100) | Nome do usu�rio |
| action | VARCHAR(100) | A��o realizada |
| entity_name | VARCHAR(100) | Nome da entidade |
| entity_id | VARCHAR(50) | ID da entidade |
| old_values | TEXT | Valores anteriores (JSON) |
| new_values | TEXT | Novos valores (JSON) |
| ip_address | VARCHAR(45) | Endere�o IP |
| user_agent | TEXT | User agent do navegador |
| timestamp | TIMESTAMP | Data e hora do log |
| severity | VARCHAR(20) | N�vel de severidade |
| message | TEXT | Mensagem descritiva |
| exception_details | TEXT | Detalhes de exce��es |

## ?? Interface do Usu�rio

### Dashboard

- **Total de Logs**: Contador total de registros
- **Info**: Registros informativos
- **Warning**: Avisos
- **Error/Critical**: Erros e cr�ticos

### DataTable

- **Pagina��o**: 10, 25, 50 ou 100 registros por p�gina
- **Busca global**: Pesquisa em todos os campos
- **Ordena��o**: Clique nos cabe�alhos das colunas
- **Responsivo**: Adapta-se a diferentes tamanhos de tela
- **Performance**: Server-side processing para 100k+ registros

## ?? Conex�o com o Banco

A connection string est� configurada em `Web.config`:

```xml
<connectionStrings>
<add name="AuditLogDB" 
       connectionString="Host=localhost;Port=5432;Database=AuditLogDB;Username=audituser;Password=Audit@123;Pooling=true;Maximum Pool Size=100;" 
       providerName="Npgsql" />
</connectionStrings>
```

## ??? Tecnologias Utilizadas

- **Backend**: ASP.NET MVC 5, C# 7.3, .NET Framework 4.7.2
- **Banco de Dados**: PostgreSQL 15
- **ORM/Driver**: Npgsql 4.1.14
- **Frontend**: Bootstrap 5, jQuery, DataTables 1.13.7
- **Containeriza��o**: Docker Compose

## ?? Estrutura do Projeto

```
WebApplication1/
??? Controllers/
?   ??? AuditController.cs   # Controller principal
??? Models/
?   ??? AuditLog.cs          # Modelo de dados
?   ??? DataTablesModels.cs         # Modelos para DataTables
??? Repositories/
?   ??? AuditLogRepository.cs  # Acesso a dados
??? Views/
?   ??? Audit/
?       ??? Index.cshtml         # Interface de auditoria
??? Web.config  # Configura��es e connection string
??? packages.config    # Depend�ncias NuGet

docker-compose.yml             # Configura��o do Docker
init-db.sql           # Script de inicializa��o do BD
```

## ?? Testando a Aplica��o

### 1. Verificar conex�o com banco

```sql
-- Conectar ao PostgreSQL
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB

-- Contar registros
SELECT COUNT(*) FROM audit_logs;

-- Ver alguns registros
SELECT * FROM audit_logs LIMIT 10;

-- Estat�sticas por severidade
SELECT severity, COUNT(*) FROM audit_logs GROUP BY severity;

-- Sair
\q
```

### 2. Testar filtros no DataTable

- Digite um nome de usu�rio na busca (ex: "admin")
- Ordene por data clicando na coluna "Data/Hora"
- Altere o n�mero de registros por p�gina
- Teste a responsividade redimensionando o navegador

## ?? Troubleshooting

### Container n�o inicia

```bash
# Parar e remover containers
docker-compose down

# Remover volumes (ATEN��O: isso apaga os dados)
docker-compose down -v

# Recriar
docker-compose up -d
```

### Erro de conex�o

- Verifique se o PostgreSQL est� rodando: `docker ps`
- Verifique os logs: `docker logs auditlog_postgres`
- Teste a conex�o: `docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB`

### Pacotes NuGet n�o encontrados

```bash
# No Package Manager Console do Visual Studio
Update-Package -reinstall
```

## ?? Customiza��o

### Adicionar novos campos ao log

1. Altere `init-db.sql` para adicionar colunas
2. Atualize o modelo `AuditLog.cs`
3. Modifique `AuditLogRepository.cs` para mapear os novos campos
4. Adicione colunas no DataTable em `Index.cshtml`

### Alterar dados de teste

Edite a fun��o `DO $$` em `init-db.sql` para customizar:
- Quantidade de registros
- Usu�rios
- A��es
- Entidades
- Mensagens

## ?? Seguran�a

**IMPORTANTE**: Em produ��o:

1. Altere as credenciais do PostgreSQL
2. Use vari�veis de ambiente para senhas
3. Configure SSL/TLS para conex�es
4. Implemente autentica��o e autoriza��o
5. Use prepared statements (j� implementado no c�digo)

## ?? Licen�a

Este projeto � fornecido como exemplo educacional.

## ?? Suporte

Para problemas ou d�vidas:
1. Verifique a se��o de Troubleshooting
2. Revise os logs do Docker
3. Verifique as configura��es de connection string

---

**Desenvolvido com ?? usando ASP.NET MVC e PostgreSQL**
