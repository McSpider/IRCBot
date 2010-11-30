//
//  MainController.m
//  IRCBot
//
//  Created by Ben K on 2010/06/30.
//  All code is provided under the New BSD license.
//

#import "MainController.h"

@interface MainController (InternalMethods)

// Messaging
- (void)pingAlive:(NSString *)server;
- (void)authUser:(NSString *)aUsername pass:(NSString *)aPassword nick:(NSString *)aNick realName:(NSString *)aName;
- (void)joinRoom:(NSString *)aRoom;
- (void)partRoom:(NSString *)aRoom;

// Log message to text view
- (void)logMessage:(NSString *)message type:(int)type;
- (void)refreshConnectionData;
- (void)parseServerOutput:(NSString *)input type:(NSString *)type;
- (NSString *)escapeString:(NSString *)string;

BOOL Debugging;
NSMutableArray* connectionData;

// IRC connection
IRCConnection *ircConnection;
@end


@implementation MainController

#pragma mark -
#pragma mark IBActions

// Connect to or disconnect IRC connection
-(IBAction)ircConnection:(id)sender
{
	[activityIndicator startAnimation:self];
	if (![ircConnection isConnected]){
		[self refreshConnectionData];
		[connectionButton setEnabled:NO];
		[serverAddress setEnabled:NO];
		[serverPort setEnabled:NO];
		[ircConnection connectToIRC:[serverAddress stringValue] port:[serverPort	intValue]];
	}else{
		[connectionButton setEnabled:NO];
		[ircConnection disconnectFromIRC:@"Bye, don't forget to feed the goldfish."];
	}
}

-(IBAction)parseCommand:(id)sender
{
	if ([ircConnection isConnected]){
		NSString *commandString = [commandField stringValue];
		NSArray *commandArray = [commandString componentsSeparatedByString:@" "];
		if ([commandString isMatchedByRegex:@"^/join\\s.*$"]){
			if (![rooms connectedToRoom:[commandArray objectAtIndex:1]])
				[self joinRoom:[commandArray objectAtIndex:1]];
		}else if ([commandString isMatchedByRegex:@"^/part\\s.*$"]){
			if ([rooms connectedToRoom:[commandArray objectAtIndex:1]])
				[self partRoom:[commandArray objectAtIndex:1]];
		}else if ([commandString isMatchedByRegex:@"^/msg\\s.*\\s.*$"]){
			if ([rooms.roomArray containsObject:[commandArray objectAtIndex:1]]){
				NSString *tempString = @"";
				int i;
				for (i = 2; i < [commandArray count]; i++){
					tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@" %@",[commandArray objectAtIndex:i]]];
				}
				[ircConnection sendMessage:tempString To:[commandArray objectAtIndex:1] logAs:2];
			}
		}else if ([commandString isMatchedByRegex:@"^/me\\s.*\\s.*$"]){
			if ([rooms.roomArray containsObject:[commandArray objectAtIndex:1]]){
				NSString *tempString = @"";
				int i;
				for (i = 2; i < [commandArray count]; i++){
					tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@" %@",[commandArray objectAtIndex:i]]];
				}
				[ircConnection sendAction:tempString To:[commandArray objectAtIndex:1] logAs:2];
			}
		}else if ([commandString isMatchedByRegex:@"^/notice\\s.*\\s.*$"]){
			if ([rooms.roomArray containsObject:[commandArray objectAtIndex:1]]){
				NSString *tempString = @"";
				int i;
				for (i = 2; i < [commandArray count]; i++){
					tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@" %@",[commandArray objectAtIndex:i]]];
				}
				[ircConnection sendNotice:tempString To:[commandArray objectAtIndex:1] logAs:2];
			}
		}else if ([commandString isMatchedByRegex:@"^/help(\\s.*$|$)"]){
			[self logMessage:@"Valid commands are:\n› /join <room>\n› /part <room>\n› /msg <room> <msg>\n› /me <room> <msg>\n› /notice <room> <msg>" type:4];
		}
		// Invalid/Incomplete command handling
		else if ([commandString isMatchedByRegex:@"^/join$"]){
			[self logMessage:@"/join <room>" type:4];
		}else if ([commandString isMatchedByRegex:@"^/part$"]){
			[self logMessage:@"/part <room>" type:4];
		}else if ([commandString isMatchedByRegex:@"^/msg($|\\s.*$)"]){
			[self logMessage:@"/msg <room> <msg>" type:4];
		}else if ([commandString isMatchedByRegex:@"^/me($|\\s.*$)"]){
			[self logMessage:@"/me <room> <msg>" type:4];
		}else if ([commandString isMatchedByRegex:@"^/notice($|\\s.*$)"]){
			[self logMessage:@"/notice <room> <msg>" type:4];
		}else{
			[self logMessage:@"IRCBot - Invalid Command\n› Type /help for help" type:4];
		}
	}else{
		NSString *commandString = [commandField stringValue];
		if ([commandString isMatchedByRegex:@"^/help(\\s.*$|$)"]){
			[self logMessage:@"Valid commands are:\n› /join <room>\n› /part <room>\n› /msg <room> <msg>\n› /me <room> <msg>\n› /notice <room> <msg>" type:4];
		}else{
			[self logMessage:@"IRCBot - No IRC Connection\n› Type /help for help" type:1];
		}
	}
	[commandField setStringValue:@""];
}

