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
@property BOOL singleList;
@property DLSListItem *listItem;
@property DLSList *tappedList;
@property (weak, nonatomic) IBOutlet UILabel *windowTitle;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *listItemsTableView;
@property (weak, nonatomic) IBOutlet UIButton *showHideButton;
@property (weak, nonatomic) IBOutlet UIButton *returnToListsButton;
@property (nonatomic, getter = isEditing) BOOL editing;

@end



@implementation DLSViewController

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
    // fetch all parent objects
    
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
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.returnToListsButton.enabled = NO;
    self.lists = [[NSMutableArray alloc] init];
    self.windowTitle.textColor = [UIColor whiteColor];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
    if (self.singleList)
    {
        self.windowTitle.text = self.tappedList.listName;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.singleList)
    {
        self.returnToListsButton.enabled = YES;
        self.returnToListsButton.hidden = NO;
        self.showHideButton.enabled = YES;
        self.showHideButton.hidden = NO;
    }
    else
    {
        self.returnToListsButton.hidden = YES;
        self.showHideButton.hidden = YES;
    }
    [self.tableView reloadData];
    
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
        return [self.listItems count];
    }
    else
    {
        return [self.lists count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLSList *listAtIndex = [self.lists objectAtIndex:indexPath.row];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    NSArray *itemsInListAtIndex = [[listAtIndex.itemsInList allObjects] sortedArrayUsingDescriptors:@[sort]];
    
    if (self.singleList)
    {
        NSString *cellIdentifier = @"listItemPrototype";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (!(itemsInListAtIndex.count == 0))
        {
            DLSListItem *listItem = [itemsInListAtIndex objectAtIndex:indexPath.row];
            // Set text according to list name
            [cell.textLabel setText:[NSString stringWithFormat:@"%@", [listItem valueForKey:@"itemName"]]];
            // Customize font, text color, and size
            cell.textLabel.textColor = [UIColor whiteColor];
            UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size: 12.0];
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
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size: 12.0];
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
        
        
        // Set the value for completed upon tapping a cell
        
        BOOL completed = [[tappedItem valueForKey:@"completed"] boolValue];
        if (completed) {
            [tappedItem setValue:[NSNumber numberWithBool:NO] forKey:@"completed"];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self saveStatus:tappedItem];
        }
        else
        {
            [tappedItem setValue:[NSNumber numberWithBool:YES] forKey:@"completed"];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self saveStatus:tappedItem];
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
        DLSListItem *objectToMove = [self.lists objectAtIndex:sourceIndexPath.row];
        [self.listItems removeObjectAtIndex:sourceIndexPath.row];
        [self.listItems insertObject:objectToMove atIndex:destinationIndexPath.row];
        
        //    NSInteger sourceIndex = sourceIndexPath.row;
        NSInteger destinationIndex = destinationIndexPath.row;
        NSValue *rowNumber = [self convertNSIntegerToNSValue:&destinationIndex];
        [objectToMove setValue:rowNumber forKey:@"displayOrder"];
        [self.tableView reloadData];
    }
    DLSList *objectToMove = [self.lists objectAtIndex:sourceIndexPath.row];
    [self.lists removeObjectAtIndex:sourceIndexPath.row];
    [self.lists insertObject:objectToMove atIndex:destinationIndexPath.row];
    
    //    NSInteger sourceIndex = sourceIndexPath.row;
    NSInteger destinationIndex = destinationIndexPath.row;
    NSValue *rowNumber = [self convertNSIntegerToNSValue:&destinationIndex];
    [objectToMove setValue:rowNumber forKey:@"displayOrder"];
    [self.tableView reloadData];
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (self.singleList)
        {
            // Delete Object from the database
            [context deleteObject:[self.listItems objectAtIndex:indexPath.row]];
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't delete! %@ %@", error, [error localizedDescription]);
                return;
            }
            
            //Remove the toDo from the table View
            [self.listItems removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        else
        {
            // Delete Object from the database
            [context deleteObject:[self.lists objectAtIndex:indexPath.row]];
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't delete! %@ %@", error, [error localizedDescription]);
                return;
            }
            
            //Remove the toDo from the table View
            [self.lists removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
    
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if(!editing) {
        int i = 0;
        for(DLSList *list in self.lists) {
            list.displayOrder = [NSNumber numberWithInt:i++];
        }
        NSError *error = nil;
        [self.managedObjectContext save:&error];
    }
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
    // add gesture recognizer to recognize taps within the table view for keyboard dismissal
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.textField resignFirstResponder];
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


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSEntityDescription *fetchedListItems = [NSEntityDescription entityForName:@"ListItem" inManagedObjectContext:[self managedObjectContext]];
    NSEntityDescription *fetchedLists = [NSEntityDescription entityForName:@"List" inManagedObjectContext:[self managedObjectContext]];
    DLSListItem *placeholder = [[DLSListItem alloc] initWithEntity:fetchedListItems insertIntoManagedObjectContext:managedObjectContext];
    
    if ([[segue identifier] isEqualToString:@"loadShoppingList"])
    {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchListItemsRequest = [[NSFetchRequest alloc] init];
        NSSortDescriptor *displayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"belongsToList like %@", self.tappedList];
        NSError *error;
        DLSViewController *listView = [segue destinationViewController];
        
        listView.tappedList = self.tappedList;
        listView.singleList = YES;
        
        if (listView.listItems.count == 0)
        {
            listView.listItems = [[NSMutableArray alloc] init];
            listView.singleList = YES;
            listView.windowTitle.text = self.tappedList.listName;
            [placeholder setValue:@"Begin adding list items" forKey:@"itemName"];
            listView.listItems[0] = placeholder;
        }
        else
        {
            [fetchListItemsRequest setEntity:fetchedListItems];
            [fetchListItemsRequest setPredicate:predicate];
            [fetchListItemsRequest shouldRefreshRefetchedObjects];
            [fetchListItemsRequest setSortDescriptors:@[displayOrder]];
            listView.listItems = [[managedObjectContext executeFetchRequest:fetchListItemsRequest error:&error] mutableCopy];
            
            // access parent entity list's listName and set self.windowTitle.text to its value
            listView.singleList = YES;
            listView.windowTitle.text = self.tappedList.listName;
            listView.windowTitle.textColor = [UIColor whiteColor];
        }
        [listView.tableView reloadData];
        
    }
    
    else if ([[segue identifier] isEqualToString:@"keyboardReturn"])
    {
        if (sender == self.textField.delegate)
        {
            // Create and save a new managed object List
            DLSViewController *lists = [segue destinationViewController];
            DLSList *newList = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:[self managedObjectContext]];
            [newList setValue:self.textField.text forKey:@"listName"];
            [newList setValue:[NSNumber numberWithInt:[self.lists count]] forKey:@"displayOrder"];
            
            NSError *error = nil;
            if (![managedObjectContext save:&error])
            {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            lists.singleList = NO;
            [lists.tableView reloadData];
            return;
        }
    }
    else if ([[segue identifier] isEqualToString:@"keyboardReturnAddItem"])
    {
        DLSViewController *listView = [segue destinationViewController];
        listView.singleList = YES;
        
        if (self.textField.text.length > 0)
        {
            DLSViewController *listView = [segue destinationViewController];
            NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
            NSError *error;
            
            
            DLSListItem *newListItem = [NSEntityDescription insertNewObjectForEntityForName:@"ListItem" inManagedObjectContext:[self managedObjectContext]];
            
            
            [newListItem setValue:self.textField.text forKey:@"itemName"];
            [newListItem setValue:[NSNumber numberWithInt:[self.listItems count]] forKey:@"displayOrder"];
            [newListItem setValue:self.tappedList forKey:@"belongsToList"];
            
            if (![managedObjectContext save:&error])
            {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            listView.singleList = YES;
            [listView.tableView reloadData];
            return;
        }
    }
    else if ([[segue identifier] isEqualToString:@"returnToLists"])
    {
        DLSViewController *lists = [segue destinationViewController];
        lists.windowTitle.text = @"My ShopDark Lists";
        lists.singleList= NO;
        
        
        // fetch Lists from the persistent data store
        
        NSSortDescriptor *displayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSFetchRequest *fetchListsRequest = [[NSFetchRequest alloc] init];
        [fetchListsRequest setEntity:fetchedLists];
        [fetchListsRequest shouldRefreshRefetchedObjects];
        [fetchListsRequest setSortDescriptors:@[displayOrder]];
        lists.lists = [[managedObjectContext executeFetchRequest:fetchListsRequest error:nil] mutableCopy];
        return;
    }
    
    else
    {
        return;
    }
    
}

- (IBAction)returnToLists:(UIStoryboardSegue *)segue
{

}

- (IBAction)keyboardReturn:(UIStoryboardSegue *)segue
{

}

- (IBAction)keyboardReturnAddItem:(UIStoryboardSegue *)segue
{
    return;
}

- (IBAction)loadShoppingList:(UIStoryboardSegue *)segue
{

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

- (NSValue *)convertNSIntegerToNSValue:(NSInteger *)input
{
    NSValue *index = [NSNumber numberWithInt:*input];
    return index;
}

- (void)saveStatus:(NSManagedObject *)listItem
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}

-(void)dismissKeyboard
{
    [self.textField resignFirstResponder];
}


@end