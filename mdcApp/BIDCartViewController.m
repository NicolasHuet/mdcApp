//
//  BIDCartViewController.m
//  AssistantVente
//
//  Created by Nicolas Huet on 04/02/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import "BIDCartViewController.h"

NSMutableArray *itemImageFiles;
NSMutableArray *itemDetails;
NSMutableArray *itemQties;
NSMutableArray *itemFraisTimbrage;
NSMutableArray *itemFraisConsult;
NSMutableArray *itemFraisConsultPart;
NSMutableArray *itemPrixResto;
NSMutableArray *itemPrixPart;
NSMutableArray *itemSubTotalResto;
NSMutableArray *itemSubTotalPart;

Client *currentClient;
NSString *currentTypeLivr;
NSString *currentCommentaire;
NSString *currentDelaiPickup;
NSString *currentClientType;
NSMutableArray *productList;
MDCAppDelegate *appDelegate;

sqlite3 *database;

double varSubTotal;
double varTotalHon;
double varTotalSAQ;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    appDelegate.cartViewNeedsRefreshing = NO;
    
    appDelegate.cartTypeLivr = @"2";
    
    [self reloadViewFromDB];

    [[self tableView] reloadData];

    
}

-(void) viewWillAppear:(BOOL)animated
{
    varSubTotal = 0;
    varTotal = 0;
    varTotalHon = 0;
    varTotalSAQ = 0;
    
    itemImageFiles = [[NSMutableArray array] init];
    itemDetails = [[NSMutableArray array] init];
    itemQties = [[NSMutableArray array] init];
    itemFraisTimbrage = [[NSMutableArray array] init];
    itemFraisConsult = [[NSMutableArray array] init];
    itemFraisConsultPart = [[NSMutableArray array] init];
    itemPrixResto = [[NSMutableArray array] init];
    itemPrixPart = [[NSMutableArray array] init];
    itemSubTotalResto = [[NSMutableArray array] init];
    itemSubTotalPart = [[NSMutableArray array] init];
    
    MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray *productList = appDelegate.cartProducts;
    currentClient = appDelegate.sessionActiveClient;
    currentTypeLivr = appDelegate.cartTypeLivr;
    currentDelaiPickup = appDelegate.cartDelaiPickup;
    currentCommentaire = appDelegate.cartCommentaire;
    
    NSUInteger arraySize = [productList count];
    
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
        
        double tmpFraisConsultPart = [currProduct.vinFraisBoutPart doubleValue];
        [itemFraisConsultPart addObject:[NSString stringWithFormat:@"%.2f", tmpFraisConsultPart]];
        
        double tmpCalcResto = [currProduct.vinPrixAchat doubleValue] + [currProduct.vinFraisEtiq doubleValue];
        [itemPrixResto addObject:[NSString stringWithFormat:@"%.2f", tmpCalcResto]];
        
        double tmpCalcPart = [currProduct.vinPrixAchat doubleValue];
        [itemPrixPart addObject:[NSString stringWithFormat:@"%.2f", tmpCalcPart]];
        
        double qtyTmp = [[appDelegate.cartQties objectAtIndex:i] doubleValue];
        double subTotalResto = qtyTmp * (tmpCalcResto + tmpFraisConsult);
        double subTotalPart = qtyTmp * (tmpCalcPart + tmpFraisConsultPart);
        
        NSString *tmpSubTotalResto = [NSString stringWithFormat:@"%.2f $", subTotalResto];
        [itemSubTotalResto addObject:tmpSubTotalResto];
        
        NSString *tmpSubTotalPart = [NSString stringWithFormat:@"%.2f $", subTotalPart];
        [itemSubTotalPart addObject:tmpSubTotalPart];
        
        
        if(([appDelegate.sessionActiveClient.clientType isEqual:@"Particulier"]) || ([appDelegate.sessionActiveClient.clientType isEqual:@"Particulier avec SAQ"])){
            varTotalHon = varTotalHon + (qtyTmp * tmpFraisConsultPart);
            varTotalSAQ = varTotalSAQ + (qtyTmp * tmpCalcPart);
            varSubTotal = varSubTotal + subTotalPart;
        } else {
            varTotalHon = varTotalHon + (qtyTmp * tmpFraisConsult);
            varTotalSAQ = varTotalSAQ + (qtyTmp * tmpCalcResto);
            varSubTotal = varSubTotal + subTotalResto;
        }
        
        varTotal = varSubTotal;
    }

    [[self tableView] reloadData];
}

