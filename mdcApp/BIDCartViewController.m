//
//  BIDCartViewController.m
//  AssistantVente
//
//  Created by Nicolas Huet on 04/02/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import "BIDCartViewController.h"

@interface BIDCartViewController ()

@end

NSMutableArray *itemImageFiles;
NSMutableArray *itemDetails;
NSMutableArray *itemQties;
NSMutableArray *itemFraisTimbrage;
NSMutableArray *itemFraisConsult;
NSMutableArray *itemSubTotal;
NSMutableArray *itemPrixUnitaire;

Client *currentClient;
NSString *currentTypeLivr;
NSString *currentCommentaire;
NSString *currentDelaiPickup;
NSMutableArray *productList;
MDCAppDelegate *appDelegate;

sqlite3 *database;

double varSubTotal;
double varTotal;

@implementation BIDCartViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(textField.tag == 200){
        self.commDatePickup = (UITextField *)textField;
    } else if(textField.tag == 201){
        self.commCommentaire = (UITextField *)textField;
    }
}

- (void)cancelCommentairePad {
        appDelegate.cartCommentaire = @"";
        self.commCommentaire.text = @"";
        [self.commCommentaire resignFirstResponder];
}

- (void)doneWithCommentairePad {
    appDelegate.cartCommentaire = self.commCommentaire.text;
    [self.commCommentaire resignFirstResponder];
}

