namespace Virgil.Mail.Viewer
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Windows;
    using System.Windows.Media;
    using System.Windows.Media.Imaging;

    using Virgil.Mail.Mvvm;

    /// <summary>
    /// Represents an encrypted mail attachment data.
    /// </summary>
    /// <seealso cref="Virgil.Mail.Mvvm.ViewModel" />
    public class EncryptedAttachmentViewModel : ViewModel
    {
        private static readonly Dictionary<string, ImageSource> IconsCache = new Dictionary<string, ImageSource>();

        /// <summary>
        /// Initializes a new instance of the <see cref="EncryptedAttachmentViewModel"/> class.
        /// </summary>
        public EncryptedAttachmentViewModel(string displayName, string fileName)
        {
            this.DisplayName = displayName;
            this.FileName = fileName;
            this.Icon = GetImageSource(this.FileName);
        }
        
        public string DisplayName { get; private set; }
        public string FileName { get; private set; }
        public ImageSource Icon { get; private set; }

        private static ImageSource GetImageSource(string fileName)
        {
            ImageSource bitmap = null;
            try
            {
                var extension = Path.GetExtension(fileName);

                if (!string.IsNullOrWhiteSpace(extension))
                {
                    extension = extension.ToLowerInvariant();

                    ImageSource value;

                    if (IconsCache.TryGetValue(extension, out value))
                    {
                        bitmap = value;
                    }
                    else
                    {
                        var icon = Icons.IconFromExtension(extension, Icons.SystemIconSize.Small).ToBitmap();

                        bitmap = System.Windows.Interop.Imaging.CreateBitmapSourceFromHBitmap(
                           icon.GetHbitmap(),
                           IntPtr.Zero,
                           Int32Rect.Empty,
                           BitmapSizeOptions.FromWidthAndHeight(icon.Width, icon.Height));

                        IconsCache[extension] = bitmap;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }

            return bitmap;
        }
    }
}