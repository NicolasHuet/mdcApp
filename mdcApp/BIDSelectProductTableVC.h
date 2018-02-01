//
//  BIDSelectProductTableVC.h
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-15.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import <sqlite3.h>
//#import "PRELocalDBTools.h"
#import "MDCAppDelegate.h"
#import "BIDProdDetailsViewController.h"

@interface BIDSelectProductTableVC : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, retain) NSMutableArray *productArray;
@property (nonatomic, retain) NSMutableArray *filteredProductsArray;
@property (nonatomic) Boolean isInSelectMode;

@property (strong, nonatomic) IBOutlet UISearchBar *productSearchBar;
@property (strong,nonatomic) NSString *pickupSource;

@end
