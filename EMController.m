//
//  EMController.m
//  EdenMath
//
//  Created by admin on Thu Feb 21 2002.
//  Copyright (c) 2002-2013 Edenwaith. All rights reserved.
//

#import "EMController.h"

@implementation EMController

// -------------------------------------------------------
// (id)init
// Allocate memory and french fries for EdenMath
// -------------------------------------------------------
- (id)init 
{
    em			= [[EMResponder alloc] init];
    undoManager = [[NSUndoManager alloc] init];
	displayAlternates = NO;
	
    return self;
}

// -------------------------------------------------------
// (void)dealloc
// Deallocate/free up memory used by Edenmath
// -------------------------------------------------------
- (void)dealloc 
{
    [em release];
    [undoManager release];
    [super dealloc];
}


// -------------------------------------------------------
// (void) awakeFromNib
// -------------------------------------------------------
- (void)awakeFromNib 
{
    [[displayField window] makeKeyAndOrderFront:self];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

#pragma mark -

// -------------------------------------------------------
// (void) off:(id)sender
// When the Off button is pressed, the application is
// terminated
// -------------------------------------------------------
- (void)off:(id)sender
{
    [NSApp terminate:self];
}

// -------------------------------------------------------
// (void) clear:(id)sender
// -------------------------------------------------------
- (void)clear:(id)sender 
{
    [self saveState];
    [em clear];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) cut:(id)sender
// -------------------------------------------------------
- (void)cut:(id)sender 
{
    [self copy:sender];
    [self saveState];
    [self clear:self];
}

// -------------------------------------------------------
// (void) copy:(id)sender
// -------------------------------------------------------
- (void)copy:(id)sender 
{
    NSString *contents = [displayField stringValue];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteboard setString:contents forType:NSStringPboardType];
}

// -------------------------------------------------------
// (void) paste:(id)sender
// -------------------------------------------------------
- (void)paste:(id)sender 
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *type = [pasteboard availableTypeFromArray:[NSArray arrayWithObject:NSStringPboardType]];
    if (type != nil) 
    {
        NSString *contents = [pasteboard stringForType:type];
        if (contents != nil) {
            NSScanner *scanner = [NSScanner scannerWithString:contents];
            double value;
            if ([scanner scanDouble:&value]) 
            {
                [self saveState];
                [em setCurrentValue:value];
                [self updateDisplay];
            }
        }
    }
}

#pragma mark -

