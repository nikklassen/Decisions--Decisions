//
//  DiceModel.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2013-02-08.
//  Copyright (c) 2013 Nik Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Die;

@interface DiceModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numDice;
@property (nonatomic, retain) NSSet *dice;
@end

@interface DiceModel (CoreDataGeneratedAccessors)

- (void)addDiceObject:(Die *)value;
- (void)removeDiceObject:(Die *)value;
- (void)addDice:(NSSet *)values;
- (void)removeDice:(NSSet *)values;

@end
