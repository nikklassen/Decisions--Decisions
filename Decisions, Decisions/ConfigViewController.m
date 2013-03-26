//
//  ConfigViewController.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-11-01.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import "AppDelegate.h"
#import "DiceModel.h"
#import "Die.h"
#import "ListModel.h"
#import "ListItem.h"
#import "ConfigViewController.h"
#import "SettingsViewController.h"
#import "ConfigDetailViewController.h"

NSString *configToEdit = nil;
BOOL isNewConfig;

@interface ConfigViewController ()

@end

@implementation ConfigViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Set up displayed part of the configurations
    configNames = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear: animated];
    NSFetchRequest *request = [NSFetchRequest new];
    NSError *error;
    
    if (configNames.count) {
        [configNames removeAllObjects];
    }
    
    if (configType == kDiceSection) {
        [configNames insertObject: @"Custom" atIndex: 0];
    }
    
    //[configNames addObjectsFromArray: [configs allKeys]];
    //[configNames removeObject: @"Custom" inRange: NSMakeRange(1, configNames.count-1)];
    
    if (configType == kDiceSection) {
        
        NSManagedObjectContext *context = [appDelegate diceMOC];
        NSEntityDescription *d = diceEntity;
        [request setEntity: d];
        returnedModels = [context executeFetchRequest: request error: &error];
        
        for (DiceModel *model in returnedModels) {
            if (![model.name isEqualToString: @"custom"])
                [configNames addObject: [model.name capitalizedString]];
        }
        
    } else if (configType == kListSection) {
        
        NSManagedObjectContext *context = [appDelegate listMOC];
        NSEntityDescription *d = listEntity;
        [request setEntity: d];
        returnedModels = [context executeFetchRequest: request error: &error];
        
        for (ListModel *model in returnedModels) {
            [configNames addObject: [model.name capitalizedString]];
        }
    }
    
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    NSDictionary *userInfo = @{@"config": [diceConfig lowercaseString]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeConfig" object:nil userInfo:userInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (![tableView isEditing])
        return [configNames count]+1;
    else
        return [configNames count]-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Basic";
    UITableViewCell *cell;
    
    // Add new configuration tab
    if (indexPath.row == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier: @"Add" forIndexPath:indexPath];
        
        cell.textLabel.text = @"Add new configuration...";
        
        return cell;
        
    } else {
        
        // Configure the cell...
        if (configNames.count) {
            
            cell = [tableView dequeueReusableCellWithIdentifier: @"Basic" forIndexPath:indexPath];
            
            cell.textLabel.text = configNames[indexPath.row-1];

            if ([cell.textLabel.text isEqualToString: [diceConfig capitalizedString]] || [cell.textLabel.text isEqualToString: [listConfig capitalizedString]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                checkedCell = indexPath;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            if ([cell.textLabel.text isEqualToString: @"Custom"]) {
                cell.editingAccessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.row == 0 && indexPath.row == 1) {
        return NO;
    } else {
        return YES;
    }
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing: editing animated: animated];
    
    NSArray *addPath = @[[NSIndexPath indexPathForRow: 0 inSection:0],
                        [NSIndexPath indexPathForRow: 1 inSection:0]];
    
    if (editing) {
        
        [[self tableView] deleteRowsAtIndexPaths: addPath
                                withRowAnimation: UITableViewRowAnimationLeft];
    } else {
        
        [[self tableView] insertRowsAtIndexPaths: addPath
                                withRowAnimation: UITableViewRowAnimationLeft];
    }
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 || indexPath.row == 1) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (configType == kDiceSection) {
            // Delete the current model from the model
            for (DiceModel *model in returnedModels) {
                if ([[model.name capitalizedString] isEqualToString: [tableView cellForRowAtIndexPath: indexPath].textLabel.text]) {
                    [[appDelegate diceMOC] deleteObject: model];
                }
            }
            
            NSError *error;
            [[appDelegate diceMOC] save: &error];
            
            // Set diceConfig to selected configuration
            if (![[diceConfig capitalizedString] isEqualToString: [tableView cellForRowAtIndexPath: indexPath].textLabel.text]) {
                diceConfig = [configNames[indexPath.row-1] lowercaseString];
            } else {
                diceConfig = @"custom";
            }
            currentConfig = configs[diceConfig];
            
        } else {
            for (ListModel *model in returnedModels) {
                if ([[model.name capitalizedString] isEqualToString: [tableView cellForRowAtIndexPath: indexPath].textLabel.text]) {
                    [[appDelegate listMOC] deleteObject: model];
                }
            }
            
            NSError *error;
            [[appDelegate listMOC] save: &error];
            
            // Set diceConfig to selected configuration
            if (![[listConfig capitalizedString] isEqualToString: [tableView cellForRowAtIndexPath: indexPath].textLabel.text]) {
                listConfig = [configNames[indexPath.row-1] lowercaseString];
            } else {
                listConfig = @"custom";
            }
            currentList = lists[diceConfig];
        }
        
        checkedCell = indexPath;
        
        // Delete the row from the data source
        [configNames removeObjectAtIndex: indexPath.row+1];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    configToEdit = [[[tableView cellForRowAtIndexPath: indexPath] textLabel] text];
    isNewConfig = NO;
    
    [tableView setEditing: NO animated: NO];
    [self setEditing: NO];
    
    [self performSegueWithIdentifier: @"configDetail"
                              sender: self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath: indexPath];
    
    if (indexPath.row == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"New Configuration"
                                                        message: @"Enter a name for your new configuration"
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                              otherButtonTitles: @"Submit", nil];
        
        [alert setAlertViewStyle: UIAlertViewStylePlainTextInput];
        [alert show];
        
    } else if (configType == kDiceSection) {
        
        if (![indexPath isEqual: checkedCell]) {
            
            // Pause to allow "selection" to show
            [NSThread sleepForTimeInterval: 0.15];
            
            // Set diceConfig to selected configuration
            diceConfig = [configNames[indexPath.row-1] lowercaseString];
            currentConfig = configs[diceConfig];
            
            checkedCell = indexPath;
            
            [tableView reloadData];
            
        }
        
    } else if (configType == kListSection){
        
        if (![indexPath isEqual: checkedCell]) {
            // Pause to allow "selection" to show
            [NSThread sleepForTimeInterval: 0.15];
            
            // Set the list used by the picker to the selected list
            currentList = lists[selectedCell.textLabel.text];
    
            listConfig = configNames[indexPath.row-1];
            currentList = configs[listConfig];
            
            checkedCell = indexPath;
            [tableView reloadData];
        }
    }
    
    [selectedCell setSelected: NO];
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        configToEdit = [[alertView textFieldAtIndex: 0] text];
        isNewConfig = YES;

        [self performSegueWithIdentifier: @"configDetail"
                                  sender: self];
        
    }
    
}

@end
