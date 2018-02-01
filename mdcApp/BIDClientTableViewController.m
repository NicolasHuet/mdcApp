//
//  BIDClientTableViewController.m
//  AssistantVente
//
//  Created by Nicolas Huet on 13/01/14.
//  Copyright (c) 2014 Present. All rights reserved.
//
#import "BIDClientTableViewController.h"
#import "MDCAppDelegate.h"
#import "MDCClientDetailsTableViewController.h"
@implementation BIDClientTableViewController
@synthesize clientArray;
@synthesize filteredClientArray;
@synthesize clientSearchBar;
MDCAppDelegate *appDelegate;
sqlite3 *database;

NSUserDefaults *userDefaults;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"mdc.sqlite"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + clientSearchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
    
    
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    userDefaults = [NSUserDefaults standardUserDefaults];
    appDelegate.currLoggedUser = [userDefaults objectForKey:@"UserCode"];
    appDelegate.currLoggedUserRole = [userDefaults objectForKey:@"UserRole"];
    appDelegate.syncServer = [userDefaults objectForKey:@"SrvAddr"];
    

    [self reloadViewFromDatabase];
    //appDelegate.clientsViewNeedsRefreshing = NO;
    
    //appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.tableView.rowHeight = 124;
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Reload the table
    [[self tableView] reloadData];
    
    self.filteredClientArray = [NSMutableArray arrayWithCapacity:[clientArray count]];
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if([appDelegate.glClientArray count] > 0){
        //clientArray = appDelegate.glClientArray;
    } else {
        appDelegate.glClientArray = [[NSMutableArray alloc]init];
        NSData *data = [userDefaults objectForKey:@"clientsTable"];
        appDelegate.glClientArray = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    }
    
    //clientArray = appDelegate.glClientArray;
    
    //if(appDelegate.clientsViewNeedsRefreshing == YES){
        //[self reloadViewFromDatabase];
        //appDelegate.clientsViewNeedsRefreshing = NO;
    //}
    
    [[self tableView] reloadData];
    
    self.filteredClientArray = [NSMutableArray arrayWithCapacity:[clientArray count]];
}

