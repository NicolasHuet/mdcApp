//
//  MDCClientDetailsTableViewController.h
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-08.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
//#import "PRELocalDBTools.h"
#import "Client.h"
#import "Order.h"
#import "BIDCartViewController.h"

@interface MDCClientDetailsTableViewController : UITableViewController

@property (nonatomic, strong) Client *client;
@property (nonatomic,strong) NSMutableArray *orderArray;

@end