// -------------------------------------------------------
// (void) updateDisplay:(id)sender
// Update the value in the display field on the
// calculator.  In versions 1.0.0 and 1.0.1, this was
// a 1 line method.  Because of odd precision problems and
// numbers like 0.001 not showing the 0's as they are 
// typed has required the extra 50 (or so) lines of code
// -------------------------------------------------------
- (void)updateDisplay
 {
    double current_value = [em getCurrentValue];
    char *y = "%15.";
    int i = [em getTrailingDigits];
    char *z = "f";
    char c_string[32] = "";
    NSString *true_precision = [[NSString alloc] initWithFormat: @"%s%d%s", y, i-1, z];
    
    NSString *new_string; // = [[NSString alloc] init];
    
    // variables for the new algorithm to format numbers properly and eliminate unncessary
    // '0' from the end of a final number.
    char final_string[32] = "";
    int cs_len = 0;
    int j = 0;
    int decimal_places = 0;
    BOOL is_decimal = NO; // 0 is false, 1 is true
    BOOL is_zero = YES; // is true
    int new_len = 0;
    int num_zeros = 0;

    NSString *precision = @"%15.10f"; // default precision
    NSString *string_value = [NSString stringWithFormat:precision, current_value]; // convert to string with certain string format

    if (i != 0) // if there ARE some set trailing digits like 65.2 or 0.001
    {
        NSString *other_value = [NSString stringWithFormat:true_precision, current_value];
        [displayField setStringValue: other_value];
    }
    else // no trailing_digits because it is a number like 6 or it is an answer and
        // trailing_digits was reset to 0
    {   
        // loop through the string converted version of the current_value, and cut
        // off any excess 0's at the end of the number, so 63.20 will appear like 63.2
        
        current_value = [string_value doubleValue];
        [string_value getCString: c_string];
        
        // new algorithm for formating numbers properly on output
        
        // check to see if there is a decimal place, and if so, how many
        // decimal places exist
        cs_len = strlen(c_string);
        
        for (j = 0; j < cs_len; j++)
        {
            if (c_string[j] == '.')
            {
                is_decimal = YES;
                while (j < cs_len)
                {
                    j++;
                    decimal_places++;
                }
            }
        }
  
        // if a decimal place exists, go through to get rid of unnecessary 0's at
        // the end of the number so 65.20 will appear to be 65.2
        if (is_decimal == YES)
        {
            for (j = 0; (j < decimal_places) && (is_zero == YES); j++)
            {
                new_len = cs_len - (1 + j);
                // count the number of 0's at the end
                if (c_string[new_len] == '0')
                {
                    num_zeros++;
                }
                else if (c_string[new_len] == '.')
                {
                    num_zeros++;
                    is_zero = NO;
                }
                else // otherwise, no more excess 0's to be found
                {
                    is_zero = NO;
                }
            }

            // loop through the necessary number of times to get rid of
            // unneeded 0's
            for (j = 0; j < (cs_len - num_zeros); j++)
            {
                final_string[j] = c_string[j];
            }
        }
        else // otherwise, there is no decimal place 
        {
            strcpy(final_string, c_string);
        }
        
        new_string = [NSString stringWithFormat:@"%s", final_string];
        
        // When printing out to NSLog, new_string looks odd (\\304\\026\\010\\304),
        // but when placed as a parameter, it seems to work.  Go figure.

        [displayField setStringValue: new_string];
    }
}

// -------------------------------------------------------
// (BOOL) applicationShould....:(NSApplication *)theApplication
// Terminate the program when the last window closes
// Need to connect File Owner and Window to EMController
// for this to work correctly
// -------------------------------------------------------
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication 
{
    return YES;
}

// -------------------------------------------------------
// (void) saveState
// -------------------------------------------------------
- (void)saveState 
{
    [undoManager registerUndoWithTarget:self selector:@selector(setState:) object:[em state]];
}

// -------------------------------------------------------
// (void) setState
// -------------------------------------------------------
- (void)setState:(NSDictionary *)emState 
{
    [self saveState];
    [em setState:emState];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) undoAction
// -------------------------------------------------------
- (void)undoAction:(id)sender 
{
    if ([undoManager canUndo])
    {
        [undoManager undo];
    }
}

// -------------------------------------------------------
// (NSUndoManager *) windowWillReturnUndoManager:(NSWindow *)sender
// -------------------------------------------------------
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender 
{
    return undoManager;
}

#pragma mark -

// -------------------------------------------------------
// (IBAction) goToProductPage: (id) sender
// -------------------------------------------------------
// Version: 8. May 2004 23:55
// Created: 8. May 2004 23:55
// -------------------------------------------------------
- (IBAction) goToProductPage: (id) sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://www.edenwaith.com/products/edenmath/"]];
}


// -------------------------------------------------------
// (IBAction) goToFeedbackPage: (id) sender
// -------------------------------------------------------
// Version: 8. May 2004 23:55
// Created: 8. May 2004 23:55
// -------------------------------------------------------
- (IBAction) goToFeedbackPage: (id) sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:support@edenwaith.com?Subject=EdenMath%20Feedback"]];
}

#pragma mark -
#pragma mark Constants

// =====================================================================================
// CONSTANTS
// =====================================================================================

// -------------------------------------------------------
// (void) digitButton:(id)sender
// New addition to EM 1.1.1 which eliminates ten other
// functions (zeroButton...nineButton) so each number
// button does not explicitly need to point to a new
// function.
// -------------------------------------------------------
- (void) digitButton: (id) sender
{
    [self saveState];
    [em newDigit: [[sender title] intValue]];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) period:(id)sender
// -------------------------------------------------------
- (void)period:(id)sender 
{
    [self saveState];
    [em period];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) pi2:(id)sender
