//
//  OrderItem.m
//  mdcApp
//
//  Created by Nicolas Huet on 2014-11-13.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import "OrderItem.h"

@implementation OrderItem

@synthesize vinID;
@synthesize vinQte;
@synthesize vinOverideFrais;
@synthesize localOrderID;

@synthesize commItemID;
@synthesize commItemCommID;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.vinID = [decoder decodeObjectForKey:@"vinID"];
        self.vinQte = [decoder decodeObjectForKey:@"vinQte"];
        self.vinOverideFrais = [decoder decodeObjectForKey:@"vinOverideFrais"];
        self.localOrderID = [decoder decodeObjectForKey:@"localOrderID"];
        
        self.commItemID = [decoder decodeObjectForKey:@"commItemID"];
        self.commItemCommID = [decoder decodeObjectForKey:@"commItemCommID"];
        
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:vinID forKey:@"vinID"];
    [encoder encodeObject:vinQte forKey:@"vinQte"];
    [encoder encodeObject:vinOverideFrais forKey:@"vinOverideFrais"];
    [encoder encodeObject:localOrderID forKey:@"localOrderID"];
    
    [encoder encodeObject:commItemID forKey:@"commItemID"];
    [encoder encodeObject:commItemCommID forKey:@"commItemCommID"];
    
}

@end
