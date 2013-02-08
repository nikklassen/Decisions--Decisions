//
//  ListViewController.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-11-23.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#define kRowMultiplier 33*[array count]

#import "ListViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "ListItem.h"
#import "ListModel.h"

@implementation ListViewController

@synthesize picker;
@synthesize managedObjectContext = _managedObjectContext;

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
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] listMOC];
    NSLog(@"%@", self.managedObjectContext);
    [picker setDataSource: self];
    [picker setUserInteractionEnabled: NO];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear: animated];
    
    array = [NSMutableArray new];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"ListModel"
                                              inManagedObjectContext: _managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];

    for (ListModel *list in fetchedObjects) {
        for (ListItem *item in list.items) {
            [array addObject: item.value];
        }
    }
    
    [picker reloadAllComponents];
    
    [picker selectRow: [array count] inComponent: 0 animated: NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) changePicker:(id)sender {
    
    int r = arc4random_uniform([array count]);
    
    // If the picker is at the top animated to the bottom and vice versa
    if ([picker selectedRowInComponent: 0] > kRowMultiplier - 10) {
        
        // Select the second occurance of the item, to simulate continuous loop
        [picker selectRow: r+[array count] inComponent: 0 animated: YES];
    } else {
        
        // Go to the second last occurance of the object
        [picker selectRow: (kRowMultiplier - [array count] + r) inComponent: 0 animated: YES];
    }
}

#pragma mark - Picker Data Source

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (component == 0) {
        
        // Return number of rows times a multiplier to create longer animation time
        return [array count] * kRowMultiplier;
    } else {
        return 0;
    }
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0) {
        // Modulus operator to create recurring values
        return array[row%[array count]];
    } else {
        return nil;
    }
}

@end
