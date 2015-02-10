//
//  MDCAppDelegate.h
//  mdcApp
//
//  Created by Nicolas Huet on 28/02/14.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"

@interface MDCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSMutableArray *cartProducts;
@property (strong, nonatomic) NSMutableArray *cartQties;
@property (strong, nonatomic) NSMutableArray *cartTransType;
@property (strong, nonatomic) NSString *cartTypeLivr;
@property (strong, nonatomic) NSString *cartDelaiPickup;
@property (strong, nonatomic) NSString *cartDateLivr;
@property (strong, nonatomic) NSString *cartCommentaire;

@property (strong, nonatomic) NSString *currLoggedUser;
@property (strong, nonatomic) NSString *currLoggedUserRole;

@property (strong, nonatomic) Client *sessionActiveClient;

@end
