//
//  BIDOrdersTableViewController.h
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-03.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "PRELocalDBTools.h"
#import "Order.h"
#import "OrderItem.h"

@interface BIDOrdersTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic,strong) NSMutableArray *orderArray;
@property (strong,nonatomic) NSMutableArray *filteredOrderArray;
@property (strong, nonatomic) IBOutlet UISearchBar *orderSearchbar;

@property (nonatomic, strong) NSMutableArray *orderSyncArray;
@property (nonatomic, strong) NSMutableArray *orderItemsArray;

- (IBAction)actionToNewOrder:(id)sender;

- (IBAction)actionToSyncOrders:(id)sender;

@end
