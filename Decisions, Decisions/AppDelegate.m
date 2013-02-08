//
//  AppDelegate.m
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2012-10-25.
//  Copyright (c) 2012 Nik Klassen. All rights reserved.
//

#import "AppDelegate.h"
#import "ListViewController.h"
#import "ListModel.h"
#import "ListItem.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Override point for customization after application launch.
    // Felt background attributed to
    // <div xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/" about="http://subtlepatterns.com/felt/"><span property="dct:title">Subtle Patterns</span> (<a rel="cc:attributionURL" property="cc:attributionName" href="http://subtlepatterns.com">Subtle Patterns</a>) / <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/">CC BY-SA 3.0</a></div>
    _window.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"felt.png"]];

    // Override point for customization after application launch.
    //UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    //ListViewController *controller = (ListViewController *)navigationController.childViewControllers[2];
    //controller.managedObjectContext = self.managedObjectContext;
}
/*
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Felt background attributed to
    // <div xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/" about="http://subtlepatterns.com/felt/"><span property="dct:title">Subtle Patterns</span> (<a rel="cc:attributionURL" property="cc:attributionName" href="http://subtlepatterns.com">Subtle Patterns</a>) / <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/">CC BY-SA 3.0</a></div>
    _window.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"felt.png"]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        //UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
    } else {
        //UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    }
    
    NSLog(@"%@", self.managedObjectContext);
    listViewController.managedObjectContext = self.managedObjectContext;
    NSLog(@"%@", listViewController);
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;

    ListModel *list = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"ListModel"
                                      inManagedObjectContext:context];
    
    list.name = @"Softies";
    NSArray *a = @[@"Nik Klassen", @"Dan Reynolds", @"Clarisse Schneider", @"Josh Netterfield"];
    for (int i = 0; i < a.count; i++) {
        ListItem *item = [NSEntityDescription
                          insertNewObjectForEntityForName:@"ListItem"
                          inManagedObjectContext:context];
        item.value = a[i];
        [list addItemsObject: item];
    }
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    // Test listing all FailedBankInfos from the store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ListModel"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (ListModel *info in fetchedObjects) {
        NSLog(@"Name: %@", info.name);
        for (ListItem *items in info.items) {
            NSLog(@"\tItem: %@", items.value);
        }
    }
    
    return YES;
}
*/
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *context = _listMOC;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)listMOC {
	
    if (_listMOC != nil) {
        return _listMOC;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self listPSC];
    if (coordinator != nil) {
        _listMOC = [NSManagedObjectContext new];
        [_listMOC setPersistentStoreCoordinator: coordinator];
    }
    return _listMOC;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)diceMOC {
	
    if (_diceMOC != nil) {
        return _diceMOC;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self dicePSC];
    if (coordinator != nil) {
        _diceMOC = [NSManagedObjectContext new];
        [_diceMOC setPersistentStoreCoordinator: coordinator];
    }
    return _diceMOC;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)listMOM {
	
    if (_listMOM != nil) {
        return _listMOM;
    }
    _listMOM = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _listMOM;
}

- (NSManagedObjectModel *)diceMOM {
	
    if (_diceMOM != nil) {
        return _diceMOM;
    }
    _diceMOM = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _diceMOM;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)dicePSC {
	
    if (_dicePSC != nil) {
        return _dicePSC;
    }
    
	NSString *storePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DiceConfigs.sqlite"];
	/*
	 Set up the store.
	 For the sake of illustration, provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"DiceConfigs" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error;
    _dicePSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self diceMOM]];
    if (![_dicePSC addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
    
    return _dicePSC;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)listPSC {
	
    if (_listPSC != nil) {
        return _listPSC;
    }
    
	NSString *storePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Lists.sqlite"];
	/*
	 Set up the store.
	 For the sake of illustration, provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Lists" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error;
    _listPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self listMOM]];
    if (![_listPSC addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
    
    return _listPSC;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
