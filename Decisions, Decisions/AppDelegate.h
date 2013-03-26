//
//  AppDelegate.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-25.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//
@class SettingsViewController;

#import <UIKit/UIKit.h>
#define appDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define diceEntity [NSEntityDescription entityForName: @"DiceModel" inManagedObjectContext: [appDelegate diceMOC]];
#define listEntity [NSEntityDescription entityForName: @"ListModel" inManagedObjectContext: [appDelegate listMOC]];
@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    NSManagedObjectContext *_listMOC;
    NSManagedObjectContext *_diceMOC;
    
    NSPersistentStoreCoordinator *_listPSC;
    NSPersistentStoreCoordinator *_dicePSC;
    
    NSManagedObjectModel *_listMOM;
    NSManagedObjectModel *_diceMOM;
    
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *listMOC;
@property (readonly, strong, nonatomic) NSManagedObjectContext *diceMOC;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *dicePSC;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *listPSC;

@property (readonly, strong, nonatomic) NSManagedObjectModel *listMOM;
@property (readonly, strong, nonatomic) NSManagedObjectModel *diceMOM;

- (void)saveContext;
- (void)createEntities;
- (NSString *)applicationDocumentsDirectory;

@end
