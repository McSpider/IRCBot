//
//  IRCRoom.m
//  IRCBot
//
//  Created by Ben K on 2010/11/29.
//  All code is provided under the New BSD license.
//

#import "IRCRoom.h"


@implementation IRCRoom
@synthesize name;
@synthesize status;

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.name = [[NSString alloc] initWithString:@"#null"];
		self.status = [[NSString alloc] initWithString:@"None"];
	}
	return self;
}


- (void)initRoom:(NSString *)aRoom withStatus:(NSString *)aStatus
{
	self.name = aRoom;
	self.status = aStatus;
}

- (NSString*)description{    
	return [NSString stringWithFormat:@"IRC Room:%@ status:%@", self.name, self.status];
}

- (void)dealloc{
	self.name = nil;
	self.status = nil;
	[super dealloc];
}

@end
