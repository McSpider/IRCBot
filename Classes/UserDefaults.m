//
//  UserDefaults.m
//  IRCBot
//
//  Created by Ben K on 2010/09/13.
//  All code is provided under the New BSD license.
//

#import "UserDefaults.h"


@interface UserDefaults (Private)
- (void)setFirstStart:(BOOL)boolean;
- (BOOL)firstStart;
@end


@implementation UserDefaults


#pragma mark -
#pragma mark Initialization

- (void)awakeFromNib // should prolly be applicationDidFinishLaunching to prevent crashes
{
	// Hide the resize indicators on the windows
	[mainWindow setShowsResizeIndicator:NO]; [prefWindow setShowsResizeIndicator:NO]; [prefWindow center];
	[toolBar setSelectedItemIdentifier:@"Account_Settings"];
	
	// Check if this is the first start of the application
	// If it is show a setup window
	if (![self firstStart]) {
		// Start modal session and open the window
		/*session = [NSApp beginModalSessionForWindow:startWindow];
		[NSApp runModalSession:session];*/
		
		[startWindow makeFirstResponder:uNameField];
		[startWindow center];
		[startWindow makeKeyAndOrderFront:self];		
	} else {
		[mainWindow makeKeyAndOrderFront:self];
		[prefs setPane:0];
		
		// Get username
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		NSString *savedUsername = [standardUserDefaults objectForKey:@"username"];
		[usernameField setStringValue:savedUsername];
		
		// Check where the password is stored
		if (![standardUserDefaults boolForKey:@"pass_in_plist"]) {
			EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"IRCBot" withUsername:savedUsername];
			if (keychainItem != nil) {
				[passwordField setStringValue:[NSString stringWithFormat:@"%@",[keychainItem password]]];
			} else {
				NSRunAlertPanel(@"Failed to retrive password from keychain",@"IRCBot couldn't access your irc password stored in the keychain.",@"OK",nil,nil);
			}
		} else {
			if ([standardUserDefaults objectForKey:@"password"]) {
				NSString* aStr = [[NSString alloc] initWithData:[standardUserDefaults objectForKey:@"password"] encoding:NSUTF8StringEncoding];
				[passwordField setStringValue:aStr];
				[aStr release];
			} else {
				NSRunAlertPanel(@"Failed to retrive password from the .plist",@"Please re-enter the password in the IRCBot preferences.",@"OK",nil,nil);
			}
		}
	}
}

// Save all the initial setup data to the .plist
- (IBAction)finishInitialSetup:(id)sender
{		
	// Check if user input is valid
	if ([[uNameField stringValue] isEqualToString:@""]) {
		[errorMessage setStringValue:@"Please fill in the username field"];
		return;
	}
	if ([[uNickField stringValue] isEqualToString:@""]) {
		[errorMessage setStringValue:@"Please fill in the nickname field"];
		return;
	}
	if ([[uRealnameField stringValue] isEqualToString:@""]) {
		[errorMessage setStringValue:@"Please fill in a real name field"];
		return;
	}
	if ([[hostmaskField stringValue] isEqualToString:@""] || ![[hostmaskField stringValue] isMatchedByRegex:@"^\\S+@\\S+\\.\\S+$"]) {
		[errorMessage setStringValue:@"Please fill in a valid hostmask"];
		return;
	}	
	
		
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults) {
		[standardUserDefaults setObject:[uNameField stringValue] forKey:@"username"];
		[EMGenericKeychainItem addGenericKeychainItemForService:@"IRCBot" withUsername:[uNameField stringValue] password:[uPasswordField stringValue]];
		[passwordField setStringValue:[uPasswordField stringValue]];
		[usernameField setStringValue:[uNameField stringValue]];
		[autojoin addRoom:@"#jzbot" autojoin:YES];
		
		[standardUserDefaults setObject:[uRealnameField stringValue] forKey:@"realname"];
		[standardUserDefaults setObject:[uNickField stringValue] forKey:@"nickname"];
		[standardUserDefaults setInteger:1 forKey:@"timeout"];
		[standardUserDefaults setObject:[NSString stringWithFormat:@"@",[uNickField stringValue]] forKey:@"triggers"];
		[standardUserDefaults setObject:@"irc.freenode.net" forKey:@"irc_server"];
		[standardUserDefaults synchronize];
	}
	[hostmasks addHostmask:[hostmaskField stringValue] block:NO];
	[self setFirstStart:YES];
	
	
	// End modal session and save settings
	/*[NSApp endModalSession:session];*/
	[self savePreferences:self];
	
	// Close the setup window and show the main window
	[startWindow orderOut:self];
	[mainWindow center];
	[mainWindow setAlphaValue:0.0];
	[mainWindow makeKeyAndOrderFront:self];
	[prefs setPane:0];
	
	// Fade in the main window
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:mainWindow, NSViewAnimationTargetKey, NSViewAnimationFadeInEffect,NSViewAnimationEffectKey,nil];
	NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dict]];
	[animation startAnimation];
	[animation release];	
}

