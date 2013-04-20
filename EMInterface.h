//
//  CalculatorModel.h
//
//  Copyright (c) 2000 Sven Van Caekenberghe. All rights reserved.
//  For more info: http://homepage.mac.com/svc/carbon-objc-mac-os-x/ - mailto:svc@mac.com
//

#import <Foundation/Foundation.h>

typedef enum _CalculatorOpCode 
{
    NO_OPERATOR = 0,
    DIVIDE_OPERATOR = 1,
    MULTIPLY_OPERATOR = 2,
    ADD_OPERATOR = 3,
    SUBTRACT_OPERATOR = 4,
    EXPONENT_OPERATOR = 5,
    XROOT_OPERATOR = 6,
    MOD_OPERATOR = 7,
    EE_OPERATOR = 8,
    NPR_OPERATOR = 9,
    NCR_OPERATOR = 10
} CalculatorOpCode;

typedef enum _AngleType
{
    DEGREE = 0,
    RADIAN = 1,
    GRADIENT = 2
} AngleType;

@interface CalculatorModel : NSObject 
{

    double accumulatorValue;                 // holds the working number (which is being edited)
    double transientValue;                   // holds other operand (previous accumulator)
    double e_value;			     // the number e
    CalculatorOpCode operatorCode;           // holds the current operator
    AngleType angle_type;	     	     // holds type of angles used
    int trailingDigits;                      // used in decimal number input
    BOOL startNewDigit;                      // used in decimal number input

}

- (double)accumulator;
- (void)setAccumulator:(double)newValue;
- (NSDictionary *)state;
- (void)setState:(NSDictionary *)stateDictionary;

- (void)pi;
- (void)e;
- (void)dot;
- (void)clear;
- (void)enter;
- (void)percentage;
- (void)invert;
- (void)inverse;
- (void)sqrtOperator;
- (void)cubed_root;

- (double)deg_to_rad:(double)degrees;
- (double)grad_to_rad:(double)gradients;
- (void)sine;
- (void)cosine;
- (void)tangent;
- (void)arcsine;
- (void)arccosine;
- (void)arctangent;

- (void)ln;
- (void)logarithm;
- (double)recursive_factorial:(double)n;
- (void)factorial;
- (void)powerE;
- (void)power10;

- (void)squared;
- (void)cubed;

- (double) generate_random_num;
- (void)random_num;

- (void)setAngleType:(AngleType)aType;

- (void)acceptOperator:(CalculatorOpCode)opCode;
- (void)newDigit:(int)digit;

@end
