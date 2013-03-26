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
#import "DiceModel.h"
#import "Die.h"
#import "ListModel.h"
#import "ListItem.h"
#import "AppDelegate.h"

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Discard" style: UIBarButtonItemStylePlain target: self action: @selector(save:)];
    backButton.tag = 1;
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    items = [NSMutableArray new];
    
    _shouldLoadNewData = YES;
    
}

-(void) viewWillAppear:(BOOL)animated {

    self.navigationItem.title = configToEdit;
    
    [super viewWillAppear: animated];
    if (!isNewConfig && _shouldLoadNewData) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSError *error;
        
        if (configType == kDiceSection) {
            
            _edittingContext = [appDelegate diceMOC];
            
            // Get all the side values from the current configuration
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"DiceModel"
                                                      inManagedObjectContext: [appDelegate diceMOC]];
            [fetchRequest setEntity:entity];
            
            NSArray *fetchedObjects = [_edittingContext executeFetchRequest:fetchRequest error:&error];
            for (DiceModel *model in fetchedObjects) {
                if ([[model.name capitalizedString] isEqualToString: configToEdit]) {
                    _edittingModel = model;
                    for (Die *die in model.dice) {
                        [items addObject: die.sides];
                    }
                }
            }
            
        } else if (configType == kListSection) {
            
            _edittingContext = [appDelegate listMOC];
            
            // Get all the list values from the current configuration
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"ListModel"
                                                      inManagedObjectContext: [appDelegate listMOC]];
            [fetchRequest setEntity:entity];
            
            NSArray *fetchedObjects = [_edittingContext executeFetchRequest:fetchRequest error:&error];
            for (ListModel *model in fetchedObjects) {
                if ([[model.name capitalizedString] isEqualToString: configToEdit]) {
                    _edittingModel = model;
                    for (ListItem *item in model.items) {
                        [items addObject: item.value];
                    }
                }
            }
        }
        [self.tableView reloadData];
    } else if (isNewConfig) {
        if (configType == kDiceSection) {
            _edittingContext = [appDelegate diceMOC];
            _edittingModel = [NSEntityDescription insertNewObjectForEntityForName: @"DiceModel" inManagedObjectContext: _edittingContext];
            ((DiceModel *)_edittingModel).name = [configToEdit lowercaseString];
        } else if (configType == kListSection) {
            _edittingContext = [appDelegate listMOC];
            _edittingModel = [NSEntityDescription insertNewObjectForEntityForName: @"ListModel" inManagedObjectContext: _edittingContext];
            ((ListModel *)_edittingModel).name = [configToEdit lowercaseString];
        }
    }
    
    _shouldLoadNewData = NO;
}

- (void) viewWillDisappear:(BOOL)animated {
    
    if (self.tableView.isEditing) {
        [self setEditing: NO animated: NO]; 
    }
    
    [super viewWillDisappear: animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button methods
- (IBAction) add:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: (configType == kDiceSection) ? @"Add New Die" : @"Add New Item"
                                                    message: (configType == kDiceSection) ? @"Enter the number of sides for this dice" : @"Enter new item"
                                                   delegate: self
                                          cancelButtonTitle: @"Cancel"
                                          otherButtonTitles: @"Add", nil];
    [alert setAlertViewStyle: UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [[alert textFieldAtIndex:0] becomeFirstResponder];
    alert.tag = 0;
    [alert show];
}

- (IBAction) save:(id)sender {
    
    if ([sender tag] != 1) {
        
        if (configType == kDiceSection) {
            
            DiceModel *model = (DiceModel *)_edittingModel;
            model.name = [(DiceModel *)_edittingModel name];
            if (!isNewConfig) {
                [model removeDice: model.dice];
            }
            model.numDice = @(0);
            for (NSNumber *n in items) {
                Die *d = [NSEntityDescription insertNewObjectForEntityForName: @"Die" inManagedObjectContext: _edittingContext];
                d.sides = n;
                [model addDiceObject: d];
                model.numDice = @([model.numDice intValue]+1);
            }
            
            NSError *error;
            [_edittingContext save: &error];
            
            NSDictionary *d = @{@"config":configToEdit, @"dice":[NSArray arrayWithArray: items]};
            [[NSNotificationCenter defaultCenter] postNotificationName: @"addConfig" object: nil userInfo: d];
            
            
        } else if (configType == kListSection) {
            
            ListModel *model = (ListModel *)_edittingModel;
            model.name = [(DiceModel *)_edittingModel name];
            if (!isNewConfig) {
                [model removeItems: model.items];
            }
            model.numItems = @(0);
            for (NSString *s in items) {
                ListItem *li = [NSEntityDescription insertNewObjectForEntityForName: @"ListItem" inManagedObjectContext: _edittingContext];
                li.value = s;
                [model addItemsObject: li];
                model.numItems = @([model.numItems intValue]+1);
            }
            
            NSError *error;
            [_edittingContext save: &error];
            
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Configuration Saved" message: @"Your configuration has been saved successfully" delegate: nil cancelButtonTitle: @"Okay" otherButtonTitles: nil];
        [alert show];
        
    } else {
        [_edittingContext rollback];
    }
    
    _shouldLoadNewData = YES;
    
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
    
    if (editing) {
        
        [[self tableView] deleteRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: 0 inSection:0]]
                                withRowAnimation: UITableViewRowAnimationLeft];
    } else {
        
        [[self tableView] insertRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: 0 inSection:0]]
                                withRowAnimation: UITableViewRowAnimationLeft];
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSLog(@"%@", indexPath);
        
        [items removeObjectAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted: NO animated: YES];
}

#pragma mark - Alert view delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // Add new item alert view
    if (alertView.tag == 0) {
        if (buttonIndex == 1) {
            if (configType == kDiceSection) {
                int sides = [[[alertView textFieldAtIndex: 0] text] intValue];
                if (sides > 0) [items addObject: @(sides)];
            } else if (configType == kListSection) {
                [items addObject: [[alertView textFieldAtIndex: 0] text]];
            }
        }
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.tableView reloadData];
}

@end
