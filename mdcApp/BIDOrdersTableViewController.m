//
//  BIDOrdersTableViewController.m
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-03.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import "BIDOrdersTableViewController.h"
#import "MDCAppDelegate.h"
#import "Client.h"

@implementation BIDOrdersTableViewController

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

MBProgressHUD *hud;

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
    
    [self reloadViewFromDatabase];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.tableView.rowHeight = 70;
    self.clearsSelectionOnViewWillAppear = NO;
    
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + orderSearchbar.bounds.size.height;
    self.tableView.bounds = newBounds;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    appDelegate.ordersViewNeedsRefreshing = NO;
    
    // Reload the table
    [[self tableView] reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    //sqlite3_close(database);
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    if(appDelegate.ordersViewNeedsRefreshing) {
        [self reloadViewFromDatabase];
        appDelegate.ordersViewNeedsRefreshing = NO;
    }
    
    [[self tableView] reloadData];
}

- (void) reloadViewFromDatabase {
    self.orderArray = [[NSMutableArray alloc] init];
    
    NSString *localquery = [NSString stringWithFormat:@"SELECT * FROM LocalCommandes ORDER BY commID DESC"];
    
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
            NSString * commIDSAQ;
            NSString * commClientID;
            NSString * commClientName;
            NSString * commCommTypeLivrID;
            NSString * commDateFact;
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
            
            columnData = (char *)sqlite3_column_text(localstatement, 3);
            if(columnData == nil){
                commIDSAQ = @"";
            } else {
                commIDSAQ = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 4);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 6);
            commCommTypeLivrID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(localstatement, 7);
            if(columnData == nil){
                commDateFact = @"";
            } else {
                commDateFact = [[NSString alloc] initWithUTF8String:columnData];
            }
            
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
            
            /*
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID == %@", commClientID];
            NSArray *tmpClientLookup = [NSMutableArray arrayWithArray:[appDelegate.glClientArray filteredArrayUsingPredicate:predicate]];
            if(tmpClientLookup.count > 0){
                Client *tmpClient = [tmpClientLookup objectAtIndex:0];
                commClientName = tmpClient.name;
            } else {
                commClientName = @"";
            }
             */
            
            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commIDSAQ = commIDSAQ;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commClientName = commClientName;
            orderToAdd.commTypeLivrID = commCommTypeLivrID;
            orderToAdd.commDelaiPickup = commDelaiPickup;
            orderToAdd.commDateFact = commDateFact;
            orderToAdd.commDatePickup = commDatePickup;
            orderToAdd.commCommentaire = commCommentaire;
            orderToAdd.commDataSource = @"local";
            
            [self.orderArray addObject:orderToAdd];
            
        }
        sqlite3_finalize(localstatement);
    }
    
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Commandes ORDER BY commID DESC"];
    
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
            NSString * commIDSAQ;
            NSString * commClientID;
            NSString * commClientName;
            NSString * commCommTypeLivrID;
            NSString * commDateFact;
            NSString * commDelaiPickup;
            NSString * commDatePickup;
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
            
            columnData = (char *)sqlite3_column_text(statement, 3);
            if(columnData == nil){
                commIDSAQ = @"";
            } else {
                commIDSAQ = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            columnIntValue = (int)sqlite3_column_int(statement, 4);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 6);
            commCommTypeLivrID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(statement, 7);
            commDateFact = [[NSString alloc] initWithUTF8String:columnData];
            
            columnIntValue = (int)sqlite3_column_int(statement, 8);
            commDelaiPickup = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(statement, 9);
            if(columnData == nil){
                commDatePickup = @"";
            } else {
                commDatePickup = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            columnData = (char *)sqlite3_column_text(statement, 12);
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
            
            /*
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID == %@", commClientID];
            NSArray *tmpClientLookup = [NSMutableArray arrayWithArray:[appDelegate.glClientArray filteredArrayUsingPredicate:predicate]];
            if(tmpClientLookup.count > 0){
                Client *tmpClient = [tmpClientLookup objectAtIndex:0];
                commClientName = tmpClient.name;
            } else {
                commClientName = @"";
            }
             */
            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commIDSAQ = commIDSAQ;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commClientName = commClientName;
            orderToAdd.commDateFact = commDateFact;
            orderToAdd.commTypeLivrID = commCommTypeLivrID;
            orderToAdd.commDelaiPickup = commDelaiPickup;
            orderToAdd.commDatePickup = commDatePickup;
            orderToAdd.commCommentaire = commCommentaire;
            orderToAdd.commIsDraftModified = commIsDraftModified;
            orderToAdd.commDataSource = @"backend";
            
            [self.orderArray addObject:orderToAdd];
            
        }
        sqlite3_finalize(statement);
        
    }
    
    self.filteredOrderArray = [NSMutableArray arrayWithCapacity:[orderArray count]];
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
    
    UILabel *clientNameLabel = (UILabel *)[cell viewWithTag:101];
    clientNameLabel.text = order.commClientName;
    
    UILabel *commIDLabel = (UILabel *)[cell viewWithTag:106];
    if([order.commDataSource  isEqual: @"local"]){
        commIDLabel.text = @"N/A";
    }else{
        commIDLabel.text = order.commID;
    }
    
    UILabel *commDateFactLabel = (UILabel *)[cell viewWithTag:102];
    if([order.commDateFact  isEqual: @"0000-00-00"]){
        commDateFactLabel.text = @"";
    }else{
        commDateFactLabel.text = order.commDateFact;
    }
    
    UILabel *commStatut = (UILabel *)[cell viewWithTag:105];
    if([order.commStatutID  isEqual: @"1"]){
        commStatut.text = @"Brouillon";
    } else if([order.commStatutID  isEqual: @"2"]){
        commStatut.text = @"Révision";
    } else if([order.commStatutID  isEqual: @"3"]){
        commStatut.text = @"Soumis SAQ";
    } else if([order.commStatutID  isEqual: @"4"]){
        commStatut.text = [NSString stringWithFormat:@"Confirmé SAQ (%@)",order.commIDSAQ];
    } else if([order.commStatutID  isEqual: @"5"]){
        commStatut.text = [NSString stringWithFormat:@"Complet (%@)",order.commIDSAQ];
    } else if([order.commStatutID  isEqual: @"6"]){
        commStatut.text = @"Réservation";
    } else if([order.commStatutID  isEqual: @"7"]){
        commStatut.text = @"Confirmé";
    } else if([order.commStatutID  isEqual: @"8"]){
        commStatut.text = [NSString stringWithFormat:@"Facturé (%@)",order.commIDSAQ];
    } else if([order.commStatutID  isEqual: @"9"]){
        commStatut.text = @"Post Daté";
    } else if([order.commStatutID  isEqual: @"10"]){
        commStatut.text = [NSString stringWithFormat:@"Terminé (%@)",order.commIDSAQ];
    } else {
        commStatut.text = @"";
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
        query = [NSString stringWithFormat:@"SELECT COUNT(*) as itemCount FROM CommandeItems WHERE commItemCommID = %@",order.commID];
    } else {
        syncStatus.image = [UIImage imageNamed:@"localItem"];
        query = [NSString stringWithFormat:@"SELECT COUNT(*) as itemCount FROM LocalCommandeItems WHERE commItemCommID = %@",order.commID];
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


- (IBAction)actionToNewOrder:(id)sender {
    
    MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.sessionActiveClient = nil;
    appDelegate.cartProducts = nil;
    appDelegate.cartQties = nil;
    appDelegate.cartDateLivr = nil;
    appDelegate.cartDelaiPickup = nil;
    appDelegate.cartTypeLivr = nil;
    appDelegate.cartCommentaire = nil;
    
    [self performSegueWithIdentifier:@"newOrder" sender:nil];
}

- (IBAction)actionToSyncOrders:(id)sender {
    
    [self convertLocalOrdersToJson];
    [self convertModifiedSynchedOrdersToJson];
    [self convertLocalReservationsToJson];
    [self convertModifiedSynchedReservationsToJson];
    
    [self checkConnectivity];
    
    
}



-(void) convertLocalOrdersToJson {
    NSMutableArray *jsonMuteArray = [[NSMutableArray alloc] init];
    
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
    
    //NSString *jsonDump = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
}

-(void) convertModifiedSynchedOrdersToJson {
    NSMutableArray *jsonMuteArray = [[NSMutableArray alloc] init];
    
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

-(void) convertLocalReservationsToJson {
    NSMutableArray *jsonMuteArray = [[NSMutableArray alloc] init];
    
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

-(void) convertModifiedSynchedReservationsToJson {
    NSMutableArray *jsonMuteArray = [[NSMutableArray alloc] init];
    
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

-(void) submitLocalOrdersJson {
    
    //UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //spinner.center = CGPointMake(384, 520);
    //spinner.hidesWhenStopped = YES;
    //[self.view addSubview:spinner];
    //[spinner startAnimating];
    
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
                                                                   //[spinner stopAnimating];
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                           
                                                           
                                                           
                                                       }];
    [dataTask resume];
    
}

-(void) submitModifiedDraftOrdersJson {
    
    //UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //spinner.center = CGPointMake(384, 520);
    //spinner.hidesWhenStopped = YES;
    //[self.view addSubview:spinner];
    //[spinner startAnimating];
    
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
                                                                   //[spinner stopAnimating];
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                           
                                                           
                                                           
                                                       }];
    [dataTask resume];
    
}

