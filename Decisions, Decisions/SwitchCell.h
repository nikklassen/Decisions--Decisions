//
//  SwitchCell.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-11-01.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface SwitchCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UISwitch *toggle;
@property IBOutlet UILabel *label;

- (IBAction) toggle:(id)sender;

@end
