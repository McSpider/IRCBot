//
//  KBScroller.m
//  IRCBot
//
//  Created by Ben K on 2010/11/21.
//  All code is provided under the New BSD license.
//

#import "KBScroller.h"

@implementation KBScroller
@synthesize usesAlternateStyle;


- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder])) {
		[self setArrowsPosition:NSScrollerArrowsNone];	
		if ([self bounds].size.width / [self bounds].size.height < 1) {
			isVertical = YES;
		} else {
			isVertical = NO;
		}
	}
	return self;
}

- (void)drawRect:(NSRect)aRect
{		
	NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
	
	
	// Background
	if (usesAlternateStyle) {
		[ctx saveGraphicsState];
		
		NSGradient *outerGradient = [[NSGradient alloc] initWithColorsAndLocations:
																 [NSColor colorWithDeviceWhite:0.96f alpha:1.0f], 0.0f, 
																 [NSColor colorWithDeviceWhite:0.92f alpha:1.0f], 1.0f, 
																 nil];
		
		[outerGradient drawInRect:[self bounds] angle:0.0f];
		[outerGradient release];
		
		NSBezierPath *line = [[NSBezierPath alloc] init];
		[line moveToPoint:NSMakePoint(0, 0)];
		[line lineToPoint:NSMakePoint(0, [self bounds].size.height)];
		[line setLineWidth:1];
		[[NSColor colorWithDeviceWhite:0.6f alpha:1.0f] set];
		[line stroke];
		[line release];
		
		[ctx restoreGraphicsState];
	}
	else {
		[[(NSScrollView *)[self superview] backgroundColor] set];
		NSRectFill([self bounds]);
	}
	
	// Slot
  [ctx saveGraphicsState];
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], 4, 4) xRadius:4 yRadius:4];
	[path addClip];
	[[NSColor colorWithCalibratedWhite:0.8 alpha:1.0] set];
	NSRectFill([self bounds]);
	
	[ctx restoreGraphicsState];
	
	
	// Knob
	[ctx saveGraphicsState];
	
	[self drawKnob];
	
	[ctx restoreGraphicsState];
}

- (void)drawKnob
{	
	if (isVertical) {
		NSRect knobRect = [self rectForPart:NSScrollerKnob];
		
		knobRect = NSInsetRect(knobRect, 4, 0);
		
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:4 yRadius:4];
		[path addClip];
		
		[[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
		
		NSRectFill(knobRect);
	}
	else {
		NSRect knobRect = [self rectForPart:NSScrollerKnob];
		
		knobRect = NSInsetRect(knobRect, 0, 4);
		
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:4 yRadius:4];
		[path addClip];
		
		[[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
		
		NSRectFill(knobRect);
	}
}


+ (CGFloat)scrollerWidth
{
	return 12.0f;
}

+ (CGFloat)scrollerWidthForControlSize:(NSControlSize)controlSize
{
	return 12.0f;
}

+ (CGFloat)scrollerHeight
{
	return 12.0f;
}

+ (CGFloat)scrollerHeightForControlSize:(NSControlSize)controlSize
{
	return 12.0f;
}


@end
