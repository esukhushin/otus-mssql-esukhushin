using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Data;
using HW14CLR.Helpers;
using HW14CLR.Enums;
using System.Data.SqlClient;
using System.IO;
using System.Xml.Linq;
using System.Xml;
using System.Xml.Schema;


namespace HW14CLR
{
    public class XmlValidation
    {
        [SqlProcedure(Name = "HW14CLR.CreateLoggerTable")]
        public static void CreateLoggerTable(out SqlString value)
        {
            value = ExecuteSqlQuery(EmbeddedResourceEnum.CreateLoggerTable);
        }

        [SqlProcedure(Name = "HW14CLR.DropLoggerTable")]
        public static void DropLoggerTable(out SqlString value)
        {
            value = ExecuteSqlQuery(EmbeddedResourceEnum.DropLoggerTable);
            
        }

        [SqlProcedure(Name = "HW14CLR.Validation")]
        public static void Validation(SqlString inputData, out SqlString value)
        {
            try
            {
                var schemaTxt = EmbeddedResourceEnum.XmlSchema.GetDescription()?.GetEmbeddedFileText();
                if (string.IsNullOrEmpty(schemaTxt))
                    throw new Exception($@"Xml schema is null");

                var isValid = true;
                var errors = new StringBuilder();

                var schemaSet = new XmlSchemaSet();
                schemaSet.Add("", XmlReader.Create(new StringReader(schemaTxt)));

                var xDoc = XDocument.Parse(inputData.Value);

                xDoc.Validate(schemaSet, (o, e) =>
                {
                    if (e.Severity == XmlSeverityType.Error)
                    {
                        isValid = false;
                        errors.Append(e.Message);
                    }
                });

                if (isValid)
                {
                    value = ExecuteSqlQuery(EmbeddedResourceEnum.InsertLoggerInfo, GetParameters(xDoc, true));
                }
                else
                {
                    var result = ExecuteSqlQuery(EmbeddedResourceEnum.InsertLoggerInfo, GetParameters(xDoc, false));
                    value = $@"{StatusEnum.ValidationError.GetDescription()} - {errors.ToString()}, {result}";
                }
            }
            catch (Exception ex)
            {
                value = $@"{StatusEnum.InternalError.GetDescription()} - {ex.Message}";
            }
        }

        private static List<Dictionary<string, object>> GetParameters(XDocument XDoc, bool isValid)
        {
            var result = new List<Dictionary<string, object>>();

            if (isValid)
            {
                foreach (var item in XDoc.Root.Descendants("User"))
                {
                    var dictionary = GetDefaultParameters();

                    dictionary["Surname"] = item.Element("Surname")?.Value;
                    dictionary["Name"] = item.Element("Name")?.Value;
                    dictionary["Patronymic"] = item.Element("Patronymic")?.Value;
                    dictionary["Birthday"] = item.Element("Birthday")?.Value;
                    dictionary["Phone"] = item.Element("Phone")?.Value;
                    dictionary["Address"] = item.Element("Address")?.Value;

                    result.Add(dictionary);
                }
            }
            else
            {
                var dictionary = GetDefaultParameters();

                dictionary["InputXml"] = XDoc.ToString();
                dictionary["IsSuccess"] = false;

                result.Add(dictionary);
            }

            return result;

        }

        private static Dictionary<string, object> GetDefaultParameters()
        {
            return new Dictionary<string, object>()
            {
                ["Surname"] = DBNull.Value,
                ["Name"] = DBNull.Value,
                ["Patronymic"] = DBNull.Value,
                ["Birthday"] = DBNull.Value,
                ["Phone"] = DBNull.Value,
                ["Address"] = DBNull.Value,
                ["InputXml"] = DBNull.Value,
                ["IsSuccess"] = true
            };
        }

        private static SqlString ExecuteSqlQuery(EmbeddedResourceEnum embeddedResourceEnum, List<Dictionary<string, object>> parameters = null)
        {
            var sqlQyery = embeddedResourceEnum.GetDescription()?.GetEmbeddedFileText();
            if (string.IsNullOrEmpty(sqlQyery))
                return StatusEnum.InternalError.GetDescription();

            using (var connection = new SqlConnection("context connection = true"))
            {
                SqlTransaction transaction = null;
                try
                {
                    connection.Open();
                    if (parameters?.Any() ?? false)
                    {
                        transaction = connection.BeginTransaction();
                        foreach (var item in parameters)
                        {
                            using (var cmd = new SqlCommand(sqlQyery, connection, transaction))
                            {
                                if (item != null)
                                {
                                    foreach (var parameter in item)
                                    {
                                        var param = new SqlParameter(parameter.Key, parameter.Value);
                                        param.IsNullable = true;
                                        cmd.Parameters.Add(param);
                                    }

                                }

                                cmd.ExecuteNonQuery();
                            }
                        }
                        transaction.Commit();
                    }
                    else
                    {
                        using (var cmd = new SqlCommand(sqlQyery, connection))
                            cmd.ExecuteNonQuery();
                    }

                    return StatusEnum.Success.GetDescription();

                }
                catch (Exception ex)
                {
                    transaction?.Rollback();
                    return $@"{StatusEnum.SqlError.GetDescription()} - {ex.Message}";
                }
                finally
                {
                    transaction?.Dispose();
                }
            }
        }
    }
}