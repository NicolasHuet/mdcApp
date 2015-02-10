//
//  BIDOrdersTableViewController.m
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-03.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import "BIDOrdersTableViewController.h"
#import "MDCAppDelegate.h"

@implementation BIDOrdersTableViewController

@synthesize orderArray;
@synthesize filteredOrderArray;
@synthesize orderSearchbar;
@synthesize orderSyncArray;
@synthesize orderItemsArray;

MDCAppDelegate *appDelegate;
sqlite3 *database;

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
    
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
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
            //NSString * commIDSAQ;
            NSString * commClientID;
            NSString * commDateFact;
            
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
            
            columnData = (char *)sqlite3_column_text(localstatement, 7);
            if(columnData == nil){
                commDateFact = @"";
            } else {
                commDateFact = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commDateFact = commDateFact;
            orderToAdd.commDataSource = @"local";
            
            [self.orderArray addObject:orderToAdd];
            
            numberOfRows = numberOfRows + 1;
            
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
            NSString * commDateFact;
            
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
            
            columnIntValue = (int)sqlite3_column_int(statement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 4);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(statement, 7);
            commDateFact = [[NSString alloc] initWithUTF8String:columnData];
            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commDateFact = commDateFact;
            orderToAdd.commDataSource = @"backend";
            
            [self.orderArray addObject:orderToAdd];
            
            numberOfRows = numberOfRows + 1;
            
        }
        sqlite3_finalize(statement);
    }
    
    //NSLog(@"Number of orders : %i", numberOfRows);
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.tableView.rowHeight = 70;
    self.clearsSelectionOnViewWillAppear = NO;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    self.filteredOrderArray = [NSMutableArray arrayWithCapacity:[orderArray count]];
    
    // Reload the table
    [[self tableView] reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    
    self.orderArray = [[NSMutableArray alloc] init];
    
    int numberOfRows = 0;
    
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
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
            //NSString * commIDSAQ;
            NSString * commClientID;
            NSString * commDateFact;
            
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
            
            columnData = (char *)sqlite3_column_text(localstatement, 7);
            if(columnData == nil){
                commDateFact = @"";
            } else {
                commDateFact = [[NSString alloc] initWithUTF8String:columnData];
            }
            
            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commDateFact = commDateFact;
            orderToAdd.commDataSource = @"local";
            
            [self.orderArray addObject:orderToAdd];
            
            numberOfRows = numberOfRows + 1;
            
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
            //NSString * commIDSAQ;
            NSString * commClientID;
            NSString * commDateFact;
            
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
            
            columnIntValue = (int)sqlite3_column_int(statement, 0);
            commID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 1);
            commStatutID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 2);
            commRepID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnIntValue = (int)sqlite3_column_int(statement, 4);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(statement, 7);
            commDateFact = [[NSString alloc] initWithUTF8String:columnData];
            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commDateFact = commDateFact;
            orderToAdd.commDataSource = @"backend";
            
            [self.orderArray addObject:orderToAdd];
            
            numberOfRows = numberOfRows + 1;
            
        }
        sqlite3_finalize(statement);
    }
    
    //NSLog(@"Number of orders : %i", numberOfRows);
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.tableView.rowHeight = 70;
    self.clearsSelectionOnViewWillAppear = NO;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    self.filteredOrderArray = [NSMutableArray arrayWithCapacity:[orderArray count]];
    
    // Reload the table
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
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Clients WHERE clientID = %@",order.commClientID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String],
                           -1, &statement, nil) == SQLITE_OK)
    {
        char *columnData;
        //int columnIntValue;
        NSString * clientID;
        NSString * clientName;
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
            
            columnData = (char *)sqlite3_column_text(statement, 0);
            clientID = [[NSString alloc] initWithUTF8String:columnData];
            
            columnData = (char *)sqlite3_column_text(statement, 1);
            clientName = [[NSString alloc] initWithUTF8String:columnData];
            
        }
        UILabel *clientNameLabel = (UILabel *)[cell viewWithTag:101];
        clientNameLabel.text = clientName;
        
    }
    sqlite3_finalize(statement);
    
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
        commStatut.text = @"Confirmé SAQ";
    } else if([order.commStatutID  isEqual: @"5"]){
        commStatut.text = @"Complet";
    } else if([order.commStatutID  isEqual: @"6"]){
        commStatut.text = @"Réservation";
    } else if([order.commStatutID  isEqual: @"7"]){
        commStatut.text = @"Confirmé";
    } else if([order.commStatutID  isEqual: @"8"]){
        commStatut.text = @"Facturé";
    } else if([order.commStatutID  isEqual: @"9"]){
        commStatut.text = @"Post Daté";
    } else if([order.commStatutID  isEqual: @"10"]){
        commStatut.text = @"Terminé";
    } else {
        commStatut.text = @"";
    }
    
    UIImageView *syncStatus = (UIImageView *)[cell viewWithTag:110];
    if([order.commDataSource isEqual: @"backend"]){
        syncStatus.image = [UIImage imageNamed:@"checkmark"];
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

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredOrderArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.Name contains[c] %@",searchText];
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
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    [self performSegueWithIdentifier:@"newOrder" sender:nil];
}

