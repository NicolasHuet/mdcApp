//
//  BIDReservationsVC.m
//  mdcApp
//
//  Created by Nicolas Huet on 2015-05-21.
//  Copyright (c) 2015 MaitreDeChai. All rights reserved.
//

#import "BIDReservationsVC.h"
#import "MDCAppDelegate.h"

@implementation BIDReservationsVC

@synthesize orderArray;
@synthesize filteredOrderArray;
@synthesize orderSearchbar;
@synthesize orderSyncArray;
@synthesize orderItemsArray;

MDCAppDelegate *appDelegate;
sqlite3 *database;
Order *currentOrder;
Order *currOrder;
NSData *jsonData;
NSData *jsonDataForModified;
NSData *jsonDataReservations;
NSData *jsonDataForModifiedReservations;

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"mdc.sqlite"];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.orderArray = [[NSMutableArray alloc] init];
    int numberOfRows = 0;
    
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + orderSearchbar.bounds.size.height;
    self.tableView.bounds = newBounds;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *localquery = [NSString stringWithFormat:@"SELECT * FROM LocalReservations ORDER BY commID DESC"];
    
    sqlite3_stmt *localstatement;
    if (sqlite3_prepare_v2(database, [localquery UTF8String],
                           -1, &localstatement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(localstatement) == SQLITE_ROW) {
            //int row = sqlite3_column_int(statement, 0);
            
            char *columnData;
            int columnIntValue;
            NSString * commID;
            NSString * commStatutID;
            NSString * commRepID;
            NSString * commClientID;
            NSString * commClientName;
            NSString * commCommentaire;
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 3);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(localstatement, 5);
            if(columnData == nil){
                commCommentaire = @"";
            } else {
                commCommentaire = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            NSString *clientQuery = [NSString stringWithFormat:@"SELECT * FROM Clients WHERE clientID = %@",commClientID];
            
            sqlite3_stmt *clientStmt;
            if (sqlite3_prepare_v2(database, [clientQuery UTF8String],
                                   -1, &clientStmt, nil) == SQLITE_OK)
            {
                char *columnData;
                //int columnIntValue;
                NSString * clientID;
                NSString * clientName;
                while (sqlite3_step(clientStmt) == SQLITE_ROW) {
                    
                    /*
                     1-clientID INT PRIMARY KEY,
                     2-clientName TEXT,
                     3-clientAdr1 TEXT,
                     4-clientAdr2 TEXT,
                     5-clientVille TEXT,
                     6-clientProv TEXT,
                     7-clientCodePostal TEXT,
                     8-clientTelComp TEXT,
                     9-clientContact TEXT,
                     10-clientEmail TEXT,
                     11-clientTel1 TEXT,
                     */
                    
                    columnData = (char *)sqlite3_column_text(clientStmt, 0);
                    clientID = [[NSString alloc] initWithUTF8String:columnData];
                    
                    columnData = (char *)sqlite3_column_text(clientStmt, 1);
                    clientName = [[NSString alloc] initWithUTF8String:columnData];
                    
                }
                commClientName = clientName;
                
            }
            sqlite3_finalize(clientStmt);
            
            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commClientName = commClientName;
            orderToAdd.commCommentaire = commCommentaire;
            orderToAdd.commDataSource = @"local";
            
            [self.orderArray addObject:orderToAdd];
            
            numberOfRows = numberOfRows + 1;
            
        }
        sqlite3_finalize(localstatement);
    }
    
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Reservations ORDER BY commID DESC"];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String],
                           -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //int row = sqlite3_column_int(statement, 0);
            
            char *columnData;
            int columnIntValue;
            NSString * commID;
            NSString * commStatutID;
            NSString * commRepID;
            NSString * commClientID;
            NSString * commClientName;
            NSString * commCommentaire;
            NSString * commIsDraftModified;
            
            /*
             1-commID INT PRIMARY KEY,
             2-commStatutID INT,
             3-commRepID INT,
             4-commIDSAQ TEXT,
             5-commClientID INT,
             6-commTypeClntID INT,
             7-commCommTypeLivrID INT,
             8-commDateFact TEXT,
             9-commDelaiPickup INT,
             10-commDatePickup TEXT,
             11-commClientJourLivr TEXT,
             12-commPartSuccID INT,
             13-commCommentaire TEXT,
             14-commLastUpdated TEXT,
             15-commIsDraftModified INT
             */
            
            columnIntValue = (int)sqlite3_column_int(statement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 3);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(statement, 5);
            if(columnData == nil){
                commCommentaire = @"";
            } else {
                commCommentaire = [[NSString alloc] initWithUTF8String:columnData];
            }
            columnIntValue = (int)sqlite3_column_int(statement, 14);
            commIsDraftModified = [NSString stringWithFormat:@"%i",columnIntValue];
            
            NSString *clientQuery = [NSString stringWithFormat:@"SELECT * FROM Clients WHERE clientID = %@",commClientID];
            
            sqlite3_stmt *clientStmt;
            if (sqlite3_prepare_v2(database, [clientQuery UTF8String],
                                   -1, &clientStmt, nil) == SQLITE_OK)
            {
                char *columnData;
                //int columnIntValue;
                NSString * clientID;
                NSString * clientName;
                while (sqlite3_step(clientStmt) == SQLITE_ROW) {
                    
                    /*
                     1-clientID INT PRIMARY KEY,
                     2-clientName TEXT,
                     3-clientAdr1 TEXT,
                     4-clientAdr2 TEXT,
                     5-clientVille TEXT,
                     6-clientProv TEXT,
                     7-clientCodePostal TEXT,
                     8-clientTelComp TEXT,
                     9-clientContact TEXT,
                     10-clientEmail TEXT,
                     11-clientTel1 TEXT,
                     */
                    
                    columnData = (char *)sqlite3_column_text(clientStmt, 0);
                    clientID = [[NSString alloc] initWithUTF8String:columnData];
                    
                    columnData = (char *)sqlite3_column_text(clientStmt, 1);
                    clientName = [[NSString alloc] initWithUTF8String:columnData];
                    
                }
                commClientName = clientName;
                
            }
            sqlite3_finalize(clientStmt);
            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commClientName = commClientName;
            orderToAdd.commCommentaire = commCommentaire;
            orderToAdd.commIsDraftModified = commIsDraftModified;
            orderToAdd.commDataSource = @"backend";
            
            [self.orderArray addObject:orderToAdd];
            
            numberOfRows = numberOfRows + 1;
            
        }
        sqlite3_finalize(statement);
    }
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.tableView.rowHeight = 70;
    self.clearsSelectionOnViewWillAppear = NO;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    self.filteredOrderArray = [NSMutableArray arrayWithCapacity:[orderArray count]];
    
    // Reload the table
    [[self tableView] reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [filteredOrderArray count];
    } else {
        return orderArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"orderCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Display recipe in the table cell
    
    Order *order = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        order = [filteredOrderArray objectAtIndex:indexPath.row];
    } else {
        order = [orderArray objectAtIndex:indexPath.row];
    }
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    
    UILabel *clientNameLabel = (UILabel *)[cell viewWithTag:101];
    clientNameLabel.text = order.commClientName;
    
    UILabel *commIDLabel = (UILabel *)[cell viewWithTag:106];
    if([order.commDataSource  isEqual: @"local"]){
        commIDLabel.text = @"N/A";
    }else{
        commIDLabel.text = order.commID;
    }
    
    NSString *query;
    sqlite3_stmt *statement;
    
    UIImageView *syncStatus = (UIImageView *)[cell viewWithTag:110];
    if([order.commDataSource isEqual: @"backend"]){
        if([order.commIsDraftModified isEqual:@"1"]){
            syncStatus.image = [UIImage imageNamed:@"localItem"];
        } else {
            syncStatus.image = [UIImage imageNamed:@"checkmark"];
        }
        query = [NSString stringWithFormat:@"SELECT COUNT(*) as itemCount FROM ReservationItems WHERE commItemCommID = %@",order.commID];
    } else {
        syncStatus.image = [UIImage imageNamed:@"localItem"];
        query = [NSString stringWithFormat:@"SELECT COUNT(*) as itemCount FROM LocalReservationItems WHERE commItemCommID = %@",order.commID];
    }
    
    if (sqlite3_prepare_v2(database, [query UTF8String],
                           -1, &statement, nil) == SQLITE_OK)
    {
        //char *columnData;
        int columnIntValue;
        NSString * itemCount;
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            /*
             1-clientID INT PRIMARY KEY,
             2-clientName TEXT,
             3-clientAdr1 TEXT,
             4-clientAdr2 TEXT,
             5-clientVille TEXT,
             6-clientProv TEXT,
             7-clientCodePostal TEXT,
             8-clientTelComp TEXT,
             9-clientContact TEXT,
             10-clientEmail TEXT,
             11-clientTel1 TEXT,
             */
            
            columnIntValue = (int)sqlite3_column_int(statement, 0);
            //NSLog(@"columnValue (Count) %i",columnIntValue);
            itemCount = [NSString stringWithFormat:@"%i",columnIntValue];
            
        }
        UILabel *commItemCount = (UILabel *)[cell viewWithTag:103];
        commItemCount.text = itemCount;
        
    }
    sqlite3_finalize(statement);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        currentOrder = [filteredOrderArray objectAtIndex:indexPath.row];
    } else {
        currentOrder = [orderArray objectAtIndex:indexPath.row];
    }
    
    [self performSegueWithIdentifier: @"reviewExistingOrder" sender: self];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"reviewExistingOrder"])
    {
        // Get reference to the destination view controller
        BIDCartViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.selectedOrder = currentOrder;
    }
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredOrderArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.commClientName contains[c] %@",searchText];
    filteredOrderArray = [NSMutableArray arrayWithArray:[orderArray filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (IBAction)unwindFromViewController:(UIStoryboardSegue *)segue
{
    //empty implementation
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)actionToNewOrder:(id)sender {
    
    MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.reservationActiveClient = nil;
    appDelegate.reservProducts = nil;
    appDelegate.reservQties = nil;
    appDelegate.reservCommentaire = nil;
    
    [self performSegueWithIdentifier:@"newOrder" sender:nil];
}

- (IBAction)actionToSyncOrders:(id)sender {
    
    [self resConvertLocalOrdersToJson];
    [self resConvertModifiedSynchedOrdersToJson];
    
    [self resConvertLocalReservationsToJson];
    [self resConvertModifiedSynchedReservationsToJson];
    
    [self resCheckConnectivity];
}



-(void) resConvertLocalOrdersToJson {
    NSMutableArray *jsonMuteArray = [[NSMutableArray alloc] init];
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *localquery = [NSString stringWithFormat:@"SELECT * FROM LocalCommandes"];
    
    sqlite3_stmt *localstatement;
    if (sqlite3_prepare_v2(database, [localquery UTF8String],
                           -1, &localstatement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(localstatement) == SQLITE_ROW) {
            
            char *columnData;
            int columnIntValue;
            NSString * commID;
            NSString * commStatutID;
            NSString * commRepID;
            NSString * commClientID;
            NSString * commTypeClntID;
            NSString * commCommTypeLivrID;
            NSString * commDelaiPickup;
            NSString * commDatePickup;
            NSString * commCommentaire;
            
            /*
             1-commID INT PRIMARY KEY,
             2-commStatutID INT,
             3-commRepID INT,
             4-commIDSAQ TEXT,
             5-commClientID INT,
             6-commTypeClntID INT,
             7-commCommTypeLivrID INT,
             8-commDateFact TEXT,
             9-commDelaiPickup INT,
             10-commDatePickup TEXT,
             11-commClientJourLivr TEXT,
             12-commPartSuccID INT,
             13-commCommentaire TEXT,
             14-commLastUpdated TEXT
             */
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 4);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 5);
            commTypeClntID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 6);
            commCommTypeLivrID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 8);
            commDelaiPickup = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(localstatement, 9);
            if(columnData == nil){
                commDatePickup = @"";
            } else {
                commDatePickup = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            columnData = (char *)sqlite3_column_text(localstatement, 12);
            if(columnData == nil){
                commCommentaire = @"";
            } else {
                commCommentaire = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            NSMutableArray *orderItems = [[NSMutableArray alloc] init];
            
            sqlite3_stmt *statement;
            NSString *query = [NSString stringWithFormat:@"SELECT * FROM LocalCommandeItems WHERE commItemCommID = %@", commID];
            
            if (sqlite3_prepare_v2(database, [query UTF8String],
                                   -1, &statement, nil) == SQLITE_OK)
            {
                orderItemsArray = [[NSMutableArray alloc] init];
                
                //char *columnData;
                int columnIntValue;
                NSString *vinID;
                NSString *vinQte;
                NSString *commItemCommID;
                
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    
                    /*
                     1-commItemID INTEGER PRIMARY KEY AUTOINCREMENT,
                     2-commItemCommID INT,
                     3-commItemVinID INT,
                     4-commItemVinQte INT
                     */
                    
                    columnIntValue = (int)sqlite3_column_int(statement, 1);
                    commItemCommID = [NSString stringWithFormat:@"%i",columnIntValue];
                    columnIntValue = (int)sqlite3_column_int(statement, 2);
                    vinID = [NSString stringWithFormat:@"%i",columnIntValue];
                    columnIntValue = (int)sqlite3_column_int(statement, 3);
                    vinQte = [NSString stringWithFormat:@"%i",columnIntValue];
                    
                    NSDictionary *dict;
                    
                    dict = @{
                             @"vinID" : vinID,
                             @"vinQte"  : vinQte,
                             @"vinOverideFrais"  : @"0.00"
                             };
                    [orderItems addObject:dict];
                    
                }
                
            }
            sqlite3_finalize(statement);
            
            NSDictionary *orderInfos = @{
                                         @"statutID" : commStatutID,
                                         @"repID"  : commRepID,
                                         @"clientID"  : commClientID,
                                         @"commCommTypeLivrID"  : commCommTypeLivrID,
                                         @"commDelaiPickup"  : commDelaiPickup,
                                         @"commPostDate"  : commDatePickup,
                                         @"commCommentaire"  : commCommentaire,
                                         @"orderItems" : orderItems
                                         };
            
            NSDictionary *order =@{
                                   @"order" : orderInfos
                                   };
            
            [jsonMuteArray addObject:order];
            
        }
        sqlite3_finalize(localstatement);
    }
    
    jsonData = [NSJSONSerialization dataWithJSONObject:jsonMuteArray
                                               options:0
                                                 error:nil];
    
}

