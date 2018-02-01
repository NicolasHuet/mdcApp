//
//  BIDProdDetailsViewController.h
//  AssistantVente
//
//  Created by Nicolas Huet on 28/01/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import <sqlite3.h>

@interface BIDProdDetailsViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, strong) Product *product;
@property (nonatomic) Boolean isInSelectMode;
@property (nonatomic) Boolean isInEditMode;
@property (nonatomic) NSInteger cartArrayIndex;
@property (nonatomic) NSInteger currProductQty;

@property (strong,nonatomic) NSString *pickupSource;

@property (strong, nonatomic) IBOutlet UIImageView *prodDetailImage;
@property (strong, nonatomic) IBOutlet UILabel *prodName;
@property (strong, nonatomic) IBOutlet UILabel *prodRegion;
@property (strong, nonatomic) IBOutlet UILabel *prodCountry;
@property (strong, nonatomic) IBOutlet UILabel *prodNumero;

@property (strong, nonatomic) IBOutlet UILabel *prodPrixAchat;
@property (strong, nonatomic) IBOutlet UILabel *prodTimbrage;
@property (strong, nonatomic) IBOutlet UILabel *prodConsult;


@property (strong, nonatomic) IBOutlet UILabel *prodSellPrice;

@property (strong, nonatomic) IBOutlet UILabel *prodInitialStock;
@property (strong, nonatomic) IBOutlet UILabel *prodEmpaquement;
@property (strong, nonatomic) IBOutlet UILabel *prodJrsLibere;

@property (strong, nonatomic) IBOutlet UILabel *prodFormat;
@property (strong, nonatomic) IBOutlet UILabel *infosLastSync;

@property (strong, nonatomic) IBOutlet UILabel *prodCurrStock;
@property (strong, nonatomic) IBOutlet UILabel *prodMargeReserv;
@property (strong, nonatomic) IBOutlet UITextField *addQty;
@property (weak, nonatomic) IBOutlet UILabel *addQtyLbl;
@property (strong, nonatomic) IBOutlet UIButton *addCartButton;
@property (strong, nonatomic) IBOutlet UIButton *subsEmpaqButton;
@property (strong, nonatomic) IBOutlet UIButton *addEmpaqButton;

@property (strong, nonatomic) IBOutlet UILabel *inventaireLbl;
@property (strong, nonatomic) IBOutlet UILabel *timbrageLbl;
@property (strong, nonatomic) IBOutlet UILabel *HonoraireLbl;
@property (strong, nonatomic) IBOutlet UIImageView *qteAchatImg;
@property (strong, nonatomic) IBOutlet UIImageView *EmpaqImg;
@property (strong, nonatomic) IBOutlet UIImageView *dispoImg;
@property (strong, nonatomic) IBOutlet UIImageView *uvcImg;

- (IBAction)addEmpaq:(id)sender;
- (IBAction)subsEmpaq:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *addToCartButton;
@property (strong, nonatomic) IBOutlet UIButton *saveToCartButton;

- (IBAction)textFieldDoneEditing:(id)sender;

- (IBAction)addToCart:(id)sender;
- (IBAction)saveToCart:(id)sender;

@end
