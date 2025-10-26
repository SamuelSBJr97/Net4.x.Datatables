# Sistema de Auditoria de Logs com PostgreSQL e DataTables

Este projeto implementa um sistema completo de auditoria de logs usando ASP.NET MVC, PostgreSQL no Docker e DataTables para visualização.

## ?? Funcionalidades

- ? Banco de dados PostgreSQL em container Docker
- ? 100.000 registros de teste pré-carregados
- ? Interface responsiva com DataTables
- ? Paginação server-side para alta performance
- ? Busca e filtros em tempo real
- ? Dashboard com estatísticas
- ? Suporte a múltiplos níveis de severidade (Info, Warning, Error, Critical)

## ?? Pré-requisitos

- Docker Desktop instalado e em execução
- Visual Studio 2019 ou superior
- .NET Framework 4.7.2

## ?? Instalação e Configuração

### 1. Iniciar o Docker com PostgreSQL

Navegue até a pasta raiz do projeto e execute:

```bash
docker-compose up -d
```

Aguarde alguns minutos para que o banco de dados seja criado e os 100.000 registros sejam inseridos.

### 2. Verificar se o container está rodando

```bash
docker ps
```

Você deve ver o container `auditlog_postgres` em execução.

### 3. Verificar os logs da inicialização

```bash
docker logs auditlog_postgres
```

Procure pela mensagem: `Inserção completa: 100.000 registros criados`

### 4. Restaurar pacotes NuGet

No Visual Studio:
- Clique com botão direito na solução
- Selecione "Restore NuGet Packages"

Ou via linha de comando:

```bash
cd WebApplication1
nuget restore
```

### 5. Build e executar o projeto

- Pressione F5 no Visual Studio
- Ou use Ctrl+F5 para executar sem debug

### 6. Acessar a página de Auditoria

Navegue até: `http://localhost:[porta]/Audit`

Ou clique no menu "Auditoria" no topo da página.

## ?? Estrutura do Banco de Dados

### Tabela: audit_logs

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| id | SERIAL | Identificador único |
| user_name | VARCHAR(100) | Nome do usuário |
| action | VARCHAR(100) | Ação realizada |
| entity_name | VARCHAR(100) | Nome da entidade |
| entity_id | VARCHAR(50) | ID da entidade |
| old_values | TEXT | Valores anteriores (JSON) |
| new_values | TEXT | Novos valores (JSON) |
| ip_address | VARCHAR(45) | Endereço IP |
| user_agent | TEXT | User agent do navegador |
| timestamp | TIMESTAMP | Data e hora do log |
| severity | VARCHAR(20) | Nível de severidade |
| message | TEXT | Mensagem descritiva |
| exception_details | TEXT | Detalhes de exceções |

## ?? Interface do Usuário

### Dashboard

- **Total de Logs**: Contador total de registros
- **Info**: Registros informativos
- **Warning**: Avisos
- **Error/Critical**: Erros e críticos

### DataTable

- **Paginação**: 10, 25, 50 ou 100 registros por página
- **Busca global**: Pesquisa em todos os campos
- **Ordenação**: Clique nos cabeçalhos das colunas
- **Responsivo**: Adapta-se a diferentes tamanhos de tela
- **Performance**: Server-side processing para 100k+ registros

## ?? Conexão com o Banco

A connection string está configurada em `Web.config`:

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
- **Containerização**: Docker Compose

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
??? Web.config  # Configurações e connection string
??? packages.config    # Dependências NuGet

docker-compose.yml             # Configuração do Docker
init-db.sql           # Script de inicialização do BD
```

## ?? Testando a Aplicação

### 1. Verificar conexão com banco

```sql
-- Conectar ao PostgreSQL
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB

-- Contar registros
SELECT COUNT(*) FROM audit_logs;

-- Ver alguns registros
SELECT * FROM audit_logs LIMIT 10;

-- Estatísticas por severidade
SELECT severity, COUNT(*) FROM audit_logs GROUP BY severity;

-- Sair
\q
```

### 2. Testar filtros no DataTable

- Digite um nome de usuário na busca (ex: "admin")
- Ordene por data clicando na coluna "Data/Hora"
- Altere o número de registros por página
- Teste a responsividade redimensionando o navegador

## ?? Troubleshooting

### Container não inicia

```bash
# Parar e remover containers
docker-compose down

# Remover volumes (ATENÇÃO: isso apaga os dados)
docker-compose down -v

# Recriar
docker-compose up -d
```

### Erro de conexão

- Verifique se o PostgreSQL está rodando: `docker ps`
- Verifique os logs: `docker logs auditlog_postgres`
- Teste a conexão: `docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB`

### Pacotes NuGet não encontrados

```bash
# No Package Manager Console do Visual Studio
Update-Package -reinstall
```

## ?? Customização

### Adicionar novos campos ao log

1. Altere `init-db.sql` para adicionar colunas
2. Atualize o modelo `AuditLog.cs`
3. Modifique `AuditLogRepository.cs` para mapear os novos campos
4. Adicione colunas no DataTable em `Index.cshtml`

### Alterar dados de teste

Edite a função `DO $$` em `init-db.sql` para customizar:
- Quantidade de registros
- Usuários
- Ações
- Entidades
- Mensagens

## ?? Segurança

**IMPORTANTE**: Em produção:

1. Altere as credenciais do PostgreSQL
2. Use variáveis de ambiente para senhas
3. Configure SSL/TLS para conexões
4. Implemente autenticação e autorização
5. Use prepared statements (já implementado no código)

## ?? Licença

Este projeto é fornecido como exemplo educacional.

## ?? Suporte

Para problemas ou dúvidas:
1. Verifique a seção de Troubleshooting
2. Revise os logs do Docker
3. Verifique as configurações de connection string

---

**Desenvolvido com ?? usando ASP.NET MVC e PostgreSQL**
