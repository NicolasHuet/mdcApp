//
//  BIDProductsViewController.m
//  AssistantVente
//
//  Created by Nicolas Huet on 22/01/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import "BIDProductsViewController.h"
#import "MDCAppDelegate.h"

@implementation BIDProductsViewController

@synthesize productArray;
@synthesize filteredProductsArray;
@synthesize productSearchBar;

Client *currentClient;
sqlite3 *database;
MDCAppDelegate *appDelegate;

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
    
    self.tableView.rowHeight = 90;
    self.clearsSelectionOnViewWillAppear = NO;
    appDelegate = [[UIApplication sharedApplication] delegate];
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self reloadViewFromDatabase];
    appDelegate.productsViewNeedsRefreshing = NO;
    
    // Reload the table
    [[self tableView] reloadData];
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    //if(appDelegate.productsViewNeedsRefreshing) {
       // [self reloadViewFromDatabase];
        //appDelegate.productsViewNeedsRefreshing = NO;
   // }
    
    if([appDelegate.glProductArray count] > 0){
        //clientArray = appDelegate.glClientArray;
    } else {
        appDelegate.glProductArray = [[NSMutableArray alloc]init];
        NSData *data = [userDefaults objectForKey:@"productsTable"];
        appDelegate.glProductArray = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    }
    
    //self.productArray = appDelegate.glProductArray;
    
    [[self tableView] reloadData];
    
}

