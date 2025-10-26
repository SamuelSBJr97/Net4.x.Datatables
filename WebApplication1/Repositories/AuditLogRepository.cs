using Npgsql;
using System;
using System.Collections.Generic;
using System.Linq;
using WebApplication1.Models;

namespace WebApplication1.Repositories
{
    public class AuditLogRepository
    {
        private readonly string _connectionString;

        public AuditLogRepository()
        {
            _connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["AuditLogDB"].ConnectionString;
        }

        public DataTablesResponse<AuditLog> GetAuditLogs(DataTablesRequest request)
        {
            var response = new DataTablesResponse<AuditLog>
            {
                Draw = request.Draw,
                Data = new List<AuditLog>()
            };

            try
            {
                using (var connection = new NpgsqlConnection(_connectionString))
                {
                    connection.Open();

                    // Obter total de registros
                    response.RecordsTotal = GetTotalRecords(connection);

                    // Construir query com filtros
                    Dictionary<string, object> parameters;
                    var query = BuildQuery(request, out parameters);

                    // Obter total filtrado
                    response.RecordsFiltered = GetFilteredRecords(connection, request);

                    // Obter dados paginados
                    using (var command = new NpgsqlCommand(query, connection))
                    {
                        foreach (var param in parameters)
                        {
                            command.Parameters.AddWithValue(param.Key, param.Value);
                        }

                        using (var reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                response.Data.Add(new AuditLog
                                {
                                    Id = reader.GetInt32(0),
                                    UserName = reader.GetString(1),
                                    Action = reader.GetString(2),
                                    EntityName = reader.IsDBNull(3) ? null : reader.GetString(3),
                                    EntityId = reader.IsDBNull(4) ? null : reader.GetString(4),
                                    OldValues = reader.IsDBNull(5) ? null : reader.GetString(5),
                                    NewValues = reader.IsDBNull(6) ? null : reader.GetString(6),
                                    IpAddress = reader.IsDBNull(7) ? null : reader.GetString(7),
                                    UserAgent = reader.IsDBNull(8) ? null : reader.GetString(8),
                                    Timestamp = reader.GetDateTime(9),
                                    Severity = reader.GetString(10),
                                    Message = reader.IsDBNull(11) ? null : reader.GetString(11),
                                    ExceptionDetails = reader.IsDBNull(12) ? null : reader.GetString(12)
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                response.Error = "Erro ao buscar logs: " + ex.Message;
            }

            return response;
        }

        private int GetTotalRecords(NpgsqlConnection connection)
        {
            using (var command = new NpgsqlCommand("SELECT COUNT(*) FROM audit_logs", connection))
            {
                return Convert.ToInt32(command.ExecuteScalar());
            }
        }

        private int GetFilteredRecords(NpgsqlConnection connection, DataTablesRequest request)
        {
            Dictionary<string, object> parameters;
            var whereClause = BuildWhereClause(request, out parameters);
            var query = string.Format("SELECT COUNT(*) FROM audit_logs {0}", whereClause);

            using (var command = new NpgsqlCommand(query, connection))
            {
                foreach (var param in parameters)
                {
                    command.Parameters.AddWithValue(param.Key, param.Value);
                }
                return Convert.ToInt32(command.ExecuteScalar());
            }
        }

        private string BuildQuery(DataTablesRequest request, out Dictionary<string, object> parameters)
        {
            parameters = new Dictionary<string, object>();

            var whereClause = BuildWhereClause(request, out parameters);
            var orderClause = BuildOrderClause(request);

            var query = string.Format(@"
                SELECT id, user_name, action, entity_name, entity_id, old_values, 
         new_values, ip_address, user_agent, timestamp, severity, message, exception_details
     FROM audit_logs
       {0}
    {1}
     LIMIT @limit OFFSET @offset", whereClause, orderClause);

            parameters.Add("@limit", request.Length);
            parameters.Add("@offset", request.Start);

            return query;
        }

        private string BuildWhereClause(DataTablesRequest request, out Dictionary<string, object> parameters)
        {
            parameters = new Dictionary<string, object>();

            if (string.IsNullOrWhiteSpace(request.Search?.Value))
            {
                return "";
            }

            var searchValue = string.Format("%{0}%", request.Search.Value);
            parameters.Add("@search", searchValue);

            return @"WHERE (
                user_name ILIKE @search OR
 action ILIKE @search OR
         entity_name ILIKE @search OR
       entity_id ILIKE @search OR
       severity ILIKE @search OR
                message ILIKE @search OR
            ip_address ILIKE @search
  )";
        }

        private string BuildOrderClause(DataTablesRequest request)
        {
            if (request.Order == null || !request.Order.Any())
            {
                return "ORDER BY timestamp DESC";
            }

            var orderBy = request.Order[0];
            var columnIndex = orderBy.Column;
            var direction = orderBy.Dir.ToUpper() == "ASC" ? "ASC" : "DESC";

            var columns = new[] { "id", "user_name", "action", "entity_name", "entity_id",
         "old_values", "new_values", "ip_address", "user_agent",
    "timestamp", "severity", "message", "exception_details" };

            if (columnIndex >= 0 && columnIndex < columns.Length)
            {
                return string.Format("ORDER BY {0} {1}", columns[columnIndex], direction);
            }

            return "ORDER BY timestamp DESC";
        }

        public Dictionary<string, int> GetStatistics()
        {
            var stats = new Dictionary<string, int>();

            try
            {
                using (var connection = new NpgsqlConnection(_connectionString))
                {
                    connection.Open();

                    // Total de logs
                    using (var command = new NpgsqlCommand("SELECT COUNT(*) FROM audit_logs", connection))
                    {
                        stats["TotalLogs"] = Convert.ToInt32(command.ExecuteScalar());
                    }

                    // Total por severidade
                    using (var command = new NpgsqlCommand(@"
            SELECT severity, COUNT(*) 
      FROM audit_logs 
  GROUP BY severity", connection))
                    {
                        using (var reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                stats[reader.GetString(0)] = reader.GetInt32(1);
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
                // Silenciar erros de estatísticas
            }

            return stats;
        }
    }
}
