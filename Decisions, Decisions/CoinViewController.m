//
//  SecondViewController.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-25.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import "CoinViewController.h"
#import "SettingsViewController.h"

@implementation CoinViewController

@synthesize coinView, flipLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    coinImages = [NSArray arrayWithObjects:[UIImage imageNamed: @"Tails.png"], [UIImage imageNamed: @"Heads.png"], nil];
    
    [coinView setAnimationImages: coinImages];
    coinView.AnimationDuration = .3;
    
    //[coinView setImage: [coinImages objectAtIndex: 0]];
    [coinView setImage: [UIImage imageNamed: @"Tails.png"]];
    
    [flipLabel setText: @""];
    
    self.view.backgroundColor = [UIColor clearColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) showSettingsWritten:(id)sender {
    
    NSDictionary *d1 = [[NSDictionary alloc] initWithContentsOfFile: diceSettingsPath];
    NSDictionary *d2 = [[NSDictionary alloc] initWithContentsOfFile: listsPath];
    
    NSLog(@"diceSettings = %@", d1);
    NSLog(@"lists = %@", d2);
}

- (IBAction) flipCoin:(id)sender {
    
    if (![coinView isAnimating]) {
        [coinView startAnimating];
    }
    
    NSThread *thread = [[NSThread alloc] initWithTarget: self selector: @selector(stopFlip) object: nil];
    [thread start];
}

- (void) stopFlip {
    
    [NSThread sleepForTimeInterval: 1];
    [coinView stopAnimating];
    
    int flip = arc4random_uniform(2);
    [coinView setImage: [coinImages objectAtIndex: flip]];
    
    if (numCoins > 1) {
        
        int tails = 0, heads = 0;
        
        for (int i = 0; i < numCoins-1; i++) {
            if (arc4random_uniform(2)) tails++;
            else heads++;
        }
        
        [flipLabel setText: [NSString stringWithFormat: @"Extra flip(s): Heads %i   Tails %i", heads, tails]];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    numCoins = textField.text.intValue;
}

@end