-(IBAction)saveLog:(id)sender
{
	// Get date and format it
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"yyyy-M-d h.m.s a"];
	NSString *formattedDate = [formatter stringFromDate:[NSDate date]];
	
	// Save log to desktop
	NSString *path = [NSString stringWithFormat:@"~/Desktop/IRCLog %@",formattedDate];
	[[[serverOutput textStorage] string] writeToFile:[path stringByExpandingTildeInPath] atomically:YES encoding:4 error:nil];
}

-(IBAction)clearLog:(id)sender
{
	[serverOutput selectAll:nil];
	[serverOutput setString:@""];
}

-(IBAction)toggleDebug:(id)sender
{
	if (Debugging){
		Debugging = NO;
		[debugMenuItem setState:0];
		[debugMenuItem setTitle:@"Debug Mode"];
	}else{
		Debugging = YES;
		[debugMenuItem setState:1];
		[debugMenuItem setTitle:@"Debug Mode On"];
	}
}


#pragma mark -
#pragma mark Application Delegate Messages

-(void)awakeFromNib
{
	[rooms addRoom:[serverRoom stringValue]];
	connectionData = [[NSMutableArray alloc] init];
	[self refreshConnectionData];
	Debugging = NO;
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if (!(ircConnection = [[IRCConnection alloc] initWithDelegate:self]))
		[self logMessage:@"IRCBot - IRCConnection Allocation Error" type:1];
}

// Application should quit but server is still connected
-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	// If socket is still conected ask user if he's sure
	if ([ircConnection isConnected]){
		int answer = NSRunAlertPanel(@"You are still conected to a server.",@"Would you like to dissconect from the server before quiting?",
																 @"Quit",@"Yes", nil);
		if(answer != NSAlertDefaultReturn){
			//[self disconnectFromIRC:@"Bye, don't forget to feed the goldfish."];
			return NSTerminateCancel;
		}
	}
	// If he is, quit application
	return NSTerminateNow;
}

// Main window is should be closed
- (BOOL)windowShouldClose:(NSWindow *)sender
{
	if (sender == mainWindow){
		// Ask user if he's sure
		int answer = NSRunInformationalAlertPanel(@"Are you sure you want to close the main window?",
																							@"You can display it again later by going under the IRCBot menu and choosing \"Main Window\".",
																							@"Close",@"Cancel", nil);
		// If he is, close window
		if (answer == NSAlertDefaultReturn)
			return YES;
		return NO;
	}
	return YES;
}


