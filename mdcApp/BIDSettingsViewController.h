//
//  BIDSettingsViewController.h
//  mdcApp
//
//  Created by Nicolas Huet on 2014-08-24.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "PRELocalDBTools.h"
#import "Order.h"
#import "OrderItem.h"
#import "MDCAppDelegate.h"

@interface BIDSettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *instanciate;
@property (nonatomic, strong) NSMutableArray *orderArray;
@property (nonatomic, strong) NSMutableArray *orderItemsArray;

//- (IBAction)instancAction:(id)sender;

- (IBAction)ordersSync:(id)sender;

- (IBAction)fullSyncCheck:(id)sender;

@end
