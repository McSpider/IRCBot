//
//  KBHostmasksData.m
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import "KBHostmasksData.h"

@implementation KBHostmasksData
@synthesize hostmaskArray;


#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (![super init])
		return nil;
	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	self.hostmaskArray = [[NSMutableArray alloc] init];
	[self.hostmaskArray addObjectsFromArray:[standardUserDefaults objectForKey:@"hostmasks"]];		
	return self;
}


#pragma mark -
#pragma mark IBActions

- (IBAction)addNewHostmask:(id)sender
{
  // Check that the hostmask isn't blank
  if ([newHostmaskField stringValue].length < 1) {
    [sheetErrorMessage setStringValue:@"Invalid hostmask."];
    return;
  }
  
	// Check if this hostmask exists
	for (NSArray *hostmaskData in self.hostmaskArray) {
		if ([[hostmaskData objectAtIndex:0] isEqualToString:[newHostmaskField stringValue]]){
			[sheetErrorMessage setStringValue:@"This hostmask already exists."];
			return;
		}
	}
	// If not add it, otherwise show a alert message
	[self addHostmask:[newHostmaskField stringValue] block:[newHostmaskCheck state]];
	[sheetErrorMessage setStringValue:@" "];
	[addHostmaskPane closeSheet:self];
}


#pragma mark -
#pragma mark Methods

- (void)addHostmask:(NSString *)host block:(BOOL)boolean
{
	int auth;
	if (boolean) auth = 1;
	else auth = 0;
	
	BOOL exists = NO;
	
	int index;
	for (index = 0; index < [self.hostmaskArray count]; index++) {
		NSArray *hostmaskData = [self.hostmaskArray objectAtIndex:index];
		if ([[hostmaskData objectAtIndex:0] isEqualToString:host]){
			NSArray *tempArray = [NSArray arrayWithObjects:host,[NSNumber numberWithInt:auth],nil];
			[self.hostmaskArray replaceObjectAtIndex:index withObject:tempArray];
			exists = YES;
			break;
		}
	}
	
	if (!exists) {
		NSArray *tempArray = [NSArray arrayWithObjects:host,[NSNumber numberWithInt:auth],nil];
		[self.hostmaskArray addObject:tempArray];
	}
	[hostmaskView reloadData];
}

- (void)removeHostmask:(NSString *)hostmask
{
	int index;
	for (index = 0; index < [self.hostmaskArray count]; index++) {
		NSArray *hostmaskData = [self.hostmaskArray objectAtIndex:index];
		if ([[hostmaskData objectAtIndex:0] isEqualToString:hostmask]) {
			[self.hostmaskArray removeObjectAtIndex:index];
		}
	}
	[hostmaskView reloadData];
}

- (void)hostmask:(NSString *)hostmask setBlocked:(BOOL)boolean
{
	int auth;
	if (boolean) auth = 1;
	else auth = 0;
	
	for (NSMutableArray *hostmaskData in self.hostmaskArray) {
		if ([[hostmaskData objectAtIndex:0] isEqualToString:hostmask]) {
			[hostmaskData replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:auth]];
		}
	}
	[hostmaskView reloadData];
}

- (IBAction)removeSelectedHostmask:(id)sender
{
	[self.hostmaskArray removeObjectAtIndex:[hostmaskView selectedRow]];
	[hostmaskView reloadData];
}

- (void)clearData
{
	[self.hostmaskArray setArray:[NSArray array]];
	[hostmaskView reloadData];
}

- (BOOL)getAuthForHostmask:(NSString *)hostmask
{
	for (NSArray *hostmaskData in self.hostmaskArray) {
		NSString *tempHostmask = [hostmaskData objectAtIndex:0];
		BOOL blocked = [[hostmaskData objectAtIndex:1] intValue];
		if ([hostmask isMatchedByRegex:tempHostmask] && !blocked) {
			return YES;
		}
	}
	return NO;
}


#pragma mark -
#pragma mark Delegate Messages

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.hostmaskArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSArray *hostmask = [self.hostmaskArray objectAtIndex:row];
	
	if ([[tableColumn identifier] intValue] == 0)
		return [hostmask objectAtIndex:0];
	if ([[tableColumn identifier] intValue] == 1)
		return [hostmask objectAtIndex:1];
	return @"";
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if ([hostmaskView selectedRow] == -1)
		[removeHostmaskButton setEnabled:NO];
	else
		[removeHostmaskButton setEnabled:YES];
	
	userIndex = [hostmaskView selectedRow];	
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(NSObject *)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSMutableArray *hostmask = [self.hostmaskArray objectAtIndex:row];
	if ([[tableColumn identifier] intValue] == 0)
		hostmask = [NSMutableArray arrayWithObjects:object, [hostmask objectAtIndex:1], nil];
	if ([[tableColumn identifier] intValue] == 1)
		hostmask = [NSMutableArray arrayWithObjects:[hostmask objectAtIndex:0], object, nil];
	[self.hostmaskArray replaceObjectAtIndex:row withObject:hostmask];
}

- (void)dealloc
{
	[hostmaskArray release];
	[super dealloc];
}

@end