-(void) resConvertModifiedSynchedOrdersToJson {
    NSMutableArray *jsonMuteArray = [[NSMutableArray alloc] init];
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *localquery = [NSString stringWithFormat:@"SELECT * FROM Commandes WHERE commIsDraftModified = 1"];
    
    sqlite3_stmt *localstatement;
    if (sqlite3_prepare_v2(database, [localquery UTF8String],
                           -1, &localstatement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(localstatement) == SQLITE_ROW) {
            
            char *columnData;
            int columnIntValue;
            NSString * commID;
            NSString * commStatutID;
            NSString * commRepID;
            NSString * commClientID;
            NSString * commTypeClntID;
            NSString * commCommTypeLivrID;
            NSString * commDelaiPickup;
            NSString * commDatePickup;
            NSString * commCommentaire;
            
            /*
             1-commID INT PRIMARY KEY,
             2-commStatutID INT,
             3-commRepID INT,
             4-commIDSAQ TEXT,
             5-commClientID INT,
             6-commTypeClntID INT,
             7-commCommTypeLivrID INT,
             8-commDateFact TEXT,
             9-commDelaiPickup INT,
             10-commDatePickup TEXT,
             11-commClientJourLivr TEXT,
             12-commPartSuccID INT,
             13-commCommentaire TEXT,
             14-commLastUpdated TEXT
             */
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 4);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 5);
            commTypeClntID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 6);
            commCommTypeLivrID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 8);
            commDelaiPickup = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(localstatement, 9);
            if(columnData == nil){
                commDatePickup = @"";
            } else {
                commDatePickup = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            columnData = (char *)sqlite3_column_text(localstatement, 12);
            if(columnData == nil){
                commCommentaire = @"";
            } else {
                commCommentaire = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            
            
            NSMutableArray *orderItems = [[NSMutableArray alloc] init];
            
            sqlite3_stmt *statement;
            NSString *query = [NSString stringWithFormat:@"SELECT * FROM CommandeItems WHERE commItemCommID = %@", commID];
            
            if (sqlite3_prepare_v2(database, [query UTF8String],
                                   -1, &statement, nil) == SQLITE_OK)
            {
                orderItemsArray = [[NSMutableArray alloc] init];
                
                //char *columnData;
                int columnIntValue;
                NSString *vinID;
                NSString *vinQte;
                NSString *commItemCommID;
                
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    
                    /*
                     1-commItemID INTEGER PRIMARY KEY AUTOINCREMENT,
                     2-commItemCommID INT,
                     3-commItemVinID INT,
                     4-commItemVinQte INT
                     */
                    
                    columnIntValue = (int)sqlite3_column_int(statement, 1);
                    commItemCommID = [NSString stringWithFormat:@"%i",columnIntValue];
                    columnIntValue = (int)sqlite3_column_int(statement, 2);
                    vinID = [NSString stringWithFormat:@"%i",columnIntValue];
                    columnIntValue = (int)sqlite3_column_int(statement, 3);
                    vinQte = [NSString stringWithFormat:@"%i",columnIntValue];
                    
                    NSDictionary *dict;
                    
                    dict = @{
                             @"vinID" : vinID,
                             @"vinQte"  : vinQte,
                             @"vinOverideFrais"  : @"0.00"
                             };
                    [orderItems addObject:dict];
                    
                }
                
            }
            sqlite3_finalize(statement);
            
            NSDictionary *orderInfos = @{
                                         @"commID" : commID,
                                         @"statutID" : commStatutID,
                                         @"repID"  : commRepID,
                                         @"clientID"  : commClientID,
                                         @"commCommTypeLivrID"  : commCommTypeLivrID,
                                         @"commDelaiPickup"  : commDelaiPickup,
                                         @"commPostDate"  : commDatePickup,
                                         @"commCommentaire"  : commCommentaire,
                                         @"orderItems" : orderItems
                                         };
            
            NSDictionary *order =@{
                                   @"order" : orderInfos
                                   };
            
            [jsonMuteArray addObject:order];
            
        }
        sqlite3_finalize(localstatement);
    }
    
    jsonDataForModified = [NSJSONSerialization dataWithJSONObject:jsonMuteArray
                                                          options:0
                                                            error:nil];
    
    //NSString *jsonDump = [[NSString alloc] initWithData:jsonDataForModified encoding:NSUTF8StringEncoding];
    
    
}

