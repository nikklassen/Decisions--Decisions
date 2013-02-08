//
//  SettingsViewController.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-28.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import "SettingsViewController.h"
#import "StepperCell.h"
#import "SwitchCell.h"
#import "DiceViewController.h"

#define ROW_HEIGHT 44

NSMutableDictionary *diceSettings = nil, *lists = nil, *currentConfig = nil, *configs = nil;
NSMutableArray *currentList = nil;
NSString *diceConfig = nil, *listConfig = nil, *diceSettingsPath = nil, *listsPath = nil;
BOOL settingsDidChange, showTotal;
int numDice = 0, numSides = 0, configType = 0;

@implementation SettingsViewController

+ (void) loadSettings {
    
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    
    /*diceSettingsPath = [[NSString alloc] init];
    listsPath = [[NSString alloc] init];
    
    diceSettingsPath = [[NSBundle mainBundle] pathForResource:@"diceSettings" ofType:@"plist"];
    listsPath = [[NSBundle mainBundle] pathForResource:@"lists" ofType:@"plist"];
    
    if ([fileManager fileExistsAtPath: diceSettingsPath]) {
        
        diceSettings = [[NSMutableDictionary alloc] initWithContentsOfFile: diceSettingsPath];
        configs = [[NSMutableDictionary alloc] initWithDictionary: [diceSettings objectForKey: @"configs"]];
        
    } else {
        NSLog(@"diceSettings not found");
    }
    
    if ([fileManager fileExistsAtPath: listsPath]) {
        
        lists = [[NSMutableDictionary alloc] initWithContentsOfFile: listsPath];
    }
    
    diceConfig = diceSettings[@"lastConfig"];
    
    listConfig = lists[@"lastList"];
    currentList = lists[listConfig];
    
    if ([diceConfig isEqualToString: @"default"]) {
        numDice = 1;
        numSides = 6;
    } else {
        currentConfig = configs[diceConfig];
        numDice = [[currentConfig objectForKey: @"numDice"] intValue];
    }
    
    showTotal = [[diceSettings objectForKey: @"showTotal"] boolValue];*/
}

- (id)initWithStyle:(UITableViewStyle)style
{
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    settings = @[@"Custom dice configurations", @"Num of Dice", @"Sides on Dice", @"Sum dice values", @"Custom Lists"];
    
    settingsDidChange = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    
    if ([diceConfig isEqualToString: @"Custom"] && settingsDidChange) {
        
        numDice = [[currentConfig objectForKey: @"numDice"] intValue];
        numSides = [[currentConfig objectForKey: @"numSides"] intValue];
        
    }
    
    [self.tableView reloadData];
    
    [super viewDidAppear: animated];
}

#pragma mark - Settings adjustments
-(IBAction) save:(id)sender {
    
    if ([diceConfig isEqualToString: @"Custom"]) {
        
        [currentConfig setObject: @(numDice) forKey: @"numDice"];
        [currentConfig setObject: @(numSides) forKey: @"numSides"];
        
        // Write over the "custom" configuration in the configs dictionary
        [configs setObject: [NSDictionary dictionaryWithDictionary: currentConfig] forKey: @"Custom"];
        
    } else {
        
        numDice = [[currentConfig objectForKey: @"numDice"] intValue];
    }
    
    if (settingsDidChange) {
        // Write (revised) list of configs
        [diceSettings setObject: configs forKey: @"configs"];
    
        // Rewrite settings to plist
        [diceSettings writeToFile: diceSettingsPath atomically: YES];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Save Complete"
                                                    message: @"Settings have been successfully saved."
                                                   delegate: nil
                                          cancelButtonTitle: @"Dismiss"
                                          otherButtonTitles: nil];
    
    [alert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections using last item of enum
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == kDiceSection) {
        return 4;
    } else if (section == kListSection) {
        return 1;
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == kDiceSection ) {
        return @"Dice Settings";
    } else if (section == kListSection) {
        return @"List Settings";
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    
    if (indexPath.section == kDiceSection) {
        
        if (indexPath.row == 0) {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Basic" forIndexPath:indexPath];
            
            // Configure the cell...
            cell.textLabel.text = [settings objectAtIndex: indexPath.row];
            cell.tag = kDiceSection;
            
            return cell;
            
        } else if (indexPath.row != 3) {
            
            StepperCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Stepper" forIndexPath:indexPath];
            
            cell.label.text = [settings objectAtIndex: indexPath.row];
            
            switch (indexPath.row) {
                case 1:
                    (numDice != -1) ? (cell.stepper.value = numDice) : (cell.stepper.value = 0);
                    cell.field.text = [NSString stringWithFormat: @"%i", (int)cell.stepper.value];
                    cell.stepper.tag = kNumDice;
                    break;
                case 2:
                    (numSides != -1) ? (cell.stepper.value = numSides) : (cell.stepper.value = 0);
                    cell.field.text = [NSString stringWithFormat: @"%i", (int)cell.stepper.value];
                    cell.stepper.tag = kNumSides;
                default:
                    break;
            }
            
            if (![diceConfig isEqualToString: @"Custom"]) {
                [cell.stepper setEnabled: NO];
                [cell.field setEnabled: NO];
            } else {
                [cell.stepper setEnabled: YES];
                [cell.field setEnabled: YES];
            }
            
            [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            
            return cell;
            
        } else {
            
            SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Switch" forIndexPath:indexPath];
            
            cell.label.text = [settings objectAtIndex: indexPath.row];
            
            [cell.toggle setOn: [diceSettings[@"showTotal"] boolValue] animated: NO];
            
            return cell;
            
        }
        
    } else if (indexPath.section == kListSection) {
        
        CellIdentifier = @"Basic";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        cell.textLabel.text = [settings objectAtIndex: indexPath.row + 4];
        cell.tag = kListSection;
        
        return cell;
    }
    else {
        
        UITableViewCell *cell;
        return cell;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 3) {
        return ROW_HEIGHT;
    } else {
        return ROW_HEIGHT*2;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    
    if (indexPath.row == 0) {
        configType = cell.tag;
        [self performSegueWithIdentifier: @"config" sender: cell];
    }
    
    [cell setSelected: NO animated: NO];
}

@end
