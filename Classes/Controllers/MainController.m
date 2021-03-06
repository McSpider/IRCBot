//
//  MainController.m
//  IRCBot
//
//  Created by Ben K on 2010/06/30.
//  All code is provided under the New BSD license.
//

#import "MainController.h"


@interface MainController (Private)
- (void)pingAlive:(NSString *)server;
- (void)authUser:(NSString *)aUsername pass:(NSString *)aPassword nick:(NSString *)aNick realName:(NSString *)aName;
- (void)refreshConnectionData;
- (void)parseServerOutput:(NSString *)input type:(NSString *)type;
- (NSString *)escapeString:(NSString *)string;
- (void)logMessage:(NSString *)message type:(int)type;
@end


@implementation MainController
@synthesize ircConnection, settings;


#pragma mark -
#pragma mark IBActions

// Connect to or disconnect IRC connection
- (IBAction)toggleIrcConnection:(id)sender
{
	if (![ircConnection isConnected]) {		
		// Check if for valid irc login, create a random one if needed
		if ([settings.username length] == 0) {
			NSString *randomUser = [NSString stringWithFormat:@"Serty%i%i%i",arc4random() % 10,arc4random() % 10,arc4random() % 10];
			[settings setUsername:randomUser];
		}
		
		// Get connection data
		NSArray *connectionArray = [[serverAddress stringValue] componentsSeparatedByString:@":"];
		NSString *ircServer;
		int ircPort;
		
		if ([connectionArray count] != 0 && ![[connectionArray objectAtIndex:0] isEqualToString:@""]) {
			ircServer = [connectionArray objectAtIndex:0];
		} else {
			[self logMessage:@"You need to specify a irc server to connect to." type:1];
			return;
		}
		
		if ([connectionArray count] >= 2)
			ircPort = [[connectionArray objectAtIndex:1] intValue];
		else
			ircPort = 6667;
		
		// Get authentication data
		NSString *username = settings.username;
		NSString *password = settings.password;	
		NSString *nickname = settings.nickname;
		NSString *realname = settings.realname;
		
		// Set the connectionData .
    [connectionData release];
		connectionData = [[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:username, password, nickname, realname,
                                                           ircServer, [NSNumber numberWithInteger:ircPort], nil]
                                   forKeys:[NSArray arrayWithObjects:@"Username", @"Password", @"Nickname", @"Realname",
                                            @"ircServer", @"ircPort",nil]] retain];
		
		[activityIndicator startAnimation:self];
		[connectionButton setEnabled:NO];
		[serverAddress setEnabled:NO];
		[ircConnection connectToIRC:[connectionData objectForKey:@"ircServer"] port:[connectionData objectForKey:@"ircPort"]];
		[self logMessage:@"Establishing connection to server" type:1];
	}
	else {
		[activityIndicator startAnimation:self];
		[connectionButton setEnabled:NO];
		[ircConnection disconnectWithMessage:@"Bye, don't forget to feed the goldfish."];
	}
}

