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
// -------------------------------------------------------
// Update the value in the display field on the
// calculator.  In versions 1.0.0 and 1.0.1, this was
// a 1 line method.  Because of odd precision problems and
// numbers like 0.001 not showing the 0's as they are 
// typed has required the extra 50 (or so) lines of code
// -------------------------------------------------------
- (void)updateDisplay
{
    double currentValue = [em getCurrentValue];
    int i = [em getTrailingDigits];

	NSString *truePrecision = [NSString stringWithFormat:@"%@%df", @"%15.", i-1];
    NSString *precision = @"%15.10f"; // default precision
    NSString *stringValue = [NSString stringWithFormat:precision, currentValue]; // convert to string with certain string format    
    NSString *newDisplayString = nil;
    
    // variables for the new algorithm to format numbers properly and eliminate unncessary
    // '0' from the end of a final number.
	char c_string[64] = "";
    char final_string[64] = "";
    int cs_len = 0;
    int j = 0;
    int decimal_places = 0;
    BOOL hasDecimal = NO; // 0 is false, 1 is true
    BOOL is_zero = YES; // is true
    int new_len = 0;
    int num_zeros = 0;

    if (i != 0) // if there ARE some set trailing digits like 65.2 or 0.001
    {
        NSString *otherValue = [NSString stringWithFormat:truePrecision, currentValue];
        [displayField setStringValue: otherValue];
    }
    else // no trailing_digits because it is a number like 6 or it is an answer and
        // trailing_digits was reset to 0
    {   
        // loop through the string converted version of the currentValue, and cut
        // off any excess 0's at the end of the number, so 63.20 will appear like 63.2
        
        currentValue = [stringValue doubleValue];
        [stringValue getCString: c_string];
        
        // new algorithm for formating numbers properly on output
        
        // check to see if there is a decimal place, and if so, how many
        // decimal places exist
        cs_len = strlen(c_string);
        
        for (j = 0; j < cs_len; j++)
        {
            if (c_string[j] == '.')
            {
                hasDecimal = YES;
                while (j < cs_len)
                {
                    j++;
                    decimal_places++;
                }
            }
        }
  
        // if a decimal place exists, go through to get rid of unnecessary 0's at
        // the end of the number so 65.20 will appear to be 65.2
        if (hasDecimal == YES)
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
        
        newDisplayString = [NSString stringWithFormat:@"%s", final_string];

		if ((newDisplayString == nil) || ([newDisplayString isEqualToString:@""] == YES)) {
			newDisplayString = @"NaN";
		}
		
		[displayField setStringValue: newDisplayString];
		
    }
}

