//
//  StepperCell.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-29.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import "StepperCell.h"
#import "DiceViewController.h"
#import "SettingsViewController.h"

@implementation StepperCell

@synthesize label, field, stepper;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(IBAction) step: (id)sender {
    
    if ([diceConfig isEqualToString: @"Custom"]) {
        switch ([sender tag]) {
            case kNumDice:
                    numDice = (int)stepper.value;
                break;
            case kNumSides:
                    numSides = (int)stepper.value;
                break;
        }
        
        field.text = [NSString stringWithFormat:@"%g", stepper.value];
        
        settingsDidChange = YES;
    }
}


@end
