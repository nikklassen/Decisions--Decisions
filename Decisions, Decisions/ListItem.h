//
//  ListItem.h
//  Decisions, Decisions
//
//  Created by Nik Klassen on 2013-02-07.
//  Copyright (c) 2013 Nik Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ListModel;

@interface ListItem : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) ListModel *list;

@end
