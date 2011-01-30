//
//  PrefController.m
//  IRCBot
//
//  Created by Ben K on 2010/10/10.
//  All code is provided under the New BSD license.
//

#import "PrefController.h"
#define WINDOW_TOOLBAR_HEIGHT 62


@implementation PrefController

-(IBAction)changePanes:(id)sender{
	NSView *view = nil;
	BOOL changePane = YES;
	
	switch ([sender tag]) {
		case 0:
			if ([[window title] isEqualToString:@"Account"])
				changePane = NO;
			[window setTitle:@"Account"];
			view = accountView;
			break;
		case 1:
			if ([[window title] isEqualToString:@"General"])
				changePane = NO;
			[window setTitle:@"General"];
			view = generalView;
			break;
		case 2:
			if ([[window title] isEqualToString:@"Hostmasks"])
				changePane = NO;
			[window setTitle:@"Hostmasks"];
			view = hostmasksView;
			break;
		case 3:
			if ([[window title] isEqualToString:@"Actions"])
				changePane = NO;
			[window setTitle:@"Actions"];
			view = actionsView;
			break;
		case 4:
			if ([[window title] isEqualToString:@"Rooms"])
				changePane = NO;
			[window setTitle:@"Rooms"];
			view = roomsView;
			break;
		default:
			[window setTitle:@"Account"];
			view = accountView;
			break;
	}
	
	// Don't replace the contents of a pane if they're the same
	if (changePane){
		NSRect windowFrame = [window frame];
		windowFrame.origin.y = NSMaxY([window frame]) - ([view frame].size.height + WINDOW_TOOLBAR_HEIGHT);
		windowFrame.origin.x = windowFrame.origin.x + (windowFrame.size.width-[view frame].size.width)/2;
		windowFrame.size.height = [view frame].size.height + WINDOW_TOOLBAR_HEIGHT;
		windowFrame.size.width = [view frame].size.width;
		
		
		if ([[contentView subviews] count] != 0){
			[[[contentView subviews] objectAtIndex:0] removeFromSuperview];
		}
		
		[window setFrame:windowFrame display:YES animate:YES];
		[contentView setFrame:[view frame]];
		[contentView addSubview:view];
		[view setAlphaValue:0.0];
		[[view animator] setAlphaValue:1.0]; // fade in
	}
}

-(void)setPane:(int)index{
	NSView *view = nil;
	
	switch (index) {
		case 0:
			[window setTitle:@"Account"];
			view = accountView;
			break;
		case 1:
			[window setTitle:@"General"];
			view = generalView;
			break;
		case 2:
			[window setTitle:@"Hostmasks"];
			view = hostmasksView;
			break;
		case 3:
			[window setTitle:@"Actions"];
			view = actionsView;
			break;
		case 4:
			[window setTitle:@"Rooms"];
			view = roomsView;
			break;
		default:
			[window setTitle:@"Account"];
			view = accountView;
			break;
	}
	
	NSRect windowFrame = [window frame];
	windowFrame.size.height = [view frame].size.height + WINDOW_TOOLBAR_HEIGHT;
	windowFrame.size.width = [view frame].size.width;
	windowFrame.origin.y = NSMaxY([window frame]) - ([view frame].size.height + WINDOW_TOOLBAR_HEIGHT);
	
	if ([[contentView subviews] count] != 0){
		[[[contentView subviews] objectAtIndex:0] removeFromSuperview];
	}
	
	[window setFrame:windowFrame display:YES animate:YES];
	[contentView setFrame:[view frame]];
	[contentView addSubview:view];
}

@end
