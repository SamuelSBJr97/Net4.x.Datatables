using System.Web.Mvc;
using WebApplication1.Models;
using WebApplication1.Repositories;

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
        public JsonResult GetLogs(DataTablesRequest request)
        {
            var response = _repository.GetAuditLogs(request);
    return Json(response);
    }

        // GET: Audit/Details/5
        public ActionResult Details(int id)
        {
         // Implementar se necessário
        return View();
        }
    }
}
