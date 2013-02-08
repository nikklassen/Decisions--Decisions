//
//  AppDelegate.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-25.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import <UIKit/UIKit.h>

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
- (NSURL *)applicationDocumentsDirectory;

@end
