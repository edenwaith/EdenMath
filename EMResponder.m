//
//  EMResponder.m
//  EdenMath
//
//  Created by admin on Thu Feb 21 2002.
//  Copyright (c) 2002-2013 Edenwaith. All rights reserved.
//
// RPN Calculator in Objective-C: http://www.math.bas.bg/softeng/bantchev/place/rpn/rpn.objc.html
// Calculator (C++): http://kosmaczewski.net/projects/calculator/
// Mathematical Expression Parser: http://apptree.net/parser.htm

#import "EMResponder.h"

#include <math.h>
#include <stdlib.h>

@implementation EMResponder


// -------------------------------------------------------
// (id) init
// -------------------------------------------------------
- (id) init
{
    currentValue	= 0.0;
    previousValue	= 0.0;
    op_type	 	= NO_OP;
    angle_type 		= DEGREE;
    e_value		= M_E; 		// 2.7182818285
    trailing_digits 	= 0;
    isNewDigit		= YES;
    
    return self;
}

// -------------------------------------------------------
// (double) getCurrentValue
// Simple return function which returns the current
// value
// -------------------------------------------------------
- (double) getCurrentValue
{
    return currentValue;
}


// -------------------------------------------------------
// (int) getTrailingDigits
// Simple return function which returns the number of
// trailing digits on the currently displayed number
// so the proper amount of precision can be displayed.
// Limit the number of trailing digits precision so odd
// errors don't occur.
// -------------------------------------------------------
- (int) getTrailingDigits
{
    if (trailing_digits == 0)
    {
        trailing_digits = 0;
    }
    else if (trailing_digits > 10)
    {
        trailing_digits = 10;
    }
    
    return trailing_digits;
}

// -------------------------------------------------------
// (void) setCurrentValue:(double)num
// -------------------------------------------------------
- (void) setCurrentValue:(double)num
{
    currentValue = num;
}


// -------------------------------------------------------
// (void) setState:(NSDictionary *)stateDictionary
// -------------------------------------------------------
- (void)setState:(NSDictionary *)stateDictionary 
{
    currentValue 	= [[stateDictionary objectForKey: @"currentValue"] doubleValue];
    previousValue   	= [[stateDictionary objectForKey: @"previousValue"] doubleValue];
    op_type     	= [[stateDictionary objectForKey: @"op_type"] intValue];
    trailing_digits   	= [[stateDictionary objectForKey: @"trailing_digits"] intValue];
    isNewDigit    	= [[stateDictionary objectForKey: @"isNewDigit"] boolValue];
}

// -------------------------------------------------------
// (NSDictionary *) state
// -------------------------------------------------------
- (NSDictionary *)state 
{
    NSDictionary *stateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithDouble: currentValue], @"currentValue",
        [NSNumber numberWithDouble: previousValue], @"previousValue",
        [NSNumber numberWithInt: op_type], @"op_type",
        [NSNumber numberWithInt: trailing_digits], @"trailing_digits",
        [NSNumber numberWithBool: isNewDigit], @"isNewDigit",
        nil]; 
    return stateDictionary;
}

// -------------------------------------------------------
// (void)newDigit:(int)digit
// -------------------------------------------------------
- (void)newDigit:(int)digit 
{

    if (isNewDigit) 
    {
        previousValue = currentValue;
        isNewDigit  = NO;
        currentValue = digit;
    } 
    else 
    {
        BOOL negative = NO;
        if (currentValue < 0) 
        {
            currentValue = - currentValue;
            negative = YES;
        }
        
        if (trailing_digits == 0) 
        {
            currentValue = currentValue * 10 + digit;
        } 
        else 
        {
            currentValue = currentValue + (digit/pow(10.0, trailing_digits));

            trailing_digits++;
        }
        
        if (negative == YES)
        {
            currentValue = - currentValue;
        }
    }
}

// -------------------------------------------------------
// (void) period
// -------------------------------------------------------
- (void)period 
{
    if (isNewDigit) 
    {
        currentValue = 0.0;
        isNewDigit = NO;
    }
    if (trailing_digits == 0) 
    {
        trailing_digits = 1;
    }
}

// -------------------------------------------------------
// (void) pi
// Display the constant pi (3.141592653589793)
// -------------------------------------------------------
- (void) pi 
{
    currentValue 	= M_PI;
    trailing_digits = 0;
    isNewDigit 		= YES;
}

