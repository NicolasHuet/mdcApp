//
//  Order.m
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-03.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import "Order.h"

@implementation Order

@synthesize commID;
@synthesize commStatutID;
@synthesize commRepID;
@synthesize commIDSAQ;
@synthesize commClientID;
@synthesize commClientName;
@synthesize commTypeClntID;
@synthesize commTypeLivrID;
@synthesize commDateFact;
@synthesize commDelaiPickup;
@synthesize commDatePickup;
@synthesize commClientJourLivr;
@synthesize commPartSuccID;
@synthesize commCommentaire;
@synthesize commLastUpdated;
@synthesize commIsDraftModified;

@synthesize commDataSource;

@synthesize remoteCommID;


- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.commID = [decoder decodeObjectForKey:@"commID"];
        self.commStatutID = [decoder decodeObjectForKey:@"commStatutID"];
        self.commRepID = [decoder decodeObjectForKey:@"commRepID"];
        self.commIDSAQ = [decoder decodeObjectForKey:@"commIDSAQ"];
        
        self.commClientID = [decoder decodeObjectForKey:@"commClientID"];
        self.commClientName = [decoder decodeObjectForKey:@"commClientName"];
        
        self.commTypeClntID = [decoder decodeObjectForKey:@"commTypeClntID"];
        self.commTypeLivrID = [decoder decodeObjectForKey:@"commTypeLivrID"];
        
        self.commDateFact = [decoder decodeObjectForKey:@"commDateFact"];
        self.commDelaiPickup = [decoder decodeObjectForKey:@"commDelaiPickup"];
        self.commDatePickup = [decoder decodeObjectForKey:@"commDatePickup"];
        self.commClientJourLivr = [decoder decodeObjectForKey:@"commClientJourLivr"];
        self.commPartSuccID = [decoder decodeObjectForKey:@"commPartSuccID"];
        self.commCommentaire = [decoder decodeObjectForKey:@"commCommentaire"];
        self.commLastUpdated = [decoder decodeObjectForKey:@"commLastUpdated"];
        
        self.commIsDraftModified = [decoder decodeObjectForKey:@"commIsDraftModified"];
        self.commDataSource = [decoder decodeObjectForKey:@"commDataSource"];
        self.remoteCommID = [decoder decodeObjectForKey:@"remoteCommID"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:commID forKey:@"commID"];
    [encoder encodeObject:commStatutID forKey:@"commStatutID"];
    [encoder encodeObject:commRepID forKey:@"commRepID"];
    [encoder encodeObject:commIDSAQ forKey:@"commIDSAQ"];
    
    [encoder encodeObject:commClientID forKey:@"commClientID"];
    [encoder encodeObject:commClientName forKey:@"commClientName"];
    
    [encoder encodeObject:commTypeClntID forKey:@"commTypeClntID"];
    [encoder encodeObject:commTypeLivrID forKey:@"commTypeLivrID"];
    
    [encoder encodeObject:commDateFact forKey:@"commDateFact"];
    [encoder encodeObject:commDelaiPickup forKey:@"commDelaiPickup"];
    [encoder encodeObject:commDatePickup forKey:@"commDatePickup"];
    [encoder encodeObject:commClientJourLivr forKey:@"commClientJourLivr"];
    [encoder encodeObject:commPartSuccID forKey:@"commPartSuccID"];
    [encoder encodeObject:commCommentaire forKey:@"commCommentaire"];
    [encoder encodeObject:commLastUpdated forKey:@"commLastUpdated"];
    
    [encoder encodeObject:commIsDraftModified forKey:@"commIsDraftModified"];
    [encoder encodeObject:commDataSource forKey:@"commDataSource"];
    [encoder encodeObject:remoteCommID forKey:@"remoteCommID"];
    
}


@end
