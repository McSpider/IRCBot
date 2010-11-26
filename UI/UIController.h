//
//  UIController.h
//  IRCBot
//
//  Created by Ben K on 2010/07/18.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>

@interface UIController : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSView *accessoryView;
	IBOutlet NSTextField *versionField;
}

// Methods
- (void)composeInterface;

@end