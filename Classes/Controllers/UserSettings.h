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
	IBOutlet NSView *generalView;
	IBOutlet NSView *hostmasksView;
	IBOutlet NSView *actionsView;
	IBOutlet NSView *roomsView;
	
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *prefWindow;
	
	IBOutlet NSToolbar *toolBar;
	IBOutlet NSTextField *triggersField;
	
	
	NSString *username;
	NSString *password;
	NSString *realname;
	NSString *nickname;
	
	BOOL passwordInPlist;
	
	IBOutlet KBHostmasksData *hostmasksData;
	IBOutlet KBLuaActionsData *actionsData;
	IBOutlet KBAutojoinData *autojoinData;	
	
}

@property (nonatomic, assign) NSString *username;
@property (nonatomic, assign) NSString *password;
@property (nonatomic, assign) NSString *realname;
@property (nonatomic, assign) NSString *nickname;
@property BOOL passwordInPlist;

@property (nonatomic, retain) KBHostmasksData *hostmasksData;
@property (nonatomic, retain) KBLuaActionsData *actionsData;
@property (nonatomic, retain) KBAutojoinData *autojoinData;	

- (IBAction)savePreferences:(id)sender;
- (IBAction)resetApplication:(id)sender;
- (IBAction)changePanes:(id)sender;
- (void)setPane:(int)index;

@end
