//
//  BIDProdDetailsViewController.m
//  AssistantVente
//
//  Created by Nicolas Huet on 28/01/14.
//  Copyright (c) 2014 Present. All rights reserved.
//

#import "BIDProdDetailsViewController.h"
#import "Product.h"
#import "MDCAppDelegate.h"


@implementation BIDProdDetailsViewController

@synthesize isInSelectMode;
@synthesize isInEditMode;
@synthesize pickupSource;
@synthesize cartArrayIndex;
@synthesize currProductQty;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(self.isInSelectMode){
        self.addQtyLbl.hidden = NO;
        self.addEmpaqButton.hidden = NO;
        self.subsEmpaqButton.hidden = NO;
        self.addCartButton.hidden = NO;
    } else if(self.isInEditMode){
        self.addQtyLbl.hidden = NO;
        self.addEmpaqButton.hidden = NO;
        self.subsEmpaqButton.hidden = NO;
        self.saveToCartButton.hidden = NO;
        self.addQtyLbl.text = [NSString stringWithFormat:@"%i", currProductQty];
    } else {
        self.addQtyLbl.hidden = YES;
        self.addEmpaqButton.hidden = YES;
        self.subsEmpaqButton.hidden = YES;
        self.addCartButton.hidden = YES;
    }
    
    if([self.product.vinCouleurID isEqual: @"3"]){
        self.prodDetailImage.image =  [UIImage imageNamed:@"wineRose(128)"];
    } else if([self.product.vinCouleurID  isEqual: @"2"]){
        self.prodDetailImage.image =  [UIImage imageNamed:@"wineWhite(128)"];
    } else {
        self.prodDetailImage.image =  [UIImage imageNamed:@"wineRed(128)"];
    }
    
    self.prodName.text = self.product.vinNom;
    self.prodNumero.text = self.product.vinNumero;
    
    double tmpAmount;
    
    NSLog(@"vinPrixAchat: %@",self.product.vinPrixAchat);
    NSLog(@"vinFraisTimbrage: %@",self.product.vinFraisEtiq);
    NSLog(@"vinFraisBout: %@",self.product.vinFraisBout);
    
    tmpAmount = [self.product.vinPrixAchat doubleValue];
    self.prodPrixAchat.text = [NSString stringWithFormat:@"$%.2f", tmpAmount];
    
    tmpAmount = [self.product.vinFraisEtiq doubleValue];
    self.prodTimbrage.text = [NSString stringWithFormat:@"$%.2f", tmpAmount];
    
    tmpAmount = [self.product.vinFraisBout doubleValue];
    self.prodConsult.text = [NSString stringWithFormat:@"$%.2f", tmpAmount];
    
    double tmpCalc = [self.product.vinPrixAchat doubleValue] + [self.product.vinFraisEtiq doubleValue] + [self.product.vinFraisBout doubleValue];
    
    self.prodSellPrice.text = [NSString stringWithFormat:@"$ %.2f", tmpCalc];
    
    self.prodInitialStock.text = self.product.vinQteAchat;
    self.prodEmpaquement.text = self.product.vinEmpaq;
    self.prodFormat.text = self.product.vinFormat;
    
    if(([self.product.vinDateAchat  isEqual:@""]) || ([self.product.vinDateAchat  isEqual:@"0000-00-00"])){
        self.prodJrsLibere.text = @"N/A";
    } else {
        NSDateFormatter *df=[[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSDate *date1 = [df dateFromString:self.product.vinDateAchat];
        NSDate *date2 = [NSDate date];
        NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:date1];
        int numberOfDays = secondsBetween / 86400;
        self.prodJrsLibere.text = [NSString stringWithFormat:@"%@ (%i)", self.product.vinDateAchat, numberOfDays];
    }
    
    
    
    int tmpInitialStock = [self.product.vinQteAchat intValue];
    int tmpAssigned = [self.product.vinTotalAssigned intValue];
    int tmpStock = tmpInitialStock - tmpAssigned;
    self.prodCurrStock.text = [NSString stringWithFormat:@"%i",tmpStock];
    
    if([self.prodCurrStock.text intValue] < 1){
        self.addToCartButton.userInteractionEnabled = NO;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"prepareForSeqgue: %@ - %@",segue.identifier, [sender reuseIdentifier]);
    //if ([segue.identifier isEqualToString:@"toStockInfo"])
    //{
      //  Product *product = nil;
      // product = self.product;
        
        //BIDProdStockInfoVC *prodStockInfoViewController = segue.destinationViewController;
        //prodStockInfoViewController.product = self.product;
    //}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"prodStock";
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //if ([cell.reuseIdentifier isEqualToString:CellIdentifier])
    //{
        //[self performSegueWithIdentifier:@"toStockInfo" sender:cell];
    //}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (IBAction)addToCart:(id)sender {
    
    [self.addQty resignFirstResponder];
    
    MDCAppDelegate *appDelegate = (MDCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if([self.pickupSource isEqual: @"Commande"]){
        if(appDelegate.cartProducts == nil){
            appDelegate.cartProducts = [[NSMutableArray alloc] init];
        }
        if(appDelegate.cartQties == nil){
            appDelegate.cartQties = [[NSMutableArray alloc] init];
        }
        
        if(appDelegate.cartTransType == nil){
            appDelegate.cartTransType = [[NSMutableArray alloc] init];
        }
        
        int testForZero = [self.addQty.text intValue];
        
        if(testForZero > 0){
            [appDelegate.cartProducts addObject:self.product];
            [appDelegate.cartQties addObject:self.addQty.text];
            [appDelegate.cartTransType addObject:@"BuyNow"];
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Item Ajouté au panier avec succès" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [actionSheet showFromToolbar:self.navigationController.toolbar];
        }
    } else {
        if(appDelegate.reservProducts == nil){
            appDelegate.reservProducts = [[NSMutableArray alloc] init];
        }
        if(appDelegate.reservQties == nil){
            appDelegate.reservQties = [[NSMutableArray alloc] init];
        }
        
        if(appDelegate.reservTransType == nil){
            appDelegate.reservTransType = [[NSMutableArray alloc] init];
        }
        
        int testForZero = [self.addQty.text intValue];
        
        if(testForZero > 0){
            [appDelegate.reservProducts addObject:self.product];
            [appDelegate.reservQties addObject:self.addQty.text];
            [appDelegate.reservTransType addObject:@"BuyNow"];
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Item Ajouté à la réservation avec succès" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [actionSheet showFromToolbar:self.navigationController.toolbar];
        }
    }
    
    
}

- (IBAction)saveToCart:(id)sender {
    [self.addQty resignFirstResponder];
    
    MDCAppDelegate *appDelegate = (MDCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if([self.pickupSource isEqual: @"Commande"]){
        
        int testForZero = [self.addQty.text intValue];
        
        if(testForZero > 0){
            [appDelegate.cartQties replaceObjectAtIndex:self.cartArrayIndex withObject:self.addQty.text];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    } else {
        
        int testForZero = [self.addQty.text intValue];
        
        if(testForZero > 0){
            [appDelegate.reservQties replaceObjectAtIndex:self.cartArrayIndex withObject:self.addQty.text];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0)
    {
        //[self.navigationController popToRootViewControllerAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}

- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)addEmpaq:(id)sender {
    int qtyEmpaq = [_prodEmpaquement.text intValue];
    int currentEmpaq = [self.addQtyLbl.text intValue];

    int calcEmpaq = currentEmpaq+qtyEmpaq;
    
    self.addQty.text = [NSString stringWithFormat:@"%i", calcEmpaq];
    self.addQtyLbl.text = [NSString stringWithFormat:@"%i", calcEmpaq];
}

- (IBAction)subsEmpaq:(id)sender {
    int qtyEmpaq = [_prodEmpaquement.text intValue];
    int currentEmpaq = [self.addQtyLbl.text intValue];
    
    int calcEmpaq = currentEmpaq-qtyEmpaq;
    if(calcEmpaq < 0){
        calcEmpaq = 0;
    }
    
    self.addQty.text = [NSString stringWithFormat:@"%i", calcEmpaq];
    self.addQtyLbl.text = [NSString stringWithFormat:@"%i", calcEmpaq];
}

@end
