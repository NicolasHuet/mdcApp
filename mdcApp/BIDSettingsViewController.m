//
//  BIDSettingsViewController.m
//  mdcApp
//
//  Created by Nicolas Huet on 2014-08-24.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import "BIDSettingsViewController.h"

sqlite3 *database;
NSString * userCodeToReturn;
NSString * userCodeRoleToReturn;
MDCAppDelegate *appDelegate;

NSData *jsonData;
NSData *jsonDataForModified;
NSData *jsonDataReservations;
NSData *jsonDataForModifiedReservations;

@implementation BIDSettingsViewController

@synthesize orderArray;
@synthesize orderItemsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *versionNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *versionMsg = @"Version de l'app Maitre de Chai : ";
    self.versionLabelCheck.text = [NSString stringWithFormat:@"%@ %@", versionMsg, versionNum];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)instancAction {
    
    [self convertLocalOrdersToJson];
    [self convertModifiedSynchedOrdersToJson];
    [self convertLocalReservationsToJson];
    [self convertModifiedSynchedReservationsToJson];
    
    [self checkConnectivityForFull];
    
}

- (IBAction)ordersSync:(id)sender {
    
    [self convertLocalOrdersToJson];
    [self convertModifiedSynchedOrdersToJson];
    [self convertLocalReservationsToJson];
    [self convertModifiedSynchedReservationsToJson];
    
    [self checkConnectivity];
    
}


- (IBAction)fullSyncCheck:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Voulez vous vraiment lancer la synchronisation?" delegate:self cancelButtonTitle:@"Annuler" destructiveButtonTitle:@"Annuler" otherButtonTitles:@"Oui", nil];
    
    actionSheet.tag = 1;
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (actionSheet.tag) {
        case 1:
            if(buttonIndex == 0){
                NSLog(@"Pressed button 0 - Do Nothing");
                
            } else if(buttonIndex == 1){
                NSLog(@"Pressed button 1 - Perform Sync");
                [self instancAction];
                
            } else if (buttonIndex == 2){
                NSLog(@"Pressed button 2");
            }
            break;
            
        case 2:
            if(buttonIndex == 0){
                //NSLog(@"Pressed button 0 - Do Nothing");
                
            } else if (buttonIndex == 1){
                //NSLog(@"Pressed button 2");
            }
            break;
    }
}


- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"mdc.sqlite"];
}


