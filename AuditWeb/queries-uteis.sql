-- ========================================
-- QUERIES ÚTEIS PARA AUDITORIA DE LOGS
-- ========================================

-- 1. Contar total de registros
SELECT COUNT(*) as total_registros FROM audit_logs;

-- 2. Ver últimos 10 logs
SELECT id, timestamp, user_name, action, entity_name, severity, message
FROM audit_logs
ORDER BY timestamp DESC
LIMIT 10;

-- 3. Estatísticas por severidade
SELECT 
    severity,
    COUNT(*) as total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentual
FROM audit_logs
GROUP BY severity
ORDER BY total DESC;

-- 4. Estatísticas por usuário
SELECT 
    user_name,
    COUNT(*) as total_acoes,
    COUNT(DISTINCT action) as acoes_diferentes
FROM audit_logs
GROUP BY user_name
ORDER BY total_acoes DESC;

-- 5. Estatísticas por ação
SELECT 
    action,
    COUNT(*) as total,
    COUNT(DISTINCT user_name) as usuarios_distintos
FROM audit_logs
GROUP BY action
ORDER BY total DESC;

-- 6. Logs de erro/críticos
SELECT id, timestamp, user_name, action, entity_name, message, exception_details
FROM audit_logs
WHERE severity IN ('Error', 'Critical')
ORDER BY timestamp DESC
LIMIT 50;

-- 7. Atividade por hora do dia
SELECT 
    EXTRACT(HOUR FROM timestamp) as hora,
    COUNT(*) as total_logs
FROM audit_logs
GROUP BY hora
ORDER BY hora;

-- 8. Atividade por dia da semana
SELECT 
  TO_CHAR(timestamp, 'Day') as dia_semana,
    EXTRACT(DOW FROM timestamp) as dia_numero,
    COUNT(*) as total_logs
FROM audit_logs
GROUP BY dia_semana, dia_numero
ORDER BY dia_numero;

-- 9. Top 10 IPs mais ativos
SELECT 
    ip_address,
    COUNT(*) as total_acessos,
    COUNT(DISTINCT user_name) as usuarios_distintos
FROM audit_logs
GROUP BY ip_address
ORDER BY total_acessos DESC
LIMIT 10;

-- 10. Buscar logs de um usuário específico
SELECT id, timestamp, action, entity_name, entity_id, severity, message
FROM audit_logs
WHERE user_name = 'admin'
ORDER BY timestamp DESC
LIMIT 20;

-- 11. Buscar logs de uma entidade específica
SELECT id, timestamp, user_name, action, entity_id, old_values, new_values
FROM audit_logs
WHERE entity_name = 'Usuario'
ORDER BY timestamp DESC
LIMIT 20;

-- 12. Logs com exceções
SELECT id, timestamp, user_name, action, severity, message, exception_details
FROM audit_logs
WHERE exception_details IS NOT NULL
ORDER BY timestamp DESC
LIMIT 20;

-- 13. Atividade nos últimos 7 dias
SELECT 
    DATE(timestamp) as data,
  COUNT(*) as total_logs,
    COUNT(DISTINCT user_name) as usuarios_ativos
FROM audit_logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY data
ORDER BY data DESC;

-- 14. Logs de alteração (com valores antigos e novos)
SELECT 
    id, timestamp, user_name, action, entity_name, entity_id,
    old_values, new_values
FROM audit_logs
WHERE action = 'Update' 
  AND old_values IS NOT NULL 
  AND new_values IS NOT NULL
ORDER BY timestamp DESC
LIMIT 20;

-- 15. Resumo geral do sistema
SELECT 
 MIN(timestamp) as primeiro_log,
    MAX(timestamp) as ultimo_log,
    COUNT(*) as total_logs,
    COUNT(DISTINCT user_name) as total_usuarios,
    COUNT(DISTINCT action) as total_acoes,
    COUNT(DISTINCT entity_name) as total_entidades,
    COUNT(CASE WHEN severity = 'Error' THEN 1 END) as total_erros,
    COUNT(CASE WHEN severity = 'Critical' THEN 1 END) as total_criticos
FROM audit_logs;

-- 16. Performance da tabela
SELECT 
    pg_size_pretty(pg_total_relation_size('audit_logs')) as tamanho_total,
    pg_size_pretty(pg_relation_size('audit_logs')) as tamanho_tabela,
    pg_size_pretty(pg_indexes_size('audit_logs')) as tamanho_indices,
    (SELECT reltuples::bigint FROM pg_class WHERE relname = 'audit_logs') as estimativa_linhas;

-- 17. Verificar índices
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'audit_logs';

-- 18. Logs por período do dia
SELECT 
  CASE 
        WHEN EXTRACT(HOUR FROM timestamp) BETWEEN 6 AND 11 THEN 'Manhã'
        WHEN EXTRACT(HOUR FROM timestamp) BETWEEN 12 AND 17 THEN 'Tarde'
   WHEN EXTRACT(HOUR FROM timestamp) BETWEEN 18 AND 23 THEN 'Noite'
        ELSE 'Madrugada'
    END as periodo,
    COUNT(*) as total_logs
FROM audit_logs
GROUP BY periodo
ORDER BY 
    CASE periodo
        WHEN 'Manhã' THEN 1
      WHEN 'Tarde' THEN 2
     WHEN 'Noite' THEN 3
      WHEN 'Madrugada' THEN 4
    END;

-- 19. Análise de logs por entidade e ação
SELECT 
    entity_name,
 action,
    COUNT(*) as total,
    MIN(timestamp) as primeira_ocorrencia,
    MAX(timestamp) as ultima_ocorrencia
FROM audit_logs
WHERE entity_name IS NOT NULL
GROUP BY entity_name, action
ORDER BY total DESC
LIMIT 20;

-- 20. Limpar logs antigos (CUIDADO!)
-- Descomente apenas se quiser deletar logs mais antigos que 1 ano
-- DELETE FROM audit_logs WHERE timestamp < CURRENT_DATE - INTERVAL '1 year';

-- 21. Criar backup da tabela
CREATE TABLE audit_logs_backup AS SELECT * FROM audit_logs;

-- 22. Restaurar do backup
-- TRUNCATE audit_logs;
-- INSERT INTO audit_logs SELECT * FROM audit_logs_backup;

-- 23. Exportar para CSV (via psql)
-- \copy (SELECT * FROM audit_logs ORDER BY timestamp DESC LIMIT 1000) TO '/tmp/audit_logs.csv' WITH CSV HEADER;

-- 24. Ver estatísticas de uso da tabela
SELECT 
    schemaname,
    relname,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    n_tup_ins,
    n_tup_upd,
    n_tup_del
FROM pg_stat_user_tables
WHERE relname = 'audit_logs';

-- 25. Otimizar tabela (vacuuming)
VACUUM ANALYZE audit_logs;

-- ========================================
-- COMANDOS DE MANUTENÇÃO
-- ========================================

-- Recriar índices
REINDEX TABLE audit_logs;

-- Analisar estatísticas
ANALYZE audit_logs;

-- Ver conexões ativas
SELECT * FROM pg_stat_activity WHERE datname = 'AuditLogDB';

-- ========================================
-- FIM DO ARQUIVO
-- ========================================
