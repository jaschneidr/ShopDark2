//
//  DLSList.m
//  ShopDark2
//
//  Created by Jason Schneider on 5/20/14.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import "DLSList.h"
#import "DLSListItem.h"

@implementation DLSList

@dynamic listName;
@dynamic creationDate;
@dynamic displayOrder;

-(void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setCreationDate:[NSDate date]];
}

@end