- (IBAction)parseCommand:(id)sender
{
	NSString *commandString = [commandField stringValue];
	NSArray *commandArray = [commandString componentsSeparatedByString:@" "];
	
	if ([commandString isEqualToString:@""])
		return;
	
  if ([[commandArray objectAtIndex:0] isEqualToString:@"help"]) {
    [self logMessage:@"Valid commands are:\n› join (room)\n› part (room)\n› msg (recipient) (.me|.ntc) (message)\n" type:4];
		[commandField setStringValue:@""];
		return;
  }
  if (![ircConnection isConnected]) {
		[self logMessage:@"No IRC Connection\n› Type help for help\n" type:1];
		[commandField setStringValue:@""];
		return;
	}
  
  
  if ([[commandArray objectAtIndex:0] isEqualToString:@"join"]) {
    if (![commandArray count] > 1 || ![[commandArray objectAtIndex:1] hasPrefix:@"#"]) {
      [self logMessage:@"Invalid or no room specified." type:4];
      return;
    }
    
		if (![rooms connectedToRoom:[commandArray objectAtIndex:1]]) {
			[self joinRoom:[commandArray objectAtIndex:1]];
		} else {
			[self logMessage:@"You are already in that room." type:4];
      [commandField setStringValue:@""];
      return;
		}
	}
	else if ([[commandArray objectAtIndex:0] isEqualToString:@"part"]) {
    if (![commandArray count] > 1 || ![[commandArray objectAtIndex:1] hasPrefix:@"#"]) {
      [self logMessage:@"Invalid or no room specified." type:4];
      return;
    }
    
		if ([rooms connectedToRoom:[commandArray objectAtIndex:1]]) {
			[self partRoom:[commandArray objectAtIndex:1]];
		}else {
			[self logMessage:@"You are not connected to that room." type:4];
      [commandField setStringValue:@""];
      return;
		}
	}
	else if ([[commandArray objectAtIndex:0] isEqualToString:@"msg"]) {
    if (![commandArray count] > 2) {
      [self logMessage:@"Invalid msg command format, proper format is:\n› msg (recipient) (.me|.ntc) (message)\n" type:4];
      return;
    }
    
		NSString * tempString = commandString;
		if ([[commandArray objectAtIndex:2] isEqualToString:@".me"]) {
      tempString = [[commandArray subarrayWithRange:NSMakeRange(3, commandArray.count - 3)] componentsJoinedByString:@" "];
			[ircConnection sendAction:tempString To:[commandArray objectAtIndex:1] logAs:2];
		} else if ([[commandArray objectAtIndex:2] isEqualToString:@".ntc"]) {
      tempString = [[commandArray subarrayWithRange:NSMakeRange(3, commandArray.count - 3)] componentsJoinedByString:@" "];
			[ircConnection sendNotice:tempString To:[commandArray objectAtIndex:1] logAs:2];
		} else {
      tempString = [[commandArray subarrayWithRange:NSMakeRange(2, commandArray.count - 2)] componentsJoinedByString:@" "];
			[ircConnection sendMessage:tempString To:[commandArray objectAtIndex:1] logAs:2];
		}
	}
	else {
		[self logMessage:@"Invalid Command\n› Type help for help" type:4];
	}
	
	[commandField addPopUpItemWithTitle:commandString];
	[commandField setStringValue:@""];		
}

- (IBAction)saveLog:(id)sender
{
	// Get the current date and format it
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"yyyy-M-d h.m.s a"];
	NSString *formattedDate = [formatter stringFromDate:[NSDate date]];
	
	// Save log to desktop
	NSString *path = [NSString stringWithFormat:@"~/Desktop/IRCLog %@",formattedDate];
	[[[serverOutput textStorage] string] writeToFile:[path stringByExpandingTildeInPath] atomically:YES encoding:4 error:nil];
}

- (IBAction)clearLog:(id)sender
{
	[serverOutput selectAll:nil];
	[serverOutput setString:@""];
}

- (IBAction)toggleDebug:(id)sender
{
	if (Debugging) {
		Debugging = NO;
		[debugMenuItem setState:0];
		[debugMenuItem setTitle:@"Debug Mode"];
	} else {
		Debugging = YES;
		[debugMenuItem setState:1];
		[debugMenuItem setTitle:@"Debug Mode On"];
	}
}


#pragma mark -
#pragma mark Application Delegate Messages

- (void)awakeFromNib
{
	connectionData = [[NSMutableArray alloc] init];
	Debugging = NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if (!(ircConnection = [[IRCConnection alloc] initWithDelegate:self]))
		[self logMessage:@"IRCConnection Allocation Error" type:1];
	
	lua = [[LuaController alloc] init];
	[lua setParentClass:self];
	[lua setConnectionClass:ircConnection];
	[lua setRoomsClass:rooms];
	[lua setSettingsClass:settings];
	
	[commandField setDisplaysMenu:YES];
	
	[self refreshConnectionData];
	[self logMessage:@"Welcome to IRCBot -- For help type help.\n" type:4];
}

// Application should quit but server is still connected
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	// If socket is still conected ask user if he's sure
	if ([ircConnection isConnected]) {
		NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"You are still conected to a server."];
    [alert setInformativeText:@"Would you like to dissconect from the server before quiting?"];
		[alert addButtonWithTitle:@"Yes"];
		[alert addButtonWithTitle:@"Quit"];
		[alert setAlertStyle:NSWarningAlertStyle];
		int answer = [alert runModal];

		if( answer == NSAlertFirstButtonReturn ) {
			[alert release];
			return NSTerminateCancel;
		}
		[alert release];
	}
	// If he is, quit application
	return NSTerminateNow;
}

