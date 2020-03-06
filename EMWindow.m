//
//  EMWindow.m
//  EdenMath
//
//  Created by Chad Armstrong on 2/7/13.
//  Copyright (c) 2002-2013 Edenwaith. All rights reserved.
//

#import "EMWindow.h"
#import "EMController.h"

@implementation EMWindow

- (void)awakeFromNib
{
	previousFlags = 0;
	[self center];
}

- (void) flagsChanged: (NSEvent *) event
{
	unsigned flags = [event modifierFlags];
	
	// NSAlphaShiftKeyMask -- CAPS LOCK
	// NSShiftKeyMask
	
	if (flags & NSAlternateKeyMask)
	{
		[[self delegate] showAlternates];
	}
	else 
	{
		if (previousFlags & NSAlternateKeyMask)
		{
			[[self delegate] hideAlternates];
		}
	}
	
	previousFlags = flags;
}

@end