-(void) submitLocalReservationsJson {
    
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

-(void) submitModifiedReservationsJson {
    
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
                                                                   //[spinner stopAnimating];
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                           
                                                           
                                                           
                                                       }];
    [dataTask resume];
    
}

- (void) ordUpdateCommandesTable {
    
    NSString *repID = appDelegate.currLoggedUser;
    
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
                                                               
                                                               NSInteger commID;
                                                               commID = [[[rows objectAtIndex:i] objectForKey:@"commID"]intValue];
                                                               
                                                               NSInteger tmpCommID = commID;
                                                               
                                                               NSString * tmpStrCommID = [NSString stringWithFormat:@"%li",(long)tmpCommID];
                                                               
                                                               NSInteger commStatutID;
                                                               commStatutID = [[[rows objectAtIndex:i] objectForKey:@"commStatutID"]intValue];
                                                               
                                                               NSInteger commRepID;
                                                               commRepID = [[[rows objectAtIndex:i] objectForKey:@"commRepID"]intValue];
                                                               
                                                               NSString * commIDSAQ;
                                                               commIDSAQ = [[rows objectAtIndex:i] objectForKey:@"commIDSAQ"];
                                                               
                                                               NSInteger commClientID;
                                                               commClientID = [[[rows objectAtIndex:i] objectForKey:@"commClientID"]intValue];
                                                               
                                                               NSInteger commTypeClntID;
                                                               commTypeClntID = [[[rows objectAtIndex:i] objectForKey:@"commTypeClntID"]intValue];
                                                               
                                                               NSInteger commCommTypeLivrID;
                                                               commCommTypeLivrID = [[[rows objectAtIndex:i] objectForKey:@"commCommTypeLivrID"]intValue];
                                                               
                                                               NSString * commDateFact;
                                                               commDateFact = [[rows objectAtIndex:i] objectForKey:@"commDateFact"];
                                                               
                                                               NSString * commDelaiPickup;
                                                               commDelaiPickup = [[rows objectAtIndex:i] objectForKey:@"commDelaiPickup"];
                                                               
                                                               NSString * commDatePickup;
                                                               commDatePickup = [[rows objectAtIndex:i] objectForKey:@"commDatePickup"];
                                                               
                                                               NSString * commClientJourLivr;
                                                               commClientJourLivr = [[rows objectAtIndex:i] objectForKey:@"commClientJourLivr"];
                                                               
                                                               NSString * commPartSuccID;
                                                               commPartSuccID = [[rows objectAtIndex:i] objectForKey:@"commPartSuccID"];
                                                               
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
                                                               
                                                               char *errorMsg = nil;
                                                               
                                                               if (sqlite3_step(stmt) != SQLITE_DONE)
                                                                   NSAssert(0, @"Error updating table: %s", errorMsg);
                                                               sqlite3_finalize(stmt);
                                                               
                                                               //[self ordUpdateCommandeItemsTable:tmpStrCommID];
                                                               //[self refreshTableViewContent];
                                                               
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   //[self refreshTableViewContent];
                                                                   //[spinner stopAnimating];
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                                    //[self.tableView reloadData];
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
    
}

