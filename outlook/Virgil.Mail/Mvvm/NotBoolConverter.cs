namespace Virgil.Mail.Common.Mvvm
{
    using System;
    using System.Globalization;
    using System.Windows.Data;

    public sealed class NotBoolConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return !(bool) value;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return !(bool)value;
        }
    }
}