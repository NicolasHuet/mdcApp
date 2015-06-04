//
//  BIDReservationCartVC.m
//  mdcApp
//
//  Created by Nicolas Huet on 2015-05-24.
//  Copyright (c) 2015 MaitreDeChai. All rights reserved.
//

#import "BIDReservationCartVC.h"

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

@implementation BIDReservationCartVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)cancelCommentairePad {
    appDelegate.reservCommentaire = @"";
    self.commCommentaire.text = @"";
    [self.commCommentaire resignFirstResponder];
}

- (void)doneWithCommentairePad {
    appDelegate.reservCommentaire = self.commCommentaire.text;
    [self.commCommentaire resignFirstResponder];
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
    
    
    
    if(self.selectedOrder != nil) {
        
        appDelegate.reservCommentaire = self.selectedOrder.commCommentaire;
        
        NSString *query;
        
        query = [NSString stringWithFormat:@"SELECT * FROM Clients WHERE clientID = %@", self.selectedOrder.commClientID];
        
        
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
                
                appDelegate.reservationActiveClient = clientToAdd;
                
            }
            sqlite3_finalize(statement);
        }
        
        if([self.selectedOrder.commDataSource  isEqual: @"local"]) {
            query = [NSString stringWithFormat:@"SELECT * FROM LocalReservationItems WHERE commItemCommID = %@",self.selectedOrder.commID];
        } else {
            query = [NSString stringWithFormat:@"SELECT * FROM ReservationItems WHERE commItemCommID = %@",self.selectedOrder.commID];
        }
        
        NSMutableArray *orderItemsArray = [[NSMutableArray alloc] init];
        
        if (sqlite3_prepare_v2(database, [query UTF8String],
                               -1, &statement, nil) == SQLITE_OK)
        {
            
            
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
                
                OrderItem *orderItemToAdd = [[OrderItem alloc] init];
                
                orderItemToAdd.vinID = vinID;
                orderItemToAdd.vinQte = vinQte;
                orderItemToAdd.vinOverideFrais = @"0.00";
                
                [orderItemsArray addObject:orderItemToAdd];
                
            }
            
        }
        sqlite3_finalize(statement);
        
        NSMutableArray *orderProductsArray = [[NSMutableArray alloc] init];
        NSMutableArray *orderQtiesArray = [[NSMutableArray alloc] init];
        
        for (int z=0; z < orderItemsArray.count; z++) {
            
            OrderItem *orderItemToSearch = [[OrderItem alloc] init];
            orderItemToSearch = [orderItemsArray objectAtIndex:z];
            
            [orderQtiesArray addObject:orderItemToSearch.vinQte];
            
            query = [NSString stringWithFormat:@"SELECT * FROM Vins WHERE vinID = %@", orderItemToSearch.vinID];
            
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
                    
                    [orderProductsArray addObject:productToAdd];
                    
                }
                sqlite3_finalize(statement);
            }
        }
        
        appDelegate.reservProducts = orderProductsArray;
        appDelegate.reservQties = orderQtiesArray;
        
        
    }
    
    productList = appDelegate.reservProducts;
    currentClient = appDelegate.reservationActiveClient;
    currentTypeLivr = appDelegate.reservTypeLivr;
    currentCommentaire = appDelegate.reservCommentaire;
    
    //I am really trying something here NH
    NSInteger arraySize = [productList count];
    
    for(int i = 0; i < arraySize; i++){
        Product *currProduct = nil;
        currProduct = [appDelegate.reservProducts objectAtIndex:i];
        NSString *currQty = [appDelegate.reservQties objectAtIndex:i];
        
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
        
        double qtyTmp = [[appDelegate.reservQties objectAtIndex:i] doubleValue];
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
    
    //self.deliveryTypeField.text = @"Livraison";
    
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
    NSMutableArray *productList = appDelegate.reservProducts;
    currentClient = appDelegate.reservationActiveClient;
    currentTypeLivr = appDelegate.reservTypeLivr;
    currentCommentaire = appDelegate.reservCommentaire;
    
    NSUInteger arraySize = [productList count];
    
    for(int i = 0; i < arraySize; i++){
        Product *currProduct = nil;
        currProduct = [appDelegate.reservProducts objectAtIndex:i];
        NSString *currQty = [appDelegate.reservQties objectAtIndex:i];
        
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
        
        double qtyTmp = [[appDelegate.reservQties objectAtIndex:i] doubleValue];
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
        
        if(self.selectedOrder != nil) {
            UIButton *selectClientButton = (UIButton *)[cell viewWithTag:500];
            selectClientButton.hidden = YES;
        }
        
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
        
            UILabel *commIDSAQLbl = (UILabel *)[cell viewWithTag:204];
            commIDSAQLbl.hidden = YES;
            UILabel *commIDSAQ = (UILabel *)[cell viewWithTag:205];
            commIDSAQ.hidden = YES;
            
            UITextField *commCommentaire = (UITextField *)[cell viewWithTag:201];
            [commCommentaire setDelegate:self];
        
        
        UILabel *totalLabel = (UILabel *)[cell viewWithTag:113];
        totalLabel.text = [NSString stringWithFormat:@"$%.2f",varTotal];
        
        self.toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, -40, 320, 40)];
        self.toolBar.barStyle = UIBarStyleBlackOpaque;
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(textFieldShouldReturn:)];
        NSArray* barItems = [NSArray arrayWithObjects:doneButton, nil];
        [self.toolBar setItems:barItems animated:YES];
        
        UITextField *commDatePickup = (UITextField *)[cell viewWithTag:200];
        [commDatePickup setDelegate:self];
        
        
        UIToolbar* userNameToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        userNameToolbar.barStyle = UIBarStyleBlackTranslucent;
        userNameToolbar.items = [NSArray arrayWithObjects:
                                 [[UIBarButtonItem alloc]initWithTitle:@"Annuler" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelCommentairePad)],
                                 [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                 [[UIBarButtonItem alloc]initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithCommentairePad)],
                                 nil];
        [userNameToolbar sizeToFit];
        commCommentaire.inputAccessoryView = userNameToolbar;
        
        
        
        
        
        
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
        rowSize = 140;
    } else {
        rowSize = 160;
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
    
    bool doSubmit = YES;
    
    if(appDelegate.reservationActiveClient == nil) {
        doSubmit = NO;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Vous devez sélectionner le client !" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        actionSheet.tag = 4;
        
        [actionSheet showInView:self.view];
    }
    
    //if(appDelegate.reservProducts.count < 1) {
        //doSubmit = NO;
        //UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Vous devez ajouter au moins 1 produit !" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        //actionSheet.tag = 5;
        
        //[actionSheet showInView:self.view];
    //}
    
    if(doSubmit){
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Êtes-vous certain de vouloir soumettre la reservation? (Rappelez-vous que les réservations affectent les stocks aussi)." delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Soumettre" otherButtonTitles:@"Non", nil];
        
        actionSheet.tag = 2;
        
        [actionSheet showInView:self.view];
    }
}

