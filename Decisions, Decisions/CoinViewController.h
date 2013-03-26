//
//  CoinViewController.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-25.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface CoinViewController : UIViewController <UITextFieldDelegate> {
    
    UIImageView *frontImageView, *backImageView;
    UIView *containerView;
    NSArray *coinImages;
    int numCoins;

    IBOutlet UITextField *_textField;
}

@property (nonatomic, strong) IBOutlet UIImageView *coinView;
@property (nonatomic, assign) IBOutlet UILabel *flipLabel;

-(IBAction) showSettingsWritten:(id)sender;
-(IBAction) flipCoin:(id)sender;
-(void) stopFlip;

@end
