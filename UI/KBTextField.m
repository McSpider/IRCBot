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


-(void)drawRect:(NSRect)rect{
	/*NSRect tempRect = NSInsetRect(rect, 2, 0);
	[super drawRect:NSOffsetRect(tempRect, 2, 0)];*/
	[super	drawRect:rect];
}

-(void)dealloc{	
	[super dealloc];
}

@end
