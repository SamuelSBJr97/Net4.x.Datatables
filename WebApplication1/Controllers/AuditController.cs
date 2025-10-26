using System.Web.Mvc;
using WebApplication1.Models;
using WebApplication1.Repositories;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System.Text;

namespace WebApplication1.Controllers
{
    public class AuditController : Controller
    {
        private readonly AuditLogRepository _repository;

        public AuditController()
        {
            _repository = new AuditLogRepository();
        }

        // GET: Audit
        public ActionResult Index()
        {
            var stats = _repository.GetStatistics();
            ViewBag.Statistics = stats;
            return View();
        }

        // POST: Audit/GetLogs (chamada AJAX do DataTables)
        [HttpPost]
        public ContentResult GetLogs(DataTablesRequest request)
        {
            var response = _repository.GetAuditLogs(request);

            // Configurar serialização para camelCase (compatível com DataTables)
            var jsonSettings = new JsonSerializerSettings
            {
                ContractResolver = new CamelCasePropertyNamesContractResolver(),
                Formatting = Formatting.None
            };

            var json = JsonConvert.SerializeObject(response, jsonSettings);

            return Content(json, "application/json", Encoding.UTF8);
        }

        // GET: Audit/Details/5
        public ActionResult Details(int id)
        {
            // Implementar se necessário
            return View();
        }
    }
}
