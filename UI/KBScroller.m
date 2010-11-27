//
//  KBScroller.m
//  IRCBot
//
//  Created by Ben K on 2010/11/21.
//  All code is provided under the New BSD license.
//

#import "KBScroller.h"

@implementation KBScroller

- (id)initWithFrame:(NSRect)frameRect;
{
	if ((self = [super initWithFrame:frameRect])){
		[self setArrowsPosition:NSScrollerArrowsNone];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder;
{
	if ((self = [super initWithCoder:decoder])){
		[self setArrowsPosition:NSScrollerArrowsNone];	
	}
	return self;
}

+(CGFloat)scrollerWidth
{
	return 12.0f;
}

+(CGFloat)scrollerWidthForControlSize:(NSControlSize)controlSize
{
	return 12.0f;
}

- (void)drawRect:(NSRect)aRect;
{
	
	[[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:1.00] set];
	NSRectFill([self bounds]);
	
	if ([self knobProportion] > 0.0){
		
		NSRect knobRect;
		NSRect slotRect = [self rectForPart:NSScrollerKnobSlot];			

		float knobHeight = roundf(slotRect.size.height * [self knobProportion]);
		
		if (knobHeight < 25)
			knobHeight = 25;
		
		float knobY = slotRect.origin.y + roundf((slotRect.size.height - knobHeight) * [self floatValue]);
		knobRect = NSMakeRect(1, knobY, 8, knobHeight);
		
		
		
		NSBezierPath *bz = [NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:4 yRadius:4];
		[bz addClip];
		[[NSColor colorWithCalibratedRed:0.70 green:0.70 blue:0.70 alpha:1.00] set];
		NSRectFill(knobRect);
		
		
	}
}

@end