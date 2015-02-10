//
//  BIDOrderDetailTableVC.h
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-11.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface BIDOrderDetailTableVC : UITableViewController

@property (nonatomic, strong) Order *order;
@property (nonatomic,strong) NSMutableArray *orderItemsArray;

@end