-(void) resConvertLocalReservationsToJson {
    NSMutableArray *jsonMuteArray = [[NSMutableArray alloc] init];
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *localquery = [NSString stringWithFormat:@"SELECT * FROM LocalReservations"];
    
    sqlite3_stmt *localstatement;
    if (sqlite3_prepare_v2(database, [localquery UTF8String],
                           -1, &localstatement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(localstatement) == SQLITE_ROW) {
            
            char *columnData;
            int columnIntValue;
            NSString * commID;
            NSString * commStatutID;
            NSString * commRepID;
            NSString * commClientID;
            NSString * commCommentaire;
            
            /*
             1-commID INTEGER PRIMARY KEY AUTOINCREMENT,
             2-commStatutID INT,
             3-commRepID INT, "
             4-commClientID INT,
             5-commDateSaisie TEXT, "
             6-commCommentaire TEXT,
             7-commLastUpdated TEXT
             */
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 3);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(localstatement, 5);
            if(columnData == nil){
                commCommentaire = @"";
            } else {
                commCommentaire = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            
            
            NSMutableArray *orderItems = [[NSMutableArray alloc] init];
            
            sqlite3_stmt *statement;
            NSString *query = [NSString stringWithFormat:@"SELECT * FROM LocalReservationItems WHERE commItemCommID = %@", commID];
            
            if (sqlite3_prepare_v2(database, [query UTF8String],
                                   -1, &statement, nil) == SQLITE_OK)
            {
                orderItemsArray = [[NSMutableArray alloc] init];
                
                //char *columnData;
                int columnIntValue;
                NSString *vinID;
                NSString *vinQte;
                NSString *commItemCommID;
                
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    
                    /*
                     1-commItemID INTEGER PRIMARY KEY AUTOINCREMENT,
                     2-commItemCommID INT,
                     3-commItemVinID INT,
                     4-commItemVinQte INT
                     */
                    
                    columnIntValue = (int)sqlite3_column_int(statement, 1);
                    commItemCommID = [NSString stringWithFormat:@"%i",columnIntValue];
                    columnIntValue = (int)sqlite3_column_int(statement, 2);
                    vinID = [NSString stringWithFormat:@"%i",columnIntValue];
                    columnIntValue = (int)sqlite3_column_int(statement, 3);
                    vinQte = [NSString stringWithFormat:@"%i",columnIntValue];
                    
                    NSDictionary *dict;
                    
                    dict = @{
                             @"vinID" : vinID,
                             @"vinQte"  : vinQte,
                             @"vinOverideFrais"  : @"0.00"
                             };
                    [orderItems addObject:dict];
                    
                }
                
            }
            sqlite3_finalize(statement);
            
            NSDictionary *orderInfos = @{
                                         @"statutID" : commStatutID,
                                         @"repID"  : commRepID,
                                         @"clientID"  : commClientID,
                                         @"commCommentaire"  : commCommentaire,
                                         @"orderItems" : orderItems
                                         };
            
            NSDictionary *order =@{
                                   @"order" : orderInfos
                                   };
            
            [jsonMuteArray addObject:order];
            
        }
        sqlite3_finalize(localstatement);
    }
    
    jsonDataReservations = [NSJSONSerialization dataWithJSONObject:jsonMuteArray
                                                           options:0
                                                             error:nil];
}

