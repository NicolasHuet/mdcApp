//
//  PRELocalDBTools.m
//  MDC
//
//  Created by Nicolas Huet on 11/07/13.
//  Copyright (c) 2013 Present. All rights reserved.
//

#import "PRELocalDBTools.h"
#import <sqlite3.h>

sqlite3 *database;
NSString * userCodeToReturn;
NSString * userCodeRoleToReturn;
MDCAppDelegate *appDelegate;

@implementation PRELocalDBTools

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"mdc.sqlite"];
}


- (void) performSyncWithLogin {
    
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
                                                           if(error == nil)
                                                           {
                                                              
                                                           }
                                                           
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
                                                                   
                                                                   [self updateVinsTable];
                                                                   [self updateClientsTable:userCodeToReturn];
                                                                   [self updateCommandesTable:userCodeToReturn];
                                                                   
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

- (void) instantiateLocalDB {
    
    // Local database initialization
    
    
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
    
    createSQL = @"CREATE TABLE IF NOT EXISTS LocalCommandeItems "
    "(commItemID INTEGER PRIMARY KEY AUTOINCREMENT, commItemCommID INT, commItemVinID INT, commItemVinQte INT);";
    
    if (sqlite3_exec (database, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    
    
    
    //sqlite3_close(database);
    
}

- (void) updateTypeClientTable {
    
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
                                                               
                                                               char *update = "INSERT INTO TypeClient "
                                                               "(typeClntID, typeClntName) "
                                                               "VALUES (?, ?);";
                                                               
                                                               sqlite3_stmt *stmt;
                                                               
                                                               NSInteger testInt;
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
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) updateClientsTable:(NSString *)repID {
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
                                                               "(clientID, clientName, clientAdr1, clientVille, clientProv, clientCodePostal, clientContact, clientTel1, clientTypeClntID, clientTitulaireID, clientTypeLivrID, clientTypeFact, clientLivrJourFixe) "
                                                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
                                                               
                                                               sqlite3_stmt *stmt;
                                                               
                                                               NSInteger clientID;
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
                                                               
                                                               NSInteger typeClient;
                                                               typeClient = [[[rows objectAtIndex:i] objectForKey:@"clientType"]intValue];
                                                               
                                                               NSInteger clientTitulaireID;
                                                               clientTitulaireID = [[[rows objectAtIndex:i] objectForKey:@"clientTitulaireID"]intValue];
                                                               
                                                               NSInteger clientTypeLivrID;
                                                               clientTypeLivrID = [[[rows objectAtIndex:i] objectForKey:@"clientTypeLivrID"]intValue];
                                                               
                                                               NSInteger clientTypeFact;
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
                                                                   sqlite3_bind_int(stmt, 10, clientTitulaireID);
                                                                   sqlite3_bind_int(stmt, 11, clientTypeLivrID);
                                                                   sqlite3_bind_int(stmt, 12, clientTypeFact);
                                                                   sqlite3_bind_text(stmt, 13, [clientJourLivr UTF8String], -1, NULL);
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
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) updateVinsTable {
    
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
                                                               
                                                               NSInteger vinID;
                                                               vinID = [[[rows objectAtIndex:i] objectForKey:@"vinID"]intValue];
                                                               
                                                               NSString * vinNumero;
                                                               vinNumero = [[rows objectAtIndex:i] objectForKey:@"vinNumero"];
                                                               
                                                               NSString * vinNom;
                                                               vinNom = [[rows objectAtIndex:i] objectForKey:@"vinNom"];
                                                               
                                                               NSInteger vinCouleurID;
                                                               vinCouleurID = [[[rows objectAtIndex:i] objectForKey:@"vinCouleurID"]intValue];
                                                               
                                                               NSInteger vinEmpaq;
                                                               vinEmpaq = [[[rows objectAtIndex:i] objectForKey:@"vinEmpaq"]intValue];
                                                               
                                                               NSInteger vinRegionID;
                                                               vinRegionID = [[[rows objectAtIndex:i] objectForKey:@"vinRegionID"]intValue];
                                                               
                                                               NSString * vinNoDemande;
                                                               vinNoDemande = [[rows objectAtIndex:i] objectForKey:@"vinNoDemande"];
                                                               
                                                               NSString * vinIDFournisseur;
                                                               vinIDFournisseur = [[rows objectAtIndex:i] objectForKey:@"vinIDFournisseur"];
                                                               
                                                               NSString * vinDateAchat;
                                                               vinDateAchat = [[rows objectAtIndex:i] objectForKey:@"vinDateAchat"];

                                                               NSInteger vinQteAchat;
                                                               vinQteAchat = [[[rows objectAtIndex:i] objectForKey:@"vinQteAchat"]intValue];
                                                               
                                                               NSInteger vinTotalAssigned;
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
                                                               
                                                               NSInteger vinEpuise;
                                                               vinEpuise = [[[rows objectAtIndex:i] objectForKey:@"vinEpuise"]intValue];
                                                               
                                                               NSInteger vinDisponible;
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
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}


- (void) updateCommandesTable:(NSString *)repID {
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
                                                               
                                                               //int tmpCommID = commID;
                                                               
                                                               //NSString * tmpStrCommID = [NSString stringWithFormat:@"%i",tmpCommID];
                                                               //[self updateCommandeItemsTable:tmpStrCommID];
                                                               
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
                                                               int intCommPartSuccID = [commPartSuccID intValue];
                                                               
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
                                                                   sqlite3_bind_int(stmt, 12, intCommPartSuccID);
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
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}

- (void) updateCommandeItemsTable {
    char *errorMsg = nil;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/mobileSync/commItemJsonForRep.php?commID=%@", appDelegate.syncServer, appDelegate.currLoggedUser];
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
                                                               commItemVinID = [[[rows objectAtIndex:i] objectForKey:@"commItemVinID"]intValue];
                                                               
                                                               int commItemVinQte;
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
                                                               }
                                                               else{
                                                                   NSLog(@"Not in main thread--completion handler");
                                                               }
                                                           });
                                                           
                                                       }];
    [dataTask resume];
}



@end
