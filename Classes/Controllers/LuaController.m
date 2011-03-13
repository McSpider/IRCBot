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
	self = [super init];
	if (self != nil) {
		// Lua setup
		luaCocoa = [[LuaCocoa alloc] init];	
		connectionData = [[NSArray alloc] init];
		triggers = [[NSArray alloc] init];
	}
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

- (void)setHostmasksClass:(id)theHostmasks
{
	hostmasks = theHostmasks;
}

- (void)setActionsClass:(id)theActions
{
	actions = theActions;
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
	
	int index;
	for (index = 0; index < [actions.actionsArray count]; index++) {
		KBLuaAction *tempAction = [actions.actionsArray objectAtIndex:index];
		
		if ([tempAction restricted]) {
			actionsArray = [actionsArray arrayByAddingObject:[NSString stringWithFormat:@"+%@",tempAction.name]];
		} else {
			actionsArray = [actionsArray arrayByAddingObject:[NSString stringWithFormat:@"-%@",tempAction.name]];
		}
	}
	
	return actionsArray;
}

- (NSArray *)getRooms
{
	NSArray *roomsArray;
	
	int index;
	for (index = 0; index < [rooms.roomArray count]; index++) {
		IRCRoom *tempRoom = [rooms.roomArray objectAtIndex:index];
		roomsArray = [roomsArray arrayByAddingObject:[NSArray arrayWithObjects:tempRoom.name, tempRoom.status, nil]];
	}
		
	return roomsArray;
}

- (NSArray *)getTriggers
{	
	return triggers;
}

- (NSString *)getNickname
{	
	NSString *nick = [connectionData objectAtIndex:2];
	return nick;
}

- (NSString *)getVersion
{
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	return version;
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
	[hostmasks addHostmask:hostmask block:blocked];
}

- (void)removeHostmask:(const char *)mask
{
	NSString *hostmask = [NSString stringWithUTF8String:mask];
	[hostmasks removeHostmask:hostmask];
}

- (void)blockHostmask:(const char *)mask
{
	NSString *hostmask = [NSString stringWithUTF8String:mask];
	[hostmasks hostmask:hostmask isBlocked:YES];
}

- (void)unblockHostmask:(const char *)mask
{
	NSString *hostmask = [NSString stringWithUTF8String:mask];
	[hostmasks hostmask:hostmask isBlocked:NO];
}
	
- (boolean_t)checkAuthFor:(const char *)aUser
{
	NSString *hostmask = [NSString stringWithUTF8String:aUser];	
	return [hostmasks getAuthForHostmask:hostmask];
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

- (void)setConnectionData:(NSArray *)theData andTriggers:(NSArray *)theTriggers
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
	// Run the main function
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
