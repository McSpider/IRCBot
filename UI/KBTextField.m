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

//-(void)awakeFromNib{
//	[self setFrame:NSMakeRect([self frame].origin.x, [self frame].origin.y-1, [self frame].size.width, [self frame].size.height+1)];
//}

-(id)initWithCoder:(NSCoder *)decoder{
	if ((self = [super initWithCoder:decoder])){

	}
	return self;
}

-(id)initWithFrame:(NSRect)frame{
	if ((self = [super initWithFrame:frame])){

	}
	return self;
}



-(void)dealloc{	
	[super dealloc];
}

-(void)drawRect:(NSRect)rect{
	//NSRect tempRect = NSInsetRect(rect, 2, 0);
	//[super drawRect:NSOffsetRect(tempRect, 2, 0)];	
	[super	drawRect:rect];
}

@end
