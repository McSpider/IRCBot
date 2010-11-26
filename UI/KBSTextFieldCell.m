//
//  KBTextFieldCell.m
//  KBTextFieldCell
//
//  Created by Ben K on 2010/08/08.
//  All code is provided under the New BSD license.
//

#import "KBSTextFieldCell.h"

static NSImage *leftCap, *centerFill, *rightCap, *leftCapD, *centerFillD, *rightCapD;

@implementation KBSTextFieldCell


+(void)initialize{
	if([KBSTextFieldCell class] == [self class])
	{
		NSBundle *bundle = [NSBundle bundleForClass:[KBSTextFieldCell class]];
		leftCap = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"KBSTextFieldLC.png"]];
		centerFill = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"KBSTextFieldCF.png"]];
		rightCap = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"KBSTextFieldRC.png"]];
		
		leftCapD = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"KBSTextFieldLC_disabled.png"]];
		centerFillD = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"KBSTextFieldCF_disabled.png"]];
		rightCapD = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"KBSTextFieldRC_disabled.png"]];
	}
}

//
-(id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder])){
		[self initialization];
	}
	return self;
}

-(void)awakeFromNib{
	[self initialization];
}

-(void)dealloc
{	
	[leftCap release];
	[rightCap release];
	[centerFill release];
	[leftCapD release];
	[rightCapD release];
	[centerFillD release];
	[super dealloc];
}

-(void)initialization{
	[self setSendsActionOnEndEditing:NO];
}
//

-(void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
	// draw frame
	//[super drawWithFrame:NSInsetRect(frame, 0, 0) inView:view];
	
	NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
	
	//Background
	[ctx saveGraphicsState];
	if ([self isEnabled] && [self isEditable])
		if([[[self controlView] window] isKeyWindow])//![self isHighlighted])
			NSDrawThreePartImage(frame,leftCap,centerFill,rightCap,NO,NSCompositeSourceOver,1.0,YES);
		else
			NSDrawThreePartImage(frame,leftCapD,centerFillD,rightCapD,NO,NSCompositeSourceOver,1.0,YES);
	else
		NSDrawThreePartImage(frame,leftCapD,centerFillD,rightCapD,NO,NSCompositeSourceOver,1.0,YES);
	[ctx restoreGraphicsState];
	
	// If we have focus, draw a focus ring around the entire cellFrame.
	if ([self showsFirstResponder]) {
		NSRect focusFrame = frame;
		focusFrame.size.height -= 1.0;
		[NSGraphicsContext saveGraphicsState];
		[[NSColor redColor] set];
		NSSetFocusRingStyle(NSFocusRingOnly);
		[[NSBezierPath bezierPathWithRoundedRect:focusFrame xRadius:2 yRadius:2] fill];
		[NSGraphicsContext restoreGraphicsState];
	}
	
	[self drawInteriorWithFrame:frame inView:view];	
}


-(void)drawInteriorWithFrame:(NSRect)rect inView:(NSView*)controlView {
	[super drawInteriorWithFrame:NSOffsetRect(rect, 2, 0) inView:controlView];
}

-(void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
	[super editWithFrame: NSOffsetRect(aRect, 2, 0) inView: controlView editor:textObj delegate:anObject event: theEvent];
}

-(void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
	[super selectWithFrame: NSOffsetRect(aRect, 2, 0) inView: controlView editor:textObj delegate:anObject start:selStart length:selLength];
}


-(BOOL)drawsBackground{
	return NO;
}

@end