- (IBAction)actionToSyncOrders:(id)sender {
    [self convertLocalDbToCD];
    
    [self performLocalOrdersSync];
    
    [self resetLocalOrderDBs];
    
    [self viewWillAppear:YES];
    
    
    //[[self tableView] reloadData];
    
}



-(void) convertLocalDbToCD {
    orderArray = [[NSMutableArray alloc] init];
    
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
            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commTypeClntID = commTypeClntID;
            orderToAdd.commTypeLivrID = commCommTypeLivrID;
            orderToAdd.commDelaiPickup = commDelaiPickup;
            orderToAdd.commDatePickup = commDatePickup;
            orderToAdd.commCommentaire = commCommentaire;
            
            [self.orderArray addObject:orderToAdd];
        }
        sqlite3_finalize(localstatement);
    }
}

-(void) performLocalOrdersSync {
    NSInteger arraySize = [orderArray count];
    
    for(int i = 0; i < arraySize; i++){
        Order *currOrder = nil;
        currOrder = [orderArray objectAtIndex:i];
        
        //[spinner startAnimating];
        
        char *errorMsg = nil;
        
        if (sqlite3_open([[self dataFilePath] UTF8String], &database)
            != SQLITE_OK) {
            sqlite3_close(database);
            NSAssert(0, @"Failed to open database");
        }
        
        sqlite3_stmt *statement;
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM LocalCommandeItems WHERE commItemCommID = %@",currOrder.commID];
        
        if (sqlite3_prepare_v2(database, [query UTF8String],
                               -1, &statement, nil) == SQLITE_OK)
        {
            orderItemsArray = [[NSMutableArray alloc] init];
            
            //char *columnData;
            int columnIntValue;
            NSString *vinID;
            NSString *vinQte;
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                /*
                 1-commItemID INTEGER PRIMARY KEY AUTOINCREMENT,
                 2-commItemCommID INT,
                 3-commItemVinID INT,
                 4-commItemVinQte INT
                 */
                
                columnIntValue = (int)sqlite3_column_int(statement, 2);
                vinID = [NSString stringWithFormat:@"%i",columnIntValue];
                columnIntValue = (int)sqlite3_column_int(statement, 3);
                vinQte = [NSString stringWithFormat:@"%i",columnIntValue];
                
                OrderItem *orderItemToAdd = [[OrderItem alloc] init];
                orderItemToAdd.vinID = vinID;
                orderItemToAdd.vinQte = vinQte;
                orderItemToAdd.vinOverideFrais = @"0.00";
                
                [orderItemsArray addObject:orderItemToAdd];
            }
            
        }
        sqlite3_finalize(statement);
        
        // Début Ajout
        
        
        
        
        // Fin ajout
        NSOperationQueue * queue = [NSOperationQueue new];
        
        [queue addOperationWithBlock:^{
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
            NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        
            //NSString *newCommentString =[currOrder.commCommentaire stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
            NSString *fullURL = [NSString stringWithFormat:@"http://www.nicolashuet.com/mdc/mobileSync/commandePost.php"];
        
            NSURL * url = [NSURL URLWithString:fullURL];
            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
        
            NSString * params = [NSString stringWithFormat:@"commStatutID=%@&commRepID=%@&commClientID=%@&commTypeClntID=%@&commCommTypeLivrID=%@&commDelaiPickup=%@&commDateLivr=%@&commCommentaire=%@", currOrder.commStatutID, currOrder.commRepID, currOrder.commClientID, currOrder.commTypeClntID, currOrder.commTypeLivrID, currOrder.commDelaiPickup, currOrder.commDatePickup, currOrder.commCommentaire];
        
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        
            NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                               NSLog(@"Response:%@ %@\n", response, error);
                                                               if(error == nil){
                                                               }
                                                               
                                                               NSMutableArray *rows  = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                                                               
                                                               for (int i=0; i<[rows count]; i++) {
                                                                   
                                                                   NSString *retObj = [[rows objectAtIndex:i] objectForKey:@"resultCode"];
                                                                   
                                                                   if(![retObj isEqual: @"Error"]){
                                                                       NSLog(@"Everything is fine. Moving on...");
                                                                       [self performLocalOrderItemsSync:retObj];
                                                                   } else {
                                                                       NSLog(@"An error was detected.");
                                                                   }
                                                                   
                                                               }
                                                               
                                                               
                                                               dispatch_semaphore_signal(semaphore);
                                                           }];
            [dataTask resume];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            
        }];
         
                                                               /*
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
        */
        
    }
    
    
}

