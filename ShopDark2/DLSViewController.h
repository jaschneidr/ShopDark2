//
//  DLSViewController.h
//  ShopDark2
//
//  Created by Jason Schneider on 5/20/14.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLSViewController : UIViewController

<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISwitch *reordering;

- (IBAction)toggleReorder:(id)sender;

@end
