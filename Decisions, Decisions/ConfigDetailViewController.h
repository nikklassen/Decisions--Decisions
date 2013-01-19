//
//  ConfigDetailViewController.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-11-04.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConfigViewController;
@class SettingsViewController;

@interface ConfigDetailViewController : UITableViewController <UIAlertViewDelegate>

- (IBAction) add:(id)sender;
- (IBAction) save:(id)sender;

@end