- (void)performSyncWithLogin {
    
    
    
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
                                                                       userCodeToReturn = [[rows objectAtIndex:i] objectForKey:@"idRep"];
                                                                       userCodeRoleToReturn = [[rows objectAtIndex:i] objectForKey:@"userRole"];
                                                                       
                                                                       appDelegate = [[UIApplication sharedApplication] delegate];
                                                                       appDelegate.currLoggedUser = userCodeToReturn;
                                                                       appDelegate.currLoggedUserRole = userCodeRoleToReturn;
                                                                       
                                                                       NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                                       
                                                                       [userDefaults setObject:userCodeToReturn forKey:@"UserCode"];
                                                                       [userDefaults setObject:userCodeRoleToReturn forKey:@"UserRole"];
                                                                       [userDefaults synchronize];
                                                                       
                                                                       [self updateVinsTable];
                                                                       [self updateClientsTable];
                                                                       [self updateCommandesTable];
                                                                       
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

- (void) instantiateLocalDB {
    
    // Local database initialization
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    char *errorMsg;
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS TypeClient "
    "(typeClntID INT PRIMARY KEY, typeClntName TEXT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    NSString *dropClientsSQL = @"DROP TABLE IF EXISTS Clients;";
    
    if (sqlite3_exec (database, [dropClientsSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS Clients "
    "(clientID INT PRIMARY KEY, clientName TEXT, clientAdr1 TEXT, "
    "clientAdr2 TEXT, clientVille TEXT, clientProv TEXT, clientCodePostal TEXT, "
    "clientTelComp TEXT, clientContact TEXT, clientEmail TEXT,clientTel1 TEXT, "
    "clientTel2 TEXT, clientTel3 TEXT,clientFactContact TEXT, clientFactEmail TEXT, "
    "clientFactTel1 TEXT, clientTypeClntID INT, clientIDSAQ TEXT, clientActif INT, "
    "clientTypeLivrID INT,clientSuccLivr INT, clientTypeFact INT, clientFactMensuelle INT, "
    "clientTitulaireID INT, clientLivrJourFixe TEXT, clientNoMembre TEXT, clientEnvoiFact INT "
    ");";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    NSString *dropVinsSQL = @"DROP TABLE IF EXISTS Vins;";
    
    if (sqlite3_exec (database, [dropVinsSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS Vins "
    "(vinID INT PRIMARY KEY, vinNumero TEXT, vinNom TEXT, vinCouleurID INT, "
    "vinEmpaq INT, vinRegionID INT, vinNoDemande TEXT, vinIDFournisseur TEXT, vinDateAchat TEXT, "
    "vinQteAchat INT, vinTotalAssigned INT, vinFormat TEXT, vinPrixAchat REAL, vinFraisEtiq REAL, "
    "vinFraisBout REAL, vinFraisBoutPart REAL, vinPrixVente REAL, vinEpuise INT, vinDisponible INT"
    ");";
    
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
    
    NSString *dropReservationsSQL = @"DROP TABLE IF EXISTS LocalCommandes;";
    
    if (sqlite3_exec (database, [dropReservationsSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS LocalCommandes "
    "(commID INTEGER PRIMARY KEY AUTOINCREMENT, commStatutID INT, commRepID INT, commIDSAQ TEXT, "
    "commClientID INT, commTypeClntID INT, commCommTypeLivrID INT, commDateFact TEXT, "
    "commDelaiPickup INT, commDatePickup TEXT, commClientJourLivr TEXT, commPartSuccID INT, "
    "commCommentaire TEXT, commLastUpdated TEXT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    dropReservationsSQL = @"DROP TABLE IF EXISTS LocalCommandeItems;";
    
    if (sqlite3_exec (database, [dropReservationsSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error dropping table: %s", errorMsg);
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS LocalCommandeItems "
    "(commItemID INTEGER PRIMARY KEY AUTOINCREMENT, commItemCommID INT, commItemVinID INT, commItemVinQte INT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    dropReservationsSQL = @"DROP TABLE IF EXISTS Reservations;";
    
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
    [spinner stopAnimating];
    
}

- (void) updateTypeClientTable {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    char *errorMsg = nil;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/typesClientJson.php", appDelegate.syncServer];
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
                                                               
                                                               char *update = "INSERT OR REPLACE INTO TypeClient "
                                                               "(typeClntID, typeClntName) "
                                                               "VALUES (?, ?);";
                                                               
                                                               sqlite3_stmt *stmt;
                                                               
                                                               int testInt;
                                                               testInt = [[[rows objectAtIndex:i] objectForKey:@"typeID"]intValue];
                                                               
                                                               NSString * testChar;
                                                               testChar = [[rows objectAtIndex:i] objectForKey:@"typeDescription"];
                                                               if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)
                                                                   == SQLITE_OK) {
                                                                   sqlite3_bind_int(stmt, 1, testInt);
                                                                   sqlite3_bind_text(stmt, 2, [testChar UTF8String], -1, NULL);
                                                               }
                                                               
                                                               if (sqlite3_step(stmt) != SQLITE_DONE)
                                                                   NSAssert(0, @"Error updating table: %s", errorMsg);
                                                               sqlite3_finalize(stmt);
                                                               
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   [spinner stopAnimating];
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) updateClientsTable {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    NSString * repID = appDelegate.currLoggedUser;
    
    char *errorMsg = nil;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/clientsRepJson.php?repID=%@", appDelegate.syncServer, repID];
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
                                                               
                                                               char *update = "INSERT INTO Clients "
                                                               "(clientID, clientName, clientAdr1, clientVille, clientProv, clientCodePostal, clientContact, clientTel1, clientTypeClntID, clientIDSAQ, clientTitulaireID, clientTypeLivrID, clientTypeFact, clientLivrJourFixe) "
                                                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
                                                               
                                                               sqlite3_stmt *stmt;
                                                               
                                                               int clientID;
                                                               clientID = [[[rows objectAtIndex:i] objectForKey:@"clientID"]intValue];
                                                               
                                                               NSString * clientName;
                                                               clientName = [[rows objectAtIndex:i] objectForKey:@"clientName"];
                                                               
                                                               NSString * clientAdr1;
                                                               clientAdr1 = [[rows objectAtIndex:i] objectForKey:@"clientAddress"];
                                                               
                                                               NSString * clientVille;
                                                               clientVille = [[rows objectAtIndex:i] objectForKey:@"clientVille"];
                                                               
                                                               NSString * clientProv;
                                                               clientProv = [[rows objectAtIndex:i] objectForKey:@"clientProv"];
                                                               
                                                               NSString * clientCodePostal;
                                                               clientCodePostal = [[rows objectAtIndex:i] objectForKey:@"clientCodePostal"];
                                                               
                                                               NSString * clientContact;
                                                               clientContact = [[rows objectAtIndex:i] objectForKey:@"clientContact"];
                                                               
                                                               NSString * clientTel1;
                                                               clientTel1 = [[rows objectAtIndex:i] objectForKey:@"clientTel1"];
                                                               
                                                               int typeClient;
                                                               typeClient = [[[rows objectAtIndex:i] objectForKey:@"clientType"]intValue];
                                                               
                                                               NSString * clientIDSAQ;
                                                               clientIDSAQ = [[rows objectAtIndex:i] objectForKey:@"clientIDSAQ"];
                                                               
                                                               int clientTitulaireID;
                                                               clientTitulaireID = [[[rows objectAtIndex:i] objectForKey:@"clientTitulaireID"]intValue];
                                                               
                                                               int clientTypeLivrID;
                                                               clientTypeLivrID = [[[rows objectAtIndex:i] objectForKey:@"clientTypeLivrID"]intValue];
                                                               
                                                               int clientTypeFact;
                                                               clientTypeFact = [[[rows objectAtIndex:i] objectForKey:@"clientTypeFact"]intValue];
                                                               
                                                               NSString * clientJourLivr;
                                                               clientJourLivr = [[rows objectAtIndex:i] objectForKey:@"clientJourLivr"];
                                                               
                                                               /*
                                                                NSLog(@"ID: %i",clientID);
                                                                NSLog(@"Nom: %@",clientName);
                                                                NSLog(@"Add: %@",clientAdr1);
                                                                NSLog(@"Ville: %@",clientVille);
                                                                NSLog(@"Prov: %@",clientProv);
                                                                NSLog(@"CP: %@",clientCodePostal);
                                                                NSLog(@"Cont: %@",clientContact);
                                                                NSLog(@"Tel: %@",clientTel1);
                                                                NSLog(@"Type: %i",typeClient);
                                                                */
                                                               
                                                               if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)
                                                                   == SQLITE_OK) {
                                                                   sqlite3_bind_int(stmt, 1, clientID);
                                                                   sqlite3_bind_text(stmt, 2, [clientName UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 3, [clientAdr1 UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 4, [clientVille UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 5, [clientProv UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 6, [clientCodePostal UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 7, [clientContact UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 8, [clientTel1 UTF8String], -1, NULL);
                                                                   sqlite3_bind_int(stmt, 9, typeClient);
                                                                   sqlite3_bind_text(stmt, 10, [clientIDSAQ UTF8String], -1, NULL);
                                                                   sqlite3_bind_int(stmt, 11, clientTitulaireID);
                                                                   sqlite3_bind_int(stmt, 12, clientTypeLivrID);
                                                                   sqlite3_bind_int(stmt, 13, clientTypeFact);
                                                                   sqlite3_bind_text(stmt, 14, [clientJourLivr UTF8String], -1, NULL);
                                                               }
                                                               
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
                                                               
                                                               if (sqlite3_step(stmt) != SQLITE_DONE)
                                                                   NSAssert(0, @"Error updating table: %s", errorMsg);
                                                               sqlite3_finalize(stmt);
                                                               
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   [spinner stopAnimating];
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) updateVinsTable {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    char *errorMsg = nil;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/vinsJson.php", appDelegate.syncServer];
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
                                                               
                                                               char *update = "INSERT INTO Vins "
                                                               "(vinID, vinNumero, vinNom, vinCouleurID, vinEmpaq, vinRegionID, "
                                                               "vinNoDemande, vinIDFournisseur, vinDateAchat, vinQteAchat, vinTotalAssigned, "
                                                               "vinFormat, vinPrixAchat, vinFraisEtiq, vinFraisBout, vinFraisBoutPart, "
                                                               "vinPrixVente, vinEpuise, vinDisponible) "
                                                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
                                                               
                                                               sqlite3_stmt *stmt;
                                                               
                                                               int vinID;
                                                               vinID = [[[rows objectAtIndex:i] objectForKey:@"vinID"]intValue];
                                                               
                                                               NSString * vinNumero;
                                                               vinNumero = [[rows objectAtIndex:i] objectForKey:@"vinNumero"];
                                                               
                                                               NSString * vinNom;
                                                               vinNom = [[rows objectAtIndex:i] objectForKey:@"vinNom"];
                                                               
                                                               int vinCouleurID;
                                                               vinCouleurID = [[[rows objectAtIndex:i] objectForKey:@"vinCouleurID"]intValue];
                                                               
                                                               int vinEmpaq;
                                                               vinEmpaq = [[[rows objectAtIndex:i] objectForKey:@"vinEmpaq"]intValue];
                                                               
                                                               int vinRegionID;
                                                               vinRegionID = [[[rows objectAtIndex:i] objectForKey:@"vinRegionID"]intValue];
                                                               
                                                               NSString * vinNoDemande;
                                                               vinNoDemande = [[rows objectAtIndex:i] objectForKey:@"vinNoDemande"];
                                                               
                                                               NSString * vinIDFournisseur;
                                                               vinIDFournisseur = [[rows objectAtIndex:i] objectForKey:@"vinIDFournisseur"];
                                                               
                                                               NSString * vinDateAchat;
                                                               vinDateAchat = [[rows objectAtIndex:i] objectForKey:@"vinDateAchat"];
                                                               
                                                               int vinQteAchat;
                                                               vinQteAchat = [[[rows objectAtIndex:i] objectForKey:@"vinQteAchat"]intValue];
                                                               
                                                               int vinTotalAssigned;
                                                               vinTotalAssigned = [[[rows objectAtIndex:i] objectForKey:@"vinTotalAssigned"]intValue];
                                                               
                                                               NSString * vinFormat;
                                                               vinFormat = [[rows objectAtIndex:i] objectForKey:@"vinFormat"];
                                                               
                                                               double vinPrixAchat;
                                                               vinPrixAchat = [[[rows objectAtIndex:i] objectForKey:@"vinPrixAchat"]doubleValue];
                                                               
                                                               double vinFraisEtiq;
                                                               vinFraisEtiq = [[[rows objectAtIndex:i] objectForKey:@"vinFraisEtiq"]doubleValue];
                                                               
                                                               double vinFraisBout;
                                                               vinFraisBout = [[[rows objectAtIndex:i] objectForKey:@"vinFraisBout"]doubleValue];
                                                               
                                                               double vinFraisBoutPart;
                                                               vinFraisBoutPart = [[[rows objectAtIndex:i] objectForKey:@"vinFraisBoutPart"]doubleValue];
                                                               
                                                               double vinPrixVente;
                                                               vinPrixVente = [[[rows objectAtIndex:i] objectForKey:@"vinPrixVente"]doubleValue];
                                                               
                                                               int vinEpuise;
                                                               vinEpuise = [[[rows objectAtIndex:i] objectForKey:@"vinEpuise"]intValue];
                                                               
                                                               int vinDisponible;
                                                               vinDisponible = [[[rows objectAtIndex:i] objectForKey:@"vinDisponible"]intValue];
                                                               
                                                               /*
                                                                vinID,
                                                                vinNumero,
                                                                vinNom,
                                                                vinCouleurID,
                                                                vinEmpaq,
                                                                vinRegionID,
                                                                vinNoDemande,
                                                                vinIDFournisseur,
                                                                vinDateAchat,
                                                                vinQteAchat,
                                                                vinTotalAssigned,
                                                                vinFormat,
                                                                vinPrixAchat,
                                                                vinFraisEtiq,
                                                                vinFraisBout,
                                                                vinFraisBoutPart,
                                                                vinPrixVente,
                                                                vinEpuise,
                                                                vinDisponible
                                                                */
                                                               
                                                               if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)
                                                                   == SQLITE_OK) {
                                                                   sqlite3_bind_int(stmt, 1, vinID);
                                                                   sqlite3_bind_text(stmt, 2, [vinNumero UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 3, [vinNom UTF8String], -1, NULL);
                                                                   sqlite3_bind_int(stmt, 4, vinCouleurID);
                                                                   sqlite3_bind_int(stmt, 5, vinEmpaq);
                                                                   sqlite3_bind_int(stmt, 6, vinRegionID);
                                                                   sqlite3_bind_text(stmt, 7, [vinNoDemande UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 8, [vinIDFournisseur UTF8String], -1, NULL);
                                                                   sqlite3_bind_text(stmt, 9, [vinDateAchat UTF8String], -1, NULL);
                                                                   sqlite3_bind_int(stmt, 10, vinQteAchat);
                                                                   sqlite3_bind_int(stmt, 11, vinTotalAssigned);
                                                                   sqlite3_bind_text(stmt, 12, [vinFormat UTF8String], -1, NULL);
                                                                   
                                                                   sqlite3_bind_double(stmt, 13, vinPrixAchat);
                                                                   sqlite3_bind_double(stmt, 14, vinFraisEtiq);
                                                                   sqlite3_bind_double(stmt, 15, vinFraisBout);
                                                                   sqlite3_bind_double(stmt, 16, vinFraisBoutPart);
                                                                   sqlite3_bind_double(stmt, 17, vinPrixVente);
                                                                   
                                                                   sqlite3_bind_int(stmt, 18, vinEpuise);
                                                                   sqlite3_bind_int(stmt, 19, vinDisponible);
                                                                   
                                                               }
                                                               
                                                               if (sqlite3_step(stmt) != SQLITE_DONE)
                                                                   NSAssert(0, @"Error updating table: %s", errorMsg);
                                                               sqlite3_finalize(stmt);
                                                               
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   [spinner stopAnimating];
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}


- (void) updateCommandesTable {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    NSString *repID = appDelegate.currLoggedUser;
    char *errorMsg = nil;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/commRepJson.php?repID=%@", appDelegate.syncServer, repID];
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
                                                                   [spinner stopAnimating];
                                                                                                                                  }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) updateCommandeItemsTable {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
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
                                                                   [spinner stopAnimating];
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) updateReservationsTable {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
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
                                                               
                                                               //[self updateReservationItemsTable:tmpStrCommID];
                                                               
                                                           }
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               
                                                               if ([[NSThread currentThread] isMainThread]){
                                                                   NSLog(@"In main thread--completion handler");
                                                                   [spinner stopAnimating];
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) updateReservationItemsTable {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
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
                                                                   [spinner stopAnimating];
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}


-(void) convertLocalOrdersToJson {
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

-(void) convertLocalReservationsToJson {
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


-(void) convertModifiedSynchedOrdersToJson {
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
}

-(void) convertModifiedSynchedReservationsToJson {
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

-(void) submitLocalOrdersJson {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
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
                                                                   [spinner stopAnimating];
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                           
                                                           
                                                           
                                                       }];
    [dataTask resume];
    
}

-(void) submitModifiedDraftOrdersJson {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
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
                                                                   [spinner stopAnimating];
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                           
                                                           
                                                           
                                                       }];
    [dataTask resume];
    
}

-(void) submitLocalReservationsJson {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
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
                                                                   [spinner stopAnimating];
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                           
                                                           
                                                           
                                                       }];
    [dataTask resume];
    
}

-(void) submitModifiedReservationsJson {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
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
                                                                   [spinner stopAnimating];
                                                                   
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                           
                                                           
                                                           
                                                       }];
    [dataTask resume];
    
}



-(void) resetLocalOrderDBs {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(384, 400);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
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
    
    [spinner stopAnimating];
    
}

- (void)syncErrorDetected {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"La tentatve de connexion au serveur a échoué." delegate:self cancelButtonTitle:@"Annuler" destructiveButtonTitle:@"Annuler" otherButtonTitles:nil, nil];
    
    actionSheet.tag = 2;
    
    [actionSheet showInView:self.view];
}

- (void) checkConnectivity {
    
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

- (void) checkConnectivityForFull {
    
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
                                                                       
                                                                       userCodeToReturn = [[rows objectAtIndex:i] objectForKey:@"idRep"];
                                                                       userCodeRoleToReturn = [[rows objectAtIndex:i] objectForKey:@"userRole"];
                                                                       
                                                                       appDelegate = [[UIApplication sharedApplication] delegate];
                                                                       appDelegate.currLoggedUser = userCodeToReturn;
                                                                       appDelegate.currLoggedUserRole = userCodeRoleToReturn;
                                                                       
                                                                       NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                                       
                                                                       [userDefaults setObject:userCodeToReturn forKey:@"UserCode"];
                                                                       [userDefaults setObject:userCodeRoleToReturn forKey:@"UserRole"];
                                                                       [userDefaults synchronize];
                                                                       
                                                                       [self completeFullSynch];
                                                                       
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
    [self submitLocalOrdersJson];
    [self submitModifiedDraftOrdersJson];
    [self submitLocalReservationsJson];
    [self submitModifiedReservationsJson];
    
    [self resetLocalOrderDBs];
    
    [self performSelector:@selector(updateCommandesTable) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(updateReservationsTable) withObject:nil afterDelay:3.0];
    
    [self performSelector:@selector(updateCommandeItemsTable) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(updateReservationItemsTable) withObject:nil afterDelay:3.0];
    
}

- (void) completeFullSynch {
    
    [self submitLocalOrdersJson];
    [self submitModifiedDraftOrdersJson];
    [self submitLocalReservationsJson];
    [self submitModifiedReservationsJson];
    
    //[self performSelector:@selector(instantiateLocalDB) withObject:nil afterDelay:1.5];
    [self instantiateLocalDB];
    [self performSelector:@selector(updateVinsTable) withObject:nil afterDelay:2.5];
    [self performSelector:@selector(updateClientsTable) withObject:nil afterDelay:2.5];
    
    [self performSelector:@selector(updateCommandesTable) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(updateReservationsTable) withObject:nil afterDelay:3.0];
    
    [self performSelector:@selector(updateCommandeItemsTable) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(updateReservationItemsTable) withObject:nil afterDelay:3.0];
}

@end