-(void) performLocalOrderItemsSync:(NSString *) orderID {
    NSInteger arraySize = [orderItemsArray count];
    
    for(int i = 0; i < arraySize; i++){
        OrderItem *currOrderItem = nil;
        currOrderItem = [orderItemsArray objectAtIndex:i];
        
        NSOperationQueue * queue = [NSOperationQueue new];
        
        [queue addOperationWithBlock:^{
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        
            NSString *fullURL = [NSString stringWithFormat:@"http://www.nicolashuet.com/mdc/mobileSync/commandeItemGet.php?commID=%@&commVinID=%@&commVinQte=%@&commVinOverideFrais=%@", orderID, currOrderItem.vinID, currOrderItem.vinQte, currOrderItem.vinOverideFrais];
        
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
                                                                   NSString *retObj = [[rows objectAtIndex:i] objectForKey:@"resultCode"];
                                                                   if(![retObj isEqual: @"Error"]){
                                                                       NSLog(@"Everything is fine. Moving on...");
                                                                   } else {
                                                                       NSLog(@"An error was detected.");
                                                                   }
                                                               }
                                                               dispatch_semaphore_signal(semaphore);
                                                           }];
            [dataTask resume];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }];
                                                               /*
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
        */
    }
}


-(void) resetLocalOrderDBs {
    
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
    "commCommentaire TEXT, commLastUpdated TEXT);";
    
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
    
    sqlite3_close(database);
    
    [self updateCommandesTable:appDelegate.currLoggedUser];
    
}

- (void) updateCommandesTable:(NSString *)repID {
    
    //[spinner startAnimating];
    
    char *errorMsg = nil;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"http://www.nicolashuet.com/mdc/mobileSync/commRepJson.php?repID=%@",repID];
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
                                                               
                                                               char *update = "INSERT OR REPLACE INTO Commandes "
                                                               "(commID, commStatutID, commRepID, commIDSAQ, commClientID, commTypeClntID, commCommTypeLivrID, commDateFact, commDelaiPickup, commDatePickup, commClientJourLivr, commPartSuccID, commCommentaire, commLastUpdated) "
                                                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
                                                               
                                                               sqlite3_stmt *stmt;
                                                               
                                                               NSInteger commID;
                                                               commID = [[[rows objectAtIndex:i] objectForKey:@"commID"]intValue];
                                                               
                                                               int tmpCommID = commID;
                                                               
                                                               NSString * tmpStrCommID = [NSString stringWithFormat:@"%i",tmpCommID];
                                                               [self updateCommandeItemsTable:tmpStrCommID];
                                                               
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
    
    [[self tableView] reloadData];
}

- (void) updateCommandeItemsTable:(NSString *)commID {
    
    //[spinner startAnimating];
    
    char *errorMsg = nil;
    
    NSLog(@"Start updating CommandeItems for commande ID: %@",commID);
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"http://www.nicolashuet.com/mdc/mobileSync/commItemJson.php?commID=%@",commID];
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
                                                               
                                                               char *update = "INSERT OR REPLACE INTO CommandeItems "
                                                               "(commItemID, commItemCommID, commItemVinID, commItemVinQte) "
                                                               "VALUES (?, ?, ?, ?);";
                                                               
                                                               sqlite3_stmt *stmt;
                                                               
                                                               //{"commItemID":13,"commItemCommID":7,"vinID":391,"vinQte":24}
                                                               NSInteger commItemID;
                                                               commItemID = [[[rows objectAtIndex:i] objectForKey:@"commItemID"]intValue];
                                                               
                                                               NSInteger commItemCommID;
                                                               commItemCommID = [[[rows objectAtIndex:i] objectForKey:@"commItemCommID"]intValue];
                                                               
                                                               NSInteger commItemVinID;
                                                               commItemVinID = [[[rows objectAtIndex:i] objectForKey:@"commItemVinID"]intValue];
                                                               
                                                               NSInteger commItemVinQte;
                                                               commItemVinQte = [[[rows objectAtIndex:i] objectForKey:@"commItemVinQte"]intValue];
                                                               
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
                                                                    [self.tableView reloadData];
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                                    //[self.tableView reloadData];
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
    //[[self tableView] reloadData];
}

@end