#pragma mark -
#pragma mark IRC Actions

-(void)pingAlive:(NSString *)server
{
	NSString* replyMessage = [NSString stringWithFormat:@"PONG %@\r\n",server];
	[ircConnection sendRawString:replyMessage logAs:2];
}

-(void)joinRoom:(NSString *)aRoom
{
	if ([aRoom hasPrefix:@"#"]){
		[self logMessage:@"IRCBot - Joining Room" type:1];
		NSString* joinMessage = [NSString stringWithFormat:@"JOIN %@ \r\n", aRoom];
		[ircConnection sendRawString:joinMessage logAs:2];
		[rooms connectRoom:aRoom];
	}
}

-(void)partRoom:(NSString *)aRoom
{
	if ([aRoom hasPrefix:@"#"]){
		[self logMessage:@"IRCBot - Parting Room" type:1];
		NSString* partMessage = [NSString stringWithFormat:@"PART %@ \r\n", aRoom];
		[ircConnection sendRawString:partMessage logAs:2];
		[rooms disconnectRoom:aRoom];
	}
}

-(void)authUser:(NSString *)aUsername pass:(NSString *)aPassword nick:(NSString *)aNick realName:(NSString *)aName
{
	// Create auth messages
	[self logMessage:@"IRCBot - Authenticating User" type:1];
	NSString *userMessage, *passMessage, *nickMessage, *nickServMessage;
	
	userMessage = [NSString stringWithFormat:@"USER %@ %@ %@ \r\n", aUsername, @" 0 * :", aName];
	nickMessage = [NSString stringWithFormat:@"NICK %@ \r\n", aNick];
	passMessage = [NSString stringWithFormat:@"PASS %@ \r\n", aPassword];	
	nickServMessage = [NSString stringWithFormat:@"identify %@",aPassword];
	
	// Send authentication messages
	[ircConnection sendRawString:userMessage logAs:2];
	[ircConnection sendRawString:nickMessage logAs:2];
	[ircConnection sendRawString:passMessage logAs:2];
	[ircConnection sendMessage:nickServMessage To:@"NickServ" logAs:2];
}

