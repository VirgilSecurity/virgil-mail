#import "NSAttributedString+Hyperlink.h"


@implementation NSAttributedString (Hyperlink)

+(NSURL *) _emptyUrl {
    static NSURL * res = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        res = [NSURL URLWithString:@""];
    });
    
    return res;
}

+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL {
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
 	
    [attrString beginEditing];
    [attrString addAttribute : NSLinkAttributeName
                       value : ((nil != aURL) ? aURL : [self _emptyUrl])
                       range : range];
    // make the text appear in blue
    NSColor * color = [NSColor colorWithDeviceRed : ((float)0x25 / 255.0)
                                            green : ((float)0x54 / 255.0)
                                             blue : ((float)0xC7 / 255.0)
                                            alpha : 1.0];
    
    [attrString addAttribute : NSForegroundColorAttributeName
                       value : color
                       range : range];
 	
    // next make the text appear with an underline
    [attrString addAttribute :
     NSUnderlineStyleAttributeName value : [NSNumber numberWithInt : NSUnderlineStyleSingle]
                       range : range];
 	
    [attrString endEditing];
 	
    return attrString;
}
@end