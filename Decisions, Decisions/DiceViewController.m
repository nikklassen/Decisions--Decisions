//
//  FirstViewController.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-25.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import "DiceViewController.h"
#import "SettingsViewController.h"

#define has6 ([diceConfig isEqualToString: @"Custom"] && numSides == 6) //|| ([diceSides containsObject: [NSNumber numberWithInt: 6]])

int numDice, numSides;

@implementation DiceViewController

@synthesize diceField, diceView, rollsView, rollBtn, totalLbl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SettingsViewController loadSettings];
    
    diceFaces = [[NSMutableArray alloc] init];
    rolls = [[NSMutableArray alloc] init];
    
    if (![diceConfig isEqualToString: @"Custom"] && ![diceConfig isEqualToString: @"default"]) {
        
        // Get custom array of dice
        diceSides = [[NSMutableArray alloc] initWithArray: [currentConfig objectForKey:@"dice"]];
        
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
    diceView.AnimationDuration = .5;
    
    if (numSides == 6) {
        [diceView setImage: [diceFaces objectAtIndex: 5]];
    }
    
    defaultDieImage = [UIImage imageNamed: @"Default Die.png"];
    
    //totalLbl.textAlignment = NSTextAlignmentCenter;
    
    rollsView.delegate = self;
    rollsView.dataSource = self;
    
    diceField.delegate = self;
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear: animated];
    
    NSLog(@"%d", settingsDidChange);
    
    [diceField setText: [NSString stringWithFormat: @"%i", numDice]];

    if (!(has6)) {
        [diceView setImage: defaultDieImage];
        if (![diceConfig isEqualToString: @"Custom"]) {
            [diceSides setArray: [currentConfig objectForKey: @"dice"]];
            numSides = -1;
        }
    } else {
        [diceView setImage: [diceFaces objectAtIndex: 5]];
    }
    
    if (settingsDidChange) {
        [rolls removeAllObjects];
        [rollsView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if (!([diceConfig isEqualToString: @"default"] || [diceConfig isEqualToString: @"Custom"])) {
            [rolls addObject: [NSNumber numberWithInt: (arc4random_uniform([[diceSides objectAtIndex: i] intValue])+1)]];
        } else {
            [rolls addObject: [NSNumber numberWithInt: (arc4random_uniform(numSides)+1)]];
        }
    }
    
    if (numSides == 6) {
        [diceView stopAnimating];
        [diceView setImage: [diceFaces objectAtIndex: [[rolls objectAtIndex: 0] intValue]-1 ]];
    }
    
    rollBtn.enabled = YES;
    
    if (showTotal) {
        
        NSEnumerator *e = [rolls objectEnumerator];
        id anObject;
        int sum = 0;
        
        while (anObject = [e nextObject]) {
            sum += [anObject intValue];
        }
        
        [totalLbl setText: [NSString stringWithFormat: @"Dice total = %i", sum]];
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
    if ([diceConfig isEqualToString: @"default"] || [diceConfig isEqualToString: @"Custom"]) {
        return YES;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Current configuration does not allow this action" delegate: nil cancelButtonTitle: @"Dimiss" otherButtonTitles: nil];
        [alert show];
        
        return NO;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //if ([diceConfig isEqualToString: @"default"] || [diceConfig isEqualToString: @"Custom"]) {
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
    if ([diceConfig isEqualToString: @"default"]){
        return 0;
    } else {
        return rolls.count;
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
    
    // Handling for "custom" when numSides is 6 and numDice > 1
    if ([diceConfig isEqualToString: @"Custom"] && numDice > 1 && numSides == 6) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Additional Rolls";
        } else {
            cell.textLabel.text = [NSString stringWithFormat: @"%d: %@", numSides, [rolls objectAtIndex: indexPath.row]];
        }
    }
    
    else {
        
        // Custom with other # of sides
        if ([diceConfig isEqualToString: @"Custom"] && numDice > 1) {
            cell.textLabel.text = [NSString stringWithFormat: @"%d: %@", numSides, [rolls objectAtIndex: indexPath.row]];
        } else {
            // Code for handling configs with varying numbers of sides
            cell.textLabel.text = [NSString stringWithFormat: @"%d: %@", [[diceSides objectAtIndex: indexPath.row] intValue], [rolls objectAtIndex: indexPath.row]];
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
