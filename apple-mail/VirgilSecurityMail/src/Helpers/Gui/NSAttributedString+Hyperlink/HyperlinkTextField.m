#import "HyperlinkTextField.h"
#import "NSAttributedString+Hyperlink.h"

@interface HyperlinkTextField ()
@property (nonatomic, readonly) NSArray *hyperlinkInfos;
@property (nonatomic, readonly) NSTextView *textView;

- (void)_resetHyperlinkCursorRects;
@end

#define kHyperlinkInfoCharacterRangeKey @"range"
#define kHyperlinkInfoURLKey            @"url"
#define kHyperlinkInfoRectKey           @"rect"

@implementation HyperlinkTextField

- (void)_hyperlinkTextFieldInit
{
    [self setEditable:NO];
    [self setSelectable:NO];
}


- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self _hyperlinkTextFieldInit];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        [self _hyperlinkTextFieldInit];
    }
    
    return self;
}


- (void)resetCursorRects
{
    [super resetCursorRects];
    [self _resetHyperlinkCursorRects];
}


- (void)_resetHyperlinkCursorRects
{
    for (NSDictionary *info in self.hyperlinkInfos)
    {
        [self addCursorRect:[[info objectForKey:kHyperlinkInfoRectKey] rectValue] cursor:[NSCursor pointingHandCursor]];
    }
}

#pragma mark -
#pragma mark Accessors

- (NSArray *)hyperlinkInfos
{
    NSMutableArray *hyperlinkInfos = [[NSMutableArray alloc] init];
    NSRange stringRange = NSMakeRange(0, [self.attributedStringValue length]);
    __block NSTextView *textView = self.textView;
    [self.attributedStringValue enumerateAttribute:NSLinkAttributeName inRange:stringRange options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
    {
        #pragma unused (stop)
        if (value)
        {
            NSUInteger rectCount = 0;
            NSRectArray rectArray = [textView.layoutManager rectArrayForCharacterRange:range withinSelectedCharacterRange:range inTextContainer:textView.textContainer rectCount:&rectCount];
            for (NSUInteger i = 0; i < rectCount; i++)
            {
                [hyperlinkInfos addObject:@{kHyperlinkInfoCharacterRangeKey : [NSValue valueWithRange:range], kHyperlinkInfoURLKey : value, kHyperlinkInfoRectKey : [NSValue valueWithRect:rectArray[i]]}];
            }
        }
    }];
    
    return [hyperlinkInfos count] ? hyperlinkInfos : nil;
}


- (NSTextView *)textView
{
    // Font used for displaying and frame calculations must match
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedStringValue];
    NSFont *font = [attributedString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    
    if (!font)
        [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, [attributedString length])];
    
    NSRect textViewFrame = [self.cell titleRectForBounds:self.bounds];
    NSTextView *textView = [[NSTextView alloc] initWithFrame:textViewFrame];
    [textView.textStorage setAttributedString:attributedString];

    return textView;
}


#pragma mark -
#pragma mark Mouse Events

- (void)mouseUp:(NSEvent *)theEvent
{
    NSTextView *textView = self.textView;
    NSPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger index = [textView.layoutManager characterIndexForPoint:localPoint inTextContainer:textView.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (index != NSNotFound)
    {
        for (NSDictionary *info in self.hyperlinkInfos)
        {
            NSRange range = [[info objectForKey:kHyperlinkInfoCharacterRangeKey] rangeValue];
            if (NSLocationInRange(index, range))
            {
                NSURL *url = [info objectForKey:kHyperlinkInfoURLKey];
                if ([NSAttributedString _emptyUrl] != url) {
                    [[NSWorkspace sharedWorkspace] openURL:url];
                }
                if (self.linkDelegate && [self.linkDelegate respondsToSelector:@selector(linkClicked:)]) {
                    [self.linkDelegate linkClicked:self];
                }
                // TODO: Pay attention here!
                // Need to simplify code
                break;
            }
        }
    }
}

@end
