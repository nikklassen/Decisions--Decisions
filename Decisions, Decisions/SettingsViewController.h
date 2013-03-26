//
//  SettingsViewController.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-28.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import <UIKit/UIKit.h>

// Contents of diceSettings.plist & lists.plist
extern NSMutableDictionary *diceSettings;
extern NSMutableDictionary *lists;

// User Defaults
extern NSUserDefaults *prefs;

// Contains the list of configurations, including custom, not including default
extern NSMutableDictionary *configs;

// Holds information about the current configuration, all methods should access this method
extern NSMutableDictionary *currentConfig;

// Mutable array to hold current list
extern NSMutableArray *currentList;

// diceConfig is simply the key for currentConfig
extern NSString *diceConfig, *listConfig, *diceSettingsPath, *listsPath;

extern BOOL settingsDidChange, showTotal;
extern int numDice, numSides, configType;

@interface SettingsViewController : UITableViewController <UITextFieldDelegate> {
    
    enum Sections {
        kDiceSection = 0,
        kListSection,
        NUM_SECTIONS
    };
    
    enum CellTags {
        kNumDice = 0,
        kNumSides,
        NUM_TAGS
    };
    
    enum Switches {
        kSaveDialog = 0
    };
    
    NSArray *settings;
}

@property (nonatomic, retain) NSManagedObjectContext *diceContext;

+ (void) loadSettings;

@end
