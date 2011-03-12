//
//  IRCRooms.h
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "IRCRoom.h"

@interface IRCRooms : NSObject {
	
	int roomIndex;
	NSMutableArray *roomArray;
	IBOutlet NSTableView *roomView;
	
}

@property (nonatomic,assign) NSMutableArray *roomArray;


- (void)addRoom:(NSString *)room;
- (void)removeRoom:(NSString *)room;
- (void)removeAllRooms;
- (void)setStatus:(NSString *)status forRoom:(NSString *)room;

- (BOOL)connectedToRoom:(NSString *)room;
- (int)indexOfRoom:(NSString *)room;
- (NSString *)roomAtIndex:(int)index;


@end