// -------------------------------------------------------
- (void)pi2:(id)sender 
{
    [self saveState];
    [em trig_constant:2*M_PI];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) pi3_2:(id)sender
// -------------------------------------------------------
- (void)pi3_2:(id)sender 
{
    [self saveState];
    [em trig_constant:3*M_PI/2];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) pi:(id)sender
// -------------------------------------------------------
- (void)pi:(id)sender 
{
    [self saveState];
    [em pi];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) pi_2:(id)sender
// -------------------------------------------------------
- (void)pi_2:(id)sender 
{
    [self saveState];
    [em trig_constant:M_PI/2];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) pi_3:(id)sender
// -------------------------------------------------------
- (void)pi_3:(id)sender 
{
    [self saveState];
    [em trig_constant:M_PI/3];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) pi_4:(id)sender
// -------------------------------------------------------
- (void)pi_4:(id)sender 
{
    [self saveState];
    [em trig_constant:M_PI/4];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) pi_6:(id)sender
// -------------------------------------------------------
- (void)pi_6:(id)sender 
{
    [self saveState];
    [em trig_constant:M_PI/6];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) e:(id)sender
// -------------------------------------------------------
- (void)e:(id)sender
{
    [self saveState];
    [em e];
    [self updateDisplay];
}

#pragma mark -
#pragma mark Standard Functions

// =====================================================================================
// STANDARD FUNCTIONS
// =====================================================================================

// -------------------------------------------------------
// (void) enter:(id)sender
// -------------------------------------------------------
- (void)enter:(id)sender 
{
    [self saveState];
    [em enter];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) add:(id)sender
