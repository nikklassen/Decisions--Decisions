//
//  Die.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2013-02-11.
//  Copyright (c) 2013 Nik Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DiceModel;

@interface Die : NSManagedObject

@property (nonatomic, retain) NSNumber * sides;
@property (nonatomic, retain) DiceModel *model;

@end