// Main window is should be closed
- (BOOL)windowShouldClose:(NSWindow *)sender
{		
	if (sender == mainWindow) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults boolForKey:@"hide_window_alert"])
			return YES;
		
		NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Are you sure you want to close the main window?"];
    [alert setInformativeText:@"You can display it again later by going under the IRCBot menu and choosing \"Main Window\"."];
		[alert addButtonWithTitle:@"Close"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert setShowsSuppressionButton:YES];
		[alert setAlertStyle:NSWarningAlertStyle];
		int answer = [alert runModal];

		if (answer == NSAlertSecondButtonReturn) {
			if ([[alert suppressionButton] state] == NSOnState)
				[defaults setBool:YES forKey:@"hide_window_alert"];
			[alert release];
			return NO;
		}
		if ([[alert suppressionButton] state] == NSOnState)
			[defaults setBool:YES forKey:@"hide_window_alert"];
		[alert release];
	}
	return YES;
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	if (anItem.action == @selector(saveLog:)) {
		return [ircConnection isConnected];
	}
	if (anItem.action == @selector(clearLog:)) {
		return [ircConnection isConnected];
	}
	return YES;
}


#pragma mark -
#pragma mark IRC Actions

- (void)pingAlive:(NSString *)server
{
	NSString* replyMessage = [NSString stringWithFormat:@"PONG %@\r\n",server];
	[ircConnection sendRawString:replyMessage logAs:2];
}

- (void)joinRoom:(NSString *)aRoom
{
	if ([aRoom hasPrefix:@"#"]) {
		[self logMessage:@"Joining Room" type:1];
		NSString* joinMessage = [NSString stringWithFormat:@"JOIN %@ \r\n", aRoom];
		[ircConnection sendRawString:joinMessage logAs:2];
		[rooms addRoom:aRoom];
	}
}

- (void)partRoom:(NSString *)aRoom
{
	if ([aRoom hasPrefix:@"#"]) {
		[self logMessage:@"Parting Room" type:1];
		NSString* partMessage = [NSString stringWithFormat:@"PART %@ \r\n", aRoom];
		[ircConnection sendRawString:partMessage logAs:2];
		[rooms setStatus:@"None" forRoom:aRoom];
	}
}

- (void)authUser:(NSString *)aUsername pass:(NSString *)aPassword nick:(NSString *)aNick realName:(NSString *)aName
{
	// Create auth messages
	[self logMessage:@"Authenticating User" type:1];
	NSString *userMessage, *passMessage, *nickMessage, *nickServMessage;
	
	userMessage = [NSString stringWithFormat:@"USER %@ %@ %@ \r\n", aUsername, @" 0 * :", aName];
	nickMessage = [NSString stringWithFormat:@"NICK %@ \r\n", aNick];
	
	// Send authentication messages
	[ircConnection sendRawString:userMessage logAs:2];
	[ircConnection sendRawString:nickMessage logAs:2];
	
	// Check if a password is specified
	if (![aPassword isEqualToString:@""]) {
		passMessage = [NSString stringWithFormat:@"PASS %@ \r\n", aPassword];	
		nickServMessage = [NSString stringWithFormat:@"identify %@",aPassword];
		[ircConnection sendRawString:passMessage logAs:2];
		[ircConnection sendMessage:nickServMessage To:@"NickServ" logAs:2];
	}
	else {
		[self logMessage:@"No password specified!" type:1];
	}
}

