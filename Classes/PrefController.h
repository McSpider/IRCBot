//
//  PrefController.h
//  IRCBot
//
//  Created by Ben K on 2010/10/10.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>


@interface PrefController : NSObject {
	IBOutlet NSView *accountView;
	IBOutlet NSView *generalView;
	IBOutlet NSView *hostmasksView;
	IBOutlet NSView *actionsView;	
	IBOutlet NSView *joinView;	
	IBOutlet NSView *contentView;
	IBOutlet NSWindow *window;
	
}

-(IBAction)changePanes:(id)sender;
-(void)setPane:(int)index;

@end
