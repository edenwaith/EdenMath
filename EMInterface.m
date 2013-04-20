//
//  CalculatorModel.m
//
//  Copyright (c) 2000 Sven Van Caekenberghe. All rights reserved.
//  For more info: http://homepage.mac.com/svc/carbon-objc-mac-os-x/ - mailto:svc@mac.com
//

#import "CalculatorModel.h"

#include <math.h>

@implementation CalculatorModel

- (id)init 
{
	accumulatorValue = transientValue = 0.0;
        operatorCode 	= NO_OPERATOR;
        angle_type 	= DEGREE;
        e_value		= 2.718281828;
        trailingDigits 	= 0;
        startNewDigit	= YES;
        return self;
}

- (double)accumulator {
    return accumulatorValue;
}

- (void)setAccumulator:(double)newValue {
    accumulatorValue = newValue;
}

- (NSDictionary *)state {
    NSDictionary *stateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithDouble: accumulatorValue], @"accumulatorValue",
        [NSNumber numberWithDouble: transientValue], @"transientValue",
        [NSNumber numberWithInt: operatorCode], @"operatorCode",
        [NSNumber numberWithInt: trailingDigits], @"trailingDigits",
        [NSNumber numberWithBool: startNewDigit], @"startNewDigit",
        nil]; 
    return stateDictionary;
}

- (void)setState:(NSDictionary *)stateDictionary {
    accumulatorValue = [[stateDictionary objectForKey: @"accumulatorValue"] doubleValue];
    transientValue = [[stateDictionary objectForKey: @"transientValue"] doubleValue];
    operatorCode = [[stateDictionary objectForKey: @"operatorCode"] intValue];
    trailingDigits = [[stateDictionary objectForKey: @"trailingDigits"] intValue];
    startNewDigit = [[stateDictionary objectForKey: @"startNewDigit"] boolValue];
}

- (void)dot {
    if (startNewDigit) {
        accumulatorValue = 0.0;
        startNewDigit = false;
    }
    if (trailingDigits == 0) {
        trailingDigits = 1;
    }
}

- (void)clear 
{
    accumulatorValue = 0.0;
    transientValue = 0.0;
    operatorCode = NO_OPERATOR;
    trailingDigits = 0;
    startNewDigit = true;
}

- (void)percentage
{
    accumulatorValue = accumulatorValue * 0.01;
    startNewDigit = true;
}

- (void)invert 
{
    accumulatorValue = - accumulatorValue;
}

- (void)inverse
{
    if (accumulatorValue != 0.0)
    {
        accumulatorValue = 1/accumulatorValue;
    }
    startNewDigit = true;
}

- (void)pi 
{
    accumulatorValue = M_PI;
    trailingDigits = 0;
    startNewDigit = true;
}

- (void)e
{
    accumulatorValue = e_value;
    trailingDigits = 0;
    startNewDigit = true;
}

- (void)sqrtOperator
{
    if (accumulatorValue >= 0.0)
    {
        accumulatorValue = sqrt(accumulatorValue);
    }
    startNewDigit = true;
}

- (void)cubed_root
{
    if (accumulatorValue >= 0.0)
    {
        accumulatorValue = pow(accumulatorValue, 0.3333333333333333);
    }
    startNewDigit = true;
}

- (double)deg_to_rad:(double)degrees
{
    double radians = 0.0;
    radians = degrees * M_PI / 180;
    
    return radians;
}

// http://www.onlineconversion.com/angles.htm
// 1 gradient = 0.015708 radians
// 1 gradient = 0.9 degrees
- (double)grad_to_rad:(double)gradients
{
    double radians = 0.0;
    radians = gradients * 0.015708;
    
    return radians;
}

- (void)sine
{
    if (angle_type == DEGREE)
    {
        accumulatorValue = [self deg_to_rad:accumulatorValue];
    }
    else if (angle_type = GRADIENT)
    {
        accumulatorValue = [self grad_to_rad:accumulatorValue];
    }
    
    accumulatorValue = sin(accumulatorValue);
    startNewDigit = true;
}

- (void)cosine
{
    if (angle_type == DEGREE)
    {
        accumulatorValue = [self deg_to_rad:accumulatorValue];
    }
    else if (angle_type = GRADIENT)
    {
        accumulatorValue = [self grad_to_rad:accumulatorValue];
    }
    
    accumulatorValue = cos(accumulatorValue);
    startNewDigit = true;
}

- (void)tangent
{
    if (angle_type == DEGREE)
    {
        accumulatorValue = [self deg_to_rad:accumulatorValue];
    }
    else if (angle_type = GRADIENT)
    {
        accumulatorValue = [self grad_to_rad:accumulatorValue];
    }
    
    accumulatorValue = tan(accumulatorValue);
    startNewDigit = true;
}

- (void)arcsine
{
    if (angle_type == DEGREE)
    {
        accumulatorValue = [self deg_to_rad:accumulatorValue];
    }
    else if (angle_type = GRADIENT)
    {
        accumulatorValue = [self grad_to_rad:accumulatorValue];
    }
    
    accumulatorValue = asin(accumulatorValue);
    startNewDigit = true;
}