- (IBAction)cancelTransaction:(id)sender {
    
    if(self.selectedOrder != nil) {
        MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.reservationActiveClient = nil;
        appDelegate.reservProducts = nil;
        appDelegate.reservQties = nil;
        appDelegate.reservCommentaire = nil;
        [[self tableView] reloadData];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Supprimer la réservation?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Supprimer" otherButtonTitles:@"Non", nil];
        
        actionSheet.tag = 1;
        
        [actionSheet showInView:self.view];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (actionSheet.tag) {
        case 1:
            if(buttonIndex == 0){
                NSLog(@"Pressed button 0");
                
                MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.reservationActiveClient = nil;
                appDelegate.reservProducts = nil;
                appDelegate.reservQties = nil;
                appDelegate.reservCommentaire = nil;
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
                if ([self.commCommentaire.text length] > 0 || self.commCommentaire.text != nil || [self.commCommentaire.text isEqual:@""] == FALSE){
                    appDelegate.reservCommentaire = self.commCommentaire.text;
                }
                NSString * statusSave = [self saveOrder:@"Revision"];
                if(![statusSave isEqual: @"Error"]){
                    NSInteger arraySize = [appDelegate.reservProducts count];
                    for(int i = 0; i < arraySize; i++){
                        Product *currProduct = nil;
                        currProduct = [appDelegate.reservProducts objectAtIndex:i];
                        NSString *currProdID = currProduct.vinID;
                        NSString *currQty = [appDelegate.reservQties objectAtIndex:i];
                        
                        [self saveOrderItem:statusSave prodID:currProdID qty:currQty];
                    }
                }
                
                MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.reservationActiveClient = nil;
                appDelegate.reservProducts = nil;
                appDelegate.reservQties = nil;
                appDelegate.reservCommentaire = nil;
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
                [[self tableView] reloadData];
                
            } else if (buttonIndex == 1){
                NSLog(@"Pressed button 2 - Pickup 24h");
                //MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                [[self tableView] reloadData];
            } else if (buttonIndex == 2){
                NSLog(@"Pressed button 2 - Pickup 48h");
                //MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                [[self tableView] reloadData];
            }
            break;
            
        case 6:
            if(buttonIndex == 0){
                NSLog(@"Pressed button 0");
                if ([self.commCommentaire.text length] > 0 || self.commCommentaire.text != nil || [self.commCommentaire.text isEqual:@""] == FALSE){
                    appDelegate.reservCommentaire = self.commCommentaire.text;
                }
                NSString * statusSave = [self saveOrder:@"Draft"];
                if(![statusSave isEqual: @"Error"]){
                    NSInteger arraySize = [appDelegate.reservProducts count];
                    for(int i = 0; i < arraySize; i++){
                        Product *currProduct = nil;
                        currProduct = [appDelegate.reservProducts objectAtIndex:i];
                        NSString *currProdID = currProduct.vinID;
                        NSString *currQty = [appDelegate.reservQties objectAtIndex:i];
                        
                        [self saveOrderItem:statusSave prodID:currProdID qty:currQty];
                    }
                }
                
                MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.reservationActiveClient = nil;
                appDelegate.reservProducts = nil;
                appDelegate.reservQties = nil;
                appDelegate.reservCommentaire = nil;
                //[[self tableView] reloadData];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            } else if(buttonIndex == 1){
                NSLog(@"Pressed button 1 - 'Non' - Do nothing");
            } else if (buttonIndex == 2){
                NSLog(@"Pressed button 2");
            }
            break;
            
        default:
            break;
    }
}


- (NSString *)saveOrder:(NSString *) orderStatus {
    
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
    int commStatutID = 6;
    
    NSString * insertResult;
    
    if(self.selectedOrder != nil) {
        if([self.selectedOrder.commDataSource isEqual:@"backend"]){
            
            sqlite3_stmt *stmt;
            char *del_stmt = "DELETE FROM ReservationItems WHERE commItemCommID = ?";
            int commID = [self.selectedOrder.commID intValue];
            
            if(sqlite3_prepare_v2(database, del_stmt, -1, &stmt, NULL) != SQLITE_OK)
                NSLog(@"Error while creating deletion statement. %s", sqlite3_errmsg(database));
            
            sqlite3_bind_int(stmt, 1, commID);
            
            if (sqlite3_step(stmt) == SQLITE_DONE)
            {
                NSLog(@"YES");
            } else {
                NSLog(@"NO");
            }
            sqlite3_finalize(stmt);
            
            char *errmsg;
            
            char *update = "UPDATE Reservations SET "
            "commStatutID = ? , commRepID = ?, commClientID = ?, "
            "commCommentaire = ?, commIsDraftModified = ? "
            "WHERE commID = ?;";
            
            /*
             @"CREATE TABLE IF NOT EXISTS LocalCommandes "
             "(commID INTEGER PRIMARY KEY AUTOINCREMENT, commStatutID INT, commRepID INT, commIDSAQ TEXT, "
             "commClientID INT, commTypeClntID INT, commCommTypeLivrID INT, commDateFact TEXT, "
             "commDelaiPickup INT, commDatePickup TEXT, commClientJourLivr TEXT, commPartSuccID INT, "
             "commCommentaire TEXT, commLastUpdated TEXT);"
             */
            
            sqlite3_stmt *insStmt;
            
            commID = [self.selectedOrder.commID intValue];
            int commRepID = [appDelegate.currLoggedUser intValue];
            int commClientID = [currentClient.clientID intValue];
            int commIsDraftModified = 1;
            
            NSString *testChar = appDelegate.reservCommentaire;
            
            if(sqlite3_prepare_v2(database, update, -1, &insStmt, NULL) != SQLITE_OK)
                NSLog(@"Error while creating update statement. %s", sqlite3_errmsg(database));
            
            sqlite3_bind_int(insStmt, 1, commStatutID);
            sqlite3_bind_int(insStmt, 2, commRepID);
            sqlite3_bind_int(insStmt, 3, commClientID);
            sqlite3_bind_text(insStmt, 4, [testChar UTF8String], -1, NULL);
            sqlite3_bind_int(insStmt, 5, commIsDraftModified);
            sqlite3_bind_int(insStmt, 6, commID);
            
            sqlite3_exec(database, "COMMIT", NULL, NULL, &errmsg);
            
            if(SQLITE_DONE != sqlite3_step(insStmt)){
                NSLog(@"Error while updating. %s", sqlite3_errmsg(database));
                insertResult = @"Error";
            } else {
                sqlite3_finalize(insStmt);
                //long test = sqlite3_last_insert_rowid(database);
                //NSString * insertionID = [NSString stringWithFormat:@"%li", test];
                insertResult =  self.selectedOrder.commID;
            }
            
            //sqlite3_finalize(insStmt);
            
            
            
            
        } else {
            
            sqlite3_stmt *stmt;
            char *del_stmt = "DELETE FROM LocalReservationItems WHERE commItemCommID = ?";
            int commID = [self.selectedOrder.commID intValue];
            
            if(sqlite3_prepare_v2(database, del_stmt, -1, &stmt, NULL) != SQLITE_OK)
                NSLog(@"Error while creating deletion statement. %s", sqlite3_errmsg(database));
            
            sqlite3_bind_int(stmt, 1, commID);
            
            if (sqlite3_step(stmt) == SQLITE_DONE)
            {
                NSLog(@"YES");
            } else {
                NSLog(@"NO");
            }
            sqlite3_finalize(stmt);
            
            char* errmsg;
            
            char *update = "UPDATE LocalReservations SET "
            "commStatutID = ? , commRepID = ?, commClientID = ?, "
            "commCommentaire = ? "
            "WHERE commID = ?;";
            
            /*
             @"CREATE TABLE IF NOT EXISTS LocalCommandes "
             "(commID INTEGER PRIMARY KEY AUTOINCREMENT, commStatutID INT, commRepID INT, commIDSAQ TEXT, "
             "commClientID INT, commTypeClntID INT, commCommTypeLivrID INT, commDateFact TEXT, "
             "commDelaiPickup INT, commDatePickup TEXT, commClientJourLivr TEXT, commPartSuccID INT, "
             "commCommentaire TEXT, commLastUpdated TEXT);"
             */
            
            sqlite3_stmt *insStmt;
            
            commID = [self.selectedOrder.commID intValue];
            int commRepID = [appDelegate.currLoggedUser intValue];
            int commClientID = [currentClient.clientID intValue];
            
            NSString *testChar = appDelegate.reservCommentaire;
            
            if(sqlite3_prepare_v2(database, update, -1, &insStmt, NULL) != SQLITE_OK)
                NSLog(@"Error while creating update statement. %s", sqlite3_errmsg(database));
            
            sqlite3_bind_int(insStmt, 1, commStatutID);
            sqlite3_bind_int(insStmt, 2, commRepID);
            sqlite3_bind_int(insStmt, 3, commClientID);
            sqlite3_bind_text(insStmt, 4, [testChar UTF8String], -1, NULL);
            sqlite3_bind_int(insStmt, 5, commID);
            
            sqlite3_exec(database, "COMMIT", NULL, NULL, &errmsg);
            
            if(SQLITE_DONE != sqlite3_step(insStmt)){
                NSLog(@"Error while updating. %s", sqlite3_errmsg(database));
                insertResult = @"Error";
            } else {
                sqlite3_finalize(insStmt);
                //long test = sqlite3_last_insert_rowid(database);
                //NSString * insertionID = [NSString stringWithFormat:@"%li", test];
                insertResult =  self.selectedOrder.commID;
            }
            
        }
        
        
    } else {
        
        char *update = "INSERT INTO LocalReservations "
        "(commStatutID, commRepID, commClientID, commCommentaire) "
        "VALUES (?, ?, ?, ?);";
        
        /*
         @"CREATE TABLE IF NOT EXISTS Reservations "
         "(commID INT PRIMARY KEY, commStatutID INT, commRepID INT, "
         "commClientID INT, commDateSaisie TEXT, "
         "commCommentaire TEXT, commLastUpdated TEXT);"
         */
        
        sqlite3_stmt *stmt;
        
        int commRepID = [appDelegate.currLoggedUser intValue];
        int commClientID = [currentClient.clientID intValue];
        
        NSString *testChar = appDelegate.reservCommentaire;
        
        if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)
            == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, commStatutID);
            sqlite3_bind_int(stmt, 2, commRepID);
            sqlite3_bind_int(stmt, 3, commClientID);
            sqlite3_bind_text(stmt, 4, [testChar UTF8String], -1, NULL);
        }
        
        if (sqlite3_step(stmt) != SQLITE_DONE){
            NSAssert(0, @"Error updating table: %s", errorMsg);
            insertResult = @"Error";
        } else {
            long test = sqlite3_last_insert_rowid(database);
            NSString * insertionID = [NSString stringWithFormat:@"%li", test];
            insertResult =  insertionID;
        }
        
        sqlite3_finalize(stmt);
    }
    
    return insertResult;
}


