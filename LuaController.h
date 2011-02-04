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
@class Hostmasks;
@class Actions;

@interface LuaController : NSObject {
	MainController *main;
	IRCConnection *irc;
	IRCRooms *rooms;
	Hostmasks *hostmasks;
	Actions *actions;
	
	LuaCocoa* luaCocoa;
}

- (void)setParentClass:(id)parent;
- (void)setConnectionClass:(id)theConnection;
- (void)setRoomsClass:(id)theRooms;
- (void)setHostmasksClass:(id)theHostmasks;
- (void)setActionsClass:(id)theActions;


- (void)loadFile:(NSString *)fileName;
- (void)runMainFunctionWithData:(NSArray *)data andArguments:(NSArray *)args;

@end
