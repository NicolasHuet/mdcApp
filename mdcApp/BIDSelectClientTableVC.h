//
//  BIDSelectClientTableVC.h
//  mdcApp
//
//  Created by Nicolas Huet on 2014-09-15.
//  Copyright (c) 2014 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "PRELocalDBTools.h"
#import "Client.h"

@interface BIDSelectClientTableVC : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic,strong) NSMutableArray *clientArray;
@property (strong,nonatomic) NSMutableArray *filteredClientArray;
//@property (strong, nonatomic) IBOutlet UISearchBar *clientSearchBar;
@property (strong, nonatomic) IBOutlet UISearchBar *clientSearchBar;

@end
