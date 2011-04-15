//
//  UserSettings.h
//  IRCBot
//
//  Created by Ben K on 2010/10/10.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "EMKeychainItem.h"
#import "KBHostmasksData.h"
#import "KBLuaActionsData.h"
#import "KBAutojoinData.h"

@interface UserSettings : NSObject {
	IBOutlet NSView *accountView;
	IBOutlet NSView *generalView;
	IBOutlet NSView *hostmasksView;
	IBOutlet NSView *actionsView;	
	IBOutlet NSView *roomsView;
	
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *startWindow;
	IBOutlet NSWindow *prefWindow;
	
	IBOutlet NSTabView *startView;
	IBOutlet NSTextField *errorMessage;
	IBOutlet NSTextField *newUsernameField;
	IBOutlet NSToolbar *toolBar;
	
	
	NSString *username;
	NSString *password;
	NSString *realname;
	NSString *nickname;
	IBOutlet NSTextField *newPasswordField;
	IBOutlet NSTextField *newRealnameField;
	IBOutlet NSTextField *newNicknameField;
	IBOutlet NSTextField *newHostmaskField;
	
	BOOL passwordInPlist;
	
	IBOutlet KBHostmasksData *hostmasksData;
	IBOutlet KBLuaActionsData *actionsData;
	IBOutlet KBAutojoinData *autojoinData;	
	
	NSModalSession session;	
}

@property (nonatomic, assign) NSString *username;
@property (nonatomic, assign) NSString *password;
@property (nonatomic, assign) NSString *realname;
@property (nonatomic, assign) NSString *nickname;
@property BOOL passwordInPlist;

@property (nonatomic, retain) KBHostmasksData *hostmasksData;
@property (nonatomic, retain) KBLuaActionsData *actionsData;
@property (nonatomic, retain) KBAutojoinData *autojoinData;	

- (IBAction)finishInitialSetup:(id)sender;
- (IBAction)savePreferences:(id)sender;
- (IBAction)resetApplication:(id)sender;
- (IBAction)changePanes:(id)sender;
- (void)setPane:(int)index;

@end
