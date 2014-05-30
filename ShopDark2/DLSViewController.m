//
//  DLSViewController.m
//  ShopDark2
//
//  Created by Jason Schneider on 5/20/14.
//  Copyright (c) 2014 Jason Schneider. All rights reserved.
//

#import "DLSViewController.h"
#import "DLSList.h"
#import "DLSListItem.h"

@interface DLSViewController ()

@property NSMutableArray *lists;
@property NSMutableArray *listItems;
@property DLSList *tappedList;
@property (weak, nonatomic) IBOutlet UILabel *windowTitle;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *listItemsTableView;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;
@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (weak, nonatomic) IBOutlet UIButton *returnToListsButton;
@property (nonatomic, assign) id<UIGestureRecognizerDelegate> delegate;
@property BOOL singleList;
@property BOOL hide;
@property BOOL reorderingMode;
@end



@implementation DLSViewController

@synthesize reordering;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        return self;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    // fetch Lists from the persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSEntityDescription *parentLists = [NSEntityDescription entityForName:@"List" inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *getParentLists = [[NSFetchRequest alloc] init];
    [getParentLists setEntity:parentLists];
    
    // set sort and relationship keypaths for prefetching
    [getParentLists setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObject:@"itemsInList"]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    [getParentLists setSortDescriptors:@[sort]];
    [getParentLists shouldRefreshRefetchedObjects];
    self.lists = [[managedObjectContext executeFetchRequest:getParentLists error:nil] mutableCopy];
    
    // set the value of hide appropriately based on stored default
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hideCompleted"])
    {
        self.hide = YES;
        
        // set filtered array for self.listItems based on predicate
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSMutableArray *placeholderArray = [[NSMutableArray alloc] init];
        NSPredicate *hideCompleted = [NSPredicate predicateWithFormat:@"completed == %@", [NSNumber numberWithBool:NO]];
        placeholderArray = [[self.listItems filteredArrayUsingPredicate:hideCompleted] mutableCopy];
        [placeholderArray sortUsingDescriptors:@[sort]];
        self.listItems = placeholderArray;

    }
    else
    {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        self.listItems = [[[self.tappedList.itemsInList allObjects] sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    }
    
    
    
    if (self.singleList)
    {
        // Take care of placeholder text and color
        NSString *itemsPlaceholderText = @"Add a new item to the list";
        UIColor *placeholderTextColor = [UIColor whiteColor];
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:itemsPlaceholderText attributes:@{NSForegroundColorAttributeName: placeholderTextColor}];
        
        // deal with setting button states
        
        self.returnToListsButton.enabled = YES;
        self.returnToListsButton.hidden = NO;
        if (self.hide)
        {
            self.hideButton.enabled = NO;
            self.hideButton.hidden = YES;
            self.showButton.enabled = YES;
            self.showButton.hidden = NO;
        }
        else
        {
            self.hideButton.enabled = YES;
            self.hideButton.hidden = NO;
            self.showButton.enabled = NO;
            self.showButton.hidden = YES;
        }
    }
    else
    {
        // Take care of placeholder text and color
        NSString *listPlaceholderText = @"Add a new list";
        UIColor *placeholderTextColor = [UIColor whiteColor];
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:listPlaceholderText attributes:@{NSForegroundColorAttributeName: placeholderTextColor}];
        
        self.returnToListsButton.hidden = YES;
        self.returnToListsButton.enabled = NO;
        self.hideButton.hidden = YES;
        self.showButton.hidden = YES;
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.returnToListsButton.enabled = NO;
    self.windowTitle.textColor = [UIColor whiteColor];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
    if (self.singleList)
    {
        self.windowTitle.text = self.tappedList.listName;
    }
    if (!self.reordering.on)
    {
        [super setEditing:NO animated:YES];
        [self.reordering setOn:NO animated:YES];
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollToBottom];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/*
 ///
 ////
 /////
 ////// Table View
 /////
 ////
 ///
 */

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    // if list has been tapped, return shoppingList.listItems count
    if (self.singleList)
    {
        if (self.hide)
        {
            return [self.listItems count];
        }
        else
        {
            return [self.listItems count];
        }
    }
    else
    {
        return [self.lists count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.reordering.on)
    {
        [self.tableView setEditing:YES];
        self.hideButton.enabled = NO;
        self.showButton.enabled = NO;
    }
    else
    {
        [self.tableView setEditing:NO];
    }
    
    if (self.singleList)
    {
        NSString *cellIdentifier = @"listItemPrototype";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        
        // If the self.listItems array is populated, do the following
        if (!(self.listItems.count == 0))
        {
            DLSListItem *listItem = [self.listItems objectAtIndex:indexPath.row];
            // Set text according to list name
            [cell.textLabel setText:[NSString stringWithFormat:@"%@", [listItem valueForKey:@"itemName"]]];
            // Customize font, text color, and size
            cell.textLabel.textColor = [UIColor whiteColor];
            UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size: 15.0];
            cell.textLabel.font = cellFont;
            
            BOOL completed = [[listItem valueForKey:@"completed"] boolValue];
            if (completed)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        return cell;
    }
    
    else
    {
        NSString *cellID = @"listCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        DLSList *list = [self.lists objectAtIndex:indexPath.row];
        
        
        // Set text according to list name
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", [list valueForKey:@"listName"]]];
        // Customize font, text color, and size
        cell.textLabel.textColor = [UIColor whiteColor];
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size: 18.0];
        cell.textLabel.font = cellFont;
        return cell;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.singleList)
    {
        // If the item is tapped, set the completed value to TRUE
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        DLSListItem *tappedItem = [self.listItems objectAtIndex:indexPath.row];
        BOOL completed = [[tappedItem valueForKey:@"completed"] boolValue];
        if (completed) {
            [tappedItem setValue:[NSNumber numberWithBool:NO] forKey:@"completed"];
            [self saveStatus];

            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
        }
        else
        {
            [tappedItem setValue:[NSNumber numberWithBool:YES] forKey:@"completed"];
            [self saveStatus];
            
            if (self.hide) {
                [self.listItems removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            }
            else
            {
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
            }
        }
    }
    
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        self.tappedList = [self.lists objectAtIndex:indexPath.row];
        self.windowTitle.text = self.tappedList.listName;
        [self performSegueWithIdentifier:@"loadShoppingList" sender:self];
    }
}