// -------------------------------------------------------
// (void) trig_constant
// Display the constant pi (3.141592653589793)
// -------------------------------------------------------
- (void) trig_constant: (double) trig_const 
{
    currentValue 	= trig_const;
    trailing_digits = 0;
    isNewDigit 		= YES;
}

// -------------------------------------------------------
// (void) e
// Display the constant e (2.718281828459045)
// -------------------------------------------------------
- (void)e
{
    currentValue 	= M_E; 
    trailing_digits = 0;
    isNewDigit 		= YES;
}

// -------------------------------------------------------
// (void) clear
// clear the displayField and reset several variables
// -------------------------------------------------------
- (void) clear 
{
    currentValue 	= 0.0;
    previousValue 	= 0.0;
    op_type 		= NO_OP;
    trailing_digits = 0;
    isNewDigit		= YES;
}

// -------------------------------------------------------
// (void)operation:(OpType)new_op_type
// -------------------------------------------------------
- (void)operation:(OpType)new_op_type
{
    if (op_type == NO_OP) 
    {
        previousValue 	= currentValue;
        isNewDigit 	= YES;
        op_type 	= new_op_type;
        trailing_digits = 0;
    } 
    else 
    {
        // cascading operations
        [self enter]; // calculate previous value, first
        previousValue = currentValue;
        isNewDigit = YES;
        op_type = new_op_type;
        trailing_digits = 0;        
    }
}

// -------------------------------------------------------
// (void)enter
// For binary operators (+, -, x, /, etc.), calculate
// the value and place into currentValue
// -------------------------------------------------------
- (void)enter 
{
    switch (op_type) 
    {
        case NO_OP:
            break;
        case ADD_OP:
            currentValue = previousValue + currentValue;
            break;
        case SUBTRACT_OP:
            currentValue = previousValue - currentValue;
            break;
        case MULTIPLY_OP:
            currentValue = previousValue * currentValue;
            break;
        case DIVIDE_OP:
            if (currentValue != 0.0)
            {
                currentValue = previousValue / currentValue;
            }
            break;
        case EXPONENT_OP: // x^y
            currentValue = pow(previousValue, currentValue);
            break;
        case XROOT_OP: // yÃx
            currentValue = pow(previousValue, 1/currentValue);
            break;
        case MOD_OP:
            currentValue = (int)previousValue % (int)currentValue;
            break;
        case EE_OP:
            currentValue = previousValue * pow(10, currentValue);
            break;
        case NPR_OP: // n!/(n-r)!
            currentValue = [self factorial:previousValue] / [self factorial:(previousValue - currentValue)];
            break;
        case NCR_OP: // n!/(r! * (n-r)!)
            currentValue = [self factorial:previousValue] / ([self factorial:currentValue] * [self factorial:(previousValue - currentValue)]);
            break;
    }
    previousValue 	= 0.0;
    op_type 		= NO_OP;
    trailing_digits 	= 0;
    isNewDigit 		= YES;
}

// =====================================================================================
// ALGEBRAIC FUNCTIONS
// =====================================================================================

// -------------------------------------------------------
// (void) reverse_sign
// -------------------------------------------------------
- (void) reverse_sign
{
    currentValue = - currentValue;
}

// -------------------------------------------------------
// (void)percentage
// -------------------------------------------------------
- (void)percentage
{
    currentValue = currentValue * 0.01;
    isNewDigit 	  = YES;
    trailing_digits = 0;
}

// -------------------------------------------------------
// (void) squared
// -------------------------------------------------------
- (void) squared
{
    currentValue = pow(currentValue, 2);
    isNewDigit    = YES;
}

// -------------------------------------------------------
// (void) cubed
// -------------------------------------------------------
- (void) cubed
{
    currentValue = pow(currentValue, 3);
    isNewDigit    = true;
}

// -------------------------------------------------------
// (void) square_root
// -------------------------------------------------------
- (void) square_root
{
    if (currentValue >= 0.0)
    {
        currentValue = sqrt(currentValue);
    }
    
    isNewDigit = YES;
}

// -------------------------------------------------------
// (void) cubed_root
// -------------------------------------------------------
- (void)cubed_root
{
    //if (currentValue >= 0.0)
    //{
        currentValue = pow(currentValue, 0.3333333333333333);
    //}
    
    isNewDigit = YES;
}

// -------------------------------------------------------
// (void) ln
// natural log
// -------------------------------------------------------
- (void)ln
{
    if (currentValue > 0.0)
    {
        currentValue = log(currentValue);
    }
    
    isNewDigit = YES;
}