- (void)reloadViewFromDB {
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    varSubTotal = 0;
    varTotal = 0;
    
    itemImageFiles = [[NSMutableArray array] init];
    itemDetails = [[NSMutableArray array] init];
    itemQties = [[NSMutableArray array] init];
    itemFraisTimbrage = [[NSMutableArray array] init];
    itemFraisConsult = [[NSMutableArray array] init];
    itemFraisConsultPart = [[NSMutableArray array] init];
    itemPrixResto = [[NSMutableArray array] init];
    itemPrixPart = [[NSMutableArray array] init];
    itemSubTotalResto = [[NSMutableArray array] init];
    itemSubTotalPart = [[NSMutableArray array] init];
    
    
    if(self.selectedOrder != nil) {
        
        if([self.selectedOrder.commTypeLivrID isEqual: @"1"]) {
            if([self.selectedOrder.commDelaiPickup isEqual: @"24"]){
                appDelegate.cartTypeLivr = @"1a";
            } else {
                appDelegate.cartTypeLivr = @"1b";
            }
        } else {
            appDelegate.cartTypeLivr = @"2";
        }
        //appDelegate.cartTypeLivr = self.selectedOrder.commTypeLivrID;
        appDelegate.cartDelaiPickup = self.selectedOrder.commDelaiPickup;
        appDelegate.cartDateLivr = self.selectedOrder.commDatePickup;
        appDelegate.cartCommentaire = self.selectedOrder.commCommentaire;
        
        //appDelegate.cartProducts;
        
        
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
                    currentClientType = @"Resto";
                } else if(columnIntValue == 2){
                    clientType = @"Particulier";
                    currentClientType = @"Part";
                } else if(columnIntValue == 3){
                    clientType = @"Resto sans SAQ";
                    currentClientType = @"Resto";
                } else if(columnIntValue == 4){
                    clientType = @"Resto avec SAQ";
                    currentClientType = @"Resto";
                } else {
                    clientType = @"Particulier sans SAQ";
                    currentClientType = @"Part";
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
                
                appDelegate.sessionActiveClient = clientToAdd;
                
            }
            sqlite3_finalize(statement);
            
        }
        
        /*
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID == %@", self.selectedOrder.commClientID];
        NSArray *tmpClientLookup = [NSMutableArray arrayWithArray:[appDelegate.glClientArray filteredArrayUsingPredicate:predicate]];
        if(tmpClientLookup.count > 0){
            Client *tmpClient = [tmpClientLookup objectAtIndex:0];
            appDelegate.sessionActiveClient = tmpClient;
        } else {
            
        }
         */
        
        //NSString *query;
        //sqlite3_stmt *statement;
        
        if([self.selectedOrder.commDataSource  isEqual: @"local"]) {
            query = [NSString stringWithFormat:@"SELECT * FROM LocalCommandeItems WHERE commItemCommID = %@",self.selectedOrder.commID];
        } else {
            query = [NSString stringWithFormat:@"SELECT * FROM CommandeItems WHERE commItemCommID = %@",self.selectedOrder.commID];
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
        
        appDelegate.cartProducts = orderProductsArray;
        appDelegate.cartQties = orderQtiesArray;
        
    }
    
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
        
        double tmpFraisConsultPart = [currProduct.vinFraisBoutPart doubleValue];
        [itemFraisConsultPart addObject:[NSString stringWithFormat:@"%.2f", tmpFraisConsultPart]];
        
        double tmpCalcResto = [currProduct.vinPrixAchat doubleValue] + [currProduct.vinFraisEtiq doubleValue];
        [itemPrixResto addObject:[NSString stringWithFormat:@"%.2f", tmpCalcResto]];
        
        double tmpCalcPart = [currProduct.vinPrixAchat doubleValue];
        [itemPrixPart addObject:[NSString stringWithFormat:@"%.2f", tmpCalcPart]];
        
        double qtyTmp = [[appDelegate.cartQties objectAtIndex:i] doubleValue];
        double subTotalResto = qtyTmp * (tmpCalcResto + tmpFraisConsult);
        double subTotalPart = qtyTmp * (tmpCalcPart + tmpFraisConsultPart);
        
        NSString *tmpSubTotalResto = [NSString stringWithFormat:@"%.2f $", subTotalResto];
        [itemSubTotalResto addObject:tmpSubTotalResto];
        
        NSString *tmpSubTotalPart = [NSString stringWithFormat:@"%.2f $", subTotalPart];
        [itemSubTotalPart addObject:tmpSubTotalPart];
        
        
        if(([appDelegate.sessionActiveClient.clientType isEqual:@"Particulier"]) || ([appDelegate.sessionActiveClient.clientType isEqual:@"Particulier avec SAQ"])){
            varTotalHon = varTotalHon + (qtyTmp * tmpFraisConsultPart);
            varTotalSAQ = varTotalSAQ + (qtyTmp * tmpCalcPart);
            varSubTotal = varSubTotal + subTotalPart;
        } else {
            varTotalHon = varTotalHon + (qtyTmp * tmpFraisConsult);
            varTotalSAQ = varTotalSAQ + (qtyTmp * tmpCalcResto);
            varSubTotal = varSubTotal + subTotalResto;            
        }
        
        varTotal = varSubTotal;
        
    }
    
    sqlite3_close(database);
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
        
        [cell setBackgroundColor:[UIColor lightGrayColor]];
        
        if(currentClient == nil){
            UILabel *clientNameLabel = (UILabel *)[cell viewWithTag:110];
            clientNameLabel.text = @"Pas de client sélectionné";
            UILabel *clientContactLabel = (UILabel *)[cell viewWithTag:111];
            clientContactLabel.text = @"N/A";
            UILabel *clientTelLabel = (UILabel *)[cell viewWithTag:112];
            clientTelLabel.text = @"N/A";
            UILabel *clientNoSAQLabel = (UILabel *)[cell viewWithTag:114];
            clientNoSAQLabel.text = @"N/A";
            
        } else {
            UILabel *clientNameLabel = (UILabel *)[cell viewWithTag:110];
            clientNameLabel.text = currentClient.name;
            UILabel *clientContactLabel = (UILabel *)[cell viewWithTag:111];
            clientContactLabel.text = currentClient.personneRessource;
            UILabel *clientTelLabel = (UILabel *)[cell viewWithTag:112];
            clientTelLabel.text = currentClient.telephone;
            UILabel *clientNoSAQLabel = (UILabel *)[cell viewWithTag:114];
            clientNoSAQLabel.text = currentClient.clientIDSAQ;
        }
        
        UIImageView *clientImageView = (UIImageView *)[cell viewWithTag:113];
        if([currentClient.clientType  isEqual: @"Hotel"]){
            clientImageView.image = [UIImage imageNamed:@"hotel"];
        } else if([currentClient.clientType  isEqual: @"Particulier"]){
            clientImageView.image = [UIImage imageNamed:@"particulier"];
        } else if([currentClient.clientType  isEqual: @"Particulier sans SAQ"]){
            clientImageView.image = [UIImage imageNamed:@"particulier"];
        } else {
            clientImageView.image = [UIImage imageNamed:@"restaurant"];
        }
        if(currentClient == nil){
            clientImageView.hidden = YES;
        } else {
            clientImageView.hidden = NO;
        }
        
    }
    if([indexPath section] == 1){
        static NSString *CellIdentifier = @"subtotalCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell setBackgroundColor:[UIColor lightGrayColor]];
        
        if((self.selectedOrder != nil) && (![self.selectedOrder.commStatutID isEqual: @"1"])) {
            UIButton *addProductButton = (UIButton *)[cell viewWithTag:600];
            addProductButton.hidden = YES;
            UIButton *submitDraftButton = (UIButton *)[cell viewWithTag:603];
            submitDraftButton.hidden = YES;
            UIButton *submitOrderButton = (UIButton *)[cell viewWithTag:602];
            submitOrderButton.hidden = YES;
            
            UITextField *commDatePickup = (UITextField *)[cell viewWithTag:200];
            commDatePickup.text = appDelegate.cartDateLivr;
            commDatePickup.enabled = NO;
            UITextField *commCommentaire = (UITextField *)[cell viewWithTag:201];
            commCommentaire.text = appDelegate.cartCommentaire;
            commCommentaire.enabled = NO;
            
            UILabel *commIDSAQLbl = (UILabel *)[cell viewWithTag:204];
            commIDSAQLbl.hidden = NO;
            UILabel *commIDSAQ = (UILabel *)[cell viewWithTag:205];
            commIDSAQ.text = self.selectedOrder.commIDSAQ;
            
            
        } else {
            UIButton *livrTypeSelect= (UIButton *)[cell viewWithTag:203];
            [livrTypeSelect addTarget:self action:@selector(presentAllDeliveryOptions:) forControlEvents:UIControlEventTouchUpInside];
            
            UITextField *commDatePickup = (UITextField *)[cell viewWithTag:200];
            [commDatePickup setDelegate:self];
            
            UILabel *commIDSAQLbl = (UILabel *)[cell viewWithTag:204];
            commIDSAQLbl.hidden = YES;
            UILabel *commIDSAQ = (UILabel *)[cell viewWithTag:205];
            commIDSAQ.hidden = YES;
            
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
        }
        
        UILabel *totalHonLabel = (UILabel *)[cell viewWithTag:215];
        UILabel *totalLabelSAQ = (UILabel *)[cell viewWithTag:214];
        UILabel *totalLabel = (UILabel *)[cell viewWithTag:213];
        
        totalHonLabel.text = [NSString stringWithFormat:@"$%.2f",varTotalHon];
        totalLabelSAQ.text = [NSString stringWithFormat:@"$%.2f",varTotalSAQ];
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
        productUnitPriceLabel.text = [itemPrixResto objectAtIndex:[indexPath row]];
        
        UILabel *productFraisTimbrLabel = (UILabel *)[cell viewWithTag:105];
        productFraisTimbrLabel.text = [itemFraisTimbrage objectAtIndex:[indexPath row]];
        
        UILabel *productFraisConsultLabel = (UILabel *)[cell viewWithTag:106];
        productFraisConsultLabel.text = [itemFraisConsult objectAtIndex:[indexPath row]];
        
        UILabel *productFraisConsultPartLabel = (UILabel *)[cell viewWithTag:107];
        productFraisConsultPartLabel.text = [itemFraisConsultPart objectAtIndex:[indexPath row]];
        
        UILabel *productSTLabel = (UILabel *)[cell viewWithTag:104];
        
        if([currentClientType  isEqual: @"Part"]){
            productSTLabel.text = [itemSubTotalPart objectAtIndex:[indexPath row]];
        } else {
            productSTLabel.text = [itemSubTotalResto objectAtIndex:[indexPath row]];
        }
        
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowSize;
    
    if(indexPath.section == 0){
        rowSize = 130;
    } else if(indexPath.section == 2){
        rowSize = 140;
    } else {
        rowSize = 225;
    }
    return rowSize;
}

