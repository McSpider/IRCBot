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

- (void)awakeFromNib{	
	//Checks to see AppSupport folder exits if not create it.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *folderPath = @"~/Library/Application Support/IRCBot Actions/";
	NSString *defaultActions = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/contents/resources/IRCBot Actions/"];
	
	folderPath = [folderPath stringByExpandingTildeInPath];
	if ([fileManager fileExistsAtPath: folderPath] == NO)
		[[NSFileManager defaultManager] copyPath:defaultActions toPath:folderPath handler:nil];
	
	// Load the actions data file
	NSString *actionsData = @"~/Library/Application Support/IRCBot Actions/data.plist";
	[self loadActionsFromFile:actionsData];
	
	// Set the NSPathControl to our home folder
	[actionPath setURL:[NSURL fileURLWithPath:[@"~/Desktop/" stringByExpandingTildeInPath]]];
	
}

- (void)loadActionsFromFile:(NSString *)file
{
	file = [file stringByExpandingTildeInPath];
	NSArray *actionsData = [NSArray arrayWithContentsOfFile:file]; 
	
	int index;
	for (index = 0; index < [actionsData count]; index++) {
		NSArray *action = [actionsData objectAtIndex:index];
		
		LuaAction *tempAction = [[LuaAction alloc] init];
		[tempAction setName:[action objectAtIndex:0] filePath:[action objectAtIndex:1] restricted:[[action objectAtIndex:2] boolValue]];
		[self.actionsArray addObject:tempAction];
		[tempAction release];
	}
}

- (void)saveActionsToFile:(NSString *)file
{
	file = [file stringByExpandingTildeInPath];
	NSMutableArray *actionsData = [[NSMutableArray alloc] init]; 
	
	int index;
	for (index = 0; index < [self.actionsArray count]; index++) {
		LuaAction *tempAction = [self.actionsArray objectAtIndex:index];
		
		NSArray *action = [NSArray arrayWithObjects:tempAction.name,tempAction.file,[NSNumber numberWithBool:tempAction.restricted],nil];
		[actionsData addObject:action];
	}
	[actionsData writeToFile:file atomically:YES];
	[actionsData release];
}


- (void)addAction:(NSString *)action name:(NSString *)name restricted:(BOOL)boolean
{	
	LuaAction *tempAction = [[LuaAction alloc] init];
	[tempAction setName:name filePath:action restricted:boolean];
	
	[self.actionsArray addObject:tempAction];
	[tempAction release];
	
	[actionsView reloadData];
}

- (IBAction)addNewAction:(id)sender
{	
	// Get filename
	NSString *url = [[actionPath URL] absoluteString];
	NSArray *parts = [url componentsSeparatedByString:@"/"];
	NSString *filename = [parts lastObject];
	
	// Check if a action by that name already exists
	int i;
	for (i = 0; i < [self.actionsArray count]; i++){
		LuaAction *tempAction = [self.actionsArray objectAtIndex:i];
		if ([tempAction.name isEqualToString:[actionName stringValue]]){
			[sheetErrorMessage setStringValue:@"A action with that name already exits."];
			return;
		}
		if ([tempAction.name isEqualToString:filename]){
			[sheetErrorMessage setStringValue:@"A action with that file name already exits."];
			return;
		}
	}
	
	// Copy file to ~/AppSupport/IRCBot/
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *folderPath = @"~/Library/Application Support/IRCBot/";
	
	if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",folderPath,filename]])
		[fileManager copyPath:[[actionPath URL] absoluteString] toPath:[NSString stringWithFormat:@"%@/%@",filename] handler:nil];		
	
	// Add reference to data.plist
	[self addAction:filename name:[actionName stringValue] restricted:[restrictAction state]];
	[sheetErrorMessage setStringValue:@""];
	[addActionPane closeSheet:self];
}

- (IBAction)removeSelectedAction:(id)sender
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

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex{
	LuaAction *tempAction = [self.actionsArray objectAtIndex:rowIndex];
	
	if ([[tableColumn identifier] intValue] == 0)
		return tempAction.name;
	if ([[tableColumn identifier] intValue] == 1)
		return tempAction.file;
	if ([[tableColumn identifier] intValue] == 2)
		return [NSNumber numberWithBool:tempAction.restricted];
	return @"";
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
	if ([actionsView selectedRow] == -1)
		[removeActionButton setEnabled:NO];
	else
		[removeActionButton setEnabled:YES];
	
	actionIndex = [actionsView selectedRow];	
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(NSObject *)object forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex{
	LuaAction *tempAction = [self.actionsArray objectAtIndex:rowIndex];
	if ([[tableColumn identifier] intValue] == 0)
		[tempAction setName:(NSString *)object];
	if ([[tableColumn identifier] intValue] == 1)
		[tempAction setFile:(NSString *)object];
	if ([[tableColumn identifier] intValue] == 2)
		[tempAction setRestricted:[(NSNumber *)object boolValue]];
}

-(void)dealloc{
	[actionsArray release];
	[super dealloc];
}

@end
