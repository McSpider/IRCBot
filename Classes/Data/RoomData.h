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
	IBOutlet NSButton *removeRoomButton;
}

@property (nonatomic,assign) NSMutableArray *roomArray;

-(IBAction)removeSelectedRoom:(id)sender;

-(void)joinRoom:(NSString *)room;
-(void)disconnectRoom:(NSString *)room;
-(void)disconnectAllRooms;

-(int)indexOfRoom:(NSString *)room;
-(NSString *)roomAtIndex:(int)index;

-(void)addRoom:(NSString *)room withStatus:(NSString *)status;
-(void)setStatus:(NSString *)status forRoom:(NSString *)room;
-(BOOL)connectedToRoom:(NSString *)room;

@end
