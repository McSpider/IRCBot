//
//  IRCRooms.m
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import "IRCRooms.h"

@implementation IRCRooms
@synthesize roomArray;


- (id)init
{
	if ((self = [super init])) {
		// Correct or is self needed?
		roomArray = [[NSMutableArray alloc] init];
	}
	return self;
}

-(IBAction)removeSelectedRoom:(id)sender
{
	[self.roomArray removeObjectAtIndex:[roomView selectedRow]];
	[roomView reloadData];
}

-(void)addRoom:(NSString *)room
{
	int index = [self indexOfRoom:room];
	if (index == -1){
		IRCRoom *tempRoom = [[IRCRoom alloc] init];
		tempRoom.name = room;
		[self.roomArray addObject:tempRoom];
	}
	[roomView reloadData];
}

-(void)removeRoom:(NSString *)room
{
	int index;
	if ((index = [self indexOfRoom:room]) != -1){
		[self.roomArray removeObjectAtIndex:index];
		[roomView reloadData];
	}
}

-(void)setStatus:(NSString *)status forRoom:(NSString *)room
{
	int index;
	if ((index = [self indexOfRoom:room]) != -1){
		IRCRoom *tempRoom = [self.roomArray objectAtIndex:index];
		tempRoom.status = status;
		[roomView reloadData];
	}
}

-(void)connectRoom:(NSString *)room
{
	int index = [self indexOfRoom:room];
	if (index == -1){
		[self addRoom:room];
		[self setStatus:@"Normal" forRoom:room];
	}else
		[self setStatus:@"Normal" forRoom:room];
	[roomView reloadData];
}


-(void)disconnectRoom:(NSString *)room
{
	[self setStatus:@"None" forRoom:room];
}

-(void)disconnectAllRooms
{
	int index;
	for (index = 0; index < [self.roomArray count]; index++){
		[self setStatus:@"None" forRoom:[self roomAtIndex:index]];
	}
}


#pragma mark -
#pragma mark Data messages

-(BOOL)connectedToRoom:(NSString *)room
{
	int index;
	if ((index = [self indexOfRoom:room]) != -1){
		IRCRoom *tempRoom = [self.roomArray objectAtIndex:index];
		if ([tempRoom.status isEqualToString:@"Normal"]){
			return YES;
		}
	}
	return NO;
}

-(int)indexOfRoom:(NSString *)room
{
	int index;
	for (index = 0; index < [self.roomArray count]; index++){
		IRCRoom *tempRoom = [self.roomArray objectAtIndex:index];
		if ([tempRoom.name isEqualToString:room]){
			return index;
		}
	}
	return -1;
}

-(NSString *)roomAtIndex:(int)index
{
	IRCRoom *tempRoom = [self.roomArray objectAtIndex:index];
	return tempRoom.name;
}


#pragma mark -
#pragma mark delegate messages

-(int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.roomArray count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(int)row
{	
	IRCRoom *tempRoom = [self.roomArray objectAtIndex:row];
	if ([[column identifier] intValue] == 0){
		if ([tempRoom.status isEqualToString:@"None"])
			return [NSImage imageNamed:@"Status_None.png"];
		else if ([tempRoom.status isEqualToString:@"Normal"])
			return [NSImage imageNamed:@"Status_Room.png"];
		else if ([tempRoom.status isEqualToString:@"Warning"])
			return [NSImage imageNamed:@"Status_Alert.png"];
		else
			return [NSImage imageNamed:@"Status_None.png"];
	}else if ([[column identifier] intValue] == 1){
		return tempRoom.name;
	}
	return @"#null";
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
	if ([roomView selectedRow] == -1 || [roomView selectedRow] == 0)
		[removeRoomButton setEnabled:NO];
	else
		[removeRoomButton setEnabled:YES];
	
	roomIndex = [roomView selectedRow];	
}

-(BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView
{
	return NO;
}

-(void)dealloc{
	[roomArray release];
	[super dealloc];
}

@end
