//
//  BIDSelectClientTableVC.m
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-15.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import "BIDSelectClientTableVC.h"
#import "MDCAppDelegate.h"


@implementation BIDSelectClientTableVC

@synthesize clientArray;
@synthesize filteredClientArray;
@synthesize clientSearchBar;
@synthesize pickupSource;

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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"mdc.sqlite"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clientArray = [[NSMutableArray alloc] init];
    appDelegate = [[UIApplication sharedApplication] delegate];
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"Utilisateur Actuel: %@", appDelegate.currLoggedUser);
    
    int numberOfRows = 0;
    
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *query;
    if([appDelegate.currLoggedUserRole  isEqual: @"admin"]){
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
            
            columnData = (char *)sqlite3_column_text(statement, 17);
            clientIDSAQ = [[NSString alloc] initWithUTF8String:columnData];
            
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
            
            [self.clientArray addObject:clientToAdd];
            
            
            numberOfRows = numberOfRows + 1;
            
        }
        sqlite3_finalize(statement);
    }
    
    /*
    if([appDelegate.currLoggedUserRole  isEqual: @"admin"]){
        self.clientArray = appDelegate.glClientArray;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientTitulaireID == %@ OR clientTempTitulaireID == %@", appDelegate.currLoggedUser,appDelegate.currLoggedUser];
        NSArray *tmpClientLookup = [NSMutableArray arrayWithArray:[appDelegate.glClientArray filteredArrayUsingPredicate:predicate]];
        self.clientArray = [NSMutableArray arrayWithArray:tmpClientLookup];
    }
 */

    
    //NSLog(@"Number of clients : %i", numberOfRows);
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.tableView.rowHeight = 120;
    self.clearsSelectionOnViewWillAppear = NO;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    self.filteredClientArray = [NSMutableArray arrayWithCapacity:[clientArray count]];
    
    // Reload the table
    [[self tableView] reloadData];
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    
    self.clientArray = [[NSMutableArray alloc] init];
    
    int numberOfRows = 0;
    
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *query;
    if([appDelegate.currLoggedUserRole  isEqual: @"admin"]){
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
            
            columnData = (char *)sqlite3_column_text(statement, 17);
            clientIDSAQ = [[NSString alloc] initWithUTF8String:columnData];
            
            
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
            
            [self.clientArray addObject:clientToAdd];
            
            
            numberOfRows = numberOfRows + 1;
            
        }
        sqlite3_finalize(statement);
    }
    
    NSLog(@"Number of clients : %i", numberOfRows);
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.tableView.rowHeight = 120;
    self.clearsSelectionOnViewWillAppear = NO;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    self.filteredClientArray = [NSMutableArray arrayWithCapacity:[clientArray count]];
    
    // Reload the table
    [[self tableView] reloadData];
    
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"clientCell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:CellIdentifier])
    {
        Client *client = nil;
        
        if (self.searchDisplayController.isActive)
        {
            //NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
            client = [self.filteredClientArray objectAtIndex:indexPath.row];
        }
        else
        {
            //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            client = [clientArray objectAtIndex:indexPath.row];
        }
        
        if([self.pickupSource isEqual: @"Commande"]){
            appDelegate.sessionActiveClient = client;
        } else {
            appDelegate.reservationActiveClient = client;
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"prepareForSeqgue: %@ - %@",segue.identifier, [sender reuseIdentifier]);
    if ([segue.identifier isEqualToString:@"backToOrder"])
    {
        Client *client = nil;
        
        if (self.searchDisplayController.isActive)
        {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
            client = [self.filteredClientArray objectAtIndex:indexPath.row];
        }
        else
        {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            client = [clientArray objectAtIndex:indexPath.row];
        }
        
        if([self.pickupSource isEqual: @"Commande"]){
            appDelegate.sessionActiveClient = client;
        } else {
            appDelegate.reservationActiveClient = client;
        }
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

@end
