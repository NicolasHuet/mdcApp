//
//  Client.m
//  AssistantVente
//
//  Created by Nicolas Huet on 13/01/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import "Client.h"

@implementation Client

@synthesize clientID;
@synthesize name;
@synthesize personneRessource;
@synthesize telephone;
@synthesize clientType;

@synthesize address;
@synthesize city;
@synthesize province;
@synthesize postalcode;

@synthesize clientIDSAQ;

@synthesize clientTypeLivr;
@synthesize clientTypeFact;
@synthesize clientJourLivr;

@synthesize clientTitulaireID;
@synthesize clientTempTitulaireID;


- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.clientID = [decoder decodeObjectForKey:@"clientID"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.personneRessource = [decoder decodeObjectForKey:@"personneRessource"];
        self.telephone = [decoder decodeObjectForKey:@"telephone"];
        self.clientType = [decoder decodeObjectForKey:@"clientType"];
        
        self.address = [decoder decodeObjectForKey:@"address"];
        self.city = [decoder decodeObjectForKey:@"city"];
        self.province = [decoder decodeObjectForKey:@"province"];
        self.postalcode = [decoder decodeObjectForKey:@"postalcode"];
        
        self.clientIDSAQ = [decoder decodeObjectForKey:@"clientIDSAQ"];
        
        self.clientTypeLivr = [decoder decodeObjectForKey:@"clientTypeLivr"];
        self.clientTypeFact = [decoder decodeObjectForKey:@"clientTypeFact"];
        self.clientJourLivr = [decoder decodeObjectForKey:@"clientJourLivr"];
        
        self.clientTitulaireID = [decoder decodeObjectForKey:@"clientTitulaireID"];
        self.clientTempTitulaireID = [decoder decodeObjectForKey:@"clientTempTitulaireID"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:clientID forKey:@"clientID"];
    
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:personneRessource forKey:@"personneRessource"];
    [encoder encodeObject:telephone forKey:@"telephone"];
    [encoder encodeObject:clientType forKey:@"clientType"];
    
    [encoder encodeObject:address forKey:@"address"];
    [encoder encodeObject:city forKey:@"city"];
    [encoder encodeObject:province forKey:@"province"];
    [encoder encodeObject:postalcode forKey:@"postalcode"];
    
    [encoder encodeObject:clientIDSAQ forKey:@"clientIDSAQ"];
    
    [encoder encodeObject:clientTypeLivr forKey:@"clientTypeLivr"];
    [encoder encodeObject:clientTypeFact forKey:@"clientTypeFact"];
    [encoder encodeObject:clientJourLivr forKey:@"clientJourLivr"];
    
    [encoder encodeObject:clientTitulaireID forKey:@"clientTitulaireID"];
    [encoder encodeObject:clientTempTitulaireID forKey:@"clientTempTitulaireID"];
    
}

@end
