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

- (id)init{
	if ((self = [super init])) {
		// Correct or is self needed?
		roomArray = [[NSMutableArray alloc] init];
		statusArray= [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)addRoom:(NSString *)room{
	if ([self.roomArray containsObject:room]){
		[statusArray replaceObjectAtIndex:[self.roomArray indexOfObject:room] withObject:@"Normal"];
		[roomView reloadData];
		return;
	}
	[self.roomArray addObject:room];
	[statusArray addObject:@"Normal"];
	[roomView reloadData];
}

-(void)removeRoom:(NSString *)room{
	[statusArray removeObjectAtIndex:[self.roomArray indexOfObject:room]];
	[self.roomArray removeObject:room];
	[roomView reloadData];
}

-(void)removeAllRooms{
	self.roomArray = nil;
	statusArray = nil;
	[roomView reloadData];
}

-(void)setRoom:(NSString *)room status:(NSString *)status{
	if ([self.roomArray containsObject:room]){
		if ([status isEqualToString:@"Warning"])
			[statusArray replaceObjectAtIndex:[self.roomArray indexOfObject:room] withObject:@"Warning"];
		else if ([status isEqualToString:@"Normal"])
			[statusArray replaceObjectAtIndex:[self.roomArray indexOfObject:room] withObject:@"Normal"];
		else if ([status isEqualToString:@"None"])
			[statusArray replaceObjectAtIndex:[self.roomArray indexOfObject:room] withObject:@"None"];
		else
			[statusArray replaceObjectAtIndex:[self.roomArray indexOfObject:room] withObject:@"None"];
		[roomView reloadData];
	}
}

-(BOOL)connectedToRoom:(NSString *)room{
	if ([self.roomArray containsObject:room]){
		if ([[statusArray objectAtIndex:[self.roomArray indexOfObject:room]] isEqualToString:@"Warning"])
			return NO;
		else if ([[statusArray objectAtIndex:[self.roomArray indexOfObject:room]] isEqualToString:@"None"])
			return NO;
		return YES;
	}
	return NO;
}

#pragma mark -
#pragma mark delegate messages

// delegate messages //
-(int)numberOfRowsInTableView:(NSTableView *)tableView{
	return [self.roomArray count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row{
	if ([[tableColumn identifier] intValue] == 0){
		if ([[statusArray objectAtIndex:row] isEqualToString:@"Warning"])
			return [NSImage imageNamed:@"Alert"];
		else if ([[statusArray objectAtIndex:row] isEqualToString:@"Normal"])
			return [NSImage imageNamed:@"Room"];
		else
			return [NSImage imageNamed:@"Empty"];
	}else if ([[tableColumn identifier] intValue] == 1)
		return [self.roomArray objectAtIndex:row];
	return @"";
}

-(BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView{
	return NO;
}

/*-(void)tableView:(NSTableView *)tableView setObjectValue:(NSObject *)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row{
	NSObject *aObject;
	if ([[tableColumn identifier] intValue] == 0)
		aObject = [NSImage imageNamed:@"Room"];
	if ([[tableColumn identifier] intValue] == 1)
		aObject = [NSString stringWithFormat:@"%@",object];
	[self.roomArray replaceObjectAtIndex:row withObject:aObject];
}*/

-(void)dealloc{
	[roomArray release];
	[statusArray release];
	[super dealloc];
}

@end