- (IBAction)selectClient:(id)sender {
    [self performSegueWithIdentifier:@"toSelectClient" sender:nil];
}

- (IBAction)addProductAction:(id)sender {
    if(appDelegate.cartProducts.count > 11){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Vous ne pouvez ajouter plus de 12 produits sur une commande !" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        actionSheet.tag = 7;
        
        [actionSheet showInView:self.view];
    } else {
        [self performSegueWithIdentifier:@"toSelectProduct" sender:nil];
    }
    
}

- (IBAction)confirmTransaction:(id)sender {
    
    bool doSubmit = YES;
    
    if(appDelegate.sessionActiveClient == nil) {
        doSubmit = NO;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Vous devez sélectionner le client !" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        actionSheet.tag = 4;
        
        [actionSheet showInView:self.view];
    }
    
    if(appDelegate.cartProducts.count < 1) {
        doSubmit = NO;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Vous devez ajouter au moins 1 produit !" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        actionSheet.tag = 5;
        
        [actionSheet showInView:self.view];
    }
    
    if(doSubmit){
    
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Êtes-vous certain de vouloir soumettre la commande en mode révision? (Vous ne pourrez plus modifier la commande par la suite)." delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Soumettre" otherButtonTitles:@"Non", nil];
    
        actionSheet.tag = 2;
    
        [actionSheet showInView:self.view];
    }
}

