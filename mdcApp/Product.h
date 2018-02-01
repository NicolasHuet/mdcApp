//
//  Product.h
//  AssistantVente
//
//  Created by Nicolas Huet on 22/01/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject <NSCoding>

@property (nonatomic, strong) NSString *vinID;
@property (nonatomic, strong) NSString *vinNumero;
@property (nonatomic, strong) NSString *vinNom;
@property (nonatomic, strong) NSString *vinCouleurID;
@property (nonatomic, strong) NSString *vinEmpaq;
@property (nonatomic, strong) NSString *vinRegionID;

@property (nonatomic, strong) NSString *vinNoDemande;
@property (nonatomic, strong) NSString *vinIDFournisseur;

@property (nonatomic, strong) NSString *vinDateAchat;
@property (nonatomic, strong) NSString *vinQteAchat;
@property (nonatomic, strong) NSString *vinTotalAssigned;

@property (nonatomic, strong) NSString *vinFormat;

@property (nonatomic, strong) NSString *vinPrixAchat;
@property (nonatomic, strong) NSString *vinFraisEtiq;
@property (nonatomic, strong) NSString *vinFraisBout;
@property (nonatomic, strong) NSString *vinFraisBoutPart;
@property (nonatomic, strong) NSString *vinPrixVente;

@property (nonatomic, strong) NSString *vinEpuise;
@property (nonatomic, strong) NSString *vinDisponible;

@end
