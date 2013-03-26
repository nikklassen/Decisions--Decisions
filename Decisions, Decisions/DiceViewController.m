//
//  FirstViewController.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-25.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import "DiceViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "DiceModel.h"
#import "Die.h"

#define isCustom [diceConfig isEqualToString: @"custom"]
#define has6 (isCustom && numSides == 6)

int numDice, numSides;

@implementation DiceViewController

@synthesize diceField, diceView, rollsView, rollBtn, totalLbl;
@synthesize moc = _moc;

#pragma mark - Initilization Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SettingsViewController loadSettings];
    
    diceFaces = [[NSMutableArray alloc] init];
    rolls = [[NSMutableArray alloc] init];
    
    [self loadConfig];
    
    if (!isCustom) {
        
        // Get custom array of dice
        diceSides = _diceConfigs[diceConfig];
        
    } else {
        
        // Dice field only used in custom setting
        [diceField setText: [NSString stringWithFormat: @"%d", numDice]];
    }

    for (int i = 1; i <= 6; i++) {
        NSString *s = [NSString stringWithFormat:@"%d.png", i];
        UIImage *image = [UIImage imageNamed: s];
        [diceFaces addObject: image];
    }
    
    [diceView setAnimationImages: diceFaces];
    diceView.AnimationDuration = 0.8;
    
    defaultDieImage = [UIImage imageNamed: @"Default Die.png"];
    
    [diceView setImage: has6 ? [diceFaces objectAtIndex: 5] : defaultDieImage];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDidChange:) name:@"changeSettings" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configDidChange:) name:@"changeConfig" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addConfig:) name:@"addConfig" object: nil];
    
    rollsView.delegate = self;
    rollsView.dataSource = self;
    
    diceField.delegate = self;
    
    self.view.backgroundColor = [UIColor clearColor];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear: animated];
    
    if (!showTotal) [totalLbl setText: nil];
    
    if (settingsDidChange) {
        [rolls removeAllObjects];
        [rollsView reloadData];
        settingsDidChange = NO;
    }
    
    if (!isCustom || (isCustom && numSides != 6)) {
        [diceView setImage: defaultDieImage];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (int) sum: (id) a {
    int i = 0;
    for (id n in a) {
        i += [n intValue];
    }
    return i;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [diceField setText: [NSString stringWithFormat: @"%i", numDice]];
    
    if (has6 && rolls.count == 0) {
        [diceView setImage: [diceFaces objectAtIndex: 5]];
    }
    
    // If a sum can/should be re-calculated on loading the view (if showTotal was previously off)
    if (showTotal && ((rolls.count && (numSides != 6 || !isCustom)) || (isCustom && rolls.count > 1))) {
        [totalLbl setText: [NSString stringWithFormat: @"Total: %d", [self sum: rolls]]];
    }
    
    [self becomeFirstResponder];
}

- (void)loadConfig {
    
    // Set up the dice configurations
    _moc = [appDelegate diceMOC];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DiceModel"
                                              inManagedObjectContext: _moc];
    [fetchRequest setEntity:entity];
    
    _diceConfigs = [NSMutableDictionary new];
    NSError *error;
    NSArray *fetchedObjects = [_moc executeFetchRequest:fetchRequest error:&error];

    for (DiceModel *model in fetchedObjects) {
        NSMutableArray *a = [NSMutableArray new];
        for (Die *d in model.dice) {
            [a addObject: d.sides];
        }
        NSLog(@"%@: %@", model.name, model.numDice);
        // Once the configuration is loaded the sides should be immutable and replaced when changed
        [_diceConfigs setObject: [NSArray arrayWithArray: a] forKey: model.name];
        
    }
    
    NSLog(@"%@", _diceConfigs);
    
    numDice = [_diceConfigs[diceConfig] count];
    if (numDice > 1 && !isCustom) {
        numSides = -1;
        diceSides = _diceConfigs[diceConfig];
    } else {
        numSides = [_diceConfigs[diceConfig][0] intValue];
    }
}


#pragma mark - Notification Selectors

- (void) settingsDidChange:(NSNotification*) notification {
    
    NSDictionary *d = notification.userInfo;
    if ([d[@"config"] isEqualToString: @"custom"]) {
        numDice = d[@"numDice"];
        numSides = d[@"numSides"];
    } else {
        numDice = d[@"numDice"];
        numSides = -1;
        diceSides = _diceConfigs[@"config"];
    }
}

