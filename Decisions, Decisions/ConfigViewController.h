//
//  ConfigViewController.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-11-01.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

extern NSString *configToEdit;
extern BOOL isNewConfig;

@interface ConfigViewController : UITableViewController <UIAlertViewDelegate> {
    
    NSMutableArray *configNames;
    NSArray *returnedModels;
    NSIndexPath *checkedCell;
    
}

@end
