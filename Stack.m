//
//  Stack.m
//
//  Created by Chad Armstrong on 5 February 2019.
//  Copyright (c) 2002-2019 Edenwaith. All rights reserved.
//


#import "Stack.h"

@implementation Stack

- (id)init {
	if (self = [super init]) {
		array = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[array release];
	[super dealloc];
}

/*
 * Push on a new item onto the stack
 */
- (void)push:(id)obj {
	if (obj != nil) {
		[array addObject:obj];
	}
}

/* 
 * Pop off the top item from the stack and return it.
 */
- (id)pop {
	if ([self isEmpty] == NO) {
		id obj = [[array lastObject] retain];
		[array removeLastObject];
		return [obj autorelease];;
	} else {
		return nil;
	}
}

/*
 * Return the top item off the stack, but do not pop
 */
- (id)peek {
	id obj = nil;
	
    if ([self count] > 0) {
        obj = [array lastObject];
    }
    
    return obj;
}

/* 
 * top is another name for the peek function
 */
- (id)top {
	return  [self peek];
}

/*
 * Check if the stack is empty or not
 */
- (BOOL)isEmpty {
	return [array count] == 0;
}

/*
 * Return the number of elements in the stack
 */
- (long)count {
	return [array count];
}

/*
 * Clear the contents of the stack
 */
- (void)clear {
	[array removeAllObjects];
}

/*
 * Construct and return the description of the stack
 */
- (NSString *)description {

	NSMutableString *result = [[NSMutableString alloc] init];
	
	for (NSString *str in array) {
		[result appendString:str];
	}
	
	return [result autorelease];
}

@end
