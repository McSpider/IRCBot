//
//  IRCConnection.h
//  IRCBot
//
//  Created by Ben K on 2010/11/28.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
#import "RegexKitLite.h"


@protocol IRCConnectionDelegate
@optional

- (void)logMessage:(NSString *)message type:(int)type;
- (void)didReadData:(NSString *)msg	ofType:(NSString *)type;
- (void)didConnectToHost:(NSString *)host port:(UInt16)port;
- (void)didDissconect;

@end

@interface IRCConnection : NSObject {
	id ircDelegate;	
}

- (id)initWithDelegate:(id)delegate;
- (id)delegate;
- (void)setDelegate:(id)delegate;

- (BOOL)isConnected;

-(void)setConnectionData:(NSArray *)array;

// Connect and disconnect from IRC server functions
- (void)connectToIRC:(NSString *)server port:(int)port;
- (void)disconnectFromIRC:(NSString *)message;

// Messaging
- (void)sendMessage:(NSString *)message To:(NSString *)recipient logAs:(int)type;
- (void)sendNotice:(NSString *)message To:(NSString *)recipient logAs:(int)type;
- (void)sendAction:(NSString *)message To:(NSString *)recipient logAs:(int)type;
- (void)sendRawString:(NSString *)string logAs:(int)type;


@end
