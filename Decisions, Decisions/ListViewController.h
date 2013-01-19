//
//  ListViewController.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-11-23.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface ListViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {

    NSArray *array;
}

@property (nonatomic, strong) IBOutlet UIPickerView *picker;

- (IBAction) changePicker:(id)sender;

@end
