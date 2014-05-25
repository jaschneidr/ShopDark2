//
//  DLSList.h
//  ShopDark2
//
//  Created by Jason Schneider on 5/20/14.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLSListItem.h"


@interface DLSList : NSManagedObject

@property (nonatomic, strong) NSString *listName;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSNumber *displayOrder;

@end