-(void)parseServerOutput:(NSString *)input type:(NSString *)type
{	
	
	// Log raw message string
	if (Debugging)
		[self logMessage:[NSString stringWithFormat:@"<%@> %@",type,input] type:0];
	else
		[self logMessage:[NSString stringWithFormat:@"%@",input] type:0];
	
	
	if ([type isEqualToString:@"IRC_QUERY_MSG"]){
		
	}
	
	if ([type isEqualToString:@"IRC_CHANNEL_MSG"]){
		// Split the message into its components 0:raw 1:Username 2:Hostmask 3:Type 4:Room 5:Message 6:Empty
		NSArray *messageData;
		messageData = [[input arrayOfCaptureComponentsMatchedByRegex:@":([^!]++)!~(\\S++)\\s++(\\S++)\\s++:?+(\\S++)\\s*+(?:[:+-]++(.*+))?(.*?)$"] objectAtIndex:0];
		
		// Get triggers
		NSArray *triggers = [[triggerField stringValue] componentsSeparatedByString:@"|"];
		
		// Hardcoded actions
		int index;
		for (index = 0; index < [triggers count]; index++){
			NSString *trigger = [triggers objectAtIndex:index];
			// Escape all regex characters, not working properly
			trigger = [self escapeString:trigger];
			
			BOOL auth = [hostmasks getAuthForHostmask:[messageData objectAtIndex:2]]; 
			if ([[messageData objectAtIndex:5] isMatchedByRegex:[NSString stringWithFormat:@"^%@shutdown.*$",trigger]]){
				if (auth){
					[ircConnection sendMessage:[NSString stringWithFormat:@"Shutting down as ordered by: %@",[messageData objectAtIndex:1]] To:[messageData objectAtIndex:4] logAs:3];
					[ircConnection disconnectFromIRC:@"Bye, don't forget to feed the goldfish."];
				}else
					[ircConnection sendMessage:[NSString stringWithFormat:@"%@, you do not have permission to execute that command.",[messageData objectAtIndex:1]] To:[messageData objectAtIndex:4] logAs:3];
			}
			if ([[messageData objectAtIndex:5] isMatchedByRegex:[NSString stringWithFormat:@"^%@auth.*$",trigger]]){
				if (auth){
					[ircConnection sendMessage:@"You can use all IRCBot actions." To:[messageData objectAtIndex:4] logAs:3];
				}else
					[ircConnection sendMessage:@"You can only use IRCBot actions that aren't restricted." To:[messageData objectAtIndex:4] logAs:3];
			}
			NSLog(@"%@",[NSString stringWithFormat:@"^%@hi.*$",trigger]);
			if ([[messageData objectAtIndex:5] isMatchedByRegex:[NSString stringWithFormat:@"^%@hi.*$",trigger]]){
				[ircConnection sendMessage:[NSString stringWithFormat:@"Hello %@",[messageData objectAtIndex:1]] To:[messageData objectAtIndex:4] logAs:3];
			}
		}
		
		// Userdefined actions
		
		
	}
	
	if ([type isEqualToString:@"IRC_KICK_NOTICE"]){
		if ([input rangeOfString:[connectionData objectAtIndex:2] options:NSLiteralSearch].location != NSNotFound){
			NSArray *tempArray = [input componentsSeparatedByString:@"KICK "];
			NSRange tempRange = [[tempArray objectAtIndex:1] rangeOfString:[connectionData objectAtIndex:2]];
			NSString *room = [[tempArray objectAtIndex:1] substringWithRange:NSMakeRange(0,tempRange.location-1)];
			NSString *reason = [[tempArray objectAtIndex:1] substringFromIndex:tempRange.location+tempRange.length+2];
			[self logMessage:[NSString stringWithFormat:@"IRCBot - You have just been kicked from:%@ reason:%@",room,reason] type:1];
			[rooms setStatus:@"Warning" forRoom:room];
		}
	}
	
	if ([type isEqualToString:@"IRC_PING"]){
		NSString *server = [input stringByMatching:@"^PING .*$"];
		server = [server substringFromIndex:5];
		[self pingAlive:server];
	}
	
}

-(NSString *)escapeString:(NSString *)string
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
	[returnString replaceOccurrencesOfString:@"|" withString:@"\\|" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@">" withString:@"\\>" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"." withString:@"\\." options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"*" withString:@"\\*" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"+" withString:@"\\+" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	[returnString replaceOccurrencesOfString:@"?" withString:@"\\?" options:NSLiteralSearch range:NSMakeRange(0, [returnString length])];
	return returnString;
}

-(void)refreshConnectionData
{
	// Get connection data
	NSString *ircServer = [serverAddress stringValue];
	int ircPort = [serverPort intValue];
	NSString *ircRoom = [serverRoom stringValue];
	
	// Get authentication data
	NSString *username = [usernameField stringValue];
	NSString *password = [passwordField stringValue];	
	NSString *nickname = [nicknameField stringValue];
	NSString *realname = [realnameField stringValue];
	
	// Get connection timeout and convert to ms
	int timeout = [[connectionTimeout titleOfSelectedItem] floatValue]*60;
	
	
	// ConnectionData: username:0 password:1 nickname:2 realname:3 ircServer:4 ircPort:5 ircRoom:6 timeout:7
	NSArray *tempArray = [NSArray arrayWithObjects:username,password,nickname,realname,ircServer,[NSNumber numberWithInteger:ircPort],ircRoom,[NSNumber numberWithInteger:timeout],nil];
	[connectionData setArray:tempArray];
	[ircConnection setConnectionData:tempArray];
}

