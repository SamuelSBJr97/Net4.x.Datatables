using System;

namespace WebApplication1.Models
{
    public class AuditLog
    {
        public int Id { get; set; }
        public string UserName { get; set; }
        public string Action { get; set; }
        public string EntityName { get; set; }
        public string EntityId { get; set; }
        public string OldValues { get; set; }
        public string NewValues { get; set; }
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
        public DateTime Timestamp { get; set; }
        public string Severity { get; set; }
        public string Message { get; set; }
        public string ExceptionDetails { get; set; }
    }
}
