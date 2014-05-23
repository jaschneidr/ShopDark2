//
//  DLSListItem.h
//  ShopDark2
//
//  Created by Jason Schneider on 5/20/14.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLSListItem : NSManagedObject

@property NSString *itemName;
@property BOOL *completed;
@property (nonatomic, retain) NSNumber *displayOrder;

@end