-(void) configDidChange:(NSNotification *) notification {
    
    NSDictionary *d = notification.userInfo;

    NSString *config = d[@"config"];
    if (_diceConfigs[config]) {
        numDice = [_diceConfigs[config] count];
        if ([config isEqualToString: @"custom"]) {
            numSides = [_diceConfigs[config][0] intValue];
        } else {
            numSides = -1;
            diceSides = _diceConfigs[config];
        }

        [diceView setImage: defaultDieImage];
    } else {
        // This will only happen if new configs aren't being added properly
        NSLog(@"%@", _diceConfigs);
        abort();
    }
    
    [rolls setArray: nil];
    [rollsView reloadData];
    [totalLbl setText: nil];
    
}

-(void) addConfig:(NSNotification *) notification {
    
    [_diceConfigs setObject: notification.userInfo[@"dice"] forKey: [notification.userInfo[@"config"] lowercaseString]];
    
}

#pragma mark - Rolling Methods

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ( event.subtype == UIEventSubtypeMotionShake ) {
        [self roll: nil];
    }
    
    if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
        [super motionEnded:motion withEvent:event];
    }
}

- (IBAction) roll:(id)sender {
    
    if ([diceField isEditing]) {
        [self textFieldShouldReturn: diceField];
    }
    
    // Disable button to prevent multiple rolls at once
    rollBtn.enabled = NO;
    
    if (has6) {
        if (![diceView isAnimating]) {
            [diceView startAnimating];
            [UIView commitAnimations];
        }
    }
    
    NSThread *thread = [[NSThread alloc] initWithTarget: self selector: @selector(stopRoll) object: nil];
    [thread start];
}

- (void) stopRoll {
    
    if (has6) {
        [NSThread sleepForTimeInterval: 1];
    }
    
    [rolls removeAllObjects];

    for (int i = 0; i < numDice; i++) {
        if (!isCustom) {
            [rolls addObject: @(arc4random_uniform([[diceSides objectAtIndex: i] intValue])+1)];
        } else {
            [rolls addObject: @(arc4random_uniform(numSides)+1)];
        }
    }

    if (numSides == 6) {
        [diceView stopAnimating];
        [diceView setImage: [diceFaces objectAtIndex: [[rolls objectAtIndex: 0] intValue]-1 ]];
    }
    
    rollBtn.enabled = YES;
    
    if (showTotal && numDice > 1) {
        
        NSEnumerator *e = [rolls objectEnumerator];
        id anObject;
        int sum = 0;
        
        while (anObject = [e nextObject]) {
            sum += [anObject intValue];
        }
        
        [totalLbl setText: [NSString stringWithFormat: @"Total: %d", sum]];
    } else {
        
        // Only clear the total when the dice are rolled again
        [totalLbl setText: nil];
    }
    [rollsView reloadData];
}

- (IBAction) quickRoll:(id)sender {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Quick Roll"
                                                    message: [NSString stringWithFormat: @"%i", (arc4random_uniform([sender tag])+1)]
                                                   delegate: nil
                                          cancelButtonTitle: @"Dismiss"
                                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark -
#pragma mark Text field delegate
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if (isCustom) {
        return YES;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Current configuration does not allow this action" delegate: nil cancelButtonTitle: @"Dimiss" otherButtonTitles: nil];
        [alert show];
        
        return NO;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //if ([diceConfig isEqualToString: @"default"] || isCustom) {
        numDice = textField.text.intValue;
    /*} else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Current configuration does not allow this action" delegate: nil cancelButtonTitle: @"Dimiss" otherButtonTitles: nil];
        [alert show];
        
        [textField setText: [NSString stringWithFormat: @"%i", numDice]];
    }*/
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (numDice == 1 && has6){
        return 0;
    } else if (isCustom) {
        return rolls.count;
    } else if (rolls.count > 0) {
        return rolls.count + 1;
    } else {
        return 0;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.textAlignment = NSTextAlignmentCenter;

    if (isCustom && numDice > 1 && numSides == 6) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Additional Rolls";
        } else {
            cell.textLabel.text = [NSString stringWithFormat: @"%d: %@", numSides, [rolls objectAtIndex: indexPath.row]];
        }
    } else {
        
        // Custom with other # of sides
        if (isCustom) {
            cell.textLabel.text = [NSString stringWithFormat: @"%d: %@", numSides, [rolls objectAtIndex: indexPath.row]];
        } else {
            if (indexPath.row == 0) {
                cell.textLabel.text = (rolls.count == 1) ? @"Roll" : @"Rolls";
            // Code for handling configs with varying numbers of sides
            } else {
                cell.textLabel.text = [NSString stringWithFormat: @"%d: %@", [diceSides[indexPath.row - 1] intValue], [rolls objectAtIndex: (indexPath.row-1)]];
            }
        }
    }
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate
/*
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 // Navigation logic may go here. Create and push another view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
 // ...
 // Pass the selected object to the new view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 [detailViewController release];
 }
 */


@end
