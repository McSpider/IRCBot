//
//  IRCRooms.m
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import "IRCRooms.h"


@interface IRCRooms (Private)
- (int)indexOfRoom:(NSString *)room;
- (NSString *)roomAtIndex:(int)index;
@end


@implementation IRCRooms

@synthesize roomArray;


- (id)init
{
	if (![super init])
		return nil;
	
	roomArray = [[NSMutableArray alloc] init];
	return self;
}

- (void)addRoom:(NSString *)room
{
	int index = [self indexOfRoom:room];
	if (index == -1) {
		IRCRoom *tempRoom = [[IRCRoom alloc] init];
		tempRoom.name = room;
		[self.roomArray addObject:tempRoom];
	}
	[roomView reloadData];
}

- (void)removeRoom:(NSString *)room
{
	int index;
	if ((index = [self indexOfRoom:room]) != -1) {
		[self.roomArray removeObjectAtIndex:index];
		[roomView reloadData];
	}
}

- (void)removeAllRooms
{
	[self.roomArray removeAllObjects];
	[roomView reloadData];
}

// None, Normal, Warning
- (void)setStatus:(NSString *)status forRoom:(NSString *)room
{
	int index;
	if ((index = [self indexOfRoom:room]) != -1) {
		IRCRoom *tempRoom = [self.roomArray objectAtIndex:index];
		tempRoom.status = status;
		[roomView reloadData];
	}
}


#pragma mark -
#pragma mark Data messages

- (BOOL)connectedToRoom:(NSString *)room
{
	int index;
	if ((index = [self indexOfRoom:room]) != -1) {
		IRCRoom *tempRoom = [self.roomArray objectAtIndex:index];
		if ([tempRoom.status isEqualToString:@"Normal"]) {
			return YES;
		}
	}
	return NO;
}

- (int)indexOfRoom:(NSString *)room
{
	int index;
	for (index = 0; index < [self.roomArray count]; index++) {
		IRCRoom *tempRoom = [self.roomArray objectAtIndex:index];
		if ([tempRoom.name isEqualToString:room]) {
			return index;
		}
	}
	return -1;
}

- (NSString *)roomAtIndex:(int)index
{
	IRCRoom *tempRoom = [self.roomArray objectAtIndex:index];
	return tempRoom.name;
}


#pragma mark -
#pragma mark Delegate messages

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.roomArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(int)row
{	
	IRCRoom *tempRoom = [self.roomArray objectAtIndex:row];
	if ([[column identifier] intValue] == 0) {
		if ([tempRoom.status isEqualToString:@"None"])
			return [NSImage imageNamed:@"Status_None.png"];
		else if ([tempRoom.status isEqualToString:@"Normal"])
			return [NSImage imageNamed:@"Status_Room.png"];
		else if ([tempRoom.status isEqualToString:@"Warning"])
			return [NSImage imageNamed:@"Status_Alert.png"];
		else
			return [NSImage imageNamed:@"Status_None.png"];
	} else if ([[column identifier] intValue] == 1) {
		return tempRoom.name;
	}
	return @"#null";
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView
{
	return NO;
}

- (void)dealloc
{
	[roomArray release];
	[super dealloc];
}

@end
