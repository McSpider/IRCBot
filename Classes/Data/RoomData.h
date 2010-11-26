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
	NSMutableArray *statusArray;
	IBOutlet NSTableView *roomView;	
}

@property (nonatomic,assign) NSMutableArray *roomArray;


-(void)addRoom:(NSString *)room;
-(void)removeRoom:(NSString *)room;
-(void)removeAllRooms;

-(void)setRoom:(NSString *)room status:(NSString *)status;
-(BOOL)connectedToRoom:(NSString *)room;

@end
