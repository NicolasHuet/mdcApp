//
//  BIDClientTableViewController.h
//  AssistantVente
//
//  Created by Nicolas Huet on 13/01/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
//#import "PRELocalDBTools.h"
#import "Client.h"

@interface BIDClientTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic,strong) NSMutableArray *clientArray;
@property (strong,nonatomic) NSMutableArray *filteredClientArray;
@property (strong, nonatomic) IBOutlet UISearchBar *clientSearchBar;

@property (nonatomic, strong) NSMutableData *responseData;

@end
