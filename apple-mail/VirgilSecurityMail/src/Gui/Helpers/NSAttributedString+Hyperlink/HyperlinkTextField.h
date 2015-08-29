#import <Cocoa/Cocoa.h>

@protocol HyperlinkTextFieldDelegate <NSObject>
- (void) linkClicked:(id)sender;
@end //end protocol

@interface HyperlinkTextField : NSTextField
@property (nonatomic, weak) id <HyperlinkTextFieldDelegate> linkDelegate;
@end