- (void)saveOrderItem:(NSString *)orderID prodID:(NSString *)prodID qty:(NSString *)qty {
    char *errorMsg = nil;
    
    char *update;
    if([self.selectedOrder.commDataSource isEqual:@"backend"]){
        update = "INSERT INTO ReservationItems "
        "(commItemCommID, commItemVinID, commItemVinQte) "
        "VALUES (?, ?, ?);";
        
    } else {
        update = "INSERT INTO LocalReservationItems "
        "(commItemCommID, commItemVinID, commItemVinQte) "
        "VALUES (?, ?, ?);";
    }
    
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if((self.selectedOrder != nil) && (![self.selectedOrder.commStatutID isEqual: @"6"])) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [appDelegate.reservProducts removeObjectAtIndex:indexPath.row];
        [appDelegate.reservQties removeObjectAtIndex:indexPath.row];
        [appDelegate.reservTransType removeObjectAtIndex:indexPath.row];
        
        [itemImageFiles removeObjectAtIndex:indexPath.row];
        [itemDetails removeObjectAtIndex:indexPath.row];
        [itemQties removeObjectAtIndex:indexPath.row];
        [itemPrixUnitaire removeObjectAtIndex:indexPath.row];
        [itemFraisTimbrage removeObjectAtIndex:indexPath.row];
        [itemFraisConsult removeObjectAtIndex:indexPath.row];
        [itemSubTotal removeObjectAtIndex:indexPath.row];
        
        productList = appDelegate.reservProducts;
        NSInteger arraySize = [productList count];
        
        varSubTotal = 0;
        varTotal = 0;
        
        for(int i = 0; i < arraySize; i++){
            Product *currProduct = nil;
            currProduct = [appDelegate.reservProducts objectAtIndex:i];
            
            double tmpCalc = [currProduct.vinPrixAchat doubleValue] + [currProduct.vinFraisEtiq doubleValue] + [currProduct.vinFraisBout doubleValue];
            
            double qtyTmp = [[appDelegate.reservQties objectAtIndex:i] doubleValue];
            double unitPriceTmp = tmpCalc;
            double subTotalTmp = qtyTmp * unitPriceTmp;
            
            varSubTotal = varSubTotal + subTotalTmp;
            varTotal = varSubTotal;
            
        }
        
        [tableView reloadData]; // tell table to refresh now
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toSelectClient"]){
        BIDSelectClientTableVC *clientSelectViewController = segue.destinationViewController;
        clientSelectViewController.pickupSource = @"Reservation";
        
    }
    
    if ([segue.identifier isEqualToString:@"toSelectProduct"]){
        BIDSelectProductTableVC *productSelectViewController = segue.destinationViewController;
        productSelectViewController.pickupSource = @"Reservation";
        
    }
    
}

@end