//Reset app and show setup window 
- (IBAction)resetApplication:(id)sender
{	
	// Ask user if he's sure
	int answer = NSRunAlertPanel(@"Are you sure you want to reset IRCBot?",@"This will remove all your settings.", @"Cancel",@"Reset", nil);
	if (answer != NSAlertDefaultReturn) {
		// Close all windows
		[mainWindow orderOut:self];
		[prefWindow orderOut:self];
		
		// Delete .plist
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		[standardUserDefaults removePersistentDomainForName:@"com.mcspider.ircbot"];
		[standardUserDefaults synchronize];
		
		// Clear textFields
		[passwordField setStringValue:@""];
		[usernameField setStringValue:@""];
		[uNameField setStringValue:@""];
		[uPasswordField setStringValue:@""];
		[uNickField setStringValue:@""];
		[uRealnameField setStringValue:@""];
		[hostmaskField setStringValue:@""];
		
		// Clear hostmask data
		[hostmasks clearData];
		[autojoin clearData];
		
		// Reset actions .plist
		NSString *actionsPath = [@"~/Library/Application Support/IRCBot Actions/" stringByExpandingTildeInPath];
		NSString *defaultActions = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/contents/resources/IRCBot Actions/"];		
		[[NSFileManager defaultManager] removeItemAtPath:actionsPath error:NULL];
		[[NSFileManager defaultManager] copyItemAtPath:defaultActions toPath:actionsPath error:NULL];
		
		// Start modal session and open setupwindow.
		//session = [NSApp beginModalSessionForWindow:startWindow];
		//[NSApp runModalSession:session];
		[startWindow makeFirstResponder:uNameField];
		[startView selectFirstTabViewItem:self];
		[startWindow center];	
		[startWindow makeKeyAndOrderFront:self];
	}
}

// Set the setup bool in the .plist to true
- (void)setFirstStart:(BOOL)boolean
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults) {
		[standardUserDefaults setBool:boolean forKey:@"setup"];
		[standardUserDefaults synchronize];
	}
}

// Check the setup bool in the .plist
- (BOOL)firstStart
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults) {
		return [standardUserDefaults boolForKey:@"setup"];
	}
	return NO;
}


#pragma mark -
#pragma mark Preferences

- (IBAction)savePreferences:(id)sender
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];	
	[standardUserDefaults setObject:[hostmasks hostmaskArray] forKey:@"hostmasks"];
	[standardUserDefaults setObject:[autojoin autojoinArray] forKey:@"autojoin"];
	[standardUserDefaults setObject:[usernameField stringValue] forKey:@"username"];
	
	NSString *actionsPath = @"~/Library/Application Support/IRCBot Actions/data.plist";
	[actions saveActionsToFile:actionsPath];
	
	// Don't try to save the pasword if its empty
	if (![[passwordField stringValue] isMatchedByRegex:@"^//S+$"]) {
		return;
	}
	
	// Save the password to the appropriate location
	if (![passwordInPlistCheck state]){
		if ([standardUserDefaults objectForKey:@"password"])
			[standardUserDefaults removeObjectForKey:@"password"];	
		NSString *savedUsername = [standardUserDefaults objectForKey:@"username"];
		EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"IRCBot" withUsername:savedUsername];
		// if the password or username has been changed
		if (![[keychainItem password] isEqualToString:[passwordField stringValue]] || ![savedUsername isEqualToString:[usernameField stringValue]]){
			// If the keychain item already exits modify it
			if (keychainItem != nil) {
				keychainItem.password = [passwordField stringValue];
				keychainItem.username = [usernameField stringValue];
			} else {
				[EMGenericKeychainItem addGenericKeychainItemForService:@"IRCBot" withUsername:[usernameField stringValue] password:[passwordField stringValue]];
			}
		}
	} else {
		NSData* aData = [[passwordField stringValue] dataUsingEncoding:NSUTF8StringEncoding];		
		[standardUserDefaults setObject:aData forKey:@"password"];	
	}
}

- (BOOL)windowShouldClose:(NSWindow *)sender
{
	// If window closed is the prefrences window then save the prefs
	if (sender == prefWindow) {
		[self savePreferences:nil];
		return YES;
	}
	return YES;
}


@end
