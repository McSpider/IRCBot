//
//  MainController.m
//  IRCBot
//
//  Created by Ben K on 2010/06/30.
//  All code is provided under the New BSD license.
//

#import "MainController.h"

@interface MainController (InternalMethods)
// Default connection messages
-(void)pingAlive:(NSString *)server;
-(void)joinRoom:(NSString *)aRoom;
-(void)partRoom:(NSString *)aRoom;
-(void)authUser:(NSString *)aUsername pass:(NSString *)aPassword nick:(NSString *)aNick realName:(NSString *)aName;

// Log message to text view
-(void)logMessage:(NSString *)message type:(int)type;

// Connect and disconnect from IRC server functions
-(void)connectToIRC:(NSString *)server port:(int)port;
-(void)disconnectFromIRC:(NSString *)message;

-(void)parseServerOutput:(NSString *)input;
-(NSString*)getMessageType:(NSString*)input;

BOOL Debugging;
// IRC connection stuff
NSString* ircServer;
int ircPort;
NSString* ircRoom;
NSMutableArray* connectionData;

// IRC connection
AsyncSocket *ircSocket;
float timeout;
@end


@implementation MainController

#pragma mark -
#pragma mark IBActions

// Connect to or disconnect IRC connection
-(IBAction)ircConnection:(id)sender
{
	if (![ircSocket isConnected]){
		[self refreshConnectionData];
		[connectionButton setEnabled:NO];
		[serverAddress setEnabled:NO];
		[serverPort setEnabled:NO];
		[self connectToIRC:ircServer port:ircPort];
	}else{
		[connectionButton setEnabled:NO];
		[self disconnectFromIRC:@"Bye, don't forget to feed the goldfish."];
	}
}

