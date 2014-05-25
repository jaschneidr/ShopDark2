//
//  DLSListItem.h
//  ShopDark2
//
//  Created by Jason Schneider on 5/25/14.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DLSList;

@interface DLSListItem : NSManagedObject

@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) DLSList *belongsToList;

@end
