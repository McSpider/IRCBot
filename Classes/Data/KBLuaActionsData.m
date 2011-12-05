//
//  Actions.m
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import "KBLuaActionsData.h"

@implementation KBLuaActionsData
@synthesize actionsArray;


- (id)init{
	if (![super init])
		return nil;
	
	self.actionsArray = [[NSMutableArray alloc] init];
	return self;
}

- (void)awakeFromNib
{	
	//Checks to see AppSupport folder exits if not create it.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *folderPath = @"~/Library/Application Support/IRCBot Actions/";
	NSString *defaultActions = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/contents/resources/IRCBot Actions/"];
	
	folderPath = [folderPath stringByExpandingTildeInPath];
	if ([fileManager fileExistsAtPath: folderPath] == NO)
		[[NSFileManager defaultManager] copyItemAtPath:defaultActions toPath:folderPath error:NULL];
	
	// Load the actions data file
	NSString *actionsData = @"~/Library/Application Support/IRCBot Actions/data.plist";
	[self loadActionsFromFile:actionsData];
	
	[actionPathControl setURL:[NSURL fileURLWithPath:[@"~/Desktop/" stringByExpandingTildeInPath]]];
}

- (void)loadActionsFromFile:(NSString *)file
{
	file = [file stringByExpandingTildeInPath];
	NSArray *actionsData = [NSArray arrayWithContentsOfFile:file]; 
	
	for (NSArray *action in actionsData) {
		KBLuaAction *tempAction = [[KBLuaAction alloc] init];
		[tempAction setName:[action objectAtIndex:0] filePath:[action objectAtIndex:1] restricted:[[action objectAtIndex:2] boolValue]];
		[self.actionsArray addObject:tempAction];
		[tempAction release];
	}
}

- (void)saveActionsToFile:(NSString *)file
{
	file = [file stringByExpandingTildeInPath];
	NSMutableArray *actionsData = [[NSMutableArray alloc] init]; 
	
	for (KBLuaAction *luaAction in self.actionsArray) {		
		NSArray *action = [NSArray arrayWithObjects:luaAction.name,luaAction.file,[NSNumber numberWithBool:luaAction.restricted],nil];
		[actionsData addObject:action];
	}
	[actionsData writeToFile:file atomically:YES];
	[actionsData release];
}


- (void)addAction:(NSString *)action name:(NSString *)name restricted:(BOOL)boolean
{	
	KBLuaAction *luaAction = [[KBLuaAction alloc] init];
	[luaAction setName:name filePath:action restricted:boolean];
	[self.actionsArray addObject:luaAction];
	[luaAction release];
	
	[actionsView reloadData];
}

- (IBAction)addNewAction:(id)sender
{	
	// Get filename
	NSString *url = [[actionPathControl URL] absoluteString];
	NSArray *parts = [url componentsSeparatedByString:@"/"];
	NSString *filename = [parts lastObject];
  
  
  // Check that the hostmask isn't blank
  if ([actionName stringValue].length < 1) {
    [sheetErrorMessage setStringValue:@"No name specified."];
    return;
  }
  if (![[url pathExtension] isEqualToString:@".lua"]) {
    [sheetErrorMessage setStringValue:@"Specified path is not a lua file."];
    return;
  }
	
	// Check if a action by that name already exists
	for (KBLuaAction *luaAction in self.actionsArray) {
		if ([luaAction.name isEqualToString:[actionName stringValue]]){
			[sheetErrorMessage setStringValue:@"A action with that name already exits."];
			return;
		}
		if ([luaAction.name isEqualToString:filename]) {
			[sheetErrorMessage setStringValue:@"A action with that file name already exits."];
			return;
		}
	}
	
	// Copy file to ~/AppSupport/IRCBot Actions/
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *folderPath = @"~/Library/Application Support/IRCBot Actions/";
	
	if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",folderPath,filename]])
		[fileManager copyItemAtPath:url toPath:[NSString stringWithFormat:@"%@/%@",folderPath,filename] error:NULL];		
	
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

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{
	KBLuaAction *luaAction = [self.actionsArray objectAtIndex:rowIndex];
	
	if ([[tableColumn identifier] intValue] == 0)
		return luaAction.name;
	if ([[tableColumn identifier] intValue] == 1)
		return luaAction.file;
	if ([[tableColumn identifier] intValue] == 2)
		return [NSNumber numberWithBool:luaAction.restricted];
	return @"";
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if ([actionsView selectedRow] == -1)
		[removeActionButton setEnabled:NO];
	else
		[removeActionButton setEnabled:YES];
	
	actionIndex = [actionsView selectedRow];	
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(NSObject *)object forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{
	KBLuaAction *luaAction = [self.actionsArray objectAtIndex:rowIndex];
	if ([[tableColumn identifier] intValue] == 0)
		[luaAction setName:(NSString *)object];
	if ([[tableColumn identifier] intValue] == 1)
		[luaAction setFile:(NSString *)object];
	if ([[tableColumn identifier] intValue] == 2)
		[luaAction setRestricted:[(NSNumber *)object boolValue]];
}

- (void)dealloc
{
	[actionsArray release];
	[super dealloc];
}

@end
