//
//  StepperCell.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-29.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiceViewController;
@class SettingsViewController;

@interface StepperCell : UITableViewCell <UITextFieldDelegate>

-(IBAction) step:(id)sender;

@property (nonatomic, strong) IBOutlet UITextField *field;
@property (nonatomic, strong) IBOutlet UIStepper *stepper;
@property (nonatomic, strong) IBOutlet UILabel *label;

@end
