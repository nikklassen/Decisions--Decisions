//
//  ListViewController.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-11-23.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#define kRowMultiplier 33*[listItems count]

#import "ListViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "ListItem.h"
#import "ListModel.h"

@implementation ListViewController

@synthesize picker;
@synthesize managedObjectContext = _moc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.managedObjectContext = [appDelegate listMOC];

    [picker setDataSource: self];
    [picker setUserInteractionEnabled: NO];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear: animated];
    
    listItems = [NSMutableArray new];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"ListModel"
                                              inManagedObjectContext: _moc];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [_moc executeFetchRequest:fetchRequest error:&error];

    for (ListModel *list in fetchedObjects) {
        if ([listConfig isEqualToString: list.name]) {
            for (ListItem *item in list.items) {
                [listItems addObject: item.value];
            }
        }
    }
    
    [picker reloadAllComponents];
    
    [picker selectRow: [listItems count] inComponent: 0 animated: NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) changePicker:(id)sender {
    
    int r = arc4random_uniform([listItems count]);
    
    // If the picker is at the top animated to the bottom and vice versa
    if ([picker selectedRowInComponent: 0] > kRowMultiplier - 10) {
        
        // Select the second occurance of the item, to simulate continuous loop
        [picker selectRow: r+[listItems count] inComponent: 0 animated: YES];
    } else {
        
        // Go to the second last occurance of the object
        [picker selectRow: (kRowMultiplier - [listItems count] + r) inComponent: 0 animated: YES];
    }
}

#pragma mark - Picker Data Source

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (component == 0) {
        
        // Return number of rows times a multiplier to create longer animation time
        return [listItems count] * kRowMultiplier;
    } else {
        return 0;
    }
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0) {
        // Modulus operator to create recurring values
        return listItems[row%[listItems count]];
    } else {
        return nil;
    }
}

@end
