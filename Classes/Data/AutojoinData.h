//
//  AutojoinData.h
//  IRCBot
//
//  Created by Ben K on 2010/11/29.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>


@interface AutojoinData : NSObject {

	int roomIndex;
	NSMutableArray *autojoinArray;
	
	IBOutlet NSTableView *autojoinView;
	IBOutlet NSButton *removeRoomButton;
	
}

@property (nonatomic,assign) NSMutableArray *autojoinArray;

-(IBAction)addNewRoom:(id)sender;
-(IBAction)removeSelectedRoom:(id)sender;

-(void)addRoom:(NSString *)room autojoin:(BOOL)autojoin;
-(void)removeRoom:(NSString *)room;
-(void)clearData;

@end