-(void) resConvertModifiedSynchedReservationsToJson {
    NSMutableArray *jsonMuteArray = [[NSMutableArray alloc] init];
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *localquery = [NSString stringWithFormat:@"SELECT * FROM Reservations WHERE commIsDraftModified = 1"];
    
    sqlite3_stmt *localstatement;
    if (sqlite3_prepare_v2(database, [localquery UTF8String],
                           -1, &localstatement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(localstatement) == SQLITE_ROW) {
            
            char *columnData;
            int columnIntValue;
            NSString * commID;
            NSString * commStatutID;
            NSString * commRepID;
            NSString * commClientID;
            NSString * commCommentaire;
            
            /*
             1-commID INT PRIMARY KEY,
             2-commStatutID INT,
             3-commRepID INT,
             4-commClientID INT,
             5-commDateSaisie TEXT,
             6-commCommentaire TEXT,
             7-commLastUpdated TEXT,
             8-commIsDraftModified INT
             */
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 3);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(localstatement, 5);
            if(columnData == nil){
                commCommentaire = @"";
            } else {
                commCommentaire = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            
            NSMutableArray *orderItems = [[NSMutableArray alloc] init];
            
            sqlite3_stmt *statement;
            NSString *query = [NSString stringWithFormat:@"SELECT * FROM ReservationItems WHERE commItemCommID = %@", commID];
            
            if (sqlite3_prepare_v2(database, [query UTF8String],
                                   -1, &statement, nil) == SQLITE_OK)
            {
                orderItemsArray = [[NSMutableArray alloc] init];
                
                //char *columnData;
                int columnIntValue;
                NSString *vinID;
                NSString *vinQte;
                NSString *commItemCommID;
                
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    
                    /*
                     1-commItemID INTEGER PRIMARY KEY AUTOINCREMENT,
                     2-commItemCommID INT,
                     3-commItemVinID INT,
                     4-commItemVinQte INT
                     */
                    
                    columnIntValue = (int)sqlite3_column_int(statement, 1);
                    commItemCommID = [NSString stringWithFormat:@"%i",columnIntValue];
                    columnIntValue = (int)sqlite3_column_int(statement, 2);
                    vinID = [NSString stringWithFormat:@"%i",columnIntValue];
                    columnIntValue = (int)sqlite3_column_int(statement, 3);
                    vinQte = [NSString stringWithFormat:@"%i",columnIntValue];
                    
                    NSDictionary *dict;
                    
                    dict = @{
                             @"vinID" : vinID,
                             @"vinQte"  : vinQte,
                             @"vinOverideFrais"  : @"0.00"
                             };
                    [orderItems addObject:dict];
                    
                }
                
            }
            sqlite3_finalize(statement);
            
            NSDictionary *orderInfos = @{
                                         @"commID" : commID,
                                         @"statutID" : commStatutID,
                                         @"repID"  : commRepID,
                                         @"clientID"  : commClientID,
                                         @"commCommentaire"  : commCommentaire,
                                         @"orderItems" : orderItems
                                         };
            
            NSDictionary *order =@{
                                   @"order" : orderInfos
                                   };
            
            [jsonMuteArray addObject:order];
            
        }
        sqlite3_finalize(localstatement);
    }
    
    jsonDataForModifiedReservations = [NSJSONSerialization dataWithJSONObject:jsonMuteArray
                                                                      options:0
                                                                        error:nil];
}

-(void) resSubmitLocalOrdersJson {
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/commandeJsonSubmit.php", appDelegate.syncServer];
    
    NSURL * url = [NSURL URLWithString:fullURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:jsonData];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil){
                                                           }
                                                           
                                                           NSMutableArray *rows  = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                                                           
                                                           NSString *currOrderID;
                                                           
                                                           for (int i=0; i<[rows count]; i++) {
                                                               
                                                               currOrderID = [[rows objectAtIndex:i] objectForKey:@"resultCode"];
                                                               if(![currOrderID isEqual: @"Error"]){
                                                                   NSLog(@"Everything is fine. Moving on...");
                                                                   
                                                               } else {
                                                                   NSLog(@"An error was detected.");
                                                               }
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                           
                                                           
                                                           
                                                       }];
    [dataTask resume];
    
}

-(void) resSubmitModifiedDraftOrdersJson {
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/commandeJsonUpdate.php", appDelegate.syncServer];
    
    NSURL * url = [NSURL URLWithString:fullURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonDataForModified length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:jsonDataForModified];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil){
                                                           }
                                                           
                                                           NSMutableArray *rows  = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                                                           
                                                           NSString *currOrderID;
                                                           
                                                           for (int i=0; i<[rows count]; i++) {
                                                               
                                                               currOrderID = [[rows objectAtIndex:i] objectForKey:@"resultCode"];
                                                               if(![currOrderID isEqual: @"Error"]){
                                                                   NSLog(@"Everything is fine. Moving on...");
                                                                   
                                                               } else {
                                                                   NSLog(@"An error was detected.");
                                                               }
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                           
                                                           
                                                           
                                                       }];
    [dataTask resume];
    
}

