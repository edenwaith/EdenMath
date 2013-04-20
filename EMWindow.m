//
//  EMWindow.m
//  EdenMath
//
//  Created by Chad Armstrong on 2/7/13.
//  Copyright 2013 Edenwaith. All rights reserved.
//

#import "EMWindow.h"
#import "EMController.h"

@implementation EMWindow

- (void)awakeFromNib
{
	previousFlags = 0;
	[self center];
}

/*
- (void) keyDown: (NSEvent *) event
{
	NSLog(@"EMWindow's keyDown:");
}

- (void) keyUp: (NSEvent *) event
{
	NSLog(@"EMWindow's keyUp:");
}
*/

- (void) flagsChanged: (NSEvent *) event
{
	unsigned flags = [event modifierFlags];
	
	/*
	NSEventType eventType = [event type];

	if (eventType == NSKeyDown)
	{
		NSLog(@"Key down!");
	}
	else if (eventType == NSKeyUp)
	{
		NSLog(@"Key up!");
	}
	else if (eventType == NSFlagsChanged)
	{
		NSLog(@"Flags changed");
	}
//	else
//	{
//		NSLog(@"eventType: %@", eventType);
//	}
	*/
	
	// NSKeyDown, event type
	
	// NSAlphaShiftKeyMask -- CAPS LOCK
	
	if (flags & NSAlternateKeyMask) // NSShiftKeyMask) 
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
