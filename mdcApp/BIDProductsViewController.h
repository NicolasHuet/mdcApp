//
//  BIDProductsViewController.h
//  AssistantVente
//
//  Created by Nicolas Huet on 22/01/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client.h"
#import "Product.h"
#import <sqlite3.h>
//#import "PRELocalDBTools.h"
#import "MDCAppDelegate.h"
#import "BIDProdDetailsViewController.h"

@interface BIDProductsViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, retain) NSMutableArray *productArray;
@property (nonatomic, retain) NSMutableArray *filteredProductsArray;
@property (strong, nonatomic) IBOutlet UISearchBar *productSearchBar;

@property (nonatomic, strong) NSMutableData *responseData;

@end
