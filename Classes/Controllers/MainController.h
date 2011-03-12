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

#import "IRCRooms.h"
#import "Hostmasks.h"
#import	"Actions.h"
#import	"AutojoinData.h"


@interface MainController : NSObject {
	
	IBOutlet NSWindow *mainWindow;
	
	IBOutlet NSTextField *commandField;
	IBOutlet NSTextField *serverAddress;
	IBOutlet NSButton *connectionButton;
	IBOutlet NSTextField *usernameField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSTextField *nicknameField;
	IBOutlet NSTextField *realnameField;
	
	IBOutlet NSTextField *triggerField;
	IBOutlet NSButton *nicknameAsTrigger;
	IBOutlet NSButton *rejoinKickedRooms;
	
	IBOutlet NSMenuItem *debugMenuItem;

	// Connection //
	IBOutlet NSTextView *serverOutput;
	IBOutlet NSProgressIndicator *activityIndicator;
		
	IBOutlet IRCRooms *rooms;
	IBOutlet Hostmasks *hostmasks;
	IBOutlet Actions *actions;	
	IBOutlet AutojoinData *autoJoin;	
	
	LuaController *lua;
}

// Connect to or disconnect IRC connection
- (IBAction)ircConnection:(id)sender;
- (IBAction)parseCommand:(id)sender;
- (IBAction)saveLog:(id)sender;
- (IBAction)clearLog:(id)sender;
- (IBAction)toggleDebug:(id)sender;

- (void)joinRoom:(NSString *)aRoom;
- (void)partRoom:(NSString *)aRoom;

- (void)logMessage:(NSString *)message type:(int)type;

@end