- (void)arccosine
{
    if (angle_type == DEGREE)
    {
        accumulatorValue = [self deg_to_rad:accumulatorValue];
    }
    else if (angle_type = GRADIENT)
    {
        accumulatorValue = [self grad_to_rad:accumulatorValue];
    }
    
    accumulatorValue = acos(accumulatorValue);
    startNewDigit = true;
}

- (void)arctangent
{
    if (angle_type == DEGREE)
    {
        accumulatorValue = [self deg_to_rad:accumulatorValue];
    }
    else if (angle_type = GRADIENT)
    {
        accumulatorValue = [self grad_to_rad:accumulatorValue];
    }
    
    accumulatorValue = atan(accumulatorValue);
    startNewDigit = true;
}


// natural log
- (void)ln
{
    if (accumulatorValue > 0.0)
    {
        accumulatorValue = log(accumulatorValue);
    }
    startNewDigit = true;
}

// logarithm base 10
- (void)logarithm
{
    if (accumulatorValue > 0.0)
    {
        accumulatorValue = log10(accumulatorValue);
    }
    startNewDigit = true;
}

// This is the REAL factorial function where the
// work gets done
- (double)recursive_factorial:(double)n
{
    if (n == 1)
    {
        return 1;
    }
    else
    {	
        n = n - 1;
        return ((n+1) * [self recursive_factorial:n]);
    }
}

// n!
- (void)factorial
{
    if (accumulatorValue < 171 && accumulatorValue >= 0)
    {
        accumulatorValue = [self recursive_factorial:accumulatorValue];
    }
    else
    {
        accumulatorValue = 0;
    }
    startNewDigit = true;
}


- (void) powerE
{
    accumulatorValue = pow(e_value, accumulatorValue);
    startNewDigit = true;
}

- (void) power10
{
    accumulatorValue = pow(10, accumulatorValue);
    startNewDigit = true;
}

- (void) squared
{
    accumulatorValue = pow(accumulatorValue, 2);
    startNewDigit = true;
}

- (void) cubed
{
    accumulatorValue = pow(accumulatorValue, 3);
    startNewDigit = true;
}

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

- (void) random_num
{
    accumulatorValue = [self generate_random_num];
    startNewDigit = true;
}

- (void)setAngleType:(AngleType)aType
{
    if (aType == DEGREE)
    {
        angle_type = DEGREE;
    }
    else if (aType == RADIAN)
    {
        angle_type = RADIAN;
    }
    else if (aType = GRADIENT)
    {
        angle_type = GRADIENT;
    }
}

- (void)enter 
{
    switch (operatorCode) {
        case NO_OPERATOR:
            break;
        case ADD_OPERATOR:
            accumulatorValue = transientValue + accumulatorValue;
            break;
        case SUBTRACT_OPERATOR:
            accumulatorValue = transientValue - accumulatorValue;
            break;
        case MULTIPLY_OPERATOR:
            accumulatorValue = transientValue * accumulatorValue;
            break;
        case DIVIDE_OPERATOR:
            if (accumulatorValue != 0.0)
                accumulatorValue = transientValue / accumulatorValue;
            break;
        case EXPONENT_OPERATOR:
            accumulatorValue = pow(transientValue, accumulatorValue);
            break;
        case XROOT_OPERATOR:
            accumulatorValue = pow(transientValue, 1/accumulatorValue);
            break;
        case MOD_OPERATOR:
            accumulatorValue = (int)transientValue % (int)accumulatorValue;
            break;
        case EE_OPERATOR:
            accumulatorValue = transientValue * pow(10, accumulatorValue);
            break;
        case NPR_OPERATOR: // n!/(n-r)!
            accumulatorValue = [self recursive_factorial:transientValue] / [self recursive_factorial:(transientValue - accumulatorValue)];
            break;
        case NCR_OPERATOR: // n!/(r! * (n-r)!)
            accumulatorValue = [self recursive_factorial:transientValue] / ([self recursive_factorial:accumulatorValue] * [self recursive_factorial:(transientValue - accumulatorValue)]);
            break;
    }
    transientValue = 0.0;
    operatorCode = NO_OPERATOR;
    trailingDigits = 0;
    startNewDigit = true;
}

- (void)acceptOperator:(CalculatorOpCode)opCode 
{
    if (operatorCode == NO_OPERATOR) {
        transientValue = accumulatorValue;
        startNewDigit = true;
        operatorCode = opCode;
        trailingDigits = 0;
    } else {
        // user is cascading operations
        // [self enter];
    }
}

- (void)newDigit:(int)digit {
    if (startNewDigit) {
        transientValue = accumulatorValue;
        startNewDigit = false;
        accumulatorValue = digit;
    } else {
        BOOL negative = NO;
        if (accumulatorValue < 0) {
            accumulatorValue = - accumulatorValue;
            negative = YES;
        }
        if (trailingDigits == 0) {
            accumulatorValue = accumulatorValue * 10 + digit;
        } else {
            accumulatorValue = accumulatorValue + digit / pow(10, trailingDigits);
            trailingDigits++;
        }
        if (negative) accumulatorValue = - accumulatorValue;
    }
}

@end
