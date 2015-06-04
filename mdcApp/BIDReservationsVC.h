//
//  BIDReservationsVC.h
//  mdcApp
//
//  Created by Nicolas Huet on 2015-05-21.
//  Copyright (c) 2015 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "PRELocalDBTools.h"
#import "BIDCartViewController.h"
#import "Order.h"
#import "OrderItem.h"

@interface BIDReservationsVC : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate>

@property (nonatomic,strong) NSMutableArray *orderArray;
@property (strong,nonatomic) NSMutableArray *filteredOrderArray;
@property (strong, nonatomic) IBOutlet UISearchBar *orderSearchbar;

@property (nonatomic, strong) NSMutableArray *orderSyncArray;
@property (nonatomic, strong) NSMutableArray *orderItemsArray;

- (IBAction)actionToNewOrder:(id)sender;

- (IBAction)actionToSyncOrders:(id)sender;

@end
