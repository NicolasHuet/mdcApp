//
//  OrderItem.h
//  mdcApp
//
//  Created by Nicolas Huet on 2014-11-13.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString *vinID;
@property (nonatomic, strong) NSString *vinQte;
@property (nonatomic, strong) NSString *vinOverideFrais;
@property (nonatomic, strong) NSString *localOrderID;

@property (nonatomic, strong) NSString *commItemID;
@property (nonatomic, strong) NSString *commItemCommID;


@end
