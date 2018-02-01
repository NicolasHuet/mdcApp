//
//  Product.m
//  AssistantVente
//
//  Created by Nicolas Huet on 22/01/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import "Product.h"

@implementation Product

@synthesize vinID;
@synthesize vinNumero;
@synthesize vinNom;
@synthesize vinCouleurID;
@synthesize vinEmpaq;
@synthesize vinRegionID;

@synthesize vinNoDemande;
@synthesize vinIDFournisseur;

@synthesize vinDateAchat;
@synthesize vinQteAchat;
@synthesize vinTotalAssigned;

@synthesize vinFormat;

@synthesize vinPrixAchat;
@synthesize vinFraisEtiq;
@synthesize vinFraisBout;
@synthesize vinFraisBoutPart;
@synthesize vinPrixVente;

@synthesize vinEpuise;
@synthesize vinDisponible;


- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.vinID = [decoder decodeObjectForKey:@"vinID"];
        self.vinNumero = [decoder decodeObjectForKey:@"vinNumero"];
        self.vinNom = [decoder decodeObjectForKey:@"vinNom"];
        self.vinCouleurID = [decoder decodeObjectForKey:@"vinCouleurID"];
        self.vinEmpaq = [decoder decodeObjectForKey:@"vinEmpaq"];
        self.vinRegionID = [decoder decodeObjectForKey:@"vinRegionID"];
        
        self.vinNoDemande = [decoder decodeObjectForKey:@"vinNoDemande"];
        self.vinIDFournisseur = [decoder decodeObjectForKey:@"vinIDFournisseur"];
        
        self.vinDateAchat = [decoder decodeObjectForKey:@"vinDateAchat"];
        self.vinQteAchat = [decoder decodeObjectForKey:@"vinQteAchat"];
        self.vinTotalAssigned = [decoder decodeObjectForKey:@"vinTotalAssigned"];
        
        self.vinFormat = [decoder decodeObjectForKey:@"vinFormat"];
        
        self.vinPrixAchat = [decoder decodeObjectForKey:@"vinPrixAchat"];
        self.vinFraisEtiq = [decoder decodeObjectForKey:@"vinFraisEtiq"];
        self.vinFraisBout = [decoder decodeObjectForKey:@"vinFraisBout"];
        self.vinFraisBoutPart = [decoder decodeObjectForKey:@"vinFraisBoutPart"];
        self.vinPrixVente = [decoder decodeObjectForKey:@"vinPrixVente"];
        
        self.vinEpuise = [decoder decodeObjectForKey:@"vinEpuise"];
        self.vinDisponible = [decoder decodeObjectForKey:@"vinDisponible"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:vinID forKey:@"vinID"];
    [encoder encodeObject:vinNumero forKey:@"vinNumero"];
    [encoder encodeObject:vinNom forKey:@"vinNom"];
    [encoder encodeObject:vinCouleurID forKey:@"vinCouleurID"];
    [encoder encodeObject:vinEmpaq forKey:@"vinEmpaq"];
    [encoder encodeObject:vinRegionID forKey:@"vinRegionID"];
    
    [encoder encodeObject:vinNoDemande forKey:@"vinNoDemande"];
    [encoder encodeObject:vinIDFournisseur forKey:@"vinIDFournisseur"];
    
    [encoder encodeObject:vinDateAchat forKey:@"vinDateAchat"];
    [encoder encodeObject:vinQteAchat forKey:@"vinQteAchat"];
    [encoder encodeObject:vinTotalAssigned forKey:@"vinTotalAssigned"];
    
    [encoder encodeObject:vinFormat forKey:@"vinFormat"];
    
    [encoder encodeObject:vinPrixAchat forKey:@"vinPrixAchat"];
    [encoder encodeObject:vinFraisEtiq forKey:@"vinFraisEtiq"];
    [encoder encodeObject:vinFraisBout forKey:@"vinFraisBout"];
    [encoder encodeObject:vinFraisBoutPart forKey:@"vinFraisBoutPart"];
    [encoder encodeObject:vinPrixVente forKey:@"vinPrixVente"];
    
    [encoder encodeObject:vinEpuise forKey:@"vinEpuise"];
    [encoder encodeObject:vinDisponible forKey:@"vinDisponible"];
    
}

@end
