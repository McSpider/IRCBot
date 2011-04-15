//
//  KBLuaAction.h
//  IRCBot
//
//  Created by Ben K on 2011/03/08.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>


@interface KBLuaAction : NSObject {
	NSString *name;
	NSString *file;
	BOOL restricted;
	BOOL enabled;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *file;
@property BOOL restricted;
@property BOOL enabled;


- (void)setName:(NSString *)aName filePath:(NSString *)aFile restricted:(BOOL)boolean;

@end
