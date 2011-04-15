//
//  UserSettings.m
//  IRCBot
//
//  Created by Ben K on 2010/10/10.
//  All code is provided under the New BSD license.
//

#import "UserSettings.h"
#define WINDOW_TOOLBAR_HEIGHT 62


@interface UserSettings (Private)
- (void)setIsSetup:(BOOL)boolean;
- (BOOL)isSetup;
@end


@implementation UserSettings
@synthesize username;
@synthesize password;
@synthesize realname;
@synthesize nickname;
@synthesize passwordInPlist;

@synthesize hostmasksData;
@synthesize actionsData;
@synthesize autojoinData;	


#pragma mark -
#pragma mark Initialization

- (void)awakeFromNib
{
	[mainWindow setShowsResizeIndicator:NO];
	[prefWindow setShowsResizeIndicator:NO];
	[prefWindow center];
	[toolBar setSelectedItemIdentifier:@"Default"];
	
	if (![self isSetup]) {
		// Show the hostmask pane
		[[NSUserDefaults standardUserDefaults] setObject:@"irc.freenode.net" forKey:@"irc_server"];
		[[NSUserDefaults standardUserDefaults] setObject:@"@" forKey:@"triggers"];
		[self setIsSetup:YES];
	}
	
	[mainWindow makeKeyAndOrderFront:self];
	[self setPane:1];
	
	// Get irc account data
	self.username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];		
	self.nickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
	self.realname = [[NSUserDefaults standardUserDefaults] objectForKey:@"realname"];	
	self.passwordInPlist = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pass_in_plist"] boolValue];
	
	// Check where the password is stored
	if (!self.passwordInPlist) {
		EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"IRCBot" withUsername:self.username];
		if (keychainItem != nil) {
			self.password = [NSString stringWithFormat:@"%@",[keychainItem password]];
		}
	}
	else {
		self.password = [[[NSString alloc] initWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] encoding:NSUTF8StringEncoding] autorelease];
	}
}


//Reset app and show setup window 
- (IBAction)resetApplication:(id)sender
{	
	int answer = NSRunAlertPanel(@"Are you sure you want to reset IRCBot?",@"This will remove all your settings.", @"Cancel",@"Reset", nil);
	if (answer == NSAlertDefaultReturn)
		return;
	
	[prefWindow orderOut:self];
	
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.mcspider.ircbot"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSUserDefaults standardUserDefaults] setObject:@"irc.freenode.net" forKey:@"irc_server"];
	[[NSUserDefaults standardUserDefaults] setObject:@"@" forKey:@"triggers"];
	
	// Clear textFields
	self.password = nil;
	self.username = nil;
	self.nickname = nil;
	self.realname = nil;
	
	// Clear hostmask data
	[hostmasksData clearData];
	[autojoinData clearData];
	
	// Reset actions .plist
	NSString *actionsPath = [@"~/Library/Application Support/IRCBot Actions/" stringByExpandingTildeInPath];
	NSString *defaultActions = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/contents/resources/IRCBot Actions/"];		
	[[NSFileManager defaultManager] removeItemAtPath:actionsPath error:NULL];
	[[NSFileManager defaultManager] copyItemAtPath:defaultActions toPath:actionsPath error:NULL];
	
}

// Set the setup bool in the .plist to true
- (void)setIsSetup:(BOOL)boolean
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults) {
		[standardUserDefaults setBool:boolean forKey:@"setup"];
		[standardUserDefaults synchronize];
	}
}

// Check the setup bool in the .plist
- (BOOL)isSetup
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"setup"];
}


#pragma mark -
#pragma mark Preferences

- (IBAction)savePreferences:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[hostmasksData hostmaskArray] forKey:@"hostmasks"];
	[[NSUserDefaults standardUserDefaults] setObject:[autojoinData autojoinArray] forKey:@"autojoin"];
	[[NSUserDefaults standardUserDefaults] setObject:self.username forKey:@"username"];
	[[NSUserDefaults standardUserDefaults] setObject:self.nickname forKey:@"nickname"];
	[[NSUserDefaults standardUserDefaults] setObject:self.realname forKey:@"realname"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.passwordInPlist] forKey:@"pass_in_plist"];	
	
	NSString *actionsPath = @"~/Library/Application Support/IRCBot Actions/data.plist";
	[actionsData saveActionsToFile:actionsPath];
	
	// Don't try to save the pasword if its empty
	if ([self.password length] == 0)
		return;
	
	// Save the password to the appropriate location
	if (!self.passwordInPlist){
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"password"])
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];	
		NSString *savedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
		EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"IRCBot" withUsername:savedUsername];
		// if the password or username has been changed
		if (![[keychainItem password] isEqualToString:self.password] || ![savedUsername isEqualToString:self.username]){
			// If the keychain item already exits modify it
			if (keychainItem != nil) {
				keychainItem.password = self.password;
				keychainItem.username = self.username;
			} else {
				[EMGenericKeychainItem addGenericKeychainItemForService:@"IRCBot" withUsername:self.username password:self.password];
			}
		}
	} else {
		NSData* aData = [self.password dataUsingEncoding:NSUTF8StringEncoding];		
		[[NSUserDefaults standardUserDefaults] setObject:aData forKey:@"password"];	
	}	
}


