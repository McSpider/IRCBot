//
//  KBScrollView.m
//  IRCBot
//
//  Created by Ben K on 2010/11/22.
//  All code is provided under the New BSD license.
//

#import "KBScrollView.h"
#import "KBScroller.h"

@implementation  KBScrollView


+(Class)_verticalScrollerClass
{
	return [KBScroller class];
}

@end
