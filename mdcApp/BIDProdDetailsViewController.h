//
//  BIDProdDetailsViewController.h
//  AssistantVente
//
//  Created by Nicolas Huet on 28/01/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface BIDProdDetailsViewController : UITableViewController

@property (nonatomic, strong) Product *product;
@property (nonatomic) Boolean isInSelectMode;

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
@property (strong, nonatomic) IBOutlet UITextField *addQty;
@property (weak, nonatomic) IBOutlet UILabel *addQtyLbl;
@property (strong, nonatomic) IBOutlet UIButton *addCartButton;
@property (strong, nonatomic) IBOutlet UIButton *subsEmpaqButton;
@property (strong, nonatomic) IBOutlet UIButton *addEmpaqButton;

- (IBAction)addEmpaq:(id)sender;
- (IBAction)subsEmpaq:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *addToCartButton;

- (IBAction)textFieldDoneEditing:(id)sender;

- (IBAction)addToCart:(id)sender;

@end
