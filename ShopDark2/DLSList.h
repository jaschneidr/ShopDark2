//
//  DLSList.h
//  ShopDark2
//
//  Created by Jason Schneider on 5/20/14.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLSListItem.h"


@interface DLSList : NSObject

@property NSString *listName;
@property NSDate *creationDate;
@property (nonatomic, retain) NSNumber *displayOrder;

@end