-(void) resSubmitLocalReservationsJson {
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/reservationJsonSubmit.php", appDelegate.syncServer];
    
    NSURL * url = [NSURL URLWithString:fullURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonDataReservations length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:jsonDataReservations];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil){
                                                           }
                                                           
                                                           NSMutableArray *rows  = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                                                           
                                                           NSString *currOrderID;
                                                           
                                                           for (int i=0; i<[rows count]; i++) {
                                                               
                                                               currOrderID = [[rows objectAtIndex:i] objectForKey:@"resultCode"];
                                                               if(![currOrderID isEqual: @"Error"]){
                                                                   NSLog(@"Everything is fine. Moving on...");
                                                                   
                                                               } else {
                                                                   NSLog(@"An error was detected.");
                                                               }
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                           
                                                           
                                                           
                                                       }];
    [dataTask resume];
    
}

-(void) resSubmitModifiedReservationsJson {
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/reservationJsonUpdate.php", appDelegate.syncServer];
    
    NSURL * url = [NSURL URLWithString:fullURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonDataForModifiedReservations length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:jsonDataForModifiedReservations];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil){
                                                           }
                                                           
                                                           NSMutableArray *rows  = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                                                           
                                                           NSString *currOrderID;
                                                           
                                                           for (int i=0; i<[rows count]; i++) {
                                                               
                                                               currOrderID = [[rows objectAtIndex:i] objectForKey:@"resultCode"];
                                                               if(![currOrderID isEqual: @"Error"]){
                                                                   NSLog(@"Everything is fine. Moving on...");
                                                                   
                                                               } else {
                                                                   NSLog(@"An error was detected.");
                                                               }
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                           
                                                           
                                                           
                                                       }];
    [dataTask resume];
    
}

