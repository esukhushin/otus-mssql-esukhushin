using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HW14CLR.Enums
{
    public enum StatusEnum
    {
        [Description("Успешно")]
        Success,

        [Description("Ошибка валидации")]
        ValidationError,

        [Description("Ошибка Sql")]
        SqlError,

        [Description("Внутренняя ошибка")]
        InternalError,
    }
}