- (void) reloadViewFromDatabase {
    self.productArray = [[NSMutableArray alloc] init];
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    //NSString *query = [NSString stringWithFormat:@"SELECT * FROM Vins WHERE vinDisponible = 1 AND vinEpuise = 0 ORDER BY vinNom"];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Vins WHERE vinEpuise = 0 ORDER BY vinNom"];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String],
                           -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //int row = sqlite3_column_int(statement, 0);
            
            char *columnData;
            int columnIntValue;
            double colDblValue;
            int vinID;
            NSString * vinNumero;
            NSString * vinNom;
            int vinCouleurID;
            int vinEmpaq;
            int vinRegionID;
            NSString * vinNoDemande;
            int vinIDFournisseur;
            NSString * vinDateAchat;
            int vinQteAchat;
            int vinTotalAssigned;
            NSString * vinFormat;
            double vinPrixAchat;
            double vinFraisEtiq;
            double vinFraisBout;
            double vinFraisBoutPart;
            double vinPrixVente;
            int vinEpuise;
            int vinDisponible;
            
            /*
             1- vinID INT PRIMARY KEY,
             2- vinNumero TEXT,
             3- vinNom TEXT,
             4- vinCouleurID INT,
             5- vinEmpaq INT,
             6- vinRegionID INT,
             7- vinNoDemande TEXT,
             8- vinIDFournisseur TEXT,
             9- vinDateAchat TEXT,
             10- vinQteAchat INT,
             11- vinTotalAssigned INT,
             12- vinFormat TEXT,
             13- vinPrixAchat REAL,
             14- vinFraisEtiq REAL,
             15- vinFraisBout REAL,
             16- vinFraisBoutPart REAL,
             17- vinPrixVente REAL,
             18- vinEpuise INT,
             19- vinDisponible INT
             */
            
            columnIntValue = (int)sqlite3_column_int(statement, 0);
            vinID = columnIntValue;
            
            columnData = (char *)sqlite3_column_text(statement, 1);
            vinNumero = [[NSString alloc] initWithUTF8String:columnData];
            
            columnData = (char *)sqlite3_column_text(statement, 2);
            vinNom = [[NSString alloc] initWithUTF8String:columnData];
            
            columnIntValue = (int)sqlite3_column_int(statement, 3);
            vinCouleurID = columnIntValue;
            
            columnIntValue = (int)sqlite3_column_int(statement, 4);
            vinEmpaq = columnIntValue;
            
            columnIntValue = (int)sqlite3_column_int(statement, 5);
            vinRegionID = columnIntValue;
            
            columnData = (char *)sqlite3_column_text(statement, 6);
            vinNoDemande = [[NSString alloc] initWithUTF8String:columnData];
            
            columnIntValue = (int)sqlite3_column_int(statement, 7);
            vinIDFournisseur = columnIntValue;
            
            columnData = (char *)sqlite3_column_text(statement, 8);
            vinDateAchat = [[NSString alloc] initWithUTF8String:columnData];
            
            columnIntValue = (int)sqlite3_column_int(statement, 9);
            vinQteAchat = columnIntValue;
            
            columnIntValue = (int)sqlite3_column_int(statement, 10);
            vinTotalAssigned = columnIntValue;
            
            columnData = (char *)sqlite3_column_text(statement, 11);
            vinFormat = [[NSString alloc] initWithUTF8String:columnData];
            
            colDblValue = (double)sqlite3_column_double(statement, 12);
            vinPrixAchat = colDblValue;
            
            colDblValue = (double)sqlite3_column_double(statement, 13);
            vinFraisEtiq = colDblValue;
            
            colDblValue = (double)sqlite3_column_double(statement, 14);
            vinFraisBout = colDblValue;
            
            colDblValue = (double)sqlite3_column_double(statement, 15);
            vinFraisBoutPart = colDblValue;
            
            colDblValue = (double)sqlite3_column_double(statement, 16);
            vinPrixVente = colDblValue;
            
            columnIntValue = (int)sqlite3_column_int(statement, 17);
            vinEpuise = columnIntValue;
            
            columnIntValue = (int)sqlite3_column_int(statement, 18);
            vinDisponible = columnIntValue;
            
            Product *productToAdd = [[Product alloc] init];
            
            productToAdd.vinID = [NSString stringWithFormat:@"%i",vinID];
            productToAdd.vinNumero = vinNumero;
            productToAdd.vinNom = vinNom;
            
            productToAdd.vinCouleurID = [NSString stringWithFormat:@"%i",vinCouleurID];
            productToAdd.vinEmpaq = [NSString stringWithFormat:@"%i",vinEmpaq];
            productToAdd.vinRegionID = [NSString stringWithFormat:@"%i",vinRegionID];
            
            productToAdd.vinNoDemande = vinNoDemande;
            productToAdd.vinIDFournisseur = [NSString stringWithFormat:@"%i",vinIDFournisseur];
            
            productToAdd.vinDateAchat = vinDateAchat;
            productToAdd.vinQteAchat = [NSString stringWithFormat:@"%i",vinQteAchat];
            productToAdd.vinTotalAssigned = [NSString stringWithFormat:@"%i",vinTotalAssigned];
            
            productToAdd.vinFormat = vinFormat;
            
            productToAdd.vinPrixAchat = [NSString stringWithFormat:@"%f",vinPrixAchat];
            productToAdd.vinFraisEtiq = [NSString stringWithFormat:@"%f",vinFraisEtiq];
            productToAdd.vinFraisBout = [NSString stringWithFormat:@"%f",vinFraisBout];
            productToAdd.vinFraisBoutPart = [NSString stringWithFormat:@"%f",vinFraisBoutPart];
            productToAdd.vinPrixVente = [NSString stringWithFormat:@"%f",vinPrixVente];
            
            productToAdd.vinEpuise = [NSString stringWithFormat:@"%i",vinEpuise];
            productToAdd.vinDisponible = [NSString stringWithFormat:@"%i",vinDisponible];
            
            [self.productArray addObject:productToAdd];
        }
        sqlite3_finalize(statement);
    }
    
    self.filteredProductsArray = [NSMutableArray arrayWithCapacity:[productArray count]];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"prepareForSeqgue: %@ - %@",segue.identifier, [sender reuseIdentifier]);
    if ([segue.identifier isEqualToString:@"toProdDetail"])
    {
        Product *product = [[Product alloc]init];
        
        if (self.searchDisplayController.isActive)
        {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
            product = [self.filteredProductsArray objectAtIndex:indexPath.row];
        }
        else
        {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            product = [productArray objectAtIndex:indexPath.row];
        }
        BIDProdDetailsViewController *prodDetailsViewController = segue.destinationViewController;
        prodDetailsViewController.isInSelectMode = NO;
        prodDetailsViewController.product = product;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"prodCell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:CellIdentifier])
    {
        [self performSegueWithIdentifier:@"toProdDetail" sender:cell];
    }
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
        return [filteredProductsArray count];
    } else {
        return productArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"prodCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        
    // Display recipe in the table cell
        
    Product *product = nil;
        
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        product = [filteredProductsArray objectAtIndex:indexPath.row];
    } else {
        product = [productArray objectAtIndex:indexPath.row];
    }
        
        
    UIImageView *prodImageView = (UIImageView *)[cell viewWithTag:100];
        
    if([product.vinCouleurID  isEqual: @"3" ]){
        prodImageView.image = [UIImage imageNamed:@"wineRose(128)"];
    } else if([product.vinCouleurID  isEqual: @"2"] ){
        prodImageView.image = [UIImage imageNamed:@"wineWhite(128)"];
    } else {
        prodImageView.image = [UIImage imageNamed:@"wineRed(128)"];
    }
    //prodImageView.image = [UIImage imageNamed:product.imageFile];
        
    UILabel *productNameLabel = (UILabel *)[cell viewWithTag:101];
    productNameLabel.text = product.vinNom;
        
    double tmpCalc = [product.vinPrixAchat doubleValue] + [product.vinFraisEtiq doubleValue] + [product.vinFraisBout doubleValue];
        
    UILabel *productPriceLabel = (UILabel *)[cell viewWithTag:104];
    productPriceLabel.text = [NSString stringWithFormat:@"$ %.2f", tmpCalc];
    
    UILabel *productAvailDays = (UILabel *)[cell viewWithTag:111];
    if(([product.vinDateAchat  isEqual:@""]) || ([product.vinDateAchat  isEqual:@"0000-00-00"])){
        productAvailDays.text = @"N/A";
    } else {
        NSDateFormatter *df=[[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSDate *date1 = [df dateFromString:product.vinDateAchat];
        NSDate *date2 = [NSDate date];
        NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:date1];
        int numberOfDays = secondsBetween / 86400;
        productAvailDays.text = [NSString stringWithFormat:@"%i", numberOfDays];
    }
    
    
    int tmpInitialStock = [product.vinQteAchat intValue];
    int tmpAssigned = [product.vinTotalAssigned intValue];
    int tmpStock = tmpInitialStock - tmpAssigned;
    
    UILabel *productStockLabel = (UILabel *)[cell viewWithTag:110];
    productStockLabel.text = [NSString stringWithFormat:@"%i",tmpStock];
    
    //if ([product.vinDisponible isEqual:@"0"]){
        //cell.backgroundColor = [UIColor lightGrayColor];
    //}
        
    return cell;
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredProductsArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.vinNom contains[c] %@",searchText];
    filteredProductsArray = [NSMutableArray arrayWithArray:[productArray filteredArrayUsingPredicate:predicate]];
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
    tableView.rowHeight = 90; // or some other height
    
    //self.tableView.rowHeight = 71;
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