// -------------------------------------------------------
// (void) binaryLogarithm
// binary logarithm base 2
// -------------------------------------------------------
- (void) binaryLogarithm
{
    if (currentValue > 0.0)
    {
        currentValue = log2(currentValue);
    }
    
    isNewDigit = YES;
}

// -------------------------------------------------------
// (void) logarithm
// logarithm base 10
// -------------------------------------------------------
- (void) logarithm
{
    if (currentValue > 0.0)
    {
        currentValue = log10(currentValue);
    }
    
    isNewDigit = YES;
}

// -------------------------------------------------------
// (void) factorial
// This new function replaces the old factorial function
// with a gamma function.  For more information, read the
// lgamma man page or 
// http://www.gnu.org/software/libc/manual/html_node/Special-Functions.html
// Version: 8. March 2004 23:40
// -------------------------------------------------------
- (void) factorial
{
    double lg;
    
    // 170.5 seems to be the max value which EdenMath can handle
    if (currentValue < 170.5)
    {
        lg = lgamma(currentValue+1.0);
        currentValue = signgam*exp(lg); /* signgam is a predefined variable */
    }
    
    trailing_digits = 0; // this allows for more precise decimal precision
    isNewDigit = YES;

}

// -------------------------------------------------------
// (double) factorial: (double) n
// This is required for the permutations and combinations
// calls.
// Version: 9. March 2004 23:48
// -------------------------------------------------------
- (double) factorial: (double) n
{
    double lg;
    
    // 170.5 seems to be the max value which EdenMath can handle
    if (n < 170.5)
    {
        lg = lgamma(n+1.0);
        n = signgam*exp(lg);
    }
    
    return (n);
    
}

// -------------------------------------------------------
// (void) powerE
// e^x
// M_E is a constant hidden somewhere in the included
// libraries
// -------------------------------------------------------
- (void) powerE
{
    currentValue = pow(M_E, currentValue);
    isNewDigit    = YES;
}

// -------------------------------------------------------
// (void) power2
// 2^x
// -------------------------------------------------------
- (void) power2
{
    currentValue = pow(2, currentValue);
    isNewDigit 	  = YES;
}

// -------------------------------------------------------
// (void) power10
// 10^x
// -------------------------------------------------------
- (void) power10
{
    currentValue = pow(10, currentValue);
    isNewDigit 	  = YES;
}

// -------------------------------------------------------
// (void) inverse
// -------------------------------------------------------
- (void)inverse
{
    if (currentValue != 0.0)
    {
        currentValue = 1/currentValue;
    }
    
    isNewDigit = YES;
}

// =====================================================================================
// TRIGOMETRIC FUNCTIONS
// =====================================================================================

// -------------------------------------------------------
// (void) setAngleType:(AngleType)aType
// Modify the type of angles using degrees, radians, or
// gradients.  EM 1.1.1 reduced this code down to one
// line, eliminating multiple IF-ELSE statements.
// -------------------------------------------------------
// Version: 31. May 2003
// -------------------------------------------------------
- (void)setAngleType:(AngleType)aType
{
    angle_type = aType;
}

// -------------------------------------------------------
// (double)deg_to_rad:(double)degrees
// Convert from degrees to radians
// -------------------------------------------------------
- (double)deg_to_rad:(double)degrees
{
    double radians = 0.0;
    radians = degrees * M_PI / 180;
    
    return radians;
}

// -------------------------------------------------------
// (double)rad_to_deg:(double)radians
// Convert from radians to degrees
// -------------------------------------------------------
// Created: 31. May 2003
// Version: 31. May 2003
// -------------------------------------------------------
- (double)rad_to_deg:(double)radians
{
    double degrees = 0.0;
    degrees = radians * 180 / M_PI;
    
    return degrees;
}

// -------------------------------------------------------
// (double)grad_to_rad:(double)gradients
// Convert from gradients to radians
// http://www.onlineconversion.com/angles.htm
// 1 gradient = 0.015707963267948966192 radians
// 1 gradient = 0.9 degrees
// Created higher precision for the conversion so 
// Tan(50g) would equal 1.  Otherwise, if the conversion
// isn't precise enough, it comes out to be 1.000003672.
// -------------------------------------------------------
// Version: 31. May 2003
// -------------------------------------------------------
- (double)grad_to_rad:(double)gradients
{
    double radians = 0.0;
    radians = gradients * 0.015707963267948966192;
    
    return radians;
}

