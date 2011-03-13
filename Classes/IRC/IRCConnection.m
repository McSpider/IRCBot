//
//  IRCConnection.m
//  IRCBot
//
//  Created by Ben K on 2010/11/28.
//  All code is provided under the New BSD license.
//

#import "IRCConnection.h"


@interface IRCConnection (InternalMethods)

-(NSString*)getMessageType:(NSString*)input;

BOOL Debugging;

// IRC connection
AsyncSocket *ircSocket;

@end


@implementation IRCConnection


#pragma mark -
#pragma mark Application Delegate Messages

- (id)delegate
{
	return ircDelegate;
}

- (void)setDelegate:(id)delegate
{
	ircDelegate = delegate;
}

- (id)initWithDelegate:(id)delegate
{
	if ((self = [super init])) {
		ircDelegate = delegate;
		ircSocket = [[AsyncSocket alloc] initWithDelegate:self];
		[ircSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
		Debugging = NO;
	}
	return self;	
}

- (BOOL)isConnected
{
	return [ircSocket isConnected];
}


#pragma mark -
#pragma mark IRC Messaging

- (void)sendMessage:(NSString *)message To:(NSString *)recipient logAs:(int)type
{
	if (recipient == nil || [recipient isEqualToString:@""])
		return;
	NSString* msg = [NSString stringWithFormat:@"PRIVMSG %@ :%@\r\n", recipient, message];
	if ([message length] >= 1) [self sendRawString:msg logAs:type];
}

- (void)sendNotice:(NSString *)message To:(NSString *)recipient logAs:(int)type
{
	if (recipient == nil || [recipient isEqualToString:@""])
		return;
	NSString* msg = [NSString stringWithFormat:@"NOTICE %@ :%@\r\n", recipient, message];
	if ([message length] >= 1) [self sendRawString:msg logAs:type];
}

- (void)sendAction:(NSString *)message To:(NSString *)recipient logAs:(int)type
{
	if (recipient == nil || [recipient isEqualToString:@""])
		return;
	NSString* msg = [NSString stringWithFormat:@"PRIVMSG %@ :%cACTION %@%c\r\n", recipient, 1, message, 1];
	if ([message length] >= 1) [self sendRawString:msg logAs:type];
}

- (void)sendRawString:(NSString *)string logAs:(int)type
{
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	if ([string length] >= 1) [ircSocket writeData:data withTimeout:1200 tag:0];
	if([ircDelegate respondsToSelector:@selector(logMessage:type:)])
		[ircDelegate logMessage:[NSString stringWithFormat:@"%@", string] type:type];
}

- (NSString*)getMessageType:(NSString*)input
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
- (void)connectToIRC:(NSString *)server port:(int)port
{	
	// Check port validity
	if (port < 0 || port > 65535)
		port = 6667;
	
	// Connect to host and report any errors that occured
	NSError *error = nil;
	if (![ircSocket connectToHost:server onPort:port withTimeout:1200 error:&error]){
		[ircDelegate logMessage:[NSString stringWithFormat:@"Error Connecting to IRC: %@", error] type:1];
		return;
	}
}

- (void)disconnectWithMessage:(NSString *)message
{
	NSString* quitMSG = [NSString stringWithFormat:@"QUIT :%@ \r\n",message];
	[self sendRawString:quitMSG logAs:2];
	
	// Dissconect socket after reading and writing
	if ([ircSocket isConnected]) 
		[ircSocket disconnectAfterReadingAndWriting];
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
	if (msg) {
		NSString *type = [self getMessageType:msg];
		// Pass on string to delegate
		if ([ircDelegate respondsToSelector:@selector(didReadData:ofType:)])
			[ircDelegate didReadData:msg ofType:type];
	} else {
		[ircDelegate logMessage:@"Error converting received data into ASCII String" type:1];
	}
	// Start new read operation if socket is still conected
	if ([ircSocket isConnected])
		[ircSocket readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}

// Socket did connect to host
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{		
	// Start reading data
	[ircSocket readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];	
	if([ircDelegate respondsToSelector:@selector(didConnectToHost:port:)])
		[ircDelegate didConnectToHost:host port:port];
}

// Socket did disconnect
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	if([ircDelegate respondsToSelector:@selector(didDissconect)])
		[ircDelegate didDissconect];
}

// Socket will discconect with error
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)error
{
	[ircDelegate logMessage:[NSString stringWithFormat:@"IRCBot - Socket will disconnect with error: %@", error] type:1];
}

// Socket write timed out
- (NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(CFIndex)length
{
	[ircDelegate logMessage:@"IRCBot - Socket write timed out" type:1];
	return -1;
}

// Socket read timed out
- (NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(CFIndex)length
{
	[ircDelegate logMessage:@"IRCBot - Socket read timed out" type:1];
	return -1;
}


#pragma mark -
#pragma mark Dealloc Memory

// deallocate used memory
- (void)dealloc
{
	[ircSocket release];
	[super dealloc]; 
}


@end