- (void)windowDidResignKey:(NSNotification *)notification
{
	if ([notification object] == prefWindow)
		[self savePreferences:nil];
}


- (IBAction)changePanes:(id)sender
{
	NSView *view = nil;
	BOOL changePane = YES;
	
	switch ([sender tag]) {
		case 1:
			if ([[prefWindow title] isEqualToString:@"General"])
				changePane = NO;
			[prefWindow setTitle:@"General"];
			view = generalView;
			break;
		case 2:
			if ([[prefWindow title] isEqualToString:@"Hostmasks"])
				changePane = NO;
			[prefWindow setTitle:@"Hostmasks"];
			view = hostmasksView;
			break;
		case 3:
			if ([[prefWindow title] isEqualToString:@"Actions"])
				changePane = NO;
			[prefWindow setTitle:@"Actions"];
			view = actionsView;
			break;
		case 4:
			if ([[prefWindow title] isEqualToString:@"Rooms"])
				changePane = NO;
			[prefWindow setTitle:@"Rooms"];
			view = roomsView;
			break;
		default:
			[prefWindow setTitle:@"General"];
			view = generalView;
			break;
	}
	
	// Don't replace the contents of a pane if they're the same
	if (changePane) {
		NSRect windowFrame = [prefWindow frame];
		windowFrame.origin.y = NSMaxY([prefWindow frame]) - ([view frame].size.height + WINDOW_TOOLBAR_HEIGHT);
		windowFrame.origin.x = windowFrame.origin.x + (windowFrame.size.width-[view frame].size.width)/2;
		windowFrame.size.height = [view frame].size.height + WINDOW_TOOLBAR_HEIGHT;
		windowFrame.size.width = [view frame].size.width;
		
		if ([[[prefWindow contentView] subviews] count] != 0) {
			[[[[prefWindow contentView] subviews] objectAtIndex:0] removeFromSuperview];
		}
		
		[prefWindow setFrame:windowFrame display:YES animate:YES];
		[[prefWindow contentView] setFrame:[view frame]];
		[[prefWindow contentView] addSubview:view];
		[view setAlphaValue:0.0];
		[[view animator] setAlphaValue:1.0]; // fade in
		[prefWindow recalculateKeyViewLoop];
	}
}

- (void)setPane:(int)index
{
	NSView *view = nil;
	
	switch (index) {
		case 1:
			[prefWindow setTitle:@"General"];
			view = generalView;
			break;
		case 2:
			[prefWindow setTitle:@"Hostmasks"];
			view = hostmasksView;
			break;
		case 3:
			[prefWindow setTitle:@"Actions"];
			view = actionsView;
			break;
		case 4:
			[prefWindow setTitle:@"Rooms"];
			view = roomsView;
			break;
		default:
			[prefWindow setTitle:@"General"];
			view = generalView;
			break;
	}
	
	NSRect windowFrame = [prefWindow frame];
	windowFrame.size.height = [view frame].size.height + WINDOW_TOOLBAR_HEIGHT;
	windowFrame.size.width = [view frame].size.width;
	windowFrame.origin.y = NSMaxY([prefWindow frame]) - ([view frame].size.height + WINDOW_TOOLBAR_HEIGHT);
	
	if ([[[prefWindow contentView] subviews] count] != 0) {
		[[[[prefWindow contentView] subviews] objectAtIndex:0] removeFromSuperview];
	}
	
	[prefWindow setFrame:windowFrame display:YES animate:YES];
	[[prefWindow contentView] setFrame:[view frame]];
	[[prefWindow contentView] addSubview:view];
	[prefWindow recalculateKeyViewLoop];
}

@end
