-- Limpar tabela se necessário
-- TRUNCATE TABLE audit_logs;

-- Função para gerar dados aleatórios (caso não exista)
CREATE OR REPLACE FUNCTION random_between(low INT, high INT) 
RETURNS INT AS $$
BEGIN
   RETURN floor(random()* (high-low + 1) + low);
END;
$$ LANGUAGE plpgsql;

-- Inserir 100.000 registros de teste
DO $$
DECLARE
    i INT;
    random_users TEXT[] := ARRAY['admin', 'user1', 'user2', 'manager', 'supervisor', 'operator', 'developer', 'analyst', 'guest', 'system'];
    random_actions TEXT[] := ARRAY['Login', 'Logout', 'Create', 'Update', 'Delete', 'View', 'Export', 'Import', 'Download', 'Upload'];
    random_entities TEXT[] := ARRAY['Usuario', 'Produto', 'Pedido', 'Cliente', 'Relatorio', 'Configuracao', 'Documento', 'Categoria', 'Fornecedor', 'Estoque'];
    random_severities TEXT[] := ARRAY['Info', 'Info', 'Info', 'Warning', 'Warning', 'Error', 'Critical'];
    random_ips TEXT[] := ARRAY['192.168.1.', '10.0.0.', '172.16.0.', '192.168.0.'];
    random_messages TEXT[] := ARRAY[
        'Operacao realizada com sucesso',
        'Registro atualizado',
        'Novo registro criado',
        'Registro removido',
     'Acesso ao sistema',
        'Tentativa de acesso',
        'Dados exportados',
        'Configuracao alterada',
   'Backup realizado',
        'Relatorio gerado'
    ];
BEGIN
    FOR i IN 1..100000 LOOP
     INSERT INTO audit_logs (
   user_name,
      action,
  entity_name,
       entity_id,
    old_values,
     new_values,
    ip_address,
            user_agent,
            timestamp,
severity,
            message,
        exception_details
        ) VALUES (
        random_users[random_between(1, array_length(random_users, 1))],
    random_actions[random_between(1, array_length(random_actions, 1))],
  random_entities[random_between(1, array_length(random_entities, 1))],
         'ID-' || LPAD(random_between(1, 9999)::TEXT, 4, '0'),
      CASE WHEN random() > 0.5 THEN '{"status":"old","value":"' || random_between(1, 100) || '"}' ELSE NULL END,
    CASE WHEN random() > 0.5 THEN '{"status":"new","value":"' || random_between(1, 100) || '"}' ELSE NULL END,
       random_ips[random_between(1, array_length(random_ips, 1))] || random_between(1, 254)::TEXT,
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          CURRENT_TIMESTAMP - (random() * INTERVAL '365 days'),
            random_severities[random_between(1, array_length(random_severities, 1))],
   random_messages[random_between(1, array_length(random_messages, 1))],
            CASE WHEN random() > 0.9 THEN 'Exception: Error at line ' || random_between(1, 1000) ELSE NULL END
        );
        
        -- Log de progresso a cada 10000 registros
        IF i % 10000 = 0 THEN
    RAISE NOTICE 'Inseridos % registros', i;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Insercao completa: 100.000 registros criados';
END $$;

-- Verificar inserção
SELECT COUNT(*) as total_records FROM audit_logs;