//
///
////
///// Editing the tableView and textField
////
///
//



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Allow the item to be edited by returning YES or true
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Allow rows to be re-ordered, also iterates through all cells because once one has moved, all are re-indexed
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (self.singleList)
    {
        DLSListItem *objectToMove = [self.listItems objectAtIndex:sourceIndexPath.row];
        [self.listItems removeObjectAtIndex:sourceIndexPath.row];
        [self.listItems insertObject:objectToMove atIndex:destinationIndexPath.row];
        
        NSInteger destination = destinationIndexPath.row + 1;
        NSNumber *rowNumber = [NSNumber numberWithInteger:destination];
        [objectToMove setDisplayOrder:rowNumber];
        [self.tableView reloadData];
        
        int i = 0;
        for (DLSListItem *item in self.listItems)
        {
            item.displayOrder = [NSNumber numberWithInt:i++];
            [self saveStatus];
        }
    }
    else
    {
        DLSList *objectToMove = [self.lists objectAtIndex:sourceIndexPath.row];
        [self.lists removeObjectAtIndex:sourceIndexPath.row];
        [self.lists insertObject:objectToMove atIndex:destinationIndexPath.row];
    
        NSInteger destination = destinationIndexPath.row + 1;
        NSNumber *rowNumber = [NSNumber numberWithInteger:destination];
        [objectToMove setDisplayOrder:rowNumber];
        [self.tableView reloadData];
        
        int i = 0;
        for (DLSList *list in self.lists)
        {
            list.displayOrder = [NSNumber numberWithInt:i++];
            [self saveStatus];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.reordering.on)
    {
        return UITableViewCellEditingStyleNone;
    }
    else
    {
        return UITableViewCellEditingStyleDelete;
    }
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (self.singleList)
        {
            // Delete Object from the database
            [self.tappedList removeItemsInListObject:[self.listItems objectAtIndex:indexPath.row]];
            [self saveStatus];
            
            //Remove the item from the table View
            [self.listItems removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            
            // Update display order
            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
            NSArray *parentList = [[self.tappedList.itemsInList allObjects] sortedArrayUsingDescriptors:@[sort]];
            int i = 0;
            for (DLSListItem *item in parentList)
            {
                item.displayOrder = [NSNumber numberWithInt:i++];
            }
            
        }
        else
        {
            // Delete Object from the database
            [[self managedObjectContext] deleteObject:[self.lists objectAtIndex:indexPath.row]];
            [self saveStatus];
            
            //Remove the item from the table View
            [self.lists removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            
            // Update display Order
            int i = 0;
            for (DLSList *list in self.lists)
            {
                list.displayOrder = [NSNumber numberWithInt:i++];
            }
        }
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error = nil;
        [context save:&error];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if(!editing)
    {
        if (self.singleList) {
            int i = 0;
            for (DLSListItem *item in self.listItems)
            {
                item.displayOrder = [NSNumber numberWithInt:i++];
            }
        }
        else
        {
            int i = 0;
            for (DLSList *list in self.lists)
            {
                list.displayOrder = [NSNumber numberWithInt:i++];
            }
        }
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error = nil;
        [context save:&error];
    }
    [self.tableView reloadData];
}
 
 
//
//
// Text Field
//
//

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.singleList)
    {
        [self performSegueWithIdentifier:@"keyboardReturnAddItem" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"keyboardReturn" sender:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    NSString *blank = @"";
    UIColor *placeholderTextColor = [UIColor whiteColor];
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:blank attributes:@{NSForegroundColorAttributeName: placeholderTextColor}];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.textField endEditing:YES];
}



