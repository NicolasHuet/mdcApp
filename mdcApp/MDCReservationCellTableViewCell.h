//
//  MDCReservationCellTableViewCell.h
//  mdcApp
//
//  Created by Nicolas Huet on 2015-06-15.
//  Copyright (c) 2015 MaitreDeChai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDCReservationCellTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *button1;

@property (nonatomic, weak) IBOutlet UILabel *clientNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *saqConfirmLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *orderSumProductsLabel;

@end
