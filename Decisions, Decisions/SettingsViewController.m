//
//  SettingsViewController.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-28.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "StepperCell.h"
#import "SwitchCell.h"
#import "DiceModel.h"
#import "Die.h"

#define ROW_HEIGHT 44

NSMutableDictionary *diceSettings = nil, *lists = nil, *currentConfig = nil, *configs = nil;
NSMutableArray *currentList = nil;
NSUserDefaults *prefs = nil;
NSString *diceConfig = nil, *listConfig = nil, *diceSettingsPath = nil, *listsPath = nil;
BOOL settingsDidChange, showTotal;
int numDice = 0, numSides = 0, configType = 0;

@implementation SettingsViewController

+ (void) loadSettings {
    
    NSString *userDefaultsValuesPath =[[NSBundle mainBundle] pathForResource:@"appDefaults"
																	  ofType:@"plist"];
    
	NSDictionary *userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile: userDefaultsValuesPath];
    
	[[NSUserDefaults standardUserDefaults] registerDefaults: userDefaultsValuesDict];
    
	if (![[NSUserDefaults standardUserDefaults] synchronize])
		NSLog(@"not successful in writing the default prefs");
    
	prefs = [NSUserDefaults standardUserDefaults];
	
	diceConfig = [prefs stringForKey: @"lastDice"];
    listConfig = [prefs stringForKey: @"lastList"];
    showTotal = [prefs boolForKey: @"showTotal"];
    
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
    
    if ([diceConfig isEqualToString: @"custom"] && settingsDidChange) {
        
        numDice = [[currentConfig objectForKey: @"numDice"] intValue];
        numSides = [[currentConfig objectForKey: @"numSides"] intValue];
        
    }
    
    [self.tableView reloadData];
    
    [super viewDidAppear: animated];
}

#pragma mark - Settings adjustments
-(void)viewWillDisappear:(BOOL)animated {
    
    NSDictionary *userInfo;
    
    if ([diceConfig isEqualToString: @"custom"]) {
        
        NSManagedObjectContext *context = [appDelegate diceMOC];
        
        NSFetchRequest *request = [NSFetchRequest new];
        [request setEntity: [NSEntityDescription entityForName: @"DiceModel" inManagedObjectContext:context]];
        
        NSError *error;
        NSArray *a = [context executeFetchRequest: request error: &error];
        
        for (DiceModel *model in a) {
            if ([model.name isEqualToString: @"custom"]) {
                [model removeDice: model.dice];
                NSMutableSet *dice = [NSMutableSet new];
                for (int i = 0; i < numDice; i++) {
                    Die *d = [NSEntityDescription insertNewObjectForEntityForName: @"Die" inManagedObjectContext:context];
                    d.sides = @(numSides);
                    [dice addObject: d];
                }
                [model addDice: dice];
            }
        }
        
        userInfo = @{@"numDice": @(numDice), @"numSides": @(numSides), @"config": @"custom"};
    }
    
#warning Add logic for setting changing configurations
    
    [super viewWillDisappear: animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections using last item of enum
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
                    cell.field.tag = kNumDice;
                    cell.stepper.tag = kNumDice;
                    break;
                case 2:
                    (numSides != -1) ? (cell.stepper.value = numSides) : (cell.stepper.value = 0);
                    cell.field.text = [NSString stringWithFormat: @"%i", (int)cell.stepper.value];
                    cell.field.tag = kNumSides;
                    cell.stepper.tag = kNumSides;
                default:
                    break;
            }
            cell.field.delegate = self;
            
            if (![diceConfig isEqualToString: @"custom"]) {
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
            
            [cell.toggle setOn: showTotal animated: NO];
            
            return cell;
            
        }
        
    } else if (indexPath.section == kListSection) {
        
        CellIdentifier = @"Basic";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
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

-(BOOL) textFieldShouldReturn:(UITextField *)textField {

    if (textField.tag == kNumDice) {
        numDice = textField.text.intValue;
    } else if (textField.tag == kNumSides) {
        numSides = textField.text.intValue;
    }
    [textField resignFirstResponder];
    return YES;
}

@end
