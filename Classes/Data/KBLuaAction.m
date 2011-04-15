//
//  KBLuaAction.m
//  IRCBot
//
//  Created by Ben K on 2011/03/08.
//  All code is provided under the New BSD license.
//

#import "KBLuaAction.h"


@implementation KBLuaAction

@synthesize name;
@synthesize file;
@synthesize restricted;
@synthesize enabled;


- (id)init
{
	if (![super init])
		return nil;
	
	self.name = [[NSString alloc] initWithString:@"Untitled"];
	self.file = [[NSString alloc] initWithString:@"NULL"];
	self.restricted = NO;
	self.enabled = YES;
	return self;
}

- (void)setName:(NSString *)aName filePath:(NSString *)aFile restricted:(BOOL)boolean
{
	self.name = aName;
	self.file = aFile;
	self.restricted = boolean;
}

- (NSString*)description
{    
	return [NSString stringWithFormat:@"Lua Action:%@ file:%@ restricted:%i", self.name, self.file, self.restricted];
}

- (void)dealloc
{
	self.name = nil;
	self.file = nil;
	[super dealloc];
}


@end
