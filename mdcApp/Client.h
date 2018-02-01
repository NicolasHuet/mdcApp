//
//  Client.h
//  AssistantVente
//
//  Created by Nicolas Huet on 13/01/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Client : NSObject <NSCoding>

@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *personneRessource;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSString *clientType;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *postalcode;

@property (nonatomic, strong) NSString *clientIDSAQ;

@property (nonatomic, strong) NSString *clientTypeLivr;
@property (nonatomic, strong) NSString *clientTypeFact;
@property (nonatomic, strong) NSString *clientJourLivr;

@property (nonatomic, strong) NSString *clientTitulaireID;
@property (nonatomic, strong) NSString *clientTempTitulaireID;

@end
