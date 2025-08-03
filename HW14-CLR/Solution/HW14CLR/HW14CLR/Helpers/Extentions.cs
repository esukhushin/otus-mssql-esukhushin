using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace HW14CLR.Helpers
{
    public static class Extentions
    {
        public static string GetDescription(this Enum enumValue)
        {
            var enumType = enumValue.GetType();
            var memberInfo = enumType.GetMember(enumValue.ToString())?.FirstOrDefault();
            if (memberInfo != null)
            {
                var attr = memberInfo.GetCustomAttributes(typeof(DescriptionAttribute), false)?.FirstOrDefault();
                if (attr != null)
                    return ((DescriptionAttribute)attr).Description;
            }
            return null;
        }

        public static string GetEmbeddedFileText(this string embeddedResourceName)
        {
            using (var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(embeddedResourceName))
            {
                var sr = new StreamReader(stream);
                return sr.ReadToEnd();
            }
        }
    }
}
