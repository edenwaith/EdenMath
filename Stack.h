//
//  Stack.h
//
//  Created by Chad Armstrong on 5 February 2019.
//  Copyright (c) 2002-2019 Edenwaith. All rights reserved.
//

#import <Foundation/Foundation.h>

// @class Stack;

@interface Stack : NSObject 
{
	NSMutableArray *array;
}

- (void)push:(id)obj;
- (id)pop;
- (id)peek;
- (id)top;
- (BOOL)isEmpty;
- (long)count;
- (void)clear;
- (NSString *)description;

@end
