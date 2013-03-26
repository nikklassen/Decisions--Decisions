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
    NSMutableArray *a = [NSMutableArray new];
    for (int i = 1; i <= 4; i++) {
        [a addObject: [UIImage imageNamed: [NSString stringWithFormat: @"Heads%d.png", i]]];
    }
    for (int i = 4; i >= 1; i--) {
        [a addObject: [UIImage imageNamed: [NSString stringWithFormat: @"Tails%d.png", i]]];
    }
    for (int i = 1; i <= 4; i++) {
        [a addObject: [UIImage imageNamed: [NSString stringWithFormat: @"Tails%d.png", i]]];
    }
    for (int i = 4; i >= 1; i--) {
        [a addObject: [UIImage imageNamed: [NSString stringWithFormat: @"Heads%d.png", i]]];
    }
    coinImages = a;
    
    [coinView setAnimationImages: coinImages];
    coinView.AnimationDuration = 0.5;
    coinView.animationRepeatCount = 0;
    
    [coinView setImage: [coinImages objectAtIndex: 0]];
    
    [flipLabel setText: @""];
    
    self.view.backgroundColor = [UIColor clearColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ( event.subtype == UIEventSubtypeMotionShake ) {
        [self flipCoin: nil];
    }
    
    if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
        [super motionEnded:motion withEvent:event];
    }
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
        
        CGRect rect = coinView.frame;
        
        [UIView beginAnimations: nil context:NULL];
        [UIView animateWithDuration: 1 animations: ^{
            coinView.frame = CGRectMake(rect.origin.x - rect.size.width*0.1, rect.origin.y - rect.size.height*0.1, rect.size.height*1.2f, rect.size.height*1.2f);
        } completion: ^(BOOL finished){
            [UIView animateWithDuration: 1 animations: ^{
                coinView.frame = rect;
            }];
        }];
        [UIView commitAnimations];
        
        NSThread *thread = [[NSThread alloc] initWithTarget: self selector: @selector(stopFlip) object: nil];
        [thread start];
    }
}

- (void) stopFlip {
    
    [NSThread sleepForTimeInterval: 1];
    [coinView stopAnimating];
    
    int flip = arc4random_uniform(2);
    [coinView setImage: [coinImages objectAtIndex: flip*7]];
    
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
    [self becomeFirstResponder];
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    numCoins = textField.text.intValue;
}

@end
