//
//  SwitchCell.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-11-01.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import "SwitchCell.h"
#import "SettingsViewController.h"

@implementation SwitchCell

@synthesize label, toggle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (IBAction) toggle:(id)sender {
    
    showTotal = [sender isOn];
}

 
@end