- (void) reloadViewFromDatabase {
    self.clientArray = [[NSMutableArray alloc] init];
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString *query;
    if([appDelegate.currLoggedUserRole isEqual: @"admin"]){
        query = [NSString stringWithFormat:@"SELECT * FROM Clients"];
    } else {
        query = [NSString stringWithFormat:@"SELECT * FROM Clients WHERE clientTitulaireID = %@ OR clientTempTitulaireID = %@",appDelegate.currLoggedUser,appDelegate.currLoggedUser];
    }
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String],
                           -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //int row = sqlite3_column_int(statement, 0);
            char *columnData;
            int columnIntValue;
            NSString * clientID;
            NSString * clientName;
            NSString * clientContact;
            NSString * clientTel;
            NSString * clientType;
            NSString * clientAddress;
            NSString * clientCity;
            NSString * clientProv;
            NSString * clientCodePostal;
            NSString * clientIDSAQ;
            NSString * clientJourLivr;
            NSString * clientTypeFact;
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
             12-clientTel2 TEXT,
             13-clientTel3 TEXT,
             14-clientFactContact TEXT,
             15-clientFactEmail TEXT,
             16-clientFactTel1 TEXT,
             17-clientTypeClntID INT,
             18-clientIDSAQ TEXT,
             19-clientActif INT,
             20-clientTypeLivrID INT,
             21-clientSuccLivr INT,
             22-clientTypeFact INT,
             23-clientFactMensuelle INT,
             24-clientTitulaireID INT,
             25-clientLivrJourFixe TEXT,
             26-clientNoMembre TEXT,
             27-clientEnvoiFact INT
             */
            columnData = (char *)sqlite3_column_text(statement, 0);
            clientID = [[NSString alloc] initWithUTF8String:columnData];
            columnData = (char *)sqlite3_column_text(statement, 1);
            clientName = [[NSString alloc] initWithUTF8String:columnData];
            columnData = (char *)sqlite3_column_text(statement, 2);
            clientAddress = [[NSString alloc] initWithUTF8String:columnData];
            columnData = (char *)sqlite3_column_text(statement, 4);
            clientCity = [[NSString alloc] initWithUTF8String:columnData];
            columnData = (char *)sqlite3_column_text(statement, 5);
            clientProv = [[NSString alloc] initWithUTF8String:columnData];
            columnData = (char *)sqlite3_column_text(statement, 6);
            clientCodePostal = [[NSString alloc] initWithUTF8String:columnData];
            columnData = (char *)sqlite3_column_text(statement, 8);
            clientContact = [[NSString alloc] initWithUTF8String:columnData];
            columnData = (char *)sqlite3_column_text(statement, 10);
            clientTel = [[NSString alloc] initWithUTF8String:columnData];
            columnIntValue = (int)sqlite3_column_int(statement, 16);
            if(columnIntValue == 1){
                clientType = @"Hotel";
            } else if(columnIntValue == 2){
                clientType = @"Particulier";
            } else if(columnIntValue == 3){
                clientType = @"Resto sans SAQ";
            } else if(columnIntValue == 4){
                clientType = @"Resto avec SAQ";
            } else {
                clientType = @"Particulier sans SAQ";
            }
            columnData = (char *)sqlite3_column_text(statement, 17);
            if(columnData != nil){
                clientIDSAQ = [[NSString alloc] initWithUTF8String:columnData];
            }
            columnIntValue = (int)sqlite3_column_int(statement, 21);
            if(columnIntValue == 1){
                clientTypeFact = @"Courriel";
            } else if(columnIntValue == 2){
                clientTypeFact = @"Poste";
            } else if(columnIntValue == 3){
                clientTypeFact = @"Courriel et poste";
            } else if(columnIntValue == 5){
                clientTypeFact = @"Courriel (mensuel)";
            } else if(columnIntValue == 6){
                clientTypeFact = @"Poste (mensuel)";
            } else {
                clientTypeFact = @"Courriel et poste (mens.)";
            }
            columnData = (char *)sqlite3_column_text(statement, 24);
            
            clientJourLivr = [[NSString alloc] initWithUTF8String:columnData];
            Client *clientToAdd = [[Client alloc] init];
            clientToAdd.clientID = clientID;
            clientToAdd.name = clientName;
            clientToAdd.personneRessource = clientContact;
            clientToAdd.telephone = clientTel;
            clientToAdd.clientType = clientType;
            clientToAdd.address = clientAddress;
            clientToAdd.city = clientCity;
            clientToAdd.province = clientProv;
            clientToAdd.postalcode = clientCodePostal;
            clientToAdd.clientIDSAQ = clientIDSAQ;
            clientToAdd.clientTypeFact = clientTypeFact;
            clientToAdd.clientJourLivr = clientJourLivr;
            [self.clientArray addObject:clientToAdd];
        }
        sqlite3_finalize(statement);
    }
    
    self.filteredClientArray = [NSMutableArray arrayWithCapacity:[clientArray count]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [filteredClientArray count];
    } else {
        return clientArray.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"clientCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Display recipe in the table cell
    Client *client = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        client = [filteredClientArray objectAtIndex:indexPath.row];
    } else {
        client = [clientArray objectAtIndex:indexPath.row];
    }
    UIImageView *clientImageView = (UIImageView *)[cell viewWithTag:100];
    if([client.clientType  isEqual: @"Hotel"]){
        clientImageView.image = [UIImage imageNamed:@"hotel"];
    } else if([client.clientType  isEqual: @"Particulier"]){
        clientImageView.image = [UIImage imageNamed:@"particulier"];
    } else if([client.clientType  isEqual: @"Particulier sans SAQ"]){
        clientImageView.image = [UIImage imageNamed:@"particulier"];
    } else {
        clientImageView.image = [UIImage imageNamed:@"restaurant"];
    }
    UILabel *clientNameLabel = (UILabel *)[cell viewWithTag:101];
    clientNameLabel.text = client.name;
    UILabel *clientContactLabel = (UILabel *)[cell viewWithTag:102];
    clientContactLabel.text = client.personneRessource;
    UILabel *clientAdrLabel = (UILabel *)[cell viewWithTag:103];
    clientAdrLabel.text = client.address;
    UILabel *clientCityLabel = (UILabel *)[cell viewWithTag:104];
    clientCityLabel.text = client.city;
    UILabel *clientTelLabel = (UILabel *)[cell viewWithTag:105];
    clientTelLabel.text = client.telephone;
    UILabel *clientIDSAQLabel= (UILabel *)[cell viewWithTag:106];
    clientIDSAQLabel.text = client.clientIDSAQ;
    UILabel *IDSAQSign = (UILabel *)[cell viewWithTag:107];
    if(([client.clientIDSAQ  isEqual: @""]) || (client.clientIDSAQ == nil)){
        IDSAQSign.hidden = YES;
    } else {
        IDSAQSign.hidden = NO;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"clientCell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:CellIdentifier])
    {
        [self performSegueWithIdentifier:@"toClientDetails" sender:cell];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"prepareForSeqgue: %@ - %@",segue.identifier, [sender reuseIdentifier]);
    if ([segue.identifier isEqualToString:@"toClientDetails"])
    {
        Client *client = nil;
        if (self.searchDisplayController.isActive)
        {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
            client = [self.filteredClientArray objectAtIndex:indexPath.row];
        } else {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            client = [clientArray objectAtIndex:indexPath.row];
        }
        MDCClientDetailsTableViewController *clientDetailsViewController = segue.destinationViewController;
        clientDetailsViewController.client = client;
    }
}
#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredClientArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    filteredClientArray = [NSMutableArray arrayWithArray:[clientArray filteredArrayUsingPredicate:predicate]];
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
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 120; // or some other height
}
/*
 - (IBAction)done:(UIStoryboardSegue *)segue
 {
 BIDAddClientVC *addClientVC = segue.sourceViewController;
 Client *newClient = [[Client alloc] init];
 newClient = addClientVC.clientToAdd;
 [self.clientArray addObject:newClient];
 [self.tableView reloadData];
 }
 - (IBAction)cancel:(UIStoryboardSegue *)segue
 {
 [self.tableView reloadData];
 }
 */
/*
 - (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
 NSInteger rowIndex = indexPath.row;
 UIImage *background = nil;
 if (rowIndex == 0) {
 background = [UIImage imageNamed:@"cell_top.png"];
 } else if (rowIndex == rowCount - 1) {
 background = [UIImage imageNamed:@"cell_bottom.png"];
 } else {
 background = [UIImage imageNamed:@"cell_middle.png"];
 }
 return background;
 }
 */
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
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
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
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
