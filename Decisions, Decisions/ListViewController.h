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

    NSManagedObjectContext *_managedObjectContext;
    NSMutableArray *array;
}

@property (nonatomic, strong) IBOutlet UIPickerView *picker;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

- (IBAction) changePicker:(id)sender;

@end
