//
//  RoomData.h
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "IRCRoom.h"

@interface RoomData : NSObject {
	
	int roomIndex;
	NSMutableArray *roomArray;
	IBOutlet NSTableView *roomView;
	IBOutlet NSButton *removeRoomButton;
}

@property (nonatomic,assign) NSMutableArray *roomArray;

-(IBAction)removeSelectedRoom:(id)sender;

-(void)addRoom:(NSString *)room;
-(void)removeRoom:(NSString *)room;
-(void)setStatus:(NSString *)status forRoom:(NSString *)room;
-(void)connectRoom:(NSString *)room;
-(void)disconnectRoom:(NSString *)room;
-(void)disconnectAllRooms;

-(BOOL)connectedToRoom:(NSString *)room;
-(int)indexOfRoom:(NSString *)room;
-(NSString *)roomAtIndex:(int)index;


@end
