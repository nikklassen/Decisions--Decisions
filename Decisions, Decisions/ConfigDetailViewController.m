//
//  ConfigDetailViewController.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-11-04.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import "ConfigDetailViewController.h"
#import "ConfigViewController.h"
#import "SettingsViewController.h"

@interface ConfigDetailViewController () {
    
    NSMutableArray *items;
    
}

@end

@implementation ConfigDetailViewController

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
    
    self.navigationItem.title = configToEdit;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Discard" style: UIBarButtonItemStylePlain target: self action: @selector(save:)];
    backButton.tag = 1;
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    if (!isNewConfig) {
        if (configType == kDiceSection) {
            items = [[NSMutableArray alloc] initWithArray: [[configs objectForKey: configToEdit] objectForKey: @"dice"]];
        } else if (configType == kListSection) {
            items = [[NSMutableArray alloc] initWithArray: [configs objectForKey: configToEdit]];
        }
    } else {
        items = [[NSMutableArray alloc] init];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button methods
- (IBAction) add:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: (configType == kDiceSection) ? @"Add New Die" : @"Add New Item"
                                                    message: (configType == kDiceSection) ? @"Enter the number of sides for this dice" : @"Enter new item name"
                                                   delegate: self
                                          cancelButtonTitle: @"Cancel"
                                          otherButtonTitles: @"Add", nil];
    [alert setAlertViewStyle: UIAlertViewStylePlainTextInput];
    [alert show];
}

- (IBAction) save:(id)sender {
    
    if ([sender tag] != 1) {
        
        if (configType == kDiceSection) {
            
            NSDictionary *dict = @{@"dice" : items,
            @"numDice" : @(items.count)};
            
            [configs setObject: dict forKey: configToEdit];
            
            //[diceSettings setObject: configs forKey: @"configs"];
            diceSettings[@"configs"] = configs;
            
            // Rewrite settings to plist
            [diceSettings writeToFile: diceSettingsPath atomically: YES];
            
            settingsDidChange = YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Configuration Saved" message: @"Your configuration has been saved successfully" delegate: nil cancelButtonTitle: @"Okay" otherButtonTitles: nil];
            [alert show];
            
            if ([diceConfig isEqualToString: configToEdit]) {
                currentConfig = [[diceSettings objectForKey: @"configs"] objectForKey: configToEdit];
            }
            
        } else if (configType == kListSection) {
            
            configs[configToEdit] = items;
            
            lists[configToEdit] = items;
            
            [lists writeToFile: listsPath atomically: YES];
            
            settingsDidChange = YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Configuration Saved" message: @"Your configuration has been saved successfully" delegate: nil cancelButtonTitle: @"Okay" otherButtonTitles: nil];
            [alert show];
            
            if ([listConfig isEqualToString: configToEdit]) {
                currentList = lists[configToEdit];
            }
            
        }
        
    }
    
    [self.navigationController popViewControllerAnimated: YES];
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
    if (![tableView isEditing]) {
        return items.count+1;
    } else {
        return items.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    (indexPath.row != 0) ? (CellIdentifier = @"Basic") : (CellIdentifier = @"Controls");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if ([CellIdentifier isEqualToString: @"Basic"]) {
        if (configType == kDiceSection) {
            cell.textLabel.text = [NSString stringWithFormat: @"%@ sided dice", [items objectAtIndex: indexPath.row-1]];
        } else {
            cell.textLabel.text = items[indexPath.row-1];
        }        
    }
    return cell;
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing: editing animated: animated];
    
    NSArray *addPath = @[[NSIndexPath indexPathForRow: 0 inSection:0]];
    
    if (editing) {
        
        [[self tableView] deleteRowsAtIndexPaths: addPath
                                withRowAnimation: UITableViewRowAnimationLeft];
    } else {
        
        [[self tableView] insertRowsAtIndexPaths: addPath
                                withRowAnimation: UITableViewRowAnimationLeft];
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [items removeObjectAtIndex: indexPath.row];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    id temp;
    
    temp = [items objectAtIndex: toIndexPath.row];
    [items setObject: [items objectAtIndex: fromIndexPath.row] atIndexedSubscript: toIndexPath.row];
    [items setObject: temp atIndexedSubscript: fromIndexPath.row];
    
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    if (indexPath.row == 0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted: NO animated: YES];
}

#pragma mark - Alert view delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        if (configType == kDiceSection) {
            [items addObject: @([[[alertView textFieldAtIndex: 0] text] intValue])];
        } else {
            [items addObject: [[alertView textFieldAtIndex: 0] text]];
        }
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.tableView reloadData];
}

@end