- (void) ordUpdateCommandeItemsTable {
    
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
                                                               
                                                               NSInteger commItemID;
                                                               commItemID = [[[rows objectAtIndex:i] objectForKey:@"commItemID"]intValue];
                                                               
                                                               NSInteger commItemCommID;
                                                               commItemCommID = [[[rows objectAtIndex:i] objectForKey:@"commItemCommID"]intValue];
                                                               
                                                               NSInteger commItemVinID;
                                                               commItemVinID = [[[rows objectAtIndex:i] objectForKey:@"vinID"]intValue];
                                                               
                                                               NSInteger commItemVinQte;
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
                                                               
                                                               char *errorMsg = nil;
                                                               
                                                               if (sqlite3_step(stmt) != SQLITE_DONE)
                                                                   NSAssert(0, @"Error updating table: %s", errorMsg);
                                                               sqlite3_finalize(stmt);
                                                               
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                        
                                                                   [hud hide:YES];
                                                                   [self refreshTableViewContent];
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                                    //[self.tableView reloadData];
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) ordUpdateReservationsTable {
    
    NSString *repID = appDelegate.currLoggedUser;
    
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
                                                               
                                                               int tmpCommID = commID;
                                                               
                                                               NSString * tmpStrCommID = [NSString stringWithFormat:@"%i",tmpCommID];
                                                               
                                                               NSInteger commStatutID;
                                                               commStatutID = [[[rows objectAtIndex:i] objectForKey:@"commStatutID"]intValue];
                                                               
                                                               NSInteger commRepID;
                                                               commRepID = [[[rows objectAtIndex:i] objectForKey:@"commRepID"]intValue];
                                                               
                                                               NSInteger commClientID;
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
                                                               
                                                               char *errorMsg = nil;
                                                               
                                                               if (sqlite3_step(stmt) != SQLITE_DONE)
                                                                   NSAssert(0, @"Error updating table: %s", errorMsg);
                                                               sqlite3_finalize(stmt);
                                                               
                                                               //[self ordUpdateReservationItemsTable:tmpStrCommID];
                                                               
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

- (void) ordUpdateReservationItemsTable {
    
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
                                                               
                                                               char *errorMsg = nil;
                                                               
                                                               if (sqlite3_step(stmt) != SQLITE_DONE)
                                                                   NSAssert(0, @"Error updating table: %s", errorMsg);
                                                               sqlite3_finalize(stmt);
                                                               
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   //[spinner stopAnimating];
                                                                   //[self refreshTableViewContent];
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
    
    NSString *localquery = [NSString stringWithFormat:@"SELECT * FROM LocalCommandes ORDER BY commID DESC"];
    
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
            NSString * commDateFact;
            NSString * commDatePickup;
            NSString * commCommentaire;
            
            columnIntValue = (int)sqlite3_column_int(localstatement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            columnIntValue = (int)sqlite3_column_int(localstatement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            columnIntValue = (int)sqlite3_column_int(localstatement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            columnIntValue = (int)sqlite3_column_int(localstatement, 4);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            columnData = (char *)sqlite3_column_text(localstatement, 7);
            if(columnData == nil){
                commDateFact = @"";
            } else {
                commDateFact = [[NSString alloc] initWithUTF8String:columnData];
            }
            
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
            orderToAdd.commDateFact = commDateFact;
            orderToAdd.commDatePickup = commDatePickup;
            orderToAdd.commCommentaire = commCommentaire;
            orderToAdd.commDataSource = @"local";
            
            [self.orderArray addObject:orderToAdd];
            
        }
        sqlite3_finalize(localstatement);
    }
    
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Commandes ORDER BY commID DESC"];
    
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
            NSString * commIDSAQ;
            NSString * commClientID;
            NSString * commClientName;
            NSString * commDateFact;
            NSString * commDatePickup;
            NSString * commCommentaire;
            
            columnIntValue = (int)sqlite3_column_int(statement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            columnIntValue = (int)sqlite3_column_int(statement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            columnIntValue = (int)sqlite3_column_int(statement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(statement, 3);
            if(columnData == nil){
                commIDSAQ = @"";
            } else {
                commIDSAQ = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            columnIntValue = (int)sqlite3_column_int(statement, 4);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            columnData = (char *)sqlite3_column_text(statement, 7);
            commDateFact = [[NSString alloc] initWithUTF8String:columnData];
            
            columnData = (char *)sqlite3_column_text(statement, 9);
            if(columnData == nil){
                commDatePickup = @"";
            } else {
                commDatePickup = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            columnData = (char *)sqlite3_column_text(statement, 12);
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
            orderToAdd.commIDSAQ = commIDSAQ;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commClientName = commClientName;
            orderToAdd.commDateFact = commDateFact;
            orderToAdd.commDatePickup = commDatePickup;
            orderToAdd.commCommentaire = commCommentaire;
            orderToAdd.commDataSource = @"backend";
            
            [self.orderArray addObject:orderToAdd];
            
            numberOfRows = numberOfRows + 1;
            
        }
        sqlite3_finalize(statement);
    }
    
    self.filteredOrderArray = [NSMutableArray arrayWithCapacity:[orderArray count]];
    
    // Reload the table
    [[self tableView] reloadData];
}

-(void) ordResetLocalOrderDBs {
    
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
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 70; // or some other height
    
    //self.tableView.rowHeight = 71;
}

- (void) checkConnectivity {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tmpUser = [[defaults objectForKey:@"repID_preference"] lowercaseString];
    NSString *tmpPassword = [defaults objectForKey:@"password"];
    
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
                                                                       [self completeSynch];
                                                                       
                                                                   } else {
                                                                       [self syncErrorDetected];
                                                                       
                                                                   }
                                                                   
                                                               }
                                                           } else {
                                                               [self syncErrorDetected];
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

- (void) completeSynch {
    
    hud                         = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.detailsLabelText        = @"Synchronisation des données";
    hud.dimBackground           = YES;
    hud.labelText               = @"SVP Patienter";
    hud.mode                    = MBProgressHUDModeIndeterminate;
    
    appDelegate.reservationsViewNeedsRefreshing = YES;
    
    [self submitLocalOrdersJson];
    [self submitModifiedDraftOrdersJson];
    [self submitLocalReservationsJson];
    [self submitModifiedReservationsJson];
    
    [self ordResetLocalOrderDBs];
    
    [self performSelector:@selector(ordUpdateCommandesTable) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(ordUpdateReservationsTable) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(ordUpdateReservationItemsTable) withObject:nil afterDelay:3.0];
    
    [self performSelector:@selector(ordUpdateCommandeItemsTable) withObject:nil afterDelay:15.0];
}

- (void)syncErrorDetected {
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
