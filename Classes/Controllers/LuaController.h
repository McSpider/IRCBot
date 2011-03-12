//
//  LuaController.h
//  IRCBot
//
//  Created by Ben K on 2011/02/02.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import <LuaCocoa/LuaCocoa.h>

@class MainController;
@class IRCConnection;
@class IRCRooms;
@class KBHostmasksData;
@class KBLuaActionsData;

@interface LuaController : NSObject {
	MainController *main;
	IRCConnection *irc;
	IRCRooms *rooms;
	KBHostmasksData *hostmasks;
	KBLuaActionsData *actions;
	
	LuaCocoa* luaCocoa;
	NSArray* connectionData;
	NSArray* triggers;
}

- (void)setParentClass:(id)parent;
- (void)setConnectionClass:(id)theConnection;
- (void)setRoomsClass:(id)theRooms;
- (void)setHostmasksClass:(id)theHostmasks;
- (void)setActionsClass:(id)theActions;


- (void)loadFile:(NSString *)fileName;
- (void)setConnectionData:(NSArray *)theData andTriggers:(NSArray *)theTriggers;
- (void)runMainFunctionWithData:(NSArray *)data andArguments:(NSArray *)args;

@end