// -------------------------------------------------------
- (void)add:(id)sender 
{
    [self saveState];
    [em operation:ADD_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) subtract:(id)sender
// -------------------------------------------------------
- (void)subtract:(id)sender 
{
    [self saveState];
    [em operation:SUBTRACT_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) multiply:(id)sender
// -------------------------------------------------------
- (void)multiply:(id)sender 
{
    [self saveState];
    [em operation:MULTIPLY_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) divide:(id)sender
// -------------------------------------------------------
- (void)divide:(id)sender 
{
    [self saveState];
    [em operation:DIVIDE_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) reverse_sign:(id)sender
// -------------------------------------------------------
- (void)reverse_sign:(id)sender 
{
    [self saveState];
    [em reverse_sign];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) percentage:(id)sender
// -------------------------------------------------------
- (void)percentage:(id)sender
{
    [self saveState];
    [em percentage];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) mod:(id)sender
// -------------------------------------------------------
- (void)mod:(id)sender 
{
    [self saveState];
    [em operation:MOD_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) EE:(id)sender
// -------------------------------------------------------
- (void)EE:(id)sender 
{
    [self saveState];
    [em operation:EE_OP];
    [self updateDisplay];
}


// =====================================================================================
// ALGEBRAIC FUNCTIONS
// =====================================================================================

// -------------------------------------------------------
// (void) exponent:(id)sender
// x^2
// -------------------------------------------------------
- (void)squared:(id)sender
{
    [self saveState];
    [em squared];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) cubed:(id)sender
// x^2
// -------------------------------------------------------
- (void)cubed:(id)sender
{
    [self saveState];
    [em cubed];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) exponent:(id)sender
// x^y
// -------------------------------------------------------
- (void)exponent:(id)sender
{
    [self saveState];
    [em operation:EXPONENT_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) xroot:(id)sender
// √
// -------------------------------------------------------
- (void)square_root:(id)sender
{
    [self saveState];
    [em square_root];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) xroot:(id)sender
// 3√
// -------------------------------------------------------
- (void)cubed_root:(id)sender
{
    [self saveState];
    [em cubed_root];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) xroot:(id)sender
// y√x
// -------------------------------------------------------
- (void)xroot:(id)sender
{
    [self saveState];
    [em operation:XROOT_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) ln:(id)sender
// -------------------------------------------------------
- (void)ln:(id)sender
{
    [self saveState];
    [em ln];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) binaryLogarithm:(id)sender
// -------------------------------------------------------
- (IBAction) binaryLogarithm: (id) sender
{
    [self saveState];
    [em binaryLogarithm];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) logarithm:(id)sender
// -------------------------------------------------------
- (void)logarithm:(id)sender
{
    [self saveState];
    [em logarithm];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) factorial:(id)sender
// -------------------------------------------------------
- (void)factorial:(id)sender
{
    [self saveState];
    [em factorial];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) powerE:(id)sender
// e^x
// -------------------------------------------------------
- (void)powerE:(id)sender
{
    [self saveState];
    [em powerE];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) power2:(id)sender
// 2^x
// -------------------------------------------------------
- (IBAction) power2: (id) sender
{
    [self saveState];
    [em power2];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) power10:(id)sender
// 10^x
// -------------------------------------------------------
- (void)power10:(id)sender
{
    [self saveState];
    [em power10];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) inverse:(id)sender
// -------------------------------------------------------
- (void)inverse:(id)sender
{
    [self saveState];
    [em inverse];
    [self updateDisplay];
}


#pragma mark -
#pragma mark Trigometric Functions 

// =====================================================================================
// TRIGOMETRIC FUNCTIONS
// =====================================================================================

// -------------------------------------------------------
// (IBAction) setAngleType:(id)sender
// -------------------------------------------------------
- (IBAction) setAngleType: (id) sender
{
	NSString *angleType = [sender title];
	
	[self saveState];
	
	if ([angleType isEqualToString: NSLocalizedString(@"Degree", nil)] == YES)
	{
		[em setAngleType:DEGREE];
	}
	else if ([angleType isEqualToString: NSLocalizedString(@"Radian", nil)] == YES)
	{
		[em setAngleType:RADIAN];
	}
	else if ([angleType isEqualToString: NSLocalizedString(@"Gradient", nil)] == YES)
	{
		[em setAngleType:GRADIENT];
	}
	
	[self updateDisplay];
}


// -------------------------------------------------------
// (void) setDegree:(id)sender
// -------------------------------------------------------
- (void)setDegree:(id)sender
{
    [self saveState];
    [em setAngleType:DEGREE];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) setRadian:(id)sender
// -------------------------------------------------------
- (void)setRadian:(id)sender
{
    [self saveState];
    [em setAngleType:RADIAN];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) setGradient:(id)sender
// -------------------------------------------------------
- (void)setGradient:(id)sender
{
    [self saveState];
    [em setAngleType:GRADIENT];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) sine:(id)sender
// -------------------------------------------------------
- (void)sine:(id)sender
{
    [self saveState];
    [em sine];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) cosine:(id)sender
// -------------------------------------------------------
- (void)cosine:(id)sender
{
    [self saveState];
    [em cosine];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) tangent:(id)sender
// -------------------------------------------------------
- (void)tangent:(id)sender
{
    [self saveState];
    [em tangent];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) arcsine:(id)sender
// -------------------------------------------------------
- (void)arcsine:(id)sender
{
    [self saveState];
    [em arcsine];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) arccosine:(id)sender
// -------------------------------------------------------
- (void)arccosine:(id)sender
{
    [self saveState];
    [em arccosine];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) arctangent:(id)sender
// -------------------------------------------------------
- (void)arctangent:(id)sender
{
    [self saveState];
    [em arctangent];
    [self updateDisplay];
}

#pragma mark -
#pragma mark Probability Functions

// =====================================================================================
// PROBABILITY FUNCTIONS
// =====================================================================================

// -------------------------------------------------------
// (void) permutation:(id)sender
// nPr
// -------------------------------------------------------
- (void)permutation:(id)sender
{
    [self saveState];
    [em operation:NPR_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) combination:(id)sender
// -------------------------------------------------------
- (void)combination:(id)sender
{
    [self saveState];
    [em operation:NCR_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (void) random_num:(id)sender
// -------------------------------------------------------
- (void)random_num:(id)sender
{
    [self saveState];
    [em random_num];
    [self updateDisplay];
}

#pragma mark -

- (void) toggleAlernates: (id) sender
{
	if (displayAlternates == YES)
	{
		[self hideAlternates];
	}
	else
	{
		[self showAlternates];
	}
	
	//	[self saveState];
	//	[self updateDisplay];
}

- (void) showAlternates
{
	if (displayAlternates == NO)
	{
		[alternateButton setState:NSOnState];
		
		[sineButton setTitle: @"sin⁻¹"];
		[sineButton setToolTip: NSLocalizedString(@"Arcsine", nil)];
		[sineButton setAction: @selector(arcsine:)];
		
		[cosineButton setTitle: @"cos⁻¹"];
		[cosineButton setToolTip: NSLocalizedString(@"Arccosine", nil)];
		[cosineButton setAction: @selector(arccosine:)];
		
		[tangentButton setTitle: @"tan⁻¹"];
		[tangentButton setToolTip: NSLocalizedString(@"Arctangent", nil)];
		[tangentButton setAction: @selector(arctangent:)];
		
		[x3Button setTitle: @"3√"];
		[x3Button setToolTip: NSLocalizedString(@"Cubed Root", nil)];
		[x3Button setAction: @selector(cubed_root:)];
		
		[xyButton setImage: nil];
		[xyButton setTitle: @"y√x"];
		[xyButton setToolTip: NSLocalizedString(@"", nil)];
		[xyButton setAction: @selector(xroot:)];
		
		[lnButton setTitle: @""];
		[lnButton setToolTip: NSLocalizedString(@"", nil)];
		[lnButton setImage: [NSImage imageNamed:@"ex"]];
		[lnButton setAction: @selector(powerE:)];
		
		[binaryLogButton setTitle: @""];
		[binaryLogButton setToolTip: @""];
		[binaryLogButton setImage: [NSImage imageNamed:@"2x"]];
		[binaryLogButton setAction: @selector(power2:)];
		
		[logButton setTitle: @""];
		[logButton setToolTip: NSLocalizedString(@"", nil)];
		[logButton setImage: [NSImage imageNamed:@"10x"]];
		[logButton setAction: @selector(power10:)];
		
		displayAlternates = YES;
	}
}

- (void) hideAlternates
{
	if (displayAlternates == YES)
	{
		[alternateButton setState:NSOffState];
		
		[sineButton setTitle: @"sin"];
		[sineButton setToolTip: NSLocalizedString(@"Sine", nil)];
		[sineButton setAction: @selector(sine:)];
		
		[cosineButton setTitle: @"cos"];
		[cosineButton setToolTip: NSLocalizedString(@"Cosine", nil)];
		[cosineButton setAction: @selector(cosine:)];
		
		[tangentButton setTitle: @"tan"];
		[tangentButton setToolTip: NSLocalizedString(@"Tangent", nil)];
		[tangentButton setAction: @selector(tangent:)];
		
		[x3Button setTitle: @"x³"];
		[x3Button setToolTip: NSLocalizedString(@"Cubed", nil)];
		[x3Button setAction: @selector(cubed:)];
		
		[xyButton setTitle: @""];
		[xyButton setToolTip: NSLocalizedString(@"Exponent", nil)];
		[xyButton setImage: [NSImage imageNamed:@"xy"]];
		[xyButton setAction: @selector(exponent:)];
		
		[lnButton setImage: nil];
		[lnButton setTitle: @"ln"];
		[lnButton setToolTip: NSLocalizedString(@"Natural Logarithm", nil)];
		[lnButton setAction: @selector(ln:)];
		
		[binaryLogButton setImage: nil];
		[binaryLogButton setTitle: @"log₂"];
		[binaryLogButton setToolTip: NSLocalizedString(@"Binary Logarithm", nil)];
		[binaryLogButton setAction: @selector(binaryLogarithm:)];
		
		[logButton setImage: nil];
		[logButton setTitle: @"log₁₀"];
		[logButton setToolTip: NSLocalizedString(@"Logarithm (Base 10)", nil)];
		[logButton setAction: @selector(logarithm:)];
		
		displayAlternates = NO;
	}
}

@end
