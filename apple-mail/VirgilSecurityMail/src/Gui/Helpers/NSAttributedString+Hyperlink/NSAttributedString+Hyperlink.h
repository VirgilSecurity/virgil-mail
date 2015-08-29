#import <Cocoa/Cocoa.h>
#import "HyperlinkTextField.h"

@interface NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
+(NSURL *) _emptyUrl;
@end