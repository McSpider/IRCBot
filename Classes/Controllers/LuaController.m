//
//  LuaController.m
//  IRCBot
//
//  Created by Ben K on 2011/02/02.
//  All code is provided under the New BSD license.
//

#import "LuaController.h"
#import "MainController.h"

#import "IRCConnection.h"
#import "IRCRooms.h"
#import "KBHostmasksData.h"
#import	"KBLuaActionsData.h"

@implementation LuaController


#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (![super init])
		return nil;
	
	luaCocoa = [[LuaCocoa alloc] init];	
	connectionData = [[NSDictionary alloc] init];
	triggers = [[NSArray alloc] init];
	return self;
}

- (void)setParentClass:(id)parent
{
	main = parent;
}

- (void)setConnectionClass:(id)theConnection
{
	irc = theConnection;
}

- (void)setRoomsClass:(id)theRooms
{
	rooms = theRooms;
}

- (void)setSettingsClass:(id)theSettings
{
	settings = theSettings;
}


#pragma mark -
#pragma mark Methods

- (void)dissconectWithMessage:(const char *)aMessage
{
	NSString *message = [NSString stringWithUTF8String:aMessage];
	[irc disconnectWithMessage:message];
}

- (void)joinRoom:(const char *)aRoom
{
	NSString *room = [NSString stringWithUTF8String:aRoom];
	[main joinRoom:room];
}

- (void)partRoom:(const char *)aRoom
{
	NSString *room = [NSString stringWithUTF8String:aRoom];
	[main partRoom:room];
}


// Data
- (NSArray *)getActions
{
	NSArray *actionsArray;
	for (KBLuaAction *luaAction in [settings.actionsData actionsArray]) {		
		if ([luaAction restricted])
			actionsArray = [actionsArray arrayByAddingObject:[NSString stringWithFormat:@"+%@",luaAction.name]];
		else
			actionsArray = [actionsArray arrayByAddingObject:[NSString stringWithFormat:@"-%@",luaAction.name]];
	}
	return [actionsArray retain];
}

- (NSArray *)getRooms
{
	NSArray *roomsArray;	
	for (IRCRoom *ircRoom in [rooms roomArray]) {
		roomsArray = [roomsArray arrayByAddingObject:[NSArray arrayWithObjects:ircRoom.name, ircRoom.status, nil]];
	}
	return roomsArray;
}

- (NSArray *)getTriggers
{	
	return triggers;
}

- (NSString *)getNickname
{	
	return [connectionData objectForKey:@"Nickname"];
}

- (NSString *)getVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}


// Messaging
- (void)sendMessage:(const char *)aMessage to:(const char *)aRecipient
{
	NSString *message = [NSString stringWithUTF8String:aMessage];
	NSString *recipient = [NSString stringWithUTF8String:aRecipient];
	[irc sendMessage:message To:recipient logAs:3];
}

- (void)sendNotice:(const char *)aNotice to:(const char *)aRecipient
{
	NSString *notice = [NSString stringWithUTF8String:aNotice];
	NSString *recipient = [NSString stringWithUTF8String:aRecipient];
	[irc sendNotice:notice To:recipient logAs:3];
}

- (void)sendActionMessage:(const char *)aAction to:(const char *)aRecipient
{
	NSString *action = [NSString stringWithUTF8String:aAction];
	NSString *recipient = [NSString stringWithUTF8String:aRecipient];
	[irc sendAction:action To:recipient logAs:3];
}

- (void)sendRawMessage:(const char *)aString
{
	NSString *message = [NSString stringWithUTF8String:aString];
	[irc sendRawString:message logAs:3];
}

// Hostmask tools
- (void)addHostmask:(const char *)mask block:(BOOL)blocked
{
	NSString *hostmask = [NSString stringWithUTF8String:mask];
	[settings.hostmasksData addHostmask:hostmask block:blocked];
}

- (void)removeHostmask:(const char *)mask
{
	NSString *hostmask = [NSString stringWithUTF8String:mask];
	[settings.hostmasksData removeHostmask:hostmask];
}

- (void)blockHostmask:(const char *)mask
{
	NSString *hostmask = [NSString stringWithUTF8String:mask];
	[settings.hostmasksData hostmask:hostmask setBlocked:YES];
}

- (void)unblockHostmask:(const char *)mask
{
	NSString *hostmask = [NSString stringWithUTF8String:mask];
	[settings.hostmasksData hostmask:hostmask setBlocked:NO];
}
	
- (boolean_t)checkAuthFor:(const char *)aUser
{
	NSString *hostmask = [NSString stringWithUTF8String:aUser];	
	return [settings.hostmasksData getAuthForHostmask:hostmask];
}


#pragma mark -
#pragma mark Lua

- (void)loadFile:(NSString *)fileName
{	
	lua_State* luaState = [luaCocoa luaState];
	int error;
	
	NSString *filePath = [[NSString stringWithFormat:@"~/Library/Application Support/IRCBot Actions/%@",fileName] stringByExpandingTildeInPath];
	
	error = luaL_loadfile(luaState, [filePath fileSystemRepresentation]);
	if (error) {
		NSLog(@"luaL_loadfile failed: %s", lua_tostring(luaState, -1));
		lua_pop(luaState, 1); /* pop error message from stack */
		exit(0);
	} 
	error = lua_pcall(luaState, 0, 0, 0);
	if (error) {
		NSLog(@"Lua parse load failed: %s", lua_tostring(luaState, -1));
		lua_pop(luaState, 1); /* pop error message from stack */
		exit(0);
	}	
}

- (void)setConnectionData:(NSDictionary *)theData andTriggers:(NSArray *)theTriggers
{
	if (connectionData != theData) {
		[connectionData release];
		connectionData = [theData copy];
	}
	if (triggers != theTriggers) {
		[triggers release];
		triggers = [theTriggers copy];
	}
}

- (void)runMainFunctionWithData:(NSArray *)data andArguments:(NSArray *)args
{
	[luaCocoa pcallLuaFunction:"main" withSignature:"@@@",data,args,self];
}


#pragma mark -
#pragma mark Dealloc Memory

- (void)dealloc
{
	[luaCocoa release];
	[connectionData release];
	[triggers release];
	[super dealloc];
}

@end