- (IBAction)saveTransactionDraft:(id)sender {
    
    bool doSubmit = YES;
    
    if(appDelegate.sessionActiveClient == nil) {
        doSubmit = NO;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Vous devez sélectionner le client !" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        actionSheet.tag = 4;
        
        [actionSheet showInView:self.view];
    }
    
    if(appDelegate.cartProducts.count < 1) {
        doSubmit = NO;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Vous devez ajouter au moins 1 produit !" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        actionSheet.tag = 5;
        
        [actionSheet showInView:self.view];
    }
    
    if(doSubmit){
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Êtes-vous certain de vouloir sauvegarder la commande en mode brouillon? (La commande ne sera pas expédiée à la SAQ tant qu'elle ne sera pas soumise pour révision)." delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Sauvegarder" otherButtonTitles:@"Non", nil];
        
        actionSheet.tag = 6;
        
        [actionSheet showInView:self.view];
    }
}

- (IBAction)cancelTransaction:(id)sender {
    
    if(self.selectedOrder != nil) {
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
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Supprimer la commande?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Supprimer" otherButtonTitles:@"Non", nil];
        
        actionSheet.tag = 1;
        
        [actionSheet showInView:self.view];
    }
    
}

- (void)presentAllDeliveryOptions:(id)sender{
    
    NSMutableArray *titleArray = [[NSMutableArray alloc] init];
    
    [titleArray addObject:@"Livraison"];
    //[titleArray addObject:@"Pickup"];
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
                if ([self.commCommentaire.text length] > 0 || self.commCommentaire.text != nil || [self.commCommentaire.text isEqual:@""] == FALSE){
                    appDelegate.cartCommentaire = self.commCommentaire.text;
                }
                NSString * statusSave = [self saveOrder:@"Revision"];
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
                
            } else if (buttonIndex == 1){
                NSLog(@"Pressed button 2 - Pickup 24h");
                //MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.cartTypeLivr = @"1a";
                [[self tableView] reloadData];
            } else if (buttonIndex == 2){
                NSLog(@"Pressed button 2 - Pickup 48h");
                //MDCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.cartTypeLivr = @"1b";
                [[self tableView] reloadData];
            }
            break;
        
        case 6:
            if(buttonIndex == 0){
                NSLog(@"Pressed button 0");
                if ([self.commCommentaire.text length] > 0 || self.commCommentaire.text != nil || [self.commCommentaire.text isEqual:@""] == FALSE){
                    appDelegate.cartCommentaire = self.commCommentaire.text;
                }
                NSString * statusSave = [self saveOrder:@"Draft"];
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
            
        case 7:
            if(buttonIndex == 0){
                //NSLog(@"Pressed button 1 - 'Non' - Do nothing");
            } else if (buttonIndex == 1){
                //NSLog(@"Pressed button 2");
            }
            break;
            
        default:
            break;
    }
}


