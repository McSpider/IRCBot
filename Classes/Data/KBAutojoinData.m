//
//  AutojoinData.m
//  IRCBot
//
//  Created by Ben K on 2010/11/29.
//  All code is provided under the New BSD license.
//

#import "KBAutojoinData.h"


@implementation KBAutojoinData
@synthesize autojoinArray;


- (id)init
{
	if (![super init])
		return nil;
	
	self.autojoinArray = [[NSMutableArray alloc] init];
	[self.autojoinArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"autojoin"]];		
	return self;
}

- (IBAction)addNewRoom:(id)sender
{
	[self addRoom:[NSString stringWithFormat:@"#null%i",[autojoinArray count]] autojoin:YES];
}

- (IBAction)removeSelectedRoom:(id)sender
{
	[self.autojoinArray removeObjectAtIndex:[autojoinView selectedRow]];
	[autojoinView reloadData];
}


- (void)addRoom:(NSString *)room autojoin:(BOOL)autojoin
{	
	NSArray *tempArray = [NSArray arrayWithObjects:room,[NSNumber numberWithInt:autojoin],nil];
	[self.autojoinArray addObject:tempArray];
	[autojoinView reloadData];
}

- (void)removeRoom:(NSString *)room
{
	
}

- (void)clearData
{
	[self.autojoinArray setArray:[NSArray array]];
	[autojoinView reloadData];
}


#pragma mark -
#pragma mark delegate messages

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.autojoinArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSArray *tempArray = [self.autojoinArray objectAtIndex:row];
	
	if ([[tableColumn identifier] intValue] == 0)
		return [tempArray objectAtIndex:0];
	if ([[tableColumn identifier] intValue] == 1)
		return [tempArray objectAtIndex:1];
	return @"";
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if ([autojoinView selectedRow] == -1) {
		[removeRoomButton setEnabled:NO];
	} else {
		[removeRoomButton setEnabled:YES];
	}
	roomIndex = [autojoinView selectedRow];	
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(NSObject *)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSMutableArray *tempArray = [self.autojoinArray objectAtIndex:row];
	if ([[tableColumn identifier] intValue] == 0)
		tempArray = [NSMutableArray arrayWithObjects:object, [tempArray objectAtIndex:1], nil];
	if ([[tableColumn identifier] intValue] == 1)
		tempArray = [NSMutableArray arrayWithObjects:[tempArray objectAtIndex:0], object, nil];
	[self.autojoinArray replaceObjectAtIndex:row withObject:tempArray];
}

- (void)dealloc
{
	[autojoinArray release];
	[super dealloc];
}

@end
