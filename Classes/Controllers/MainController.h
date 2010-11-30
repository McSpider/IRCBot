//
//  MainController.h
//  IRCBot
//
//  Created by Ben K on 2010/06/30.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import	"IRCConnection.h"

#import "RoomData.h"
#import "HostmaskData.h"
#import	"ActionsData.h"
#import	"AutojoinData.h"


@interface MainController : NSObject {
	
	IBOutlet NSWindow *mainWindow;
	
	IBOutlet NSTextField *commandField;
	IBOutlet NSTextField *serverAddress;
	IBOutlet NSTextField *serverPort;
	IBOutlet NSTextField *serverRoom;
	IBOutlet NSButton *connectionButton;
	IBOutlet NSTextField *usernameField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSTextField *nicknameField;
	IBOutlet NSTextField *realnameField;
	
	IBOutlet NSMenuItem *debugMenuItem;

	// Connection //
	IBOutlet NSTextView *serverOutput;
	IBOutlet NSProgressIndicator *activityIndicator;
	IBOutlet NSPopUpButton *connectionTimeout;
	IBOutlet NSTextField *triggerField;
		
	IBOutlet RoomData *rooms;
	IBOutlet HostmaskData *hostmasks;
	IBOutlet ActionsData *actions;	
	IBOutlet AutojoinData *autoJoin;	
}

// Connect to or disconnect IRC connection
- (IBAction)ircConnection:(id)sender;
- (IBAction)parseCommand:(id)sender;
- (IBAction)saveLog:(id)sender;
- (IBAction)clearLog:(id)sender;
- (IBAction)toggleDebug:(id)sender;

@end
