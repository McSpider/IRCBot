//
//  KBLabel.m
//  Inside Job
//
//  Created by Ben K on 2011/03/08.
//  Copyright 2011 Ben K. All rights reserved.
//

#import "KBLabel.h"


@implementation KBLabel

- (id)initWithCoder:(NSCoder *)decoder;
{
	self = [super initWithCoder:decoder];
	if (self) {
		[[self cell] setBackgroundStyle:NSBackgroundStyleRaised];
	}
	return self;
}

@end
