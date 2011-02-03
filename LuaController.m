//
//  LuaController.m
//  IRCBot
//
//  Created by Ben K on 2011/02/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LuaController.h"
#import "MainController.h"

#import "IRCConnection.h"
#import "IRCRooms.h"
#import "Hostmasks.h"
#import	"Actions.h"

@implementation LuaController


#pragma mark -
#pragma mark Initialization

- (id)init
{
	self = [super init];
	if (self != nil) {
		// Lua setup
		luaCocoa = [[LuaCocoa alloc] init];	
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
#pragma mark Functions

- (void)dissconectWithMessage:(NSString *)message
{
	[irc disconnectWithMessage:message];
}

- (void)joinRoom:(NSString *)room
{
	[main joinRoom:room];
}

- (void)partRoom:(NSString *)room
{
	[main partRoom:room];
}

- (NSArray *)getActionsList
{
	return [actions actionsArray];
}

- (NSArray *)getRoomsList
{
	return [rooms roomArray];
}


// Messaging
- (void)sendMessage:(NSString *)message to:(NSString *)recipient
{
	[irc sendMessage:message To:recipient logAs:3];
}

- (void)sendNotice:(NSString *)notice to:(NSString *)recipient
{
	[irc sendNotice:notice To:recipient logAs:3];
}

- (void)sendActionMessage:(NSString *)action to:(NSString *)recipient
{
	[irc sendAction:action To:recipient logAs:3];
}

- (void)sendRawMessage:(NSString *)message
{
	[irc sendRawString:message logAs:3];

}

// Hostmask tools
- (void)addHostmask:(NSString *)mask block:(BOOL)blocked
{
	
}

- (void)removeHostmask:(NSString *)mask
{
	
}

- (void)blockHostmask:(NSString *)mask
{
	
}

- (void)unblockHostmask:(NSString *)mask
{
	
}

-(void)listHostmasks
{
	
}

#pragma mark -
#pragma mark Lua

- (void)loadFile:(NSString *)fileName
{	
	lua_State* luaState = [luaCocoa luaState];
	int error;
	
	NSString *filePath = [[NSString stringWithFormat:@"~/Library/Application Support/IRCBot Actions/%@",fileName] stringByExpandingTildeInPath];
	
	error = luaL_loadfile(luaState, [filePath fileSystemRepresentation]);
	if(error)
	{
		NSLog(@"luaL_loadfile failed: %s", lua_tostring(luaState, -1));
		lua_pop(luaState, 1); /* pop error message from stack */
		exit(0);
	} 
	error = lua_pcall(luaState, 0, 0, 0);
	if(error)
	{
		NSLog(@"Lua parse load failed: %s", lua_tostring(luaState, -1));
		lua_pop(luaState, 1); /* pop error message from stack */
		exit(0);
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
	[super dealloc];
}

@end
