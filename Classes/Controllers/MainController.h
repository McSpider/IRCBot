//
//  MainController.h
//  IRCBot
//
//  Created by Ben K on 2010/06/30.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import	"IRCConnection.h"
#import "LuaController.h"
#import "UserSettings.h"

#import "IRCRooms.h"
#import "KBHostmasksData.h"
#import	"KBLuaActionsData.h"
#import	"KBAutojoinData.h"
#import "KBTextField.h"


@interface MainController : NSObject {
	IBOutlet NSWindow *mainWindow;
	
	IBOutlet NSTextField *serverAddress;
	IBOutlet NSButton *connectionButton;
	IBOutlet NSTextField *triggerField;
	IBOutlet NSButton *nicknameAsTrigger;
	IBOutlet NSButton *rejoinKickedRooms;
	IBOutlet NSMenuItem *debugMenuItem;
	IBOutlet KBTextField *commandField;

	IBOutlet NSTextView *serverOutput;
	IBOutlet NSProgressIndicator *activityIndicator;
	
	IBOutlet IRCRooms *rooms;	
	IBOutlet UserSettings *settings;
	
	BOOL Debugging;
	NSMutableArray* connectionData;
	IRCConnection *ircConnection;
	LuaController *lua;
}

// Connect to or disconnect IRC connection
- (IBAction)toggleIrcConnection:(id)sender;
- (IBAction)parseCommand:(id)sender;
- (IBAction)saveLog:(id)sender;
- (IBAction)clearLog:(id)sender;
- (IBAction)toggleDebug:(id)sender;

- (void)joinRoom:(NSString *)aRoom;
- (void)partRoom:(NSString *)aRoom;

@end
