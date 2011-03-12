//
//  KBTextField.h
//  KBTextField
//
//  Created by Ben K on 2010/08/09.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>


@interface KBTextField : NSTextField {
	NSPopUpButton *endcapButton;
	NSMenu *popupMenu;
	
	NSString *popUpMenuTitle;
	BOOL displaysMenu;
	int maxPopUpItems;
}

- (void)setDisplaysMenu:(BOOL)boolean;
- (void)setMaxPopUpItems:(int)max;
- (void)setPopUpMenuTitle:(NSString *)title;

- (BOOL)displaysMenu;
- (int)maxPopUpItems;
- (NSString *)popUpMenuTitle;


- (void)addItemToPopupWithTitle:(NSString *)title;

@end
