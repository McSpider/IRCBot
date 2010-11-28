//
//  ActionsData.m
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import "ActionsData.h"

@implementation ActionsData
@synthesize actionsArray;


- (id)init{
	if ((self = [super init])) {		
		self.actionsArray = [[NSMutableArray alloc] init];
		NSString *folder = @"~/Library/Application Support/IRCBot/";
		NSString *actions = @"~/Library/Application Support/IRCBot/Actions.plist";
		NSString *defaultActions = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/contents/resources/Actions.plist"];
		
		// If actions file exits in support folder load it, otherwise load the default file
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath: actions]){
			if ([fileManager fileExistsAtPath: folder] == NO)
				[fileManager createDirectoryAtPath: folder attributes: nil];
			[fileManager copyPath:defaultActions toPath:[NSString stringWithFormat:@"%@/Actions.plist",folder] handler:nil];
		}
		[self.actionsArray addObjectsFromArray:[NSArray arrayWithContentsOfFile:[actions stringByExpandingTildeInPath]]];	
	}
	return self;
}

-(void)addAction:(NSString *)action name:(NSString *)name restricted:(BOOL)restricted
{	
	NSString *auth;
	if (restricted) auth = @"Yes";
	else auth = @"No";
	
	NSArray *tempArray = [NSArray arrayWithObjects:name,action,auth,nil];
	[self.actionsArray addObject:tempArray];
	[actionsView reloadData];
}

-(IBAction)addNewAction:(id)sender
{
	// Check if a action by that name already exists
	BOOL exists = NO;
	int i;
	for (i = 0; i < [self.actionsArray count]; i++){
		NSArray *actionData = [self.actionsArray objectAtIndex:i];
		if ([[actionData objectAtIndex:0] isEqualToString:[actionName stringValue]]){
			exists = YES;
		}
	}
	// If not add it otherwise show a alert message
	if (!exists){
		[self addAction:[actionFunction stringValue] name:[actionName stringValue] restricted:[restrictAction state]];
		[sheetErrorMessage setStringValue:@""];
		[addActionPane closeSheet:self];
	}else{
		[sheetErrorMessage setStringValue:@"A action with that name already exits."];
	}
}

-(IBAction)removeSelectedAction:(id)sender
{
	[self.actionsArray removeObjectAtIndex:[actionsView selectedRow]];
	[actionsView reloadData];
}


#pragma mark -
#pragma mark delegate messages

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.actionsArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row{
	NSArray *tempArray = [self.actionsArray objectAtIndex:row];
	
	if ([[tableColumn identifier] intValue] == 0)
		return [tempArray objectAtIndex:0];
	if ([[tableColumn identifier] intValue] == 1)
		return [tempArray objectAtIndex:1];
	if ([[tableColumn identifier] intValue] == 2)
		return [tempArray objectAtIndex:2];
	return @"";
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
	if ([actionsView selectedRow] == -1)
		[removeActionButton setEnabled:NO];
	else
		[removeActionButton setEnabled:YES];
	
	actionIndex = [actionsView selectedRow];	
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(NSObject *)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row{
	NSMutableArray *tempArray = [self.actionsArray objectAtIndex:row];
	if ([[tableColumn identifier] intValue] == 0)
		tempArray = [NSMutableArray arrayWithObjects:object, [tempArray objectAtIndex:1], [tempArray objectAtIndex:2], nil];
	if ([[tableColumn identifier] intValue] == 1)
		tempArray = [NSMutableArray arrayWithObjects:[tempArray objectAtIndex:0], object, [tempArray objectAtIndex:2], nil];
	if ([[tableColumn identifier] intValue] == 2)
		tempArray = [NSMutableArray arrayWithObjects:[tempArray objectAtIndex:0], [tempArray objectAtIndex:1], object, nil];
	[self.actionsArray replaceObjectAtIndex:row withObject:tempArray];
}

-(void)dealloc{
	[actionsArray release];
	[super dealloc];
}

@end
