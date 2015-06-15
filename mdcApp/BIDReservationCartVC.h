//
//  BIDReservationCartVC.h
//  mdcApp
//
//  Created by Nicolas Huet on 2015-05-24.
//  Copyright (c) 2015 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDCAppDelegate.h"
#import "BIDSelectClientTableVC.h"
#import "BIDSelectProductTableVC.h"
#import "BIDProdDetailsViewController.h"
#import "Product.h"
#import "Client.h"
#import "Order.h"
#import "OrderItem.h"
#import <sqlite3.h>


@interface BIDReservationCartVC : UITableViewController <UIActionSheetDelegate, UITextFieldDelegate>

@property (nonatomic, assign) BOOL returningDocument;

@property (strong, nonatomic) Order *selectedOrder;

@property (strong, nonatomic) IBOutlet UILabel *itemDetails;
@property (strong, nonatomic) IBOutlet UILabel *lblQty;
@property (strong, nonatomic) IBOutlet UILabel *lblSubTotal;
@property (strong, nonatomic) IBOutlet UILabel *lblUnitPrice;
@property (strong, nonatomic) IBOutlet UILabel *deliveryTypeField;

@property (strong, nonatomic) IBOutlet UIButton *selectClientButton;
@property (strong, nonatomic) IBOutlet UIButton *addProductButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelOrderButton;
@property (strong, nonatomic) IBOutlet UIButton *submitOrderButton;

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
