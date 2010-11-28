//
//  RoomData.m
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import "RoomData.h"

@implementation RoomData
@synthesize roomArray;


- (id)init
{
	if ((self = [super init])) {
		// Correct or is self needed?
		roomArray = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)awakeFromNib
{
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];		
		[self.roomArray addObjectsFromArray:[standardUserDefaults objectForKey:@"rooms"]];
		[self disconnectAllRooms];
		[roomView reloadData];
}

-(void)saveRooms
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:self.roomArray forKey:@"rooms"];
}

-(void)joinRoom:(NSString *)room
{
	int index = [self indexOfRoom:room];
	if (index == -1)
		[self.roomArray addObject:[NSMutableArray arrayWithObjects:room,@"Normal",nil]];
	else
		[self setStatus:@"Normal" forRoom:room];
	[roomView reloadData];
	[self saveRooms];
}

-(void)removeRoom:(NSString *)room
{
	int index;
	if ((index = [self indexOfRoom:room]) != -1){
		[self.roomArray removeObjectAtIndex:index];
		[roomView reloadData];
	}
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

-(void)setStatus:(NSString *)status forRoom:(NSString *)room
{
	int index;
	if ((index = [self indexOfRoom:room]) != -1){
		[[self.roomArray objectAtIndex:index] replaceObjectAtIndex:1 withObject:status];
		[roomView reloadData];
	}
}

-(int)indexOfRoom:(NSString *)room
{
	int index;
	for (index = 0; index < [self.roomArray count]; index++){
		NSArray *tempArray = [self.roomArray objectAtIndex:index];
		if ([[tempArray objectAtIndex:0] isEqualToString:room]){
			return index;
		}
	}
	return -1;
}

-(NSString *)roomAtIndex:(int)index
{
		NSArray *tempArray = [self.roomArray objectAtIndex:index];
		return [tempArray objectAtIndex:0];
}

-(BOOL)connectedToRoom:(NSString *)room
{
	int index;
	if ((index = [self indexOfRoom:room]) != -1){
		NSArray *tempArray = [self.roomArray objectAtIndex:index];
		if ([[tempArray objectAtIndex:1] isEqualToString:@"Normal"]){
			return YES;
		}
	}
	return NO;
}


#pragma mark -
#pragma mark delegate messages

-(int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.roomArray count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(int)row
{	
	NSArray *tempArray = [self.roomArray objectAtIndex:row];
	if ([[column identifier] intValue] == 0){
		if ([[tempArray objectAtIndex:1] isEqualToString:@"None"])
			return [NSImage imageNamed:@"Empty.png"];
		else if ([[tempArray objectAtIndex:1] isEqualToString:@"Normal"])
			return [NSImage imageNamed:@"Room.png"];
		else if ([[tempArray objectAtIndex:1] isEqualToString:@"Warning"])
			return [NSImage imageNamed:@"Alert.png"];
		else
			return [NSImage imageNamed:@"Empty.png"];
	}else if ([[column identifier] intValue] == 1){
		return [tempArray objectAtIndex:0];
	}
	return @"#null";
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
