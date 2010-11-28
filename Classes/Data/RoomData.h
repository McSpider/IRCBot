//
//  RoomData.h
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>


@interface RoomData : NSObject {
	
	int roomIndex;
	NSMutableArray *roomArray;
	IBOutlet NSTableView *roomView;
	IBOutlet NSButton *rememberConnectedRooms;
}

@property (nonatomic,assign) NSMutableArray *roomArray;


-(void)joinRoom:(NSString *)room;
-(void)disconnectRoom:(NSString *)room;
-(void)disconnectAllRooms;

-(void)saveRooms;

-(int)indexOfRoom:(NSString *)room;
-(NSString *)roomAtIndex:(int)index;

-(void)setStatus:(NSString *)status forRoom:(NSString *)room;
-(BOOL)connectedToRoom:(NSString *)room;

@end
