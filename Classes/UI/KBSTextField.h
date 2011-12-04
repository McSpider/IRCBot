//
//  KBSTextField.h
//  KBSTextField
//
//  Created by Ben K on 2010/08/09.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>


@interface KBSTextField : NSTextField {
	NSPopUpButton *endcapButton;
	NSMenu *popupMenu;
	
	NSString *popUpMenuTitle;
	BOOL displaysMenu;
	int maxPopUpItems;
	
	IBOutlet id delegate;
}


- (void)setDisplaysMenu:(BOOL)boolean;
- (void)setMaxPopUpItems:(int)max;
- (void)setPopUpMenuTitle:(NSString *)title;

- (BOOL)displaysMenu;
- (int)maxPopUpItems;
- (NSString *)popUpMenuTitle;


- (void)addPopUpItemWithTitle:(NSString *)title;
- (void)removePopUpItemAtIndex:(int)index;

@end
