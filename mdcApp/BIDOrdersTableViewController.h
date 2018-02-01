//
//  BIDOrdersTableViewController.h
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-03.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
//#import "PRELocalDBTools.h"
#import "BIDCartViewController.h"
#import "Order.h"
#import "OrderItem.h"
#import "MBProgressHUD.h"

@interface BIDOrdersTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate>

@property (nonatomic,strong) NSMutableArray *orderArray;
@property (strong,nonatomic) NSMutableArray *filteredOrderArray;
@property (strong, nonatomic) IBOutlet UISearchBar *orderSearchbar;

@property (nonatomic, strong) NSMutableArray *orderSyncArray;
@property (nonatomic, strong) NSMutableArray *orderItemsArray;

@property (nonatomic) Boolean needsRefreshing;

- (IBAction)actionToNewOrder:(id)sender;

- (IBAction)actionToSyncOrders:(id)sender;

@end