/*
 ///
 //// Segue/Nav
 ///
 */


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"loadShoppingList"])
    {
        NSSortDescriptor *displayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        DLSViewController *listView = [segue destinationViewController];
        listView.tappedList = self.tappedList;
        listView.singleList = YES;
        listView.listItems = [[[self.tappedList.itemsInList allObjects] sortedArrayUsingDescriptors:@[displayOrder]] mutableCopy];
        listView.windowTitle.text = self.tappedList.listName;
        listView.windowTitle.textColor = [UIColor whiteColor];
    }
    
    else if ([[segue identifier] isEqualToString:@"keyboardReturn"])
    {
        if ((sender == self.textField.delegate) && (self.textField.text.length > 0))
        {
            DLSList *newList = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:[self managedObjectContext]];
            NSUInteger displayOrder = [self.lists count] +1;
            
            
            [newList setValue:self.textField.text forKey:@"listName"];
            [newList setValue:[NSNumber numberWithInt:displayOrder] forKey:@"displayOrder"];
            [self saveStatus];
            return;
        }

    }
    
    else if ([[segue identifier] isEqualToString:@"keyboardReturnAddItem"])
    {
        if (sender == self.textField.delegate)
        {
            if (self.textField.text.length > 0)
            {
                DLSViewController *listView = [segue destinationViewController];
                NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
                DLSListItem *newListItem = [NSEntityDescription insertNewObjectForEntityForName:@"ListItem" inManagedObjectContext:[self managedObjectContext]];
                
                // Set display order
                NSUInteger displayOrder = [[self.tappedList.itemsInList allObjects] count] +1;
                
                [newListItem setValue:self.textField.text forKey:@"itemName"];
                [newListItem setValue:[NSNumber numberWithInt:displayOrder] forKey:@"displayOrder"];
                [newListItem setValue:[NSNumber numberWithBool:NO] forKey:@"completed"];
                [self.tappedList addItemsInListObject:newListItem];
                
                
                listView.singleList = YES;
                listView.hide = self.hide;
                listView.tappedList = self.tappedList;
                listView.listItems = [[[self.tappedList.itemsInList allObjects] sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                [self saveStatus];
                return;
            }
        }
        else
        {
            DLSViewController *listView = [segue destinationViewController];
            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
                
            if (self.hide)
            {
                listView.hide = self.hide;
                listView.singleList = YES;
                listView.tappedList = self.tappedList;
                listView.listItems = self.listItems;
            }
            else
            {
                listView.hide = self.hide;
                listView.singleList = YES;
                listView.tappedList = self.tappedList;
                listView.listItems = [[[self.tappedList.itemsInList allObjects] sortedArrayUsingDescriptors:@[sort]] mutableCopy];
            }
        }
    }
    
    else if ([[segue identifier] isEqualToString:@"hideCompleted"])
    {
        
        // set default appropriately
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"hideCompleted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        DLSViewController *listView = [segue destinationViewController];
        
        listView.hide = YES;
        listView.singleList = YES;
        listView.tappedList = self.tappedList;
        listView.listItems = self.listItems;
       
        
    }
    
    else if ([[segue identifier] isEqualToString:@"showCompleted"])
    {
        
        //set default appropriately
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:@"hideCompleted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        DLSViewController *listView = [segue destinationViewController];
        
        listView.hide = NO;
        listView.singleList = YES;
        listView.tappedList = self.tappedList;
        
    }
    
    else if ([[segue identifier] isEqualToString:@"returnToLists"])
    {
        DLSViewController *lists = [segue destinationViewController];
        
        lists.windowTitle.text = @"ShopDark Lists";
        lists.singleList = NO;
        lists.hide = NO;
        return;
    }

    else
    {
        return;
    }
    return;
}



/*
 ///
 ////
 /////
 ////// Helper Methods
 /////
 ////
 ///
 */

// set the managed object context
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)saveStatus
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }

}

- (void)scrollToBottom
{
    CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
    if ( bottomOffset.y > 0 ) {
        [self.tableView setContentOffset:bottomOffset animated:YES];
    }
}

-(void)dismissKeyboard
{
    [self.textField resignFirstResponder];
}

- (void)toggleReorder:(id)sender
{
    [self.tableView reloadData];
}

@end