- (void)parseServerOutput:(NSString *)input type:(NSString *)type
{	
	// Log raw message string
	if (Debugging) {
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:@"hh:mm"];
		NSString *time = [formatter stringFromDate:[NSDate date]];
		[self logMessage:[NSString stringWithFormat:@"%@ [%@] %@",time,type,input] type:0];
	}
	else
		[self logMessage:[NSString stringWithFormat:@"%@",input] type:0];
	
	
	if ([type isEqualToString:@"IRC_CHANNEL_MSG"] || [type isEqualToString:@"IRC_QUERY_MSG"]) {
		// Split the message into its components, see Notes.rtf for more info
		NSArray *messageData;
		messageData = [[input arrayOfCaptureComponentsMatchedByRegex:@":([^!]+)!~(\\S+)\\s+(\\S+)\\s+:?+(\\S+)\\s*(?:[:+-]+(.*+))?$"] objectAtIndex:0];
		NSString *message = [messageData objectAtIndex:5];
		
		// Get auth for the hostmask
		BOOL auth = [settings.hostmasksData getAuthForHostmask:[messageData objectAtIndex:2]]; 
		
		// Get triggers
		NSMutableArray *triggers = [NSMutableArray arrayWithArray:[settings.triggers componentsSeparatedByString:@","]];
		if (settings.nicknameAsTrigger)
			[triggers insertObject:[NSString stringWithFormat:@"%@: ",[connectionData objectForKey:@"Nickname"]] atIndex:0];
		
		// Actions
		for (NSString *trigger in triggers) {
			if (![message hasPrefix:trigger])
				continue;
				
			for (KBLuaAction *luaAction in [settings.actionsData actionsArray]) {				
				NSString *regex = [NSString stringWithFormat:@"^(%@%@)(\\s+|$).*$",trigger,luaAction.name];
				if ([message isMatchedByRegex:regex]) {
					NSArray *messageComponents;
					regex = @"'[^']*'|[^\\s]+";
					messageComponents = [message componentsMatchedByRegex:regex];
											
					if ((luaAction.restricted && auth) || !luaAction.restricted) {
						[lua loadFile:luaAction.file];
						[lua setConnectionData:connectionData andTriggers:triggers];
						[lua runMainFunctionWithData:messageData andArguments:messageComponents];
					} else {
						NSString *errorMessage = [NSString stringWithFormat:@"%@, you do not have permission to execute that command.",[messageData objectAtIndex:1]];
						[ircConnection sendMessage:errorMessage To:[messageData objectAtIndex:4] logAs:3];
					}
				}	
			}
		}		
	}
	
	if ([type isEqualToString:@"IRC_KICK_NOTICE"]) {
		if ([input rangeOfString:[connectionData objectForKey:@"Nickname"] options:NSLiteralSearch].location != NSNotFound){
			NSArray *tempArray = [input componentsSeparatedByString:@"KICK "];
			NSRange tempRange = [[tempArray objectAtIndex:1] rangeOfString:[connectionData objectForKey:@"Nickname"]];
			NSString *room = [[tempArray objectAtIndex:1] substringWithRange:NSMakeRange(0,tempRange.location-1)];
			NSString *reason = [[tempArray objectAtIndex:1] substringFromIndex:tempRange.location+tempRange.length+2];
			[self logMessage:[NSString stringWithFormat:@"You have just been kicked from:%@ reason:%@",room,reason] type:1];
			[rooms setStatus:@"Warning" forRoom:room];
			
			if (settings.rejoinKickedRooms) {
				[self performSelector:@selector(joinRoom:) withObject:room afterDelay:1.0f];
			}
		}
	}
	
	// Cleanup and make more universal
	if ([type isEqualToString:@"IRC_STATUS_MSG"]) {
		// Split the message into its components 0:raw 1:ircServer 2:Empty 3:Notice# 4:Botname 5:Room 6:Message
		NSArray *messageData;
		messageData = [input arrayOfCaptureComponentsMatchedByRegex:@":(\\S+)\\s+([0-9]*?)(\\S+)\\s+(\\S+)\\s+:?+(\\S+)\\s*(?:[:+-]+(.*+))?$"];
				
		if ([input isMatchedByRegex:[NSString stringWithFormat:@"^.*\\s366\\s%@\\s.*:End of /NAMES.*$",[connectionData objectForKey:@"Nickname"]]]) {
			[rooms setStatus:@"Normal" forRoom:[[messageData objectAtIndex:0] objectAtIndex:5]];
		}
	}
	
	if ([type isEqualToString:@"IRC_PING"]) {
		NSString *server = [input stringByMatching:@"^PING .*$"];
		server = [server substringFromIndex:5];
		[self pingAlive:server];
	}
	
}

- (NSString *)escapeStringescapeString:(NSString *)string
{
	NSMutableString *returnString = [NSMutableString stringWithString:string];
	[returnString replaceOccurrencesOfString:@"^" withString:@"\\^" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"$" withString:@"\\$" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"(" withString:@"\\(" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@")" withString:@"\\)" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"<" withString:@"\\<" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"[" withString:@"\\[" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"{" withString:@"\\{" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@">" withString:@"\\>" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"." withString:@"\\." options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"*" withString:@"\\*" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"+" withString:@"\\+" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"?" withString:@"\\?" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	return returnString;
}

- (void)refreshConnectionData
{
	// Get authentication data
	NSString *username = settings.username;
	NSString *password = settings.password;	
	NSString *nickname = settings.nickname;
	NSString *realname = settings.realname;
	
	// Set the connectionData array, see Notes.rtf for more info
  [connectionData release];
  connectionData = [[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:username,password,nickname,realname,nil]
                                                             forKeys:[NSArray arrayWithObjects:@"Username",@"Password",@"Nickname",@"Realname",nil]] retain];

}

// Log message to text view
- (void)logMessage:(NSString *)message type:(int)type
{	
	NSMutableString *secureMessage = [NSMutableString stringWithString:message];
	// Block out the password in the log
	if ([[connectionData objectForKey:@"Password"] length] > 0)
			if ([secureMessage rangeOfString:[connectionData objectForKey:@"Password"]].location != NSNotFound)
				[secureMessage replaceCharactersInRange:[secureMessage rangeOfString:[connectionData objectForKey:@"Password"]] withString:@"••••••"];
	
	// Get the length of the textview contents
	NSRange theEnd = NSMakeRange([[serverOutput string] length],0);
	
	NSMutableString *formatedMessage;
	NSColor *textColor;
	NSFont *textFont = [NSFont fontWithName:@"Menlo" size:12.0];
	
	// Setup color of string depending on type
	if (type == 1) {
		textColor = [NSColor colorWithCalibratedRed:0.35 green:0.00 blue:0.00 alpha:1.00]; // Red -- Notice
		formatedMessage = [NSString stringWithFormat:@"› %@\n",secureMessage];
	}
	else if (type == 2) {
		textColor = [NSColor colorWithCalibratedRed:0.00 green:0.00 blue:0.35 alpha:1.00]; // Blue -- Status
		formatedMessage = [NSString stringWithFormat:@"› %@",secureMessage];
	}
	else if (type == 3) {
		textColor = [NSColor colorWithCalibratedRed:0.15 green:0.30 blue:0.00 alpha:1.00]; // Green -- Activity
		formatedMessage = [NSString stringWithFormat:@"› %@",secureMessage];
	}
	else if (type == 4) {
		textColor = [NSColor colorWithCalibratedRed:0.24 green:0.00 blue:0.30 alpha:1.00]; // Purple -- Info;
		formatedMessage = [NSString stringWithFormat:@"› %@\n",secureMessage];
	}
	else {
		textColor = [NSColor blackColor]; // Black
		formatedMessage = [NSString stringWithFormat:@"%@\n",secureMessage];
	}
		
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              textColor,NSForegroundColorAttributeName,
                              textFont,NSFontAttributeName,nil];
	NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:formatedMessage attributes:attributes] autorelease];
		
	// Smart Scrolling
	if (NSMaxY([serverOutput visibleRect]) == NSMaxY([serverOutput bounds])) {
		[[serverOutput textStorage] appendAttributedString:attributedString];
		theEnd.location+=[formatedMessage length];
		[serverOutput scrollRangeToVisible:theEnd];
	}
	else {
		[[serverOutput textStorage] appendAttributedString:attributedString];
	}
}


#pragma mark -
#pragma mark Socket Delegate Messages

- (void)didReadData:(NSString *)msg	ofType:(NSString *)type
{
	[self parseServerOutput:msg type:type];
}

- (void)didConnectToHost:(NSString *)host port:(UInt16)port
{
	// Stop activity indicator and enable and disable all relevant controls
	[activityIndicator stopAnimation:self];
	[connectionButton setEnabled:YES];
	[connectionButton setTitle:@"Disconect"];
		
	// Authenticate user and join the default room
	[self authUser:[connectionData objectForKey:@"Username"]
            pass:[connectionData objectForKey:@"Password"]
            nick:[connectionData objectForKey:@"Nickname"]
        realName:[connectionData objectForKey:@"Realname"]];
	
	// Join rooms in the autojoin list
	for (NSArray *autojoinRoom in [settings.autojoinData autojoinArray]) {
		if ([[autojoinRoom objectAtIndex:1] boolValue] == YES)
			[self joinRoom:[autojoinRoom objectAtIndex:0]];
	}
}

- (void)didDissconect
{
	[self logMessage:@"Socket disconnected\n" type:1];
	
	// Stop activity indicator and disable and enable all relevant controls
	[activityIndicator stopAnimation:self];
	[serverAddress setEnabled:YES];
	[rooms removeAllRooms];
	[connectionButton setEnabled:YES];
	[connectionButton setTitle:@"Connect"];
}


#pragma mark -
#pragma mark Dealloc Memory

// deallocate used memory
- (void)dealloc
{
	[lua release];
	[ircConnection release];
	[connectionData release];
	[super dealloc]; 
}


@end
