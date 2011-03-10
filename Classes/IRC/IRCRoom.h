//
//  IRCRoom.h
//  IRCBot
//
//  Created by Ben K on 2010/11/29.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>


@interface IRCRoom : NSObject {
	NSString *name;
	NSString *status;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *status;

- (void)initRoom:(NSString *)aRoom withStatus:(NSString *)aStatus;

@end