// -------------------------------------------------------
// (BOOL) applicationShould....:(NSApplication *)theApplication
// -------------------------------------------------------
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
// (IBAction) checkForNewVersion: (id) sender
// -------------------------------------------------------
// Version: 27 May 2013 16:24
// Created: 8. May 2004 23:55
// -------------------------------------------------------
- (IBAction) checkForNewVersion: (id) sender
{
    NSString *currentVersionNumber = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *productVersionDict = [NSDictionary dictionaryWithContentsOfURL: [NSURL URLWithString:@"http://www.edenwaith.com/xml/version.xml"]];
    NSString *latestVersionNumber = [productVersionDict valueForKey:@"EdenMath"];
    int button = 0;
	
    if ( latestVersionNumber == nil )
    {
        NSBeep();
        NSRunAlertPanel(NSLocalizedString(@"Could not check for update", nil), NSLocalizedString(@"A problem arose while attempting to check for a new version of EdenMath.  Edenwaith.com may be temporarily unavailable or your network may be down.", nil), NSLocalizedString(@"OK", nil), nil, nil);
    }
    else if ( [latestVersionNumber isEqualTo: currentVersionNumber] )
    {
        NSRunAlertPanel(NSLocalizedString(@"Software is Up-To-Date", nil), NSLocalizedString(@"You have the most recent version of EdenMath.", nil), NSLocalizedString(@"OK", nil), nil, nil);
    }
    else
    {
        button = NSRunAlertPanel(NSLocalizedString(@"New Version is Available", nil), NSLocalizedString(@"A new version of EdenMath is available.", nil), NSLocalizedString(@"Download", nil), NSLocalizedString(@"Cancel", nil), NSLocalizedString(@"More Info", nil), nil);
        
        if (button == NSOKButton)	// Download
        {
            [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://www.edenwaith.com/downloads/edenmath.php"]];
        }
		else if (NSAlertOtherReturn == button) // More Info
        {
            [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://www.edenwaith.com/products/edenmath/"]];
        }
    }
}

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

// -------------------------------------------------------
// (IBAction) digitButton:(id)sender
// -------------------------------------------------------
// New addition to EM 1.1.1 which eliminates ten other
// functions (zeroButton...nineButton) so each number
// button does not explicitly need to point to a new
// function.
// -------------------------------------------------------
- (IBAction) digitButton: (id) sender
{
    [self saveState];
    [em newDigit: [[sender title] intValue]];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) period:(id)sender
// -------------------------------------------------------
- (IBAction)period:(id)sender 
{
    [self saveState];
    [em period];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) pi2:(id)sender
// -------------------------------------------------------
- (IBAction)pi2:(id)sender 
{
    [self saveState];
    [em trigConstant:2*M_PI];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) pi3_2:(id)sender
// -------------------------------------------------------
- (IBAction)pi3_2:(id)sender 
{
    [self saveState];
    [em trigConstant:3*M_PI/2];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) pi:(id)sender
// -------------------------------------------------------
- (IBAction)pi:(id)sender 
{
    [self saveState];
    [em pi];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) pi_2:(id)sender
// -------------------------------------------------------
- (IBAction)pi_2:(id)sender 
{
    [self saveState];
    [em trigConstant:M_PI/2];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) pi_3:(id)sender
// -------------------------------------------------------
- (IBAction)pi_3:(id)sender 
{
    [self saveState];
    [em trigConstant:M_PI/3];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) pi_4:(id)sender
// -------------------------------------------------------
- (IBAction)pi_4:(id)sender 
{
    [self saveState];
    [em trigConstant:M_PI/4];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) pi_6:(id)sender
// -------------------------------------------------------
- (IBAction)pi_6:(id)sender 
{
    [self saveState];
    [em trigConstant:M_PI/6];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) e:(id)sender
// -------------------------------------------------------
- (IBAction)e:(id)sender
{
    [self saveState];
    [em e];
    [self updateDisplay];
}

#pragma mark -
#pragma mark Standard Functions

// -------------------------------------------------------
// (IBAction) enter:(id)sender
// -------------------------------------------------------
- (IBAction)enter:(id)sender 
{
    [self saveState];
    [em enter];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) add:(id)sender
// -------------------------------------------------------
- (IBAction)add:(id)sender 
{
    [self saveState];
    [em operation:ADD_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) subtract:(id)sender
// -------------------------------------------------------
- (IBAction)subtract:(id)sender 
{
    [self saveState];
    [em operation:SUBTRACT_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) multiply:(id)sender
// -------------------------------------------------------
- (IBAction)multiply:(id)sender 
{
    [self saveState];
    [em operation:MULTIPLY_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) divide:(id)sender
// -------------------------------------------------------
- (IBAction)divide:(id)sender 
{
    [self saveState];
    [em operation:DIVIDE_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) reverseSign:(id)sender
// +/-
// -------------------------------------------------------
- (IBAction)reverseSign:(id)sender 
{
    [self saveState];
    [em reverseSign];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) percentage:(id)sender
// -------------------------------------------------------
- (IBAction)percentage:(id)sender
{
    [self saveState];
    [em percentage];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) mod:(id)sender
// modulus division
// -------------------------------------------------------
- (IBAction)mod:(id)sender 
{
    [self saveState];
    [em operation:MOD_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) EE:(id)sender
// -------------------------------------------------------
- (IBAction)EE:(id)sender 
{
    [self saveState];
    [em operation:EE_OP];
    [self updateDisplay];
}

#pragma mark -
#pragma mark Algebraic Functions

// -------------------------------------------------------
// (IBAction) exponent:(id)sender
// x^2
// -------------------------------------------------------
- (IBAction)squared:(id)sender
{
    [self saveState];
    [em squared];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) cubed:(id)sender
// x^3
// -------------------------------------------------------
- (IBAction)cubed:(id)sender
{
    [self saveState];
    [em cubed];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) exponent:(id)sender
// x^y
// -------------------------------------------------------
- (IBAction)exponent:(id)sender
{
    [self saveState];
    [em operation:EXPONENT_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) squareRoot:(id)sender
// √
// -------------------------------------------------------
- (IBAction)squareRoot:(id)sender
{
    [self saveState];
    [em squareRoot];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) cubedRoot:(id)sender
// 3√
// -------------------------------------------------------
- (IBAction)cubedRoot:(id)sender
{
    [self saveState];
    [em cubedRoot];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) xRoot:(id)sender
// y√x
// -------------------------------------------------------
- (IBAction)xRoot:(id)sender
{
    [self saveState];
    [em operation:XROOT_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) ln:(id)sender
// -------------------------------------------------------
- (IBAction)ln:(id)sender
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
// (IBAction) logarithm:(id)sender
// -------------------------------------------------------
- (IBAction)logarithm:(id)sender
{
    [self saveState];
    [em logarithm];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) factorial:(id)sender
// -------------------------------------------------------
- (IBAction)factorial:(id)sender
{
    [self saveState];
    [em factorial];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) powerE:(id)sender
// e^x
// -------------------------------------------------------
- (IBAction)powerE:(id)sender
{
    [self saveState];
    [em powerE];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) power2:(id)sender
// 2^x
// -------------------------------------------------------
- (IBAction) power2: (id) sender
{
    [self saveState];
    [em power2];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) power10:(id)sender
// 10^x
// -------------------------------------------------------
- (IBAction)power10:(id)sender
{
    [self saveState];
    [em power10];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) inverse:(id)sender
// 1/x
// -------------------------------------------------------
- (IBAction)inverse:(id)sender
{
    [self saveState];
    [em inverse];
    [self updateDisplay];
}


#pragma mark -
#pragma mark Trigometric Functions 

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
// (IBAction) setDegree:(id)sender
// -------------------------------------------------------
- (IBAction)setDegree:(id)sender
{
    [self saveState];
    [em setAngleType:DEGREE];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) setRadian:(id)sender
// -------------------------------------------------------
- (IBAction)setRadian:(id)sender
{
    [self saveState];
    [em setAngleType:RADIAN];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) setGradient:(id)sender
// -------------------------------------------------------
- (IBAction)setGradient:(id)sender
{
    [self saveState];
    [em setAngleType:GRADIENT];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) sine:(id)sender
// -------------------------------------------------------
- (IBAction)sine:(id)sender
{
    [self saveState];
    [em sine];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) cosine:(id)sender
// -------------------------------------------------------
- (IBAction)cosine:(id)sender
{
    [self saveState];
    [em cosine];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) tangent:(id)sender
// -------------------------------------------------------
- (IBAction)tangent:(id)sender
{
    [self saveState];
    [em tangent];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) arcsine:(id)sender
// -------------------------------------------------------
- (IBAction)arcsine:(id)sender
{
    [self saveState];
    [em arcsine];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) arccosine:(id)sender
// -------------------------------------------------------
- (IBAction)arccosine:(id)sender
{
    [self saveState];
    [em arccosine];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) arctangent:(id)sender
// -------------------------------------------------------
- (IBAction)arctangent:(id)sender
{
    [self saveState];
    [em arctangent];
    [self updateDisplay];
}

#pragma mark -
#pragma mark Probability Functions

// -------------------------------------------------------
// (IBAction) permutation:(id)sender
// nPr
// -------------------------------------------------------
- (IBAction)permutation:(id)sender
{
    [self saveState];
    [em operation:NPR_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) combination:(id)sender
// nCr
// -------------------------------------------------------
- (IBAction)combination:(id)sender
{
    [self saveState];
    [em operation:NCR_OP];
    [self updateDisplay];
}

// -------------------------------------------------------
// (IBAction) randomNum:(id)sender
// -------------------------------------------------------
- (IBAction)randomNum:(id)sender
{
    [self saveState];
    [em randomNum];
    [self updateDisplay];
}

#pragma mark -
#pragma mark Toggle alternate functions

// -------------------------------------------------------
// (IBAction) toggleAlternates: (id) sender
// -------------------------------------------------------
- (IBAction) toggleAlernates: (id) sender
{
	if (displayAlternates == YES)
	{
		[self hideAlternates];
	}
	else
	{
		[self showAlternates];
	}
}

// -------------------------------------------------------
// (void) showAlternates: (id) sender
// -------------------------------------------------------
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
		[x3Button setAction: @selector(cubedRoot:)];
		
		[xyButton setImage: nil];
		[xyButton setTitle: @"y√x"];
		[xyButton setToolTip: NSLocalizedString(@"", nil)];
		[xyButton setAction: @selector(xRoot:)];
		
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

// -------------------------------------------------------
// (void) hideAlternates: (id) sender
// -------------------------------------------------------
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
