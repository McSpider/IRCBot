//
//  UIController.m
//  IRCBot
//
//  Created by Ben K on 2010/07/18.
//  All code is provided under the New BSD license.
//

#import "UIController.h"


@interface UIController (Private)
- (void)composeInterface;
@end


@implementation UIController


#pragma mark Initialization

- (void)awakeFromNib
{
	[self composeInterface];
}


#pragma mark Methods

- (void)composeInterface
{
	// compose our UI out of views
	NSView *themeFrame = [[mainWindow contentView] superview];
	
	NSRect c = [themeFrame frame];	// c for "container"
	NSRect aV = [accessoryView frame];	// aV for "accessory view"
	NSRect newFrame = NSMakeRect(
															 c.size.width - aV.size.width,	// x position
															 c.size.height - aV.size.height,	// y position
															 aV.size.width,	// width
															 aV.size.height);	// height
	[accessoryView setFrame:newFrame];
	
	[themeFrame addSubview:accessoryView];	
	[versionField setStringValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}


@end
