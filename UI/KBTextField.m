//
//  KBTextField.m
//  KBTextField
//
//  Created by Ben K on 2010/08/09.
//  All code is provided under the New BSD license.
//

#import "KBTextField.h"
#import "KBSTextFieldCell.h"

@implementation KBTextField


#pragma mark -
#pragma mark Initialization

- (void)awakeFromNib
{
	NSRect popupRect = NSMakeRect(0, 0, 25, 22);
	displaysMenu = NO;
	maxPopUpItems = 10;
	popUpMenuTitle = @"Command History";
	
	// Initalize the popup menu
	popupMenu = [[NSMenu alloc] init];
	[popupMenu setAutoenablesItems:NO];
	
	NSMenuItem *menuTitle = [[NSMenuItem alloc] initWithTitle:popUpMenuTitle action:NULL keyEquivalent:@""];
	[menuTitle setEnabled:NO];
	[popupMenu addItem:menuTitle];
	[popupMenu setTitle:popUpMenuTitle];
	[menuTitle release];

	
	// Initalize popup button
	endcapButton = [[NSPopUpButton alloc] init];
	[endcapButton setFrame:popupRect];
	
	[endcapButton setAutoenablesItems:NO];
	[endcapButton setBezelStyle:NSSmallSquareBezelStyle];
	[endcapButton setBordered:NO];
	[endcapButton setMenu:popupMenu];
	
	// Insert a blank item at first place
	[endcapButton insertItemWithTitle:@"" atIndex:0];
	[endcapButton setPullsDown:YES];
	[endcapButton selectItemAtIndex:0];
	[[endcapButton itemAtIndex:1] setState:NSOffState];
			
	[endcapButton setHidden:!displaysMenu];
	[endcapButton setEnabled:displaysMenu];
	[self addSubview:endcapButton];	
}

- (void)popupItemWasSelected:(id)sender
{
	NSLog(@"Item Was Selected: (%@)",sender);
	[self setStringValue:[sender representedObject]];
}

- (void)addItemToPopupWithTitle:(NSString *)title
{
	NSMenuItem *popUpItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(popupItemWasSelected:) keyEquivalent:@""];
	[popUpItem setRepresentedObject:title];
	[popUpItem setTarget:self];
	
	if ([popupMenu numberOfItems] > maxPopUpItems) {
		[popupMenu removeItemAtIndex:2];
	}
	
	[popupMenu addItem:popUpItem];
	[popUpItem release];
}


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	NSRect popupRect = NSMakeRect(0, 0, 25, 22);
	[endcapButton setFrame:popupRect];
	
	if (displaysMenu) {
		[[self cell] setPaddingLeft:18];
	} else {
		[[self cell] setPaddingLeft:2];	
	}
		
	[super drawRect:rect];
}


#pragma mark -
#pragma mark Setters and Getters

- (void)setPopUpMenuTitle:(NSString *)title
{
	popUpMenuTitle = title;
	NSMenuItem *menuTitle = [[NSMenuItem alloc] initWithTitle:popUpMenuTitle action:NULL keyEquivalent:@""];
	[menuTitle setEnabled:NO];
	[popupMenu removeItemAtIndex:1];
	[popupMenu insertItem:menuTitle atIndex:1];
	[popupMenu setTitle:title];
	[menuTitle release];
}

- (NSString *)popUpMenuTitle
{
	return popUpMenuTitle;
}

- (void)setDisplaysMenu:(BOOL)boolean
{
	displaysMenu = boolean;
	[endcapButton setHidden:!displaysMenu];
	[endcapButton setEnabled:displaysMenu];
	[self needsDisplay];
}

- (void)setMaxPopUpItems:(int)max
{
	maxPopUpItems = max;
}

- (BOOL)displaysMenu
{
	return displaysMenu;
}

- (int)maxPopUpItems
{
	return maxPopUpItems;
}


#pragma mark -
#pragma mark Cleanup

-(void)dealloc{	
	[super dealloc];
	[popupMenu release];
	[endcapButton release];
}

@end
