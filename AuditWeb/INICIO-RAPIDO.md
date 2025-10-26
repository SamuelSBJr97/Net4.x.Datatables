# ?? GUIA R�PIDO - Sistema de Auditoria

## Passo a Passo para Executar

### 1?? Iniciar o Docker com PostgreSQL

```powershell
.\start-docker.ps1
```

**Aguarde** a mensagem de sucesso e a cria��o dos 100.000 registros (pode levar 2-5 minutos).

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
2. Aguarde o Visual Studio restaurar os pacotes (se necess�rio)
3. Clique com bot�o direito na solu��o ? **Rebuild Solution**

---

### 4?? Executar a Aplica��o

- Pressione **F5** (com debug)
- Ou **Ctrl+F5** (sem debug)

---

### 5?? Acessar a Auditoria

No navegador, clique no menu **"Auditoria"** ou acesse diretamente:

```
http://localhost:[porta]/Audit
```

---

## ? Verifica��o R�pida

### Testar conex�o com o banco:

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

## ?? O que voc� ver� na aplica��o?

### Dashboard
- Total de Logs: 100.000
- Contadores por severidade (Info, Warning, Error, Critical)

### DataTable Interativo
- Pesquisa global em tempo real
- Pagina��o (10, 25, 50, 100 por p�gina)
- Ordena��o por qualquer coluna
- Filtros por usu�rio, a��o, severidade, etc.
- Performance otimizada com server-side processing

---

## ?? Funcionalidades Principais

| Funcionalidade | Descri��o |
|----------------|-----------|
| **Pagina��o** | Server-side para alta performance |
| **Busca** | Pesquisa em m�ltiplos campos |
| **Ordena��o** | Por qualquer coluna |
| **Responsivo** | Funciona em mobile/tablet/desktop |
| **Performance** | Suporta milh�es de registros |
| **Estat�sticas** | Dashboard com m�tricas em tempo real |

---

## ?? Troubleshooting R�pido

### Erro de conex�o?
```powershell
# Verificar se container est� rodando
docker ps

# Ver logs
docker logs auditlog_postgres
```

### Pacotes NuGet n�o encontrados?
No Visual Studio:
- Tools ? NuGet Package Manager ? Package Manager Console
- Execute: `Update-Package -reinstall`

### Build com erros?
1. Clean Solution (Build ? Clean Solution)
2. Rebuild Solution (Build ? Rebuild Solution)
3. Se ainda houver erro, feche e reabra o Visual Studio

---

## ?? Comandos �teis

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

# Ver estat�sticas
docker exec -it auditlog_postgres psql -U audituser -d AuditLogDB -c "SELECT severity, COUNT(*) FROM audit_logs GROUP BY severity;"
```

---

## ?? Pronto!

Sua aplica��o de auditoria de logs est� funcionando com:
- ? PostgreSQL no Docker
- ? 100.000 registros de teste
- ? Interface responsiva com DataTables
- ? Performance otimizada

---

**Documenta��o completa:** Veja `README-AUDITORIA.md`
