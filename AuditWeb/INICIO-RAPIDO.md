# ?? GUIA RÁPIDO - Sistema de Auditoria

## Passo a Passo para Executar

### 1?? Iniciar o Docker com PostgreSQL

```powershell
.\start-docker.ps1
```

**Aguarde** a mensagem de sucesso e a criação dos 100.000 registros (pode levar 2-5 minutos).

Para acompanhar o progresso:
```powershell
docker logs -f auditlog_postgres
```

Pressione `Ctrl+C` para sair dos logs.

---

### 2?? Instalar Pacotes NuGet

```powershell
.\install-packages.ps1
```

---

### 3?? Abrir no Visual Studio

1. Abra o arquivo `WebApplication1.sln` no Visual Studio
2. Aguarde o Visual Studio restaurar os pacotes (se necessário)
3. Clique com botão direito na solução ? **Rebuild Solution**

---

### 4?? Executar a Aplicação

- Pressione **F5** (com debug)
- Ou **Ctrl+F5** (sem debug)

---

### 5?? Acessar a Auditoria

No navegador, clique no menu **"Auditoria"** ou acesse diretamente:

```
http://localhost:[porta]/Audit
```

---

## ? Verificação Rápida

### Testar conexão com o banco:

```powershell
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB -c "SELECT COUNT(*) FROM audit_logs;"
```

Deve retornar **100000** registros.

---

## ?? Parar o Docker

```powershell
docker-compose down
```

---

## ?? O que você verá na aplicação?

### Dashboard
- Total de Logs: 100.000
- Contadores por severidade (Info, Warning, Error, Critical)

### DataTable Interativo
- Pesquisa global em tempo real
- Paginação (10, 25, 50, 100 por página)
- Ordenação por qualquer coluna
- Filtros por usuário, ação, severidade, etc.
- Performance otimizada com server-side processing

---

## ?? Funcionalidades Principais

| Funcionalidade | Descrição |
|----------------|-----------|
| **Paginação** | Server-side para alta performance |
| **Busca** | Pesquisa em múltiplos campos |
| **Ordenação** | Por qualquer coluna |
| **Responsivo** | Funciona em mobile/tablet/desktop |
| **Performance** | Suporta milhões de registros |
| **Estatísticas** | Dashboard com métricas em tempo real |

---

## ?? Troubleshooting Rápido

### Erro de conexão?
```powershell
# Verificar se container está rodando
docker ps

# Ver logs
docker logs auditlog_postgres
```

### Pacotes NuGet não encontrados?
No Visual Studio:
- Tools ? NuGet Package Manager ? Package Manager Console
- Execute: `Update-Package -reinstall`

### Build com erros?
1. Clean Solution (Build ? Clean Solution)
2. Rebuild Solution (Build ? Rebuild Solution)
3. Se ainda houver erro, feche e reabra o Visual Studio

---

## ?? Comandos Úteis

```powershell
# Ver containers rodando
docker ps

# Parar container
docker-compose down

# Reiniciar container
docker-compose restart

# Ver logs em tempo real
docker logs -f auditlog_postgres

# Acessar PostgreSQL diretamente
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB

# Contar registros
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB -c "SELECT COUNT(*) FROM audit_logs;"

# Ver estatísticas
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB -c "SELECT severity, COUNT(*) FROM audit_logs GROUP BY severity;"
```

---

## ?? Pronto!

Sua aplicação de auditoria de logs está funcionando com:
- ? PostgreSQL no Docker
- ? 100.000 registros de teste
- ? Interface responsiva com DataTables
- ? Performance otimizada

---

**Documentação completa:** Veja `README-AUDITORIA.md`
