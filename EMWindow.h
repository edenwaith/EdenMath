//
//  EMWindow.h
//  EdenMath
//
//  Created by Chad Armstrong on 2/7/13.
//  Copyright (c) 2002-2013 Edenwaith. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EMWindow : NSWindow 
{
	int previousFlags;	// last set of meta keys pressed
}

- (void) flagsChanged: (NSEvent *) event;

@end
