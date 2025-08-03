using System.ComponentModel;

namespace HW14CLR.Enums
{
    public enum EmbeddedResourceEnum
    {
        [Description("HW14CLR.EmbeddedResourceFiles.UsersSchema.xsd")]
        XmlSchema,

        [Description("HW14CLR.EmbeddedResourceFiles.CreateLoggerTable.sql")]
        CreateLoggerTable,

        [Description("HW14CLR.EmbeddedResourceFiles.DropLoggerTable.sql")]
        DropLoggerTable,

        [Description("HW14CLR.EmbeddedResourceFiles.InsertLoggerInfo.sql")]
        InsertLoggerInfo
    }
}