- (NSString *)saveOrder:(NSString *) orderStatus {
    
    appDelegate.ordersViewNeedsRefreshing = YES;
    
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
    int commStatutID;
    if([orderStatus isEqual:@"Draft"]){
        commStatutID = 1;
    } else {
        commStatutID = 2;
    }
    
    NSString * insertResult;
    
    if(self.selectedOrder != nil) {
        if([self.selectedOrder.commDataSource isEqual:@"backend"]){
                
            sqlite3_stmt *stmt;
            char *del_stmt = "DELETE FROM CommandeItems WHERE commItemCommID = ?";
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
            
            char *update = "UPDATE Commandes SET "
            "commStatutID = ? , commRepID = ?, commClientID = ?, commTypeClntID = ?, commCommTypeLivrID= ?, "
            "commDelaiPickup= ?, commDatePickup = ?, commCommentaire = ?, commDateFact = ?, commIsDraftModified = ? "
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
            int commTypeLivr;
            int commDelaiPickup;
            int commIsDraftModified = 1;
            
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
            } else {
                commTypeLivr = 2;
                commDelaiPickup = 0;
            }
            
            NSString *datePickup = appDelegate.cartDateLivr;
            NSString *testChar = appDelegate.cartCommentaire;
            
            if(sqlite3_prepare_v2(database, update, -1, &insStmt, NULL) != SQLITE_OK)
                NSLog(@"Error while creating update statement. %s", sqlite3_errmsg(database));
            
            sqlite3_bind_int(insStmt, 1, commStatutID);
            sqlite3_bind_int(insStmt, 2, commRepID);
            sqlite3_bind_int(insStmt, 3, commClientID);
            sqlite3_bind_int(insStmt, 4, clientTypeClntID);
            sqlite3_bind_int(insStmt, 5, commTypeLivr);
            sqlite3_bind_int(insStmt, 6, commDelaiPickup);
            sqlite3_bind_text(insStmt, 7, [datePickup UTF8String], -1, NULL);
            sqlite3_bind_text(insStmt, 8, [testChar UTF8String], -1, NULL);
            sqlite3_bind_text(insStmt, 9, [@"" UTF8String], -1, NULL);
            sqlite3_bind_int(insStmt, 10, commIsDraftModified);
            sqlite3_bind_int(insStmt, 11, commID);
            
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
            
            //NSString *sql = [NSString stringWithFormat:@"DELETE FROM LocalCommandeItem WHERE commItemCommID = %@",@"?"];
            sqlite3_stmt *stmt;
            char *del_stmt = "DELETE FROM LocalCommandeItems WHERE commItemCommID = ?";
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
            
            char *update = "UPDATE LocalCommandes SET "
            "commStatutID = ? , commRepID = ?, commClientID = ?, commTypeClntID = ?, commCommTypeLivrID= ?, "
            "commDelaiPickup= ?, commDatePickup = ?, commCommentaire = ?, commDateFact = ? "
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
            } else {
                commTypeLivr = 2;
                commDelaiPickup = 0;
            }
            
            NSString *datePickup = appDelegate.cartDateLivr;
            NSString *testChar = appDelegate.cartCommentaire;
            
            if(sqlite3_prepare_v2(database, update, -1, &insStmt, NULL) != SQLITE_OK)
                NSLog(@"Error while creating update statement. %s", sqlite3_errmsg(database));
            
                sqlite3_bind_int(insStmt, 1, commStatutID);
                sqlite3_bind_int(insStmt, 2, commRepID);
                sqlite3_bind_int(insStmt, 3, commClientID);
                sqlite3_bind_int(insStmt, 4, clientTypeClntID);
                sqlite3_bind_int(insStmt, 5, commTypeLivr);
                sqlite3_bind_int(insStmt, 6, commDelaiPickup);
                sqlite3_bind_text(insStmt, 7, [datePickup UTF8String], -1, NULL);
                sqlite3_bind_text(insStmt, 8, [testChar UTF8String], -1, NULL);
                sqlite3_bind_text(insStmt, 9, [@"" UTF8String], -1, NULL);
                sqlite3_bind_int(insStmt, 10, commID);
            
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
            insertResult = @"Error";
        } else {
            long test = sqlite3_last_insert_rowid(database);
            NSString * insertionID = [NSString stringWithFormat:@"%li", test];
            insertResult =  insertionID;
        }
        
        sqlite3_finalize(stmt);
    }
    
    return insertResult;
    sqlite3_close(database);
}


