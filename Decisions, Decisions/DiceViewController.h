//
//  FirstViewController.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-25.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface DiceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {

    NSMutableArray *diceFaces, *rolls, *diceSides;
    UIImage *defaultDieImage;
}

-(IBAction) roll:(id)sender;
-(void) stopRoll;
-(IBAction) quickRoll:(id)sender;

@property (nonatomic, assign) IBOutlet UITextField *diceField;
@property (nonatomic, assign) IBOutlet UIImageView *diceView;
@property (nonatomic, assign) IBOutlet UITableView *rollsView;
@property (nonatomic, strong) IBOutlet UIButton *rollBtn;
@property (nonatomic, strong) IBOutlet UILabel *totalLbl;

@end