- (void)datePickerValueChanged:(UIDatePicker*) datePicker{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    self.commDatePickup.text = [NSString stringWithFormat:@"%@",[df stringFromDate:datePicker.date]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    self.commDatePickup.text = [NSString stringWithFormat:@"%@",[df stringFromDate:self.datePicker.date]];
    appDelegate.cartDateLivr = self.commDatePickup.text;
    [self.commDatePickup resignFirstResponder];
    
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    varSubTotal = 0;
    varTotal = 0;
    
    itemImageFiles = [[NSMutableArray array] init];
    itemDetails = [[NSMutableArray array] init];
    itemQties = [[NSMutableArray array] init];
    itemFraisTimbrage = [[NSMutableArray array] init];
    itemFraisConsult = [[NSMutableArray array] init];
    itemSubTotal = [[NSMutableArray array] init];
    itemPrixUnitaire = [[NSMutableArray array] init];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    productList = appDelegate.cartProducts;
    currentClient = appDelegate.sessionActiveClient;
    currentTypeLivr = appDelegate.cartTypeLivr;
    currentDelaiPickup = appDelegate.cartDelaiPickup;
    currentCommentaire = appDelegate.cartCommentaire;
    
    //I am really trying something here NH
    NSInteger arraySize = [productList count];
    
    for(int i = 0; i < arraySize; i++){
        Product *currProduct = nil;
        currProduct = [appDelegate.cartProducts objectAtIndex:i];
        NSString *currQty = [appDelegate.cartQties objectAtIndex:i];
        
        if([currProduct.vinCouleurID  isEqual: @"3" ]){
            [itemImageFiles addObject:@"wineRose(128)"];
        } else if([currProduct.vinCouleurID  isEqual: @"2"] ){
            [itemImageFiles addObject:@"wineWhite(128)"];
        } else {
            [itemImageFiles addObject:@"wineRed(128)"];
        }
        
        [itemDetails addObject:currProduct.vinNom];
        [itemQties addObject:currQty];
        
        double tmpFraisTimbr = [currProduct.vinFraisEtiq doubleValue];
        [itemFraisTimbrage addObject:[NSString stringWithFormat:@"%.2f", tmpFraisTimbr]];
        
        double tmpFraisConsult = [currProduct.vinFraisBout doubleValue];
        [itemFraisConsult addObject:[NSString stringWithFormat:@"%.2f", tmpFraisConsult]];
        
        double tmpCalc = [currProduct.vinPrixAchat doubleValue] + [currProduct.vinFraisEtiq doubleValue] + [currProduct.vinFraisBout doubleValue];
        
        
        [itemPrixUnitaire addObject:[NSString stringWithFormat:@"%.2f", tmpCalc]];
        
        double qtyTmp = [[appDelegate.cartQties objectAtIndex:i] doubleValue];
        double unitPriceTmp = tmpCalc;
        double subTotalTmp = qtyTmp * unitPriceTmp;
        
        NSString *tmpSubTotal = [NSString stringWithFormat:@"%.2f $", subTotalTmp];
        [itemSubTotal addObject:tmpSubTotal];
        
        varSubTotal = varSubTotal + subTotalTmp;
        varTotal = varSubTotal;
        
    }
    //NSLog(@"Testing...");
    [[self tableView] reloadData];

    
}

-(void) viewWillAppear:(BOOL)animated
{
    //[super viewWillAppear:animated];
    
    varSubTotal = 0;
    varTotal = 0;
    
    itemImageFiles = [[NSMutableArray array] init];
    itemDetails = [[NSMutableArray array] init];
    itemQties = [[NSMutableArray array] init];
    itemFraisTimbrage = [[NSMutableArray array] init];
    itemFraisConsult = [[NSMutableArray array] init];
    itemSubTotal = [[NSMutableArray array] init];
    itemPrixUnitaire = [[NSMutableArray array] init];
    
    MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray *productList = appDelegate.cartProducts;
    currentClient = appDelegate.sessionActiveClient;
    currentTypeLivr = appDelegate.cartTypeLivr;
    currentDelaiPickup = appDelegate.cartDelaiPickup;
    currentCommentaire = appDelegate.cartCommentaire;
    
    int arraySize = [productList count];
    
    for(int i = 0; i < arraySize; i++){
        Product *currProduct = nil;
        currProduct = [appDelegate.cartProducts objectAtIndex:i];
        NSString *currQty = [appDelegate.cartQties objectAtIndex:i];
        
        if([currProduct.vinCouleurID  isEqual: @"3" ]){
            [itemImageFiles addObject:@"wineRose(128)"];
        } else if([currProduct.vinCouleurID  isEqual: @"2"] ){
            [itemImageFiles addObject:@"wineWhite(128)"];
        } else {
            [itemImageFiles addObject:@"wineRed(128)"];
        }
        
        [itemDetails addObject:currProduct.vinNom];
        [itemQties addObject:currQty];
        
        double tmpFraisTimbr = [currProduct.vinFraisEtiq doubleValue];
        [itemFraisTimbrage addObject:[NSString stringWithFormat:@"%.2f", tmpFraisTimbr]];
        
        double tmpFraisConsult = [currProduct.vinFraisBout doubleValue];
        [itemFraisConsult addObject:[NSString stringWithFormat:@"%.2f", tmpFraisConsult]];
        
        double tmpCalc = [currProduct.vinPrixAchat doubleValue] + [currProduct.vinFraisEtiq doubleValue] + [currProduct.vinFraisBout doubleValue];
        
        [itemPrixUnitaire addObject:[NSString stringWithFormat:@"%.2f", tmpCalc]];
        
        double qtyTmp = [[appDelegate.cartQties objectAtIndex:i] doubleValue];
        double unitPriceTmp = tmpCalc;
        double subTotalTmp = qtyTmp * unitPriceTmp;
        
        NSString *tmpSubTotal = [NSString stringWithFormat:@"%.2f $", subTotalTmp];
        [itemSubTotal addObject:tmpSubTotal];
        
        varSubTotal = varSubTotal + subTotalTmp;
        varTotal = varSubTotal;
        
    }
    //NSLog(@"Testing...");
    [[self tableView] reloadData];
}

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"mdc.sqlite"];
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
    // Return the number of rows in the section.
    NSInteger rowToReturn;
    if(section == 0){
        rowToReturn = 1;
    }
    if(section == 1) {
        rowToReturn = 1;
    }
    if(section == 2){
        rowToReturn = [itemImageFiles count];
    }
    return rowToReturn;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if([indexPath section] == 0){
        static NSString *CellIdentifier = @"clientCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if(currentClient == nil){
            UILabel *clientNameLabel = (UILabel *)[cell viewWithTag:110];
            clientNameLabel.text = @"Pas de client sélectionné";
            UILabel *clientContactLabel = (UILabel *)[cell viewWithTag:111];
            clientContactLabel.text = @"N/A";
            UILabel *clientTelLabel = (UILabel *)[cell viewWithTag:112];
            clientTelLabel.text = @"N/A";
            
        } else {
            UILabel *clientNameLabel = (UILabel *)[cell viewWithTag:110];
            clientNameLabel.text = currentClient.name;
            UILabel *clientContactLabel = (UILabel *)[cell viewWithTag:111];
            clientContactLabel.text = currentClient.personneRessource;
            UILabel *clientTelLabel = (UILabel *)[cell viewWithTag:112];
            clientTelLabel.text = currentClient.telephone;
        }
    }
    if([indexPath section] == 1){
        static NSString *CellIdentifier = @"subtotalCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        UILabel *totalLabel = (UILabel *)[cell viewWithTag:113];
        totalLabel.text = [NSString stringWithFormat:@"$%.2f",varTotal];
        
        UILabel *typeLivrLabel = (UILabel *)[cell viewWithTag:202];
        if([appDelegate.cartTypeLivr isEqual:@"1"]){
            typeLivrLabel.text = @"Pickup";
        } else if([appDelegate.cartTypeLivr isEqual:@"1a"]){
            typeLivrLabel.text = @"Pickup 24hres";
        } else if([appDelegate.cartTypeLivr isEqual:@"1b"]){
            typeLivrLabel.text = @"Pickup 48hres";
        } else if([appDelegate.cartTypeLivr isEqual:@"2"]){
            typeLivrLabel.text = @"Livraison";
        }
        
        self.toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, -40, 320, 40)];
        self.toolBar.barStyle = UIBarStyleBlackOpaque;
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(textFieldShouldReturn:)];
        NSArray* barItems = [NSArray arrayWithObjects:doneButton, nil];
        [self.toolBar setItems:barItems animated:YES];
        
        UITextField *commDatePickup = (UITextField *)[cell viewWithTag:200];
        [commDatePickup setDelegate:self];
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        [datePicker addTarget:self action:@selector(datePickerValueChanged:)
             forControlEvents:UIControlEventValueChanged];
        self.datePicker = datePicker;
        [commDatePickup setInputView:datePicker];
        [commDatePickup setInputAccessoryView:self.toolBar];
        
        datePicker.datePickerMode = UIDatePickerModeDate;
        [datePicker addTarget:self action:@selector(datePickerValueChanged:)
             forControlEvents:UIControlEventValueChanged];
        self.datePicker = datePicker;
        [commDatePickup setInputView:datePicker];
        [commDatePickup setInputAccessoryView:self.toolBar];
        
        UITextField *commCommentaire = (UITextField *)[cell viewWithTag:201];
        [commCommentaire setDelegate:self];
        
        UIToolbar* userNameToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        userNameToolbar.barStyle = UIBarStyleBlackTranslucent;
        userNameToolbar.items = [NSArray arrayWithObjects:
                                 [[UIBarButtonItem alloc]initWithTitle:@"Annuler" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelCommentairePad)],
                                 [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                 [[UIBarButtonItem alloc]initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithCommentairePad)],
                                 nil];
        [userNameToolbar sizeToFit];
        commCommentaire.inputAccessoryView = userNameToolbar;
        
        
        UIButton *livrTypeSelect= (UIButton *)[cell viewWithTag:203];
        [livrTypeSelect addTarget:self action:@selector(presentAllDeliveryOptions:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
    }
    if([indexPath section] == 2){
        static NSString *CellIdentifier = @"itemCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        UIImageView *prodImageView = (UIImageView *)[cell viewWithTag:100];
        prodImageView.image = [UIImage imageNamed:[itemImageFiles objectAtIndex:[indexPath row]]];
        
        UILabel *productNameLabel = (UILabel *)[cell viewWithTag:101];
        productNameLabel.text = [itemDetails objectAtIndex:[indexPath row]];
        
        UILabel *productQtyLabel = (UILabel *)[cell viewWithTag:102];
        productQtyLabel.text = [itemQties objectAtIndex:[indexPath row]];
        
        UILabel *productUnitPriceLabel = (UILabel *)[cell viewWithTag:103];
        productUnitPriceLabel.text = [itemPrixUnitaire objectAtIndex:[indexPath row]];
        
        UILabel *productFraisTimbrLabel = (UILabel *)[cell viewWithTag:105];
        productFraisTimbrLabel.text = [itemFraisTimbrage objectAtIndex:[indexPath row]];
        
        UILabel *productFraisConsultLabel = (UILabel *)[cell viewWithTag:106];
        productFraisConsultLabel.text = [itemFraisConsult objectAtIndex:[indexPath row]];
        
        UILabel *productSTLabel = (UILabel *)[cell viewWithTag:104];
        productSTLabel.text = [itemSubTotal objectAtIndex:[indexPath row]];
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowSize;
    
    if(indexPath.section == 0){
        rowSize = 104;
    } else if(indexPath.section == 2){
        rowSize = 164;
    } else {
        rowSize = 210;
    }
    return rowSize;
}

- (IBAction)selectClient:(id)sender {
    [self performSegueWithIdentifier:@"toSelectClient" sender:nil];
}

- (IBAction)addProductAction:(id)sender {
    [self performSegueWithIdentifier:@"toSelectProduct" sender:nil];
}

- (IBAction)confirmTransaction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Êtes-vous certain de vouloir soumettre la commande?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Soumettre" otherButtonTitles:@"Non", nil];
    
    actionSheet.tag = 2;
    
    [actionSheet showInView:self.view];
    
}

