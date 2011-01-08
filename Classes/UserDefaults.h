//
//  UserDefaults.h
//  IRCBot
//
//  Created by Ben K on 2010/09/13.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "EMKeychainItem.h"
#import "Hostmasks.h"
#import "Actions.h"
#import "AutojoinData.h"
#import "PrefController.h"

@interface UserDefaults : NSObject {

	// Setup
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *startWindow;
	IBOutlet NSWindow *prefWindow;
	IBOutlet NSToolbar *toolBar;
	IBOutlet NSView	*accountView;
	IBOutlet NSTextField *uName;
	IBOutlet NSSecureTextField *uPassword;
	IBOutlet NSTextField *uNick;
	IBOutlet NSTextField *uRealname;
	IBOutlet NSTextField *hostMask;
	IBOutlet NSTextField *usernameField;
	IBOutlet NSSecureTextField *passwordField;
	IBOutlet NSButton *passwordInPlistCheck;
	IBOutlet PrefController *prefs;

	IBOutlet Hostmasks *hostmasks;
	IBOutlet Actions *actions;
	IBOutlet AutojoinData *autojoin;
	
	NSModalSession session;
}

// Setup
-(IBAction)finishInitialSetup:(id)sender;
-(IBAction)savePreferences:(id)sender;
-(IBAction)resetApplication:(id)sender;

-(void)setFirstStart:(BOOL)boolean;
-(BOOL)firstStart;

@end
