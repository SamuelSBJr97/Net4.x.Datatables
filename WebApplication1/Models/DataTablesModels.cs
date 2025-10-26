using System.Collections.Generic;

namespace WebApplication1.Models
{
    public class DataTablesRequest
    {
        public int Draw { get; set; }
        public int Start { get; set; }
        public int Length { get; set; }
    public DataTablesSearch Search { get; set; }
        public List<DataTablesOrder> Order { get; set; }
   public List<DataTablesColumn> Columns { get; set; }
    }

    public class DataTablesSearch
    {
        public string Value { get; set; }
        public bool Regex { get; set; }
    }

    public class DataTablesOrder
    {
        public int Column { get; set; }
        public string Dir { get; set; }
}

    public class DataTablesColumn
    {
   public string Data { get; set; }
        public string Name { get; set; }
        public bool Searchable { get; set; }
        public bool Orderable { get; set; }
        public DataTablesSearch Search { get; set; }
    }

    public class DataTablesResponse<T>
    {
        public int Draw { get; set; }
        public int RecordsTotal { get; set; }
        public int RecordsFiltered { get; set; }
        public List<T> Data { get; set; }
  public string Error { get; set; }
    }
}
