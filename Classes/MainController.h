//
//  MainController.h
//  IRCBot
//
//  Created by Ben K on 2010/06/30.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
#import "RegexKitLite.h"

#import "RoomData.h"
#import "HostmaskData.h"
#import	"ActionsData.h"


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
}

// Connect to or disconnect IRC connection
-(IBAction)ircConnection:(id)sender;
-(IBAction)parseCommand:(id)sender;
-(IBAction)saveLog:(id)sender;
-(IBAction)clearLog:(id)sender;
-(IBAction)toggleDebug:(id)sender;

-(void)refreshConnectionData;

-(void)sendMessage:(NSString *)message To:(NSString *)recipient logAs:(int)type;
-(void)sendNotice:(NSString *)message To:(NSString *)recipient logAs:(int)type;
-(void)sendAction:(NSString *)message To:(NSString *)recipient logAs:(int)type;
-(void)sendRawString:(NSString *)string logAs:(int)type;


@end