// Log message to text view
-(void)logMessage:(NSString *)message type:(int)type
{	
	NSMutableString *secureMessage = [NSMutableString stringWithString:message];
	// Block out the password in the log
	if ([secureMessage rangeOfString:[connectionData objectAtIndex:1]].location != NSNotFound)
		[secureMessage replaceCharactersInRange: [secureMessage rangeOfString:[connectionData objectAtIndex:1]] withString: @"******"];
	
	// Get the length of the textview contents
	NSRange theEnd=NSMakeRange([[serverOutput string] length],0);
	
	NSMutableString *formatedMessage;
	NSColor *textColor;		
	NSFont *textFont = [NSFont fontWithName:@"Menlo" size:12.0];
	
	// Setup color of string depending on type
	if (type == 1){
		textColor = [NSColor colorWithCalibratedRed:0.35 green:0.00 blue:0.00 alpha:1.00];
		formatedMessage = [NSString stringWithFormat:@"› %@\n",secureMessage];
	}else if (type == 2){
		textColor = [NSColor colorWithCalibratedRed:0.00 green:0.00 blue:0.35 alpha:1.00];
		formatedMessage = [NSString stringWithFormat:@"› %@",secureMessage];
	}else if (type == 3){
		textColor = [NSColor colorWithCalibratedRed:0.15 green:0.30 blue:0.00 alpha:1.00];
		formatedMessage = [NSString stringWithFormat:@"› %@",secureMessage];
	}else if (type == 4){
		textColor = [NSColor colorWithCalibratedRed:0.24 green:0.00 blue:0.30 alpha:1.00];
		formatedMessage = [NSString stringWithFormat:@"› %@\n",secureMessage];
	}else{
		textColor = [NSColor blackColor];
		formatedMessage = [NSString stringWithFormat:@"%@\n",secureMessage];
	}
	
	if (Debugging){
		// Get date and format it
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:@"h.mm.ss a"];
		NSString *formattedDate = [formatter stringFromDate:[NSDate date]];
		
		// Add it to the message
		formatedMessage = [NSString stringWithFormat:@"<%@> %@",formattedDate,formatedMessage];
	}
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:textColor,NSForegroundColorAttributeName,textFont,NSFontAttributeName,nil];
	NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:formatedMessage attributes:attributes] autorelease];
		
	// Smart Scrolling
	if (NSMaxY([serverOutput visibleRect]) == NSMaxY([serverOutput bounds])) {
		// Append string to textview and scroll to bottom
		[[serverOutput textStorage] appendAttributedString:attributedString];
		theEnd.location+=[formatedMessage length];
		[serverOutput scrollRangeToVisible:theEnd];
	}else{
		// Append string to textview
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
	[self authUser:[connectionData objectAtIndex:0] pass:[connectionData objectAtIndex:1] nick:[connectionData objectAtIndex:2] realName:[connectionData objectAtIndex:3]];
	[self joinRoom:[connectionData objectAtIndex:6]];
	
	// Join rooms in the autojoin list
	int index;
	for (index = 0; index < [autoJoin.autojoinArray count]; index++){
		NSArray *tempArray = [autoJoin.autojoinArray objectAtIndex:index];
		if ([[tempArray objectAtIndex:1] intValue] != 0)
			[self joinRoom:[tempArray objectAtIndex:0]];
	}
	
}

- (void)didDissconect
{
	[self logMessage:@"IRCBot - Socket disconnected" type:1];
	
	// Stop activity indicator and disable and enable all relevant controls
	[activityIndicator stopAnimation:self];
	[serverAddress setEnabled:YES];
	[serverPort setEnabled:YES];
	[rooms disconnectAllRooms];
	[connectionButton setEnabled:YES];
	[connectionButton setTitle:@"Connect"];
}


#pragma mark -
#pragma mark Dealloc Memory

// deallocate used memory
-(void)dealloc
{
	[ircConnection release];
	[connectionData release];
	[super dealloc]; 
}


@end
