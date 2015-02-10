//
//  BIDCartViewController.h
//  AssistantVente
//
//  Created by Nicolas Huet on 04/02/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDCAppDelegate.h"
#import "Product.h"
#import "Client.h"
#import <sqlite3.h>

@interface BIDCartViewController : UITableViewController <UIActionSheetDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *itemDetails;
@property (strong, nonatomic) IBOutlet UILabel *lblQty;
@property (strong, nonatomic) IBOutlet UILabel *lblSubTotal;
@property (strong, nonatomic) IBOutlet UILabel *lblUnitPrice;

@property (strong, nonatomic) IBOutlet UITextField *commDatePickup;
@property (strong, nonatomic) IBOutlet UITextField *commCommentaire;
@property (nonatomic, retain) UIDatePicker* datePicker;
@property (nonatomic, retain) UIToolbar* toolBar;

@property (nonatomic, strong) NSMutableData *responseData;

- (IBAction)selectClient:(id)sender;

- (IBAction)addProductAction:(id)sender;

- (IBAction)confirmTransaction:(id)sender;

- (IBAction)cancelTransaction:(id)sender;

@end
