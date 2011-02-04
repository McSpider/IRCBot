//
//  Actions.m
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import "Actions.h"

@implementation Actions
@synthesize actionsArray;


- (id)init{
	if ((self = [super init])) {		
		self.actionsArray = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)awakeFromNib{	
	//Checks to see AppSupport folder exits if not create it.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *folderPath = @"~/Library/Application Support/IRCBot Actions/";
	NSString *defaultActions = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/contents/resources/IRCBot Actions/"];
	
	folderPath = [folderPath stringByExpandingTildeInPath];
	if ([fileManager fileExistsAtPath: folderPath] == NO)
		[[NSFileManager defaultManager] copyPath:defaultActions toPath:folderPath handler:nil];
	
	// Load the actions data file
	NSString *actionsData = @"~/Library/Application Support/IRCBot Actions/data.plist";
	[self.actionsArray addObjectsFromArray:[NSArray arrayWithContentsOfFile:[actionsData stringByExpandingTildeInPath]]];
	
	// Set the NSPathControl to our home folder
	[actionPath setURL:[NSURL fileURLWithPath:[@"~/Desktop/" stringByExpandingTildeInPath]]];
}

-(void)addAction:(NSString *)action name:(NSString *)name restricted:(BOOL)boolean
{	
	int auth;
	if (boolean) auth = 1;
	else auth = 0;
	
	NSLog(@"Then: %@",[self actionsArray]);
	
	NSArray *tempArray = [NSArray arrayWithObjects:name,action,[NSNumber numberWithInt:auth],nil];
	[self.actionsArray addObject:tempArray];
	
	NSLog(@"Now: %@",[self actionsArray]);
	
	[actionsView reloadData];
}

-(IBAction)addNewAction:(id)sender
{	
	// Get filename
	NSString *url = [[actionPath URL] absoluteString];
	NSArray *parts = [url componentsSeparatedByString:@"/"];
	NSString *filename = [parts lastObject];
	
	// Check if a action by that name already exists
	NSString *exists = @"NO";
	int i;
	for (i = 0; i < [self.actionsArray count]; i++){
		NSArray *actionData = [self.actionsArray objectAtIndex:i];
		if ([[actionData objectAtIndex:0] isEqualToString:[actionName stringValue]]){
			exists = @"A action with that name already exits.";
		}
		if ([[actionData objectAtIndex:1] isEqualToString:filename]){
			exists = @"A action with that file name already exits.";
		}
	}
	
	// If not add it otherwise show a alert message
	if ([exists isEqualToString:@"NO"]){
		// Copy file to ~/AppSupport/IRCBot/
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *folderPath = @"~/Library/Application Support/IRCBot/";
		
		if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",folderPath,filename]])
			[fileManager copyPath:[[actionPath URL] absoluteString] toPath:[NSString stringWithFormat:@"%@/%@",filename] handler:nil];		
		
		// Add reference to data.plist
		[self addAction:filename name:[actionName stringValue] restricted:[restrictAction state]];
		[sheetErrorMessage setStringValue:@""];
		[addActionPane closeSheet:self];
	}else{
		[sheetErrorMessage setStringValue:exists];
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