-(IBAction)parseCommand:(id)sender
{
	if ([ircSocket isConnected]){
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
				[self sendMessage:tempString To:[commandArray objectAtIndex:1] logAs:2];
			}
		}else if ([commandString isMatchedByRegex:@"^/me\\s.*\\s.*$"]){
			if ([rooms.roomArray containsObject:[commandArray objectAtIndex:1]]){
				NSString *tempString = @"";
				int i;
				for (i = 2; i < [commandArray count]; i++){
					tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@" %@",[commandArray objectAtIndex:i]]];
				}
				[self sendAction:tempString To:[commandArray objectAtIndex:1] logAs:2];
			}
		}else if ([commandString isMatchedByRegex:@"^/notice\\s.*\\s.*$"]){
			if ([rooms.roomArray containsObject:[commandArray objectAtIndex:1]]){
				NSString *tempString = @"";
				int i;
				for (i = 2; i < [commandArray count]; i++){
					tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@" %@",[commandArray objectAtIndex:i]]];
				}
				[self sendNotice:tempString To:[commandArray objectAtIndex:1] logAs:2];
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
	connectionData = [[NSMutableArray alloc] init];
	[self refreshConnectionData];
	Debugging = NO;
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if (!(ircSocket = [[AsyncSocket alloc] initWithDelegate:self]))
		[self logMessage:@"IRCBot - Socket Allocation Error" type:1];
	// Advanced options - enable the socket to contine operations even during modal dialogs, and menu browsing
	[ircSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

// Application should quit but server is still connected
-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	// If socket is still conected ask user if he's sure
	if ([ircSocket isConnected]){
		int answer = NSRunAlertPanel(@"You are still conected to a server.",@"Would you like to dissconect from the server before quiting?",
																 @"Quit",@"Yes", nil);
		if(answer != NSAlertDefaultReturn)
			//[self disconnectFromIRC:@"Bye, don't forget to feed the goldfish."];
			return NSTerminateCancel;
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
	[self sendRawString:replyMessage logAs:2];
}

-(void)joinRoom:(NSString *)aRoom
{
	if ([aRoom hasPrefix:@"#"]){
		[self logMessage:@"IRCBot - Joining Room" type:1];
		NSString* joinMessage = [NSString stringWithFormat:@"JOIN %@ \r\n", aRoom];
		[self sendRawString:joinMessage logAs:2];
		[rooms addRoom:aRoom];
	}
}

-(void)partRoom:(NSString *)aRoom
{
	if ([aRoom hasPrefix:@"#"]){
		[self logMessage:@"IRCBot - Parting Room" type:1];
		NSString* partMessage = [NSString stringWithFormat:@"PART %@ \r\n", aRoom];
		[self sendRawString:partMessage logAs:2];
		[rooms removeRoom:aRoom];
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
	[self sendRawString:userMessage logAs:2];
	[self sendRawString:nickMessage logAs:2];
	[self sendRawString:passMessage logAs:2];
	[self sendMessage:nickServMessage To:@"NickServ" logAs:2];
}


#pragma mark -
#pragma mark IRC Messaging

-(void)sendMessage:(NSString *)message To:(NSString *)recipient logAs:(int)type
{
	if (recipient == nil || [recipient isEqualToString:@"NONE"])
		recipient = ircRoom;
	NSString* msg = [NSString stringWithFormat:@"PRIVMSG %@ :%@\r\n", recipient, message];
	if ([message length] >= 1) [self sendRawString:msg logAs:type];
}

-(void)sendNotice:(NSString *)message To:(NSString *)recipient logAs:(int)type
{
	if (recipient == nil || [recipient isEqualToString:@"NONE"])
		recipient = ircRoom;
	NSString* msg = [NSString stringWithFormat:@"NOTICE %@ :%@\r\n", recipient, message];
	if ([message length] >= 1) [self sendRawString:msg logAs:type];
}

-(void)sendAction:(NSString *)message To:(NSString *)recipient logAs:(int)type
{
	if (recipient == nil || [recipient isEqualToString:@"NONE"])
		recipient = ircRoom;
	NSString* msg = [NSString stringWithFormat:@"PRIVMSG %@ :%cACTION %@%c\r\n", recipient, 1, message, 1];
	if ([message length] >= 1) [self sendRawString:msg logAs:type];
}

-(void)sendRawString:(NSString *)string logAs:(int)type
{
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	if ([string length] >= 1) [ircSocket writeData:data withTimeout:timeout tag:0];
	[self logMessage:[NSString stringWithFormat:@"%@", string] type:type];
}

-(void)parseServerOutput:(NSString *)input
{	
	NSString *type = [self getMessageType:input];
	
	// Log raw message string
	if (Debugging) [self logMessage:[NSString stringWithFormat:@"<%@> %@",type,input] type:0];
	else [self logMessage:[NSString stringWithFormat:@"%@",input] type:0];
	
	
	if ([type isEqualToString:@"IRC_QUERY_MSG"]){
		
	}
	
	if ([type isEqualToString:@"IRC_CHANNEL_MSG"]){
		// Split the message into its components 0:raw 1:Username 2:Hostmask 3:Type 4:Room 5:Message 6:Empty
		NSArray *messageData;
		messageData = [[input arrayOfCaptureComponentsMatchedByRegex:@":([^!]++)!~(\\S++)\\s++(\\S++)\\s++:?+(\\S++)\\s*+(?:[:+-]++(.*+))?(.*?)$"] objectAtIndex:0];

		// Parse message and check for IRCBot functions, TODO
		if ([[messageData objectAtIndex:5] isMatchedByRegex:@"^hi.*$"]){
			if ([hostmasks getAuthForHostmask:[messageData objectAtIndex:2]])
				[self sendMessage:[NSString stringWithFormat:@"Hello %@",[messageData objectAtIndex:1]] To:ircRoom logAs:3];
			else
				[self sendMessage:[NSString stringWithFormat:@"UnAuthed Hostmask :P hi %@",[messageData objectAtIndex:1]] To:[messageData objectAtIndex:4] logAs:3];
		}
	}
	
	if ([type isEqualToString:@"IRC_KICK_NOTICE"]){
		if ([input rangeOfString:[connectionData objectAtIndex:2] options:NSLiteralSearch].location != NSNotFound){
			NSArray *tempArray = [input componentsSeparatedByString:@"KICK "];
			NSRange tempRange = [[tempArray objectAtIndex:1] rangeOfString:[connectionData objectAtIndex:2]];
			NSString *room = [[tempArray objectAtIndex:1] substringWithRange:NSMakeRange(0,tempRange.location-1)];
			NSString *reason = [[tempArray objectAtIndex:1] substringFromIndex:tempRange.location+tempRange.length+2];
			[self logMessage:[NSString stringWithFormat:@"IRCBot - You have just been kicked from:%@ reason:%@",room,reason] type:1];
			[rooms setRoom:room status:@"Warning"];
		}
	}
	
	if ([type isEqualToString:@"IRC_PING"]){
		NSString *server = [input stringByMatching:@"^PING .*$"];
		server = [server substringFromIndex:5];
		[self pingAlive:server];
	}
	
}

-(NSString*)getMessageType:(NSString*)input
{	
	if ([input isMatchedByRegex:@"^:[^ ]+? [0-9]{3} .+$"])
		return @"IRC_STATUS_MSG";
	
	// Add the ascii character 1 to the regex using %c
	if ([input isMatchedByRegex:[NSString stringWithFormat:@"^:.*? PRIVMSG .* :%cACTION .*%c$",1,1]])
		return @"IRC_ACTION_MSG";
	else if ([input isMatchedByRegex:[NSString stringWithFormat:@"^:.*? PRIVMSG .* :%c.*%c$",1,1]])
		return @"IRC_CTCP_REQUEST";
	else if ([input isMatchedByRegex:[NSString stringWithFormat:@"^:.*? NOTICE .* :%c.*%c$",1,1]])
		return @"IRC_CTCP_REPLY";
	else if ([input isMatchedByRegex:@"^:.*? PRIVMSG (&|#|\\+|!).* :.*$"])
		return @"IRC_CHANNEL_MSG";
	else if ([input isMatchedByRegex:@"^:.*? PRIVMSG .*:.*$"])
		return @"IRC_QUERY_MSG";
	else if ([input isMatchedByRegex:@"^:.*? NOTICE .* :.*$"])
		return @"IRC_NOTICE_MSG";
	else if ([input isMatchedByRegex:@"^:.*? INVITE .* .*$"])
		return @"IRC_INVITE_NOTICE";
	else if ([input isMatchedByRegex:@"^:.*? JOIN .*$"])
		return @"IRC_JOIN_NOTICE";
	else if ([input isMatchedByRegex:@"^:.*? TOPIC .* :.*$"])
		return @"IRC_TOPICCHANGE_NOTICE";
	else if ([input isMatchedByRegex:@"^:.*? NICK .*$"])
		return @"IRC_NICKCHANGE_NOTICE";
	else if ([input isMatchedByRegex:@"^:.*? KICK .* .*$"]) //maybe: "^:.*?@.*? KICK .* .*$"
		return @"IRC_KICK_NOTICE";
	else if ([input isMatchedByRegex:@"^:.*? PART .*$"])
		return @"IRC_PART_NOTICE";
	else if ([input isMatchedByRegex:@"^:.*? MODE .* .*$"])
		return @"IRC_MODECHANGE_NOTICE";
	else if ([input isMatchedByRegex:@"^:.*? QUIT :.*$"])
		return @"IRC_QUIT_NOTICE";
	else if ([input isMatchedByRegex:@"^PING.*?$"])
		return @"IRC_PING";
	return @"IRC_TYPE_NIL";
}


#pragma mark -
#pragma mark IRC Connection

// Connect and disconnect from IRC server functions //
-(void)connectToIRC:(NSString *)server port:(int)port
{
	[self logMessage:@"IRCBot - Connecting To IRC" type:1];
	
	// Check port validity
	if (port < 0 || port > 65535)
		port = 6667;
	
	// Connect to host and report any errors that occured
	NSError *error = nil;
	if (![ircSocket connectToHost:server onPort:port withTimeout:timeout error:&error]){
		[self logMessage:[NSString stringWithFormat:@"Error Connecting to IRC: %@", error] type:1];
		return;
	}
	// Accept connection and report any errors that occured
	error = nil;
	if (![ircSocket acceptOnPort:port error:&error]){
		[self logMessage:[NSString stringWithFormat:@"Error Accepting Connection: %@", error] type:1];
		return;
	}
	[activityIndicator startAnimation:self];
}

-(void)disconnectFromIRC:(NSString *)message
{
	[self logMessage:@"IRCBot - Closing Connection to IRC" type:1];
	NSString* quitMSG = [NSString stringWithFormat:@"QUIT :%@ \r\n",message];
	[self sendRawString:quitMSG logAs:2];
	
	// Start activity indicator and dissconect socket after reading and writing
	[activityIndicator startAnimation:self];
	if ([ircSocket isConnected]) 
		[ircSocket disconnectAfterReadingAndWriting];
}

// Load conection data from the textfields
-(void)refreshConnectionData
{
	// Get connection data
	ircServer = [serverAddress stringValue];
	ircPort = [serverPort intValue];
	ircRoom = [serverRoom stringValue];
	
	// Get authentication data
	NSString *username = [usernameField stringValue];
	NSString *password = [passwordField stringValue];	
	NSString *nickname = [nicknameField stringValue];
	NSString *realname = [realnameField stringValue];

	// Get connection timeout and convert to ms
	timeout = [[connectionTimeout titleOfSelectedItem] floatValue]*60;
	
	NSArray *tempArray = [NSArray arrayWithObjects:username,password,nickname,realname,ircServer,[NSNumber numberWithInteger:ircPort],ircRoom,nil];
	[connectionData setArray:tempArray];
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

// Socket did read data
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	// Retrive that data and convert to a UTF8String | NSUTF8StringEncoding | NSNonLossyASCIIStringEncoding
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSNonLossyASCIIStringEncoding] autorelease];
	
	// If the data is valid start parsing it
	if (msg){
		[self parseServerOutput:msg];
	}else{
		NSLog(@"%@",msg);
		[self logMessage:@"Error converting received data into ASCII String" type:1];
	}
	// Start new read operation if socket is still conected
	if ([ircSocket isConnected])
		[ircSocket readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}

// Socket did connect to host
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{	
	// Stop activity indicator and enable and disable all relevant controls
	[activityIndicator stopAnimation:self];
	[connectionButton setEnabled:YES];
	[connectionButton setTitle:@"Disconect"];
	
	// Start reading data
	[ircSocket readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];	
	
	// Authenticate user and join default room
	[self authUser:[connectionData objectAtIndex:0] pass:[connectionData objectAtIndex:1] nick:[connectionData objectAtIndex:2] realName:[connectionData objectAtIndex:3]];
	[self joinRoom:ircRoom];
}

// Socket did disconnect
-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	[self logMessage:@"IRCBot - Socket disconnected" type:1];

	// Stop activity indicator and disable and enable all relevant controls
	[activityIndicator stopAnimation:self];
	[serverAddress setEnabled:YES];
	[serverPort setEnabled:YES];
	[connectionButton setEnabled:YES];
	[connectionButton setTitle:@"Connect"];
	[rooms removeAllRooms];
}

// Socket will discconect with error
-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)error
{
	// Log disconnect error
	[self logMessage:[NSString stringWithFormat:@"IRCBot - Socket will disconnect with error: %@", error] type:1];
}

// Socket write timed out
- (NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(CFIndex)length
{
	[self logMessage:@"IRCBot - Socket write timed out" type:1];
	return -1;
}

// Socket read timed out
- (NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(CFIndex)length
{
	[self logMessage:@"IRCBot - Socket read timed out" type:1];
	return -1;
}


#pragma mark -
#pragma mark Dealloc Memory

// deallocate used memory
-(void)dealloc
{
	[ircSocket release];
	[connectionData release];
	[super dealloc]; 
}


@end