// -------------------------------------------------------
// (double)rad_to_grad:(double)radians
// Convert from radians to gradients
// http://www.onlineconversion.com/angles.htm
// 1 gradient = 0.015707963267948966192 radians
// 1 gradient = 0.9 degrees
// -------------------------------------------------------
// Created: 31. May 2003
// Version: 31. May 2003
// -------------------------------------------------------
- (double)rad_to_grad:(double)radians
{
    double gradients = 0.0;
    gradients = radians / 0.015707963267948966192;
    
    return gradients;
}

// -------------------------------------------------------
// (void) sine
// -------------------------------------------------------
- (void)sine
{
    if (angle_type == DEGREE)
    {
        currentValue = [self deg_to_rad:currentValue];
    }
    else if (angle_type == GRADIENT)
    {
        currentValue = [self grad_to_rad:currentValue];
    }
    
    currentValue = sin(currentValue);
    isNewDigit 	  = YES;
}

// -------------------------------------------------------
// (void) cosine
// -------------------------------------------------------
- (void)cosine
{
    if (angle_type == DEGREE)
    {
        currentValue = [self deg_to_rad:currentValue];
    }
    else if (angle_type == GRADIENT)
    {
        currentValue = [self grad_to_rad:currentValue];
    }
    
    currentValue = cos(currentValue);
    isNewDigit 	  = YES;
}

// -------------------------------------------------------
// (void) tangent
// -------------------------------------------------------
- (void)tangent
{
    if (angle_type == DEGREE)
    {
        currentValue = [self deg_to_rad:currentValue];
    }
    else if (angle_type == GRADIENT)
    {
        currentValue = [self grad_to_rad:currentValue];
    }
    
    if ( ( currentValue == M_PI/2) || (currentValue == 3 * M_PI / 2) || 
         ( currentValue == - M_PI/2) || (currentValue == -3 * M_PI / 2) )
    {
        NSBeep();
        NSRunAlertPanel(@"Warning", @"Tan cannot calculate values of ¸/2 or 3¸/2",
                        @"OK", nil, nil);
    }
    else // otherwise, tan will still be calculated on ¸/2 or 3¸/2, which is wrong.
    {
        currentValue = tan(currentValue);
    }
    
    isNewDigit    = YES;
}

// -------------------------------------------------------
// (void) arcsine
// -------------------------------------------------------
// Version: 31. May 2003
// -------------------------------------------------------
- (void)arcsine
{
    currentValue = asin(currentValue);
    isNewDigit 	 = YES;
    
    if (angle_type == DEGREE)
    {
        currentValue = [self rad_to_deg:currentValue];
    }
    else if (angle_type == GRADIENT)
    {
        currentValue = [self rad_to_grad:currentValue];
    }
}

// -------------------------------------------------------
// (void) arccosine
// -------------------------------------------------------
// Version: 31. May 2003
// -------------------------------------------------------
- (void)arccosine
{ 
    currentValue = acos(currentValue);
    isNewDigit 	  = YES;
    
    if (angle_type == DEGREE)
    {
        currentValue = [self rad_to_deg:currentValue];
    }
    else if (angle_type == GRADIENT)
    {
        currentValue = [self rad_to_grad:currentValue];
    }    
}

// -------------------------------------------------------
// (void) arctangent
// -------------------------------------------------------
// Version: 31. May 2003
// -------------------------------------------------------
- (void)arctangent
{    
    currentValue = atan(currentValue);
    isNewDigit 	  = YES;
    
    if (angle_type == DEGREE)
    {
        currentValue = [self rad_to_deg:currentValue];
    }
    else if (angle_type == GRADIENT)
    {
        currentValue = [self rad_to_grad:currentValue];
    }    
}

// =====================================================================================
// PROBABILITY FUNCTIONS
// The Probability and Combination functions are in the enter function since they
// act as binary operators
// =====================================================================================

// -------------------------------------------------------
// (void) generate_random_num
// -------------------------------------------------------
- (double) generate_random_num
{
    static int seeded = 0;
    double value = 0.0;
    
    if (seeded == 0)
    {
        srand((unsigned)time((time_t *)NULL));
        seeded = 1;
    }
    
    value = rand();
    
    return value;
}

// -------------------------------------------------------
// (void) random_num
// -------------------------------------------------------
- (void) random_num
{
    currentValue = [self generate_random_num];
    isNewDigit 	 = YES;
}

@end
