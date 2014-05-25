//
//  DLSList.h
//  ShopDark2
//
//  Created by Jason Schneider on 5/25/14.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DLSListItem;

@interface DLSList : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * listName;
@property (nonatomic, retain) NSSet *itemsInList;
@end

@interface DLSList (CoreDataGeneratedAccessors)

- (void)addItemsInListObject:(DLSListItem *)value;
- (void)removeItemsInListObject:(DLSListItem *)value;
- (void)addItemsInList:(NSSet *)values;
- (void)removeItemsInList:(NSSet *)values;

@end
