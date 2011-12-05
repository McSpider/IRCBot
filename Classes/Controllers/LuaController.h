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
@class UserSettings;

@interface LuaController : NSObject {
	MainController *main;
	IRCConnection *irc;
	IRCRooms *rooms;
	UserSettings *settings;
	
	LuaCocoa* luaCocoa;
	NSDictionary* connectionData;
	NSArray* triggers;
}

- (void)setParentClass:(id)parent;
- (void)setConnectionClass:(id)theConnection;
- (void)setRoomsClass:(id)theRooms;
- (void)setSettingsClass:(id)theSettings;

- (void)loadFile:(NSString *)fileName;
- (void)setConnectionData:(NSDictionary *)theData andTriggers:(NSArray *)theTriggers;
- (void)runMainFunctionWithData:(NSArray *)data andArguments:(NSArray *)args;

@end