- (void)saveOrderItem:(NSString *)orderID prodID:(NSString *)prodID qty:(NSString *)qty {
    char *errorMsg = nil;
    
    char *update;
    if([self.selectedOrder.commDataSource isEqual:@"backend"]){
        update = "INSERT INTO CommandeItems "
        "(commItemCommID, commItemVinID, commItemVinQte) "
        "VALUES (?, ?, ?);";
        
    } else {
        update = "INSERT INTO LocalCommandeItems "
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        if((self.selectedOrder == nil) || ([self.selectedOrder.commStatutID isEqual: @"1"])){
            static NSString *CellIdentifier = @"itemCell";
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell.reuseIdentifier isEqualToString:CellIdentifier])
            {
                [self performSegueWithIdentifier:@"toProdEdit" sender:cell];
            }
        }
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        if((self.selectedOrder != nil) && (![self.selectedOrder.commStatutID isEqual: @"1"])) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [appDelegate.cartProducts removeObjectAtIndex:indexPath.row];
        [appDelegate.cartQties removeObjectAtIndex:indexPath.row];
        [appDelegate.cartTransType removeObjectAtIndex:indexPath.row];

        [itemImageFiles removeObjectAtIndex:indexPath.row];
        [itemDetails removeObjectAtIndex:indexPath.row];
        [itemQties removeObjectAtIndex:indexPath.row];
        [itemFraisTimbrage removeObjectAtIndex:indexPath.row];
        [itemFraisConsult removeObjectAtIndex:indexPath.row];
        [itemFraisConsultPart removeObjectAtIndex:indexPath.row];
        [itemPrixResto removeObjectAtIndex:indexPath.row];
        [itemPrixPart removeObjectAtIndex:indexPath.row];
        [itemSubTotalResto removeObjectAtIndex:indexPath.row];
        [itemSubTotalPart removeObjectAtIndex:indexPath.row];
        
        productList = appDelegate.cartProducts;
        NSInteger arraySize = [productList count];
        
        varSubTotal = 0;
        varTotal = 0;
        varTotalHon = 0;
        varTotalSAQ = 0;
        
        for(int i = 0; i < arraySize; i++){
            Product *currProduct = nil;
            currProduct = [appDelegate.cartProducts objectAtIndex:i];
            
            double qtyTmp = [[appDelegate.cartQties objectAtIndex:i] doubleValue];
            double tmpCalcSAQ;
            double tmpCalcHon;
            
            if(([appDelegate.sessionActiveClient.clientType isEqual:@"Particulier"]) || ([appDelegate.sessionActiveClient.clientType isEqual:@"Particulier avec SAQ"])){
                tmpCalcSAQ = [currProduct.vinPrixAchat doubleValue];
                tmpCalcHon = [currProduct.vinFraisBoutPart doubleValue];
                varTotalHon = varTotalHon + (qtyTmp * tmpCalcHon);
                varTotalSAQ = varTotalSAQ + (qtyTmp * tmpCalcSAQ);
                
                double subTotalPart = qtyTmp * (tmpCalcHon + tmpCalcSAQ);
                varSubTotal = varSubTotal + subTotalPart;
            } else {
                tmpCalcSAQ = [currProduct.vinPrixAchat doubleValue] + [currProduct.vinFraisBout doubleValue];
                tmpCalcHon = [currProduct.vinFraisBout doubleValue];
                varTotalHon = varTotalHon + (qtyTmp * tmpCalcHon);
                varTotalSAQ = varTotalSAQ + (qtyTmp * tmpCalcSAQ);
                
                double subTotalResto = qtyTmp * (tmpCalcHon + tmpCalcSAQ);
                varSubTotal = varSubTotal + subTotalResto;
            }
        }
        
        [tableView reloadData]; // tell table to refresh now
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toSelectClient"]){
        
        BIDSelectClientTableVC *clientSelectViewController = segue.destinationViewController;
        clientSelectViewController.pickupSource = @"Commande";
        
    }
    
    if ([segue.identifier isEqualToString:@"toSelectProduct"]){
        
        BIDSelectProductTableVC *productSelectViewController = segue.destinationViewController;
        productSelectViewController.pickupSource = @"Commande";
        
    }
    
    if ([segue.identifier isEqualToString:@"toProdEdit"])
    {
        Product *product = nil;
        

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        product = [appDelegate.cartProducts objectAtIndex:indexPath.row];

        BIDProdDetailsViewController *prodDetailsViewController = segue.destinationViewController;
        prodDetailsViewController.isInEditMode = YES;
        prodDetailsViewController.product = product;
        prodDetailsViewController.currProductQty = [[appDelegate.cartQties objectAtIndex:indexPath.row] intValue];
        prodDetailsViewController.cartArrayIndex = indexPath.row;
        prodDetailsViewController.pickupSource = @"Commande";
    }
    
    
}


@end
