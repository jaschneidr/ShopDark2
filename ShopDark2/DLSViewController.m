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

@property NSArray *fetchedLists;
@property NSArray *fetchedListItems;
@property NSMutableArray *lists;
@property NSMutableArray *listItems;
@property DLSListItem *listItem;
@property DLSList *shoppingList;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, assign) IBOutlet UITableView *tableView;

@end

@implementation DLSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lists = [[NSMutableArray alloc] init];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
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
    
    // fetch List Items from the persistent data store if displaying a List in the tableView
    
    //reload the table, and scroll to the bottom
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender == self.textField.delegate)
    {
        if (self.textField.text.length > 0)
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
        else
        {
            return;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self performSegueWithIdentifier:@"keyboardReturn" sender:self];
    return YES;
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
    
    
    
    // else return lists count
    
    return [self.lists count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
// If displaying list of lists
///
////
    static NSString *CellIdentifier = @"listCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSManagedObject *list = [self.lists objectAtIndex:indexPath.row];
    
    
    // Set text according to list name
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", [list valueForKey:@"listName"]]];
    // Customize font, text color, and size
    cell.textLabel.textColor = [UIColor whiteColor];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size: 12.0];
    cell.textLabel.font = cellFont;
    return cell;
    
// If displaying a shopping list
///
////
    /*
    static NSString *CellIdentifier = @"listCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSManagedObject *listItem = [self.shoppingList objectAtIndex:indexPath.row];
    
    
    // Set text according to list name
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", [list valueForKey:@"itemName"]]];
    // Customize font, text color, and size
    cell.textLabel.textColor = [UIColor whiteColor];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size: 12.0];
    cell.textLabel.font = cellFont;
    return cell;
    
    
    // Configure the cell to display properly with a check mark for completed items and without for incomplete items
    BOOL completed = [[toDoItem valueForKey:@"completed"] boolValue];
    if (completed)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
     */
    
}


#pragma mark - Table view delegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSManagedObject *tappedItem = [self.lists objectAtIndex:indexPath.row];
    
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

*/




//
///
////
///// Editing the tableView
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

- (void)saveStatus:(NSManagedObject *)toDoItem
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}

-(void)loadInitialData
{
    DLSList *list1 = [[DLSList alloc] init];
    list1.listName = @"Wegmans";
    [self.lists addObject:list1];
    DLSList *list2 = [[DLSList alloc] init];
    list2.listName = @"Guitar Center";
    [self.lists addObject:list2];
}

@end
