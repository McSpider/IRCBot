//
//  KBSTextFieldCell.h
//  KBSTextFieldCell
//
//  Created by Ben K on 2010/08/08.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>

@interface KBSTextFieldCell : NSTextFieldCell {
	int leftPadding;
}

- (void)setPaddingLeft:(int)padding;

@end
