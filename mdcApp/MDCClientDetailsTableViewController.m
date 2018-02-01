//
//  MDCClientDetailsTableViewController.m
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-08.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import "MDCClientDetailsTableViewController.h"
#import "MDCAppDelegate.h"

@implementation MDCClientDetailsTableViewController

@synthesize orderArray;

sqlite3 *database;
Order *currentOrder;
MDCAppDelegate *appDelegate;

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
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    int numberOfRows = 0;
    
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Commandes WHERE commClientID = %@", self.client.clientID];
    
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
            
            columnData = (char *) sqlite3_column_text(statement, 3);
            commIDSAQ = [[NSString alloc] initWithUTF8String:columnData];
            
            columnIntValue = (int)sqlite3_column_int(statement, 4);
            commClientID = [NSString stringWithFormat:@"%i",columnIntValue];
            
            columnData = (char *)sqlite3_column_text(statement, 7);
            commDateFact = [[NSString alloc] initWithUTF8String:columnData];

            
            Order *orderToAdd = [[Order alloc] init];
            orderToAdd.commID = commID;
            orderToAdd.commStatutID = commStatutID;
            orderToAdd.commRepID = commRepID;
            orderToAdd.commClientID = commClientID;
            orderToAdd.commIDSAQ = commIDSAQ;
            orderToAdd.commDateFact = commDateFact;
            
            [orderArray addObject:orderToAdd];
            
            numberOfRows = numberOfRows + 1;
            
        }
        sqlite3_finalize(statement);
    }
    
    NSLog(@"Number of orders : %i", numberOfRows);
    //[[self tableView] reloadData];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    int rowToReturn;
    if(section == 0){
        rowToReturn = 1;
    }
    if(section == 1){
        rowToReturn = 1;
    }
    if(section == 2) {
        rowToReturn = orderArray.count;
    }
    return rowToReturn;
    //return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if([indexPath section] == 0){
        static NSString *CellIdentifier = @"clientCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        // Configure the cell...
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        // Display recipe in the table cell

        Client *client = nil;

        client = self.client;


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
    
        UILabel *clientAdrLabel = (UILabel *)[cell viewWithTag:102];
        clientAdrLabel.text = client.address;
    
        UILabel *clientCityLabel = (UILabel *)[cell viewWithTag:103];
        clientCityLabel.text = client.city;
    
        UILabel *clientCPostalLabel = (UILabel *)[cell viewWithTag:104];
        clientCPostalLabel.text = client.postalcode;

        UILabel *clientContactLabel = (UILabel *)[cell viewWithTag:105];
        clientContactLabel.text = client.personneRessource;
        
        UILabel *clientTelLabel = (UILabel *)[cell viewWithTag:106];
        clientTelLabel.text = client.telephone;
        
        UILabel *clientTypeLabel = (UILabel *)[cell viewWithTag:110];
        clientTypeLabel.text = client.clientType;
        
        UILabel *clientLivrLabel = (UILabel *)[cell viewWithTag:111];
        clientLivrLabel.text = client.clientTypeLivr;
        
        UILabel *clientTypeFact = (UILabel *)[cell viewWithTag:112];
        clientTypeFact.text = client.clientTypeFact;
        
        UILabel *clientJourLivr = (UILabel *)[cell viewWithTag:113];
        clientJourLivr.text = client.clientJourLivr;
        
        UILabel *clientIDSAQ = (UILabel *)[cell viewWithTag:115];
        clientIDSAQ.text = client.clientIDSAQ;
        
        
    }
    
    if([indexPath section] == 1){
        static NSString *CellIdentifier = @"lblCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        UILabel *dspLabel = (UILabel *)[cell viewWithTag:120];
        dspLabel.text = @"Historique des commandes";
    }
    
    if([indexPath section] == 2){
        static NSString *CellIdentifier = @"orderCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Display recipe in the table cell
        
        Order *order = nil;
        
        order = [orderArray objectAtIndex:indexPath.row];
        
        
        
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
            NSString * clientIDSAQ;
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
     
                 //1-clientID INT PRIMARY KEY,
                 //2-clientName TEXT,
                 //3-clientAdr1 TEXT,
                 //4-clientAdr2 TEXT,
                 //5-clientVille TEXT,
                 //6-clientProv TEXT,
                 //7-clientCodePostal TEXT,
                 //8-clientTelComp TEXT,
                 //9-clientContact TEXT,
                 //10-clientEmail TEXT,
                 //11-clientTel1 TEXT,
                 //20-clientIDSAQ TEXT
     
                columnData = (char *)sqlite3_column_text(statement, 0);
                clientID = [[NSString alloc] initWithUTF8String:columnData];
                
                columnData = (char *)sqlite3_column_text(statement, 1);
                clientName = [[NSString alloc] initWithUTF8String:columnData];
                
                columnData = (char *)sqlite3_column_text(statement, 19);
                clientIDSAQ = [[NSString alloc] initWithUTF8String:columnData];
                
            }
            UILabel *clientNameLabel = (UILabel *)[cell viewWithTag:131];
            clientNameLabel.text = clientName;
            
        }
        sqlite3_finalize(statement);
        
        /*
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID == %@", order.commClientID];
        NSArray *tmpClientLookup = [NSMutableArray arrayWithArray:[appDelegate.glClientArray filteredArrayUsingPredicate:predicate]];
        if(tmpClientLookup.count > 0){
            Client *tmpClient = [tmpClientLookup objectAtIndex:0];
            UILabel *clientNameLabel = (UILabel *)[cell viewWithTag:131];
            clientNameLabel.text = tmpClient.name;
        } else {
            
        }
        */
        
        
        UILabel *commIDLabel = (UILabel *)[cell viewWithTag:135];
        commIDLabel.text = order.commID;
        
        UILabel *commDateFactLabel = (UILabel *)[cell viewWithTag:133];
        if([order.commDateFact  isEqual: @"0000-00-00"]){
            commDateFactLabel.text = @"";
        }else{
            commDateFactLabel.text = order.commDateFact;
        }
        
        UILabel *commStatut = (UILabel *)[cell viewWithTag:132];
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
        
        //NSString *query;
        //sqlite3_stmt *statement;
        
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
            UILabel *commItemCount = (UILabel *)[cell viewWithTag:134];
            commItemCount.text = itemCount;
            
        }
        sqlite3_finalize(statement);
    }
    

    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section){
        case 0:
            return 275.0; // first section is 123pt high
        case 1:
            return 33.0; // second section  is 33pt high
        default:
            return 80.0; // all other rows are 40pt high
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    currentOrder = [orderArray objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier: @"reviewOrderFromClient" sender: self];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"reviewOrderFromClient"])
    {
        // Get reference to the destination view controller
        BIDCartViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.selectedOrder = currentOrder;
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
    // Configure the cell...
 
    return cell;
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

@end
