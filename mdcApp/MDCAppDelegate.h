//
//  MDCAppDelegate.h
//  mdcApp
//
//  Created by Nicolas Huet on 28/02/14.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "Client.h"

@interface MDCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSMutableArray *cartProducts;
@property (strong, nonatomic) NSMutableArray *cartQties;
@property (strong, nonatomic) NSMutableArray *cartTransType;

@property (strong, nonatomic) NSMutableArray *reservProducts;
@property (strong, nonatomic) NSMutableArray *reservQties;
@property (strong, nonatomic) NSMutableArray *reservTransType;

@property (strong, nonatomic) NSString *cartTypeLivr;

@property (strong, nonatomic) NSString *reservTypeLivr;

@property (strong, nonatomic) NSString *cartDelaiPickup;
@property (strong, nonatomic) NSString *cartDateLivr;

@property (strong, nonatomic) NSString *cartCommentaire;
@property (strong, nonatomic) NSString *reservCommentaire;

@property (strong, nonatomic) NSString *currLoggedUser;
@property (strong, nonatomic) NSString *currLoggedUserRole;

@property (strong, nonatomic) NSString *syncServer;

@property (strong, nonatomic) Client *sessionActiveClient;

@property (strong, nonatomic) Client *reservationActiveClient;

@property (nonatomic) Boolean clientsViewNeedsRefreshing;
@property (nonatomic) Boolean productsViewNeedsRefreshing;
@property (nonatomic) Boolean ordersViewNeedsRefreshing;
@property (nonatomic) Boolean reservationsViewNeedsRefreshing;
@property (nonatomic) Boolean cartViewNeedsRefreshing;

@property (nonatomic) Boolean canSubmitReservationDoc;

@property (nonatomic,strong) NSMutableArray *glClientArray;
@property (nonatomic,strong) NSMutableArray *glOrderArray;
@property (nonatomic,strong) NSMutableArray *glOrderItemsArray;
@property (nonatomic,strong) NSMutableArray *glReservationArray;
@property (nonatomic,strong) NSMutableArray *glReservationItemsArray;
@property (nonatomic,strong) NSMutableArray *glProductArray;


@end