-(void) resResetLocalOrderDBs {
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    char *errorMsg;
    
    NSString *dropClientsSQL = @"DROP TABLE IF EXISTS LocalCommandeItems;";
    
    if (sqlite3_exec (database, [dropClientsSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    dropClientsSQL = @"DROP TABLE IF EXISTS LocalCommandes;";
    
    if (sqlite3_exec (database, [dropClientsSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS LocalCommandes "
    "(commID INTEGER PRIMARY KEY AUTOINCREMENT, commStatutID INT, commRepID INT, commIDSAQ TEXT, "
    "commClientID INT, commTypeClntID INT, commCommTypeLivrID INT, commDateFact TEXT, "
    "commDelaiPickup INT, commDatePickup TEXT, commClientJourLivr TEXT, commPartSuccID INT, "
    "commCommentaire TEXT, commLastUpdated TEXT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS LocalCommandeItems "
    "(commItemID INTEGER PRIMARY KEY AUTOINCREMENT, commItemCommID INT, commItemVinID INT, commItemVinQte INT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    NSString *dropCommandesSQL = @"DROP TABLE IF EXISTS Commandes;";
    
    if (sqlite3_exec (database, [dropCommandesSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS Commandes "
    "(commID INT PRIMARY KEY, commStatutID INT, commRepID INT, commIDSAQ TEXT, "
    "commClientID INT, commTypeClntID INT, commCommTypeLivrID INT, commDateFact TEXT, "
    "commDelaiPickup INT, commDatePickup TEXT, commClientJourLivr TEXT, commPartSuccID INT, "
    "commCommentaire TEXT, commLastUpdated TEXT, commIsDraftModified INT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    NSString *dropCommandeItemsSQL = @"DROP TABLE IF EXISTS CommandeItems;";
    
    if (sqlite3_exec (database, [dropCommandeItemsSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS CommandeItems "
    "(commItemID INT PRIMARY KEY, commItemCommID INT, commItemVinID INT, commItemVinQte INT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    NSString *dropReservationsSQL = @"DROP TABLE IF EXISTS Reservations;";
    
    if (sqlite3_exec (database, [dropReservationsSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS Reservations "
    "(commID INT PRIMARY KEY, commStatutID INT, commRepID INT, "
    "commClientID INT, commDateSaisie TEXT, "
    "commCommentaire TEXT, commLastUpdated TEXT, commIsDraftModified INT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    NSString *dropReservationItemsSQL = @"DROP TABLE IF EXISTS ReservationItems;";
    
    if (sqlite3_exec (database, [dropReservationItemsSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS ReservationItems "
    "(commItemID INT PRIMARY KEY, commItemCommID INT, commItemVinID INT, commItemVinQte INT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    dropReservationsSQL = @"DROP TABLE IF EXISTS LocalReservations;";
    
    if (sqlite3_exec (database, [dropReservationsSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS LocalReservations "
    "(commID INTEGER PRIMARY KEY AUTOINCREMENT, commStatutID INT, commRepID INT, "
    "commClientID INT, commDateSaisie TEXT, "
    "commCommentaire TEXT, commLastUpdated TEXT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    dropReservationItemsSQL = @"DROP TABLE IF EXISTS LocalReservationItems;";
    
    if (sqlite3_exec (database, [dropReservationItemsSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS LocalReservationItems "
    "(commItemID INTEGER PRIMARY KEY AUTOINCREMENT, commItemCommID INT, commItemVinID INT, commItemVinQte INT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    
    sqlite3_close(database);
    
}

- (void) resUpdateCommandesTable {
    
    //[spinner startAnimating];
    NSString *repID = appDelegate.currLoggedUser;
    
    char *errorMsg = nil;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/commRepJson.php?repID=%@", appDelegate.syncServer ,repID];
    NSURL * url = [NSURL URLWithString:fullURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params = @"";
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil){
                                                           }
                                                           
                                                           NSMutableArray *rows  = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                                                           
                                                           for (int i=0; i<[rows count]; i++) {
                                                               
                                                               char *update = "INSERT INTO Commandes "
                                                               "(commID, commStatutID, commRepID, commIDSAQ, commClientID, commTypeClntID, commCommTypeLivrID, commDateFact, commDelaiPickup, commDatePickup, commClientJourLivr, commPartSuccID, commCommentaire, commLastUpdated) "
                                                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
                                                               
                                                               sqlite3_stmt *stmt;
                                                               
                                                               int commID;
                                                               commID = [[[rows objectAtIndex:i] objectForKey:@"commID"]intValue];
                                                               
                                                               NSInteger tmpCommID = commID;
                                                               
                                                               NSString * tmpStrCommID = [NSString stringWithFormat:@"%li",(long)tmpCommID];
                                                               //[self resUpdateCommandeItemsTable:tmpStrCommID];
                                                               
                                                               int commStatutID;
                                                               commStatutID = [[[rows objectAtIndex:i] objectForKey:@"commStatutID"]intValue];
                                                               
                                                               int commRepID;
                                                               commRepID = [[[rows objectAtIndex:i] objectForKey:@"commRepID"]intValue];
                                                               
                                                               NSString * commIDSAQ;
                                                               commIDSAQ = [[rows objectAtIndex:i] objectForKey:@"commIDSAQ"];
                                                               
                                                               int commClientID;
                                                               commClientID = [[[rows objectAtIndex:i] objectForKey:@"commClientID"]intValue];
                                                               
                                                               int commTypeClntID;
                                                               commTypeClntID = [[[rows objectAtIndex:i] objectForKey:@"commTypeClntID"]intValue];
                                                               
                                                               int commCommTypeLivrID;
                                                               commCommTypeLivrID = [[[rows objectAtIndex:i] objectForKey:@"commCommTypeLivrID"]intValue];
                                                               
                                                               NSString * commDateFact;
                                                               commDateFact = [[rows objectAtIndex:i] objectForKey:@"commDateFact"];
                                                               
                                                               NSString * commDelaiPickup;
                                                               commDelaiPickup = [[rows objectAtIndex:i] objectForKey:@"commDelaiPickup"];
                                                               
                                                               NSString * commDatePickup;
                                                               commDatePickup = [[rows objectAtIndex:i] objectForKey:@"commDatePickup"];
                                                               
                                                               NSString * commClientJourLivr;
                                                               commClientJourLivr = [[rows objectAtIndex:i] objectForKey:@"commClientJourLivr"];
                                                               
                                                               int commPartSuccID;
                                                               commPartSuccID = [[[rows objectAtIndex:i] objectForKey:@"commPartSuccID"]intValue];
                                                               
                                                               NSString * commCommentaire;
                                                               commCommentaire = [[rows objectAtIndex:i] objectForKey:@"commCommentaire"];
                                                               
                                                               NSString * commLastUpdated;
                                                               commLastUpdated = [[rows objectAtIndex:i] objectForKey:@"commLastUpdated"];
                                                               
                                                               if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)
                                                                   == SQLITE_OK) {
                                                                   sqlite3_bind_int(stmt, 1, commID);
                                                                   sqlite3_bind_int(stmt, 2, commStatutID);
                                                                   sqlite3_bind_int(stmt, 3, commRepID);
                                                                   sqlite3_bind_text(stmt, 4, [commIDSAQ UTF8String], -1, NULL);
                                                                   sqlite3_bind_int(stmt, 5, commClientID);
                                                                   sqlite3_bind_int(stmt, 6, commTypeClntID);
                                                                   sqlite3_bind_int(stmt, 7, commCommTypeLivrID);
                                                                   sqlite3_bind_text(stmt, 8, [commDateFact UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 9, [commDelaiPickup UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 10, [commDatePickup UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 11, [commClientJourLivr UTF8String], -1, NULL);
                                                                   sqlite3_bind_int(stmt, 12, commPartSuccID);
                                                                   sqlite3_bind_text(stmt, 13, [commCommentaire UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 14, [commLastUpdated UTF8String], -1, NULL);
                                                                   
                                                               }
                                                               
                                                               /*
                                                                1-commID INT PRIMARY KEY,
                                                                2-commStatutID INT,
                                                                3-commRepID INT,
                                                                4-commIDSAQ TEXT,
                                                                5-commClientID INT,
                                                                6-commTypeClntID INT,
                                                                7-commCommTypeLivrID INT,
                                                                8-commDateFact TEXT,
                                                                9-commDelaiPickup INT,
                                                                10-commDatePickup TEXT,
                                                                11-commClientJourLivr TEXT,
                                                                12-commPartSuccID INT,
                                                                13-commCommentaire TEXT,
                                                                14-commLastUpdated TEXT
                                                                */
                                                               
                                                               if (sqlite3_step(stmt) != SQLITE_DONE)
                                                                   NSAssert(0, @"Error updating table: %s", errorMsg);
                                                               sqlite3_finalize(stmt);
                                                               
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   //[spinner stopAnimating];
                                                                   
                                                                   //[self.tableView reloadData];
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                                   //[self.tableView reloadData];
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
    
}

- (void) resUpdateCommandeItemsTable {
    
    //[spinner startAnimating];
    
    char *errorMsg = nil;

    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/commItemJsonForRep.php?repID=%@", appDelegate.syncServer, appDelegate.currLoggedUser];
    NSURL * url = [NSURL URLWithString:fullURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params = @"";
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil){
                                                           }
                                                           
                                                           NSMutableArray *rows  = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                                                           
                                                           for (int i=0; i<[rows count]; i++) {
                                                               
                                                               //(commItemID INT PRIMARY KEY, commItemCommID INT, commItemVinID INT, commItemVinQte INT)
                                                               
                                                               char *update = "INSERT INTO CommandeItems "
                                                               "(commItemID, commItemCommID, commItemVinID, commItemVinQte) "
                                                               "VALUES (?, ?, ?, ?);";
                                                               
                                                               sqlite3_stmt *stmt;
                                                               
                                                               int commItemID;
                                                               commItemID = [[[rows objectAtIndex:i] objectForKey:@"commItemID"]intValue];
                                                               
                                                               int commItemCommID;
                                                               commItemCommID = [[[rows objectAtIndex:i] objectForKey:@"commItemCommID"]intValue];
                                                               
                                                               int commItemVinID;
                                                               commItemVinID = [[[rows objectAtIndex:i] objectForKey:@"vinID"]intValue];
                                                               
                                                               int commItemVinQte;
                                                               commItemVinQte = [[[rows objectAtIndex:i] objectForKey:@"vinQte"]intValue];
                                                               
                                                               if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)
                                                                   == SQLITE_OK) {
                                                                   sqlite3_bind_int(stmt, 1, commItemID);
                                                                   sqlite3_bind_int(stmt, 2, commItemCommID);
                                                                   sqlite3_bind_int(stmt, 3, commItemVinID);
                                                                   sqlite3_bind_int(stmt, 4, commItemVinQte);
                                                               }
                                                               
                                                               /*
                                                                1-commItemID INT PRIMARY KEY,
                                                                2-commItemCommID INT,
                                                                3-commItemVinID INT,
                                                                4-commItemVinQte INT
                                                                */
                                                               
                                                               if (sqlite3_step(stmt) != SQLITE_DONE)
                                                                   NSAssert(0, @"Error updating table: %s", errorMsg);
                                                               sqlite3_finalize(stmt);
                                                               
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   //[[self tableView] reloadData];
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                                   //[self.tableView reloadData];
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) resUpdateReservationsTable {
    
    NSString *repID = appDelegate.currLoggedUser;
    char *errorMsg = nil;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/reservRepJson.php?repID=%@", appDelegate.syncServer, repID];
    NSURL * url = [NSURL URLWithString:fullURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params = @"";
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil){
                                                           }
                                                           
                                                           NSMutableArray *rows  = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                                                           
                                                           for (int i=0; i<[rows count]; i++) {
                                                               
                                                               char *update = "INSERT INTO Reservations "
                                                               "(commID, commStatutID, commRepID, commClientID, "
                                                               "commCommentaire, commLastUpdated) "
                                                               "VALUES (?, ?, ?, ?, ?, ?);";
                                                               
                                                               /*
                                                                
                                                                commID INT PRIMARY KEY, commStatutID INT, commRepID INT, "
                                                                "commClientID INT, commDateSaisie TEXT, "
                                                                "commCommentaire TEXT, commLastUpdated TEXT, commIsDraftModified INT
                                                                
                                                                */
                                                               
                                                               sqlite3_stmt *stmt;
                                                               
                                                               int commID;
                                                               commID = [[[rows objectAtIndex:i] objectForKey:@"commID"]intValue];
                                                               
                                                               //int tmpCommID = commID;
                                                               
                                                               //NSString * tmpStrCommID = [NSString stringWithFormat:@"%i",tmpCommID];
                                                               
                                                               int commStatutID;
                                                               commStatutID = [[[rows objectAtIndex:i] objectForKey:@"commStatutID"]intValue];
                                                               
                                                               int commRepID;
                                                               commRepID = [[[rows objectAtIndex:i] objectForKey:@"commRepID"]intValue];
                                                               
                                                               int commClientID;
                                                               commClientID = [[[rows objectAtIndex:i] objectForKey:@"commClientID"]intValue];
                                                               
                                                               NSString * commCommentaire;
                                                               commCommentaire = [[rows objectAtIndex:i] objectForKey:@"commCommentaire"];
                                                               
                                                               NSString * commLastUpdated;
                                                               commLastUpdated = [[rows objectAtIndex:i] objectForKey:@"commLastUpdated"];
                                                               
                                                               if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)
                                                                   == SQLITE_OK) {
                                                                   sqlite3_bind_int(stmt, 1, commID);
                                                                   sqlite3_bind_int(stmt, 2, commStatutID);
                                                                   sqlite3_bind_int(stmt, 3, commRepID);
                                                                   sqlite3_bind_int(stmt, 4, commClientID);
                                                                   sqlite3_bind_text(stmt, 5, [commCommentaire UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 6, [commLastUpdated UTF8String], -1, NULL);
                                                                   
                                                               }
                                                               
                                                               /*
                                                                1-commID INT PRIMARY KEY,
                                                                2-commStatutID INT,
                                                                3-commRepID INT,
                                                                4-commIDSAQ TEXT,
                                                                5-commClientID INT,
                                                                6-commTypeClntID INT,
                                                                7-commCommTypeLivrID INT,
                                                                8-commDateFact TEXT,
                                                                9-commDelaiPickup INT,
                                                                10-commDatePickup TEXT,
                                                                11-commClientJourLivr TEXT,
                                                                12-commPartSuccID INT,
                                                                13-commCommentaire TEXT,
                                                                14-commLastUpdated TEXT
                                                                */
                                                               
                                                               if (sqlite3_step(stmt) != SQLITE_DONE)
                                                                   NSAssert(0, @"Error updating table: %s", errorMsg);
                                                               sqlite3_finalize(stmt);
                                                               
                                                               //[self resUpdateReservationItemsTable:tmpStrCommID];
                                                               
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   //[spinner stopAnimating];
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) resUpdateReservationItemsTable {
    
    char *errorMsg = nil;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/reservItemJsonForRep.php?repID=%@", appDelegate.syncServer, appDelegate.currLoggedUser];
    NSURL * url = [NSURL URLWithString:fullURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params = @"";
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil){
                                                           }
                                                           
                                                           NSMutableArray *rows  = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                                                           
                                                           for (int i=0; i<[rows count]; i++) {
                                                               
                                                               //(commItemID INT PRIMARY KEY, commItemCommID INT, commItemVinID INT, commItemVinQte INT)
                                                               
                                                               char *update = "INSERT INTO ReservationItems "
                                                               "(commItemID, commItemCommID, commItemVinID, commItemVinQte) "
                                                               "VALUES (?, ?, ?, ?);";
                                                               
                                                               sqlite3_stmt *stmt;
                                                               
                                                               //{"commItemID":13,"commItemCommID":7,"vinID":391,"vinQte":24}
                                                               int commItemID;
                                                               commItemID = [[[rows objectAtIndex:i] objectForKey:@"commItemID"]intValue];
                                                               
                                                               int commItemCommID;
                                                               commItemCommID = [[[rows objectAtIndex:i] objectForKey:@"commItemCommID"]intValue];
                                                               
                                                               int commItemVinID;
                                                               commItemVinID = [[[rows objectAtIndex:i] objectForKey:@"vinID"]intValue];
                                                               
                                                               int commItemVinQte;
                                                               commItemVinQte = [[[rows objectAtIndex:i] objectForKey:@"vinQte"]intValue];
                                                               
                                                               if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)
                                                                   == SQLITE_OK) {
                                                                   sqlite3_bind_int(stmt, 1, commItemID);
                                                                   sqlite3_bind_int(stmt, 2, commItemCommID);
                                                                   sqlite3_bind_int(stmt, 3, commItemVinID);
                                                                   sqlite3_bind_int(stmt, 4, commItemVinQte);
                                                               }
                                                               
                                                               /*
                                                                1-commItemID INT PRIMARY KEY,
                                                                2-commItemCommID INT,
                                                                3-commItemVinID INT,
                                                                4-commItemVinQte INT
                                                                */
                                                               
                                                               if (sqlite3_step(stmt) != SQLITE_DONE)
                                                                   NSAssert(0, @"Error updating table: %s", errorMsg);
                                                               sqlite3_finalize(stmt);
                                                               
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) refreshTableViewContent {
    
    self.orderArray = [[NSMutableArray alloc] init];
    
    int numberOfRows = 0;
    
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *localquery = [NSString stringWithFormat:@"SELECT * FROM LocalReservations ORDER BY commID DESC"];
    
    sqlite3_stmt *localstatement;
    if (sqlite3_prepare_v2(database, [localquery UTF8String],
                           -1, &localstatement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(localstatement) == SQLITE_ROW) {
            //int row = sqlite3_column_int(statement, 0);
            
            char *columnData;
            int columnIntValue;
            NSString * commID;
            NSString * commStatutID;
            NSString * commRepID;
            NSString * commClientID;
            NSString * commClientName;
            NSString * commCommentaire;
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 3);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(localstatement, 5);
            if(columnData == nil){
                commCommentaire = @"";
            } else {
                commCommentaire = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            NSString *clientQuery = [NSString stringWithFormat:@"SELECT * FROM Clients WHERE clientID = %@",commClientID];
            
            sqlite3_stmt *clientStmt;
            if (sqlite3_prepare_v2(database, [clientQuery UTF8String],
                                   -1, &clientStmt, nil) == SQLITE_OK)
            {
                char *columnData;
                //int columnIntValue;
                NSString * clientID;
                NSString * clientName;
                while (sqlite3_step(clientStmt) == SQLITE_ROW) {
                    
                    /*
                     1-clientID INT PRIMARY KEY,
                     2-clientName TEXT,
                     3-clientAdr1 TEXT,
                     4-clientAdr2 TEXT,
                     5-clientVille TEXT,
                     6-clientProv TEXT,
                     7-clientCodePostal TEXT,
                     8-clientTelComp TEXT,
                     9-clientContact TEXT,
                     10-clientEmail TEXT,
                     11-clientTel1 TEXT,
                     */
                    
                    columnData = (char *)sqlite3_column_text(clientStmt, 0);
                    clientID = [[NSString alloc] initWithUTF8String:columnData];
                    
                    columnData = (char *)sqlite3_column_text(clientStmt, 1);
                    clientName = [[NSString alloc] initWithUTF8String:columnData];
                    
                }
                commClientName = clientName;
                
            }
            sqlite3_finalize(clientStmt);
            
            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commClientName = commClientName;
            orderToAdd.commCommentaire = commCommentaire;
            orderToAdd.commDataSource = @"local";
            
            [self.orderArray addObject:orderToAdd];
            
            numberOfRows = numberOfRows + 1;
            
        }
        sqlite3_finalize(localstatement);
    }
    
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Reservations ORDER BY commID DESC"];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String],
                           -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //int row = sqlite3_column_int(statement, 0);
            
            char *columnData;
            int columnIntValue;
            NSString * commID;
            NSString * commStatutID;
            NSString * commRepID;
            NSString * commClientID;
            NSString * commClientName;
            NSString * commCommentaire;
            NSString * commIsDraftModified;
            
            /*
             1-commID INT PRIMARY KEY,
             2-commStatutID INT,
             3-commRepID INT,
             4-commIDSAQ TEXT,
             5-commClientID INT,
             6-commTypeClntID INT,
             7-commCommTypeLivrID INT,
             8-commDateFact TEXT,
             9-commDelaiPickup INT,
             10-commDatePickup TEXT,
             11-commClientJourLivr TEXT,
             12-commPartSuccID INT,
             13-commCommentaire TEXT,
             14-commLastUpdated TEXT,
             15-commIsDraftModified INT
             */
            
            columnIntValue = (int)sqlite3_column_int(statement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 3);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(statement, 5);
            if(columnData == nil){
                commCommentaire = @"";
            } else {
                commCommentaire = [[NSString alloc] initWithUTF8String:columnData];
            }
            columnIntValue = (int)sqlite3_column_int(statement, 14);
            commIsDraftModified = [NSString stringWithFormat:@"%i",columnIntValue];
            
            NSString *clientQuery = [NSString stringWithFormat:@"SELECT * FROM Clients WHERE clientID = %@",commClientID];
            
            sqlite3_stmt *clientStmt;
            if (sqlite3_prepare_v2(database, [clientQuery UTF8String],
                                   -1, &clientStmt, nil) == SQLITE_OK)
            {
                char *columnData;
                //int columnIntValue;
                NSString * clientID;
                NSString * clientName;
                while (sqlite3_step(clientStmt) == SQLITE_ROW) {
                    
                    /*
                     1-clientID INT PRIMARY KEY,
                     2-clientName TEXT,
                     3-clientAdr1 TEXT,
                     4-clientAdr2 TEXT,
                     5-clientVille TEXT,
                     6-clientProv TEXT,
                     7-clientCodePostal TEXT,
                     8-clientTelComp TEXT,
                     9-clientContact TEXT,
                     10-clientEmail TEXT,
                     11-clientTel1 TEXT,
                     */
                    
                    columnData = (char *)sqlite3_column_text(clientStmt, 0);
                    clientID = [[NSString alloc] initWithUTF8String:columnData];
                    
                    columnData = (char *)sqlite3_column_text(clientStmt, 1);
                    clientName = [[NSString alloc] initWithUTF8String:columnData];
                    
                }
                commClientName = clientName;
                
            }
            sqlite3_finalize(clientStmt);
            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commClientName = commClientName;
            orderToAdd.commCommentaire = commCommentaire;
            orderToAdd.commIsDraftModified = commIsDraftModified;
            orderToAdd.commDataSource = @"backend";
            
            [self.orderArray addObject:orderToAdd];
            
            numberOfRows = numberOfRows + 1;
            
        }
        sqlite3_finalize(statement);
    }
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.tableView.rowHeight = 70;
    self.clearsSelectionOnViewWillAppear = NO;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    self.filteredOrderArray = [NSMutableArray arrayWithCapacity:[orderArray count]];
    
    // Reload the table
    [[self tableView] reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 70; // or some other height
    
    //self.tableView.rowHeight = 71;
}

- (void) resCheckConnectivity {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tmpUser = [[defaults objectForKey:@"repID_preference"] lowercaseString];
    NSString *tmpPassword = [defaults objectForKey:@"password"];
    
    NSLog(@"User: %@",tmpUser);
    NSLog(@"Psw: %@",tmpPassword);
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/loginProcessJson.php", appDelegate.syncServer];
    NSURL * url = [NSURL URLWithString:fullURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params = [NSString stringWithFormat:@"pseudo=%@&mot_de_passe=%@",tmpUser, tmpPassword];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil){
                                                               NSMutableArray *rows  = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                                                               
                                                               
                                                               for (int i=0; i<[rows count]; i++) {
                                                                   
                                                                   NSString * loginResult;
                                                                   loginResult = [[rows objectAtIndex:i] objectForKey:@"resultCode"];
                                                                   
                                                                   if([loginResult isEqual: @"OK"]){
                                                                       [self resCompleteSynch];
                                                                       
                                                                   } else {
                                                                       [self resSyncErrorDetected];
                                                                       
                                                                   }
                                                                   
                                                               }
                                                           } else {
                                                               [self resSyncErrorDetected];
                                                           }
                                                           
                                                           
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
    
}

- (void) resCompleteSynch {
    [self resSubmitLocalOrdersJson];
    [self resSubmitModifiedDraftOrdersJson];
    [self resSubmitLocalReservationsJson];
    [self resSubmitModifiedReservationsJson];
    
    [self resResetLocalOrderDBs];
    
    [self performSelector:@selector(resUpdateCommandesTable) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(resUpdateReservationsTable) withObject:nil afterDelay:2.0];
    
    [self performSelector:@selector(resUpdateCommandeItemsTable) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(resUpdateReservationItemsTable) withObject:nil afterDelay:2.0];
    
    [self performSelector:@selector(refreshTableViewContent) withObject:nil afterDelay:10.0];
    
    
}

- (void)resSyncErrorDetected {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"La tentatve de connexion au serveur a échoué." delegate:self cancelButtonTitle:@"Annuler" destructiveButtonTitle:@"Annuler" otherButtonTitles:nil, nil];
    
    actionSheet.tag = 1;
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (actionSheet.tag) {
        case 1:
            if(buttonIndex == 0){
                //NSLog(@"Pressed button 0 - Do Nothing");
                
            } else if (buttonIndex == 1){
                //NSLog(@"Pressed button 2");
            }
            break;
    }
}



@end