- (IBAction)cancelTransaction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Supprimer la commande?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Supprimer" otherButtonTitles:@"Non", nil];
    
    actionSheet.tag = 1;
    
    [actionSheet showInView:self.view];
}

- (void)presentAllDeliveryOptions:(id)sender{
    
    NSMutableArray *titleArray = [[NSMutableArray alloc] init];
    
    [titleArray addObject:@"Livraison"];
    [titleArray addObject:@"Pickup"];
    [titleArray addObject:@"Pickup (24hres)"];
    [titleArray addObject:@"Pickup (48hres)"];
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Type de livraison" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = 3;
    // ObjC Fast Enumeration
    
    for (NSString *title in titleArray) {
        [actionSheet addButtonWithTitle:title];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Annuler"];
    
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (actionSheet.tag) {
        case 1:
            if(buttonIndex == 0){
                NSLog(@"Pressed button 0");
                
                MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.sessionActiveClient = nil;
                appDelegate.cartProducts = nil;
                appDelegate.cartQties = nil;
                appDelegate.cartDateLivr = nil;
                appDelegate.cartTypeLivr = nil;
                appDelegate.cartDelaiPickup = nil;
                appDelegate.cartCommentaire = nil;
                [[self tableView] reloadData];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            } else if(buttonIndex == 1){
                NSLog(@"Pressed button 1 - 'Non' - Do nothing");
            } else if (buttonIndex == 2){
                NSLog(@"Pressed button 2");
            }
        break;
            
        case 2:
            if(buttonIndex == 0){
                NSLog(@"Pressed button 0");
                NSString * statusSave = [self saveOrder];
                if(![statusSave isEqual: @"Error"]){
                    NSInteger arraySize = [appDelegate.cartProducts count];
                    for(int i = 0; i < arraySize; i++){
                        Product *currProduct = nil;
                        currProduct = [appDelegate.cartProducts objectAtIndex:i];
                        NSString *currProdID = currProduct.vinID;
                        NSString *currQty = [appDelegate.cartQties objectAtIndex:i];
                        
                        [self saveOrderItem:statusSave prodID:currProdID qty:currQty];
                    }
                }
                
                //NSString *msg = @"La commande a été enregistrée avec succès.";
                
                //UIAlertView *alert = [[UIAlertView alloc]
                                      //initWithTitle:@"Commande Soumise"
                                      //message:msg
                                      //delegate:self
                                      //cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
                
                MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.sessionActiveClient = nil;
                appDelegate.cartProducts = nil;
                appDelegate.cartQties = nil;
                appDelegate.cartDateLivr = nil;
                appDelegate.cartDelaiPickup = nil;
                appDelegate.cartTypeLivr = nil;
                appDelegate.cartCommentaire = nil;
                //[[self tableView] reloadData];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            } else if(buttonIndex == 1){
                NSLog(@"Pressed button 1 - 'Non' - Do nothing");
            } else if (buttonIndex == 2){
                NSLog(@"Pressed button 2");
            }
        break;
        
        case 3:
            if(buttonIndex == 0){
                NSLog(@"Pressed button 0 - Livraison");
                //MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.cartTypeLivr = @"2";
                [[self tableView] reloadData];
                
            } else if(buttonIndex == 1){
                NSLog(@"Pressed button 1 - Pickup");
                //MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.cartTypeLivr = @"1";
                [[self tableView] reloadData];
            } else if (buttonIndex == 2){
                NSLog(@"Pressed button 2 - Pickup 24h");
                //MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.cartTypeLivr = @"1a";
                [[self tableView] reloadData];
            } else if (buttonIndex == 3){
                NSLog(@"Pressed button 2 - Pickup 48h");
                //MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.cartTypeLivr = @"1b";
                [[self tableView] reloadData];
            }
            break;
                
            
        default:
            break;
    }
}


- (NSString *)saveOrder {
    
    NSString * clientID;
    NSString * clientName;
    int clientTypeClntID;
    int clientTypeLivrID;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *query;
    query = [NSString stringWithFormat:@"SELECT * FROM Clients WHERE clientID = %@", currentClient.clientID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String],
                           -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //int row = sqlite3_column_int(statement, 0);
            
            char *columnData;
            int columnIntValue;
            
            
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
            
            columnIntValue = (int)sqlite3_column_int(statement, 16);
            clientTypeClntID = columnIntValue;
            
            columnIntValue = (int)sqlite3_column_int(statement, 19);
            clientTypeLivrID = columnIntValue;
            if(clientTypeLivrID == 0){
                clientTypeLivrID = 2;
            }
            
        }
        sqlite3_finalize(statement);
    }
    
    
    char *errorMsg = nil;
    
    char *update = "INSERT INTO LocalCommandes "
    "(commStatutID, commRepID, commClientID, commTypeClntID, commCommTypeLivrID, commDelaiPickup, commDatePickup, commCommentaire, commDateFact) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    /*
     @"CREATE TABLE IF NOT EXISTS LocalCommandes "
     "(commID INTEGER PRIMARY KEY AUTOINCREMENT, commStatutID INT, commRepID INT, commIDSAQ TEXT, "
     "commClientID INT, commTypeClntID INT, commCommTypeLivrID INT, commDateFact TEXT, "
     "commDelaiPickup INT, commDatePickup TEXT, commClientJourLivr TEXT, commPartSuccID INT, "
     "commCommentaire TEXT, commLastUpdated TEXT);"
    */
    
    sqlite3_stmt *stmt;
    
    int commStatutID = 2;
    int commRepID = [appDelegate.currLoggedUser intValue];
    int commClientID = [currentClient.clientID intValue];
    int commTypeLivr;
    int commDelaiPickup;
    
    if([appDelegate.cartTypeLivr isEqual:@""]){
        commTypeLivr = clientTypeLivrID;
        if(commTypeLivr == 0){
            commTypeLivr = 1;
        }
        commDelaiPickup = 0;
    } else if([appDelegate.cartTypeLivr isEqual:@"1"]){
        commTypeLivr = 1;
        commDelaiPickup = 0;
    } else if([appDelegate.cartTypeLivr isEqual:@"1a"]){
        commTypeLivr = 1;
        commDelaiPickup = 24;
    } else if([appDelegate.cartTypeLivr isEqual:@"1b"]){
        commTypeLivr = 1;
        commDelaiPickup = 48;
    } else if([appDelegate.cartTypeLivr isEqual:@"2"]){
        commTypeLivr = 2;
        commDelaiPickup = 0;
    }
    
    NSString *datePickup = appDelegate.cartDateLivr;
    NSString *testChar = appDelegate.cartCommentaire;
    
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)
        == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, commStatutID);
        sqlite3_bind_int(stmt, 2, commRepID);
        sqlite3_bind_int(stmt, 3, commClientID);
        sqlite3_bind_int(stmt, 4, clientTypeClntID);
        sqlite3_bind_int(stmt, 5, commTypeLivr);
        sqlite3_bind_int(stmt, 6, commDelaiPickup);
        sqlite3_bind_text(stmt, 7, [datePickup UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 8, [testChar UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 9, [@"" UTF8String], -1, NULL);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE){
        NSAssert(0, @"Error updating table: %s", errorMsg);
        return @"Error";
    } else {
        long test = sqlite3_last_insert_rowid(database);
        NSString * insertionID = [NSString stringWithFormat:@"%li", test];
        return insertionID;
    }
    
    sqlite3_finalize(stmt);
    
}


- (void)saveOrderItem:(NSString *)orderID prodID:(NSString *)prodID qty:(NSString *)qty {
    char *errorMsg = nil;
    
    char *update = "INSERT INTO LocalCommandeItems "
    "(commItemCommID, commItemVinID, commItemVinQte) "
    "VALUES (?, ?, ?);";
    
    /*
     @"CREATE TABLE IF NOT EXISTS LocalCommandeItems "
     "(commItemID INTEGER PRIMARY KEY AUTOINCREMENT, commItemCommID INT, commItemVinID INT, commItemVinQte INT);"
     */
    
    sqlite3_stmt *stmt;
    
    int commItemCommID = [orderID intValue];
    int commItemVinID = [prodID intValue];
    int commItemVinQte = [qty intValue];
    
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)
        == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, commItemCommID);
        sqlite3_bind_int(stmt, 2, commItemVinID);
        sqlite3_bind_int(stmt, 3, commItemVinQte);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE){
        NSAssert(0, @"Error updating table: %s", errorMsg);
    }
    sqlite3_finalize(stmt);
}

@end
