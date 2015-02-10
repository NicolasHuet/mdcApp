//
//  Order.h
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-03.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject

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

@property (nonatomic, strong) NSString *commID;
@property (nonatomic, strong) NSString *commStatutID;
@property (nonatomic, strong) NSString *commRepID;
@property (nonatomic, strong) NSString *commIDSAQ;
@property (nonatomic, strong) NSString *commClientID;
@property (nonatomic, strong) NSString *commTypeClntID;
@property (nonatomic, strong) NSString *commTypeLivrID;
@property (nonatomic, strong) NSString *commDateFact;
@property (nonatomic, strong) NSString *commDelaiPickup;
@property (nonatomic, strong) NSString *commDatePickup;
@property (nonatomic, strong) NSString *commClientJourLivr;
@property (nonatomic, strong) NSString *commPartSuccID;
@property (nonatomic, strong) NSString *commCommentaire;
@property (nonatomic, strong) NSString *commLastUpdated;

@property (nonatomic, strong) NSString *commDataSource;


@end
