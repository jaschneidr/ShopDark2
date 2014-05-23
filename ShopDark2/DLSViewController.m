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
@property NSString *cellIdentifier;
@property NSString *parentList;
@property DLSListItem *listItem;
@property DLSList *shoppingList;
@property (weak, nonatomic) IBOutlet UILabel *windowTitle;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *returnToListsButton;
@property (weak, nonatomic) IBOutlet UIButton *showHideButton;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.returnToListsButton.enabled = NO;
    self.lists = [[NSMutableArray alloc] init];
    self.parentList = [[NSString alloc] init];
    self.cellIdentifier = [[NSString alloc] init];

    self.tableView.backgroundColor = [UIColor blackColor];
    [self.tableView reloadData];
    // Do any additional setup after loading the view.

    if ([self.cellIdentifier isEqualToString:@"listItemsPrototype"])
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // fetch Lists from the persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSSortDescriptor *displayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    NSFetchRequest *fetchListsRequest = [[NSFetchRequest alloc] initWithEntityName:@"List"];
    [fetchListsRequest shouldRefreshRefetchedObjects];
    [fetchListsRequest setSortDescriptors:@[displayOrder]];
    self.lists = [[managedObjectContext executeFetchRequest:fetchListsRequest error:nil] mutableCopy];
    
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
    if ([self.cellIdentifier  isEqualToString:@"listItemsPrototype"])
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
    
    if ([self.cellIdentifier isEqualToString:@"listItemsPrototype"])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
        NSManagedObject *listItem = [self.listItems objectAtIndex:indexPath.row];
        
        
        // Set text according to list name
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", [listItem valueForKey:@"itemName"]]];
        // Customize font, text color, and size
        cell.textLabel.textColor = [UIColor whiteColor];
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size: 12.0];
        cell.textLabel.font = cellFont;
        return cell;
    }
    
    else
    {
        NSString *cellID = @"listCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        NSManagedObject *list = [self.lists objectAtIndex:indexPath.row];
        
        
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
    NSManagedObjectContext *context = [self managedObjectContext];
    if ([self.cellIdentifier isEqualToString:@"listItemsPrototype"])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        NSEntityDescription *descListItems = [NSEntityDescription insertNewObjectForEntityForName:@"ListItem" inManagedObjectContext:self.managedObjectContext];
        NSManagedObject *tappedItem = [[NSManagedObject alloc] initWithEntity:descListItems insertIntoManagedObjectContext:context];
        self.listItem = [[DLSListItem alloc] init];
        tappedItem = [self.lists objectAtIndex:indexPath.row];
        self.listItem.itemName = [tappedItem valueForKeyPath:@"itemName"];
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
        NSManagedObject *tappedItem = [self.lists objectAtIndex:indexPath.row];
        self.shoppingList = [[DLSList alloc] init];
        self.shoppingList.listName = [tappedItem valueForKey:@"listName"];
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
    NSManagedObject *objectToMove = [self.lists objectAtIndex:sourceIndexPath.row];
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
        
        if ([self.cellIdentifier isEqualToString:@"listItemPrototype"])
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
    [self performSegueWithIdentifier:@"keyboardReturn" sender:self];
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
    DLSListItem *placeholder = [[DLSListItem alloc] init];
    if ([[segue identifier] isEqualToString:@"loadShoppingList"])
    {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchListItemsRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *fetchedListItems = [NSEntityDescription entityForName:@"ListItem" inManagedObjectContext:managedObjectContext];
        NSSortDescriptor *displayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"belongsToList like %@", self.shoppingList.listName];
        NSError *error;
        
        if (self.listItems == nil)
        {
            self.listItems = [[NSMutableArray alloc] init];
            self.cellIdentifier = @"listItemsPrototype";
            self.windowTitle.text = self.shoppingList.listName;
            [self.tableView reloadData];
        }
        else
        {
            [fetchListItemsRequest setEntity:fetchedListItems];
            [fetchListItemsRequest setPredicate:predicate];
            [fetchListItemsRequest shouldRefreshRefetchedObjects];
            [fetchListItemsRequest setSortDescriptors:@[displayOrder]];
            self.listItems = [[managedObjectContext executeFetchRequest:fetchListItemsRequest error:&error] mutableCopy];
            
            // access parent entity list's listName and set self.windowTitle.text to its value
            self.cellIdentifier = @"listItemsPrototype";
            self.windowTitle.text = self.shoppingList.listName;
            [self.tableView reloadData];
        }
        
    }
    
    else if ([[segue identifier] isEqualToString:@"keyboardReturn"])
    {
        if (sender == self.textField.delegate)
        {
            
            if ((self.textField.text.length > 0) && ([self.cellIdentifier  isEqualToString:@"listCell"]))
            {
                NSManagedObjectContext *context = [self managedObjectContext];
                //Create and save a new Managed Object
                DLSViewController *destination = [segue destinationViewController];
                NSManagedObject *newList = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:context];
                [newList setValue:self.textField.text forKey:@"listName"];
                [newList setValue:[NSNumber numberWithInt:[destination.lists count]] forKey:@"displayOrder"];
                
                NSError *error = nil;
                if (![context save:&error])
                {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
            else if ((self.textField.text.length > 0) && ([self.cellIdentifier  isEqualToString:@"listItemsPrototype"]))
            {
                if ([placeholder.itemName isEqualToString:@"Begin adding new items"])
                {
                    [self.listItems removeObject:placeholder];
                }
                NSManagedObjectContext *context = [self managedObjectContext];
                //Create and save a new Managed Object
                DLSViewController *destination = [segue destinationViewController];
                NSManagedObject *newListItem = [NSEntityDescription insertNewObjectForEntityForName:@"ListItem" inManagedObjectContext:context];
                [newListItem setValue:self.textField.text forKey:@"itemName"];
                [newListItem setValue:[NSNumber numberWithInt:[destination.listItems count]] forKey:@"displayOrder"];
                
                NSError *error = nil;
                if (![context save:&error])
                {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
        }
    }
    else if ([[segue identifier] isEqualToString:@"returnToLists"])
    {
        self.windowTitle.text = @"My ShopDark Lists";
        self.cellIdentifier = @"listCell";
        // fetch Lists from the persistent data store
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSSortDescriptor *displayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSFetchRequest *fetchListsRequest = [[NSFetchRequest alloc] initWithEntityName:@"List"];
        [fetchListsRequest shouldRefreshRefetchedObjects];
        [fetchListsRequest setSortDescriptors:@[displayOrder]];
        self.lists = [[managedObjectContext executeFetchRequest:fetchListsRequest error:nil] mutableCopy];
    }
    
    else
    {
        return;
    }
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
