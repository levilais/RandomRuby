//
//  StoreViewController.h
//  RandomRuby
//
//  Created by BrightSun on 9/5/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreViewController : UIViewController {
    UIView  *m_MenuBar;
    
    int     m_nSelectedIndex;
    UIView *purchaseProPopupView;
    UIButton *rubyCountButton;
}
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
//@property (weak, nonatomic) IBOutlet UIButton *store350Button;
@property (weak, nonatomic) IBOutlet UIButton *storeRRProButton;
//@property (weak, nonatomic) IBOutlet UIButton *store750Button;
//@property (weak, nonatomic) IBOutlet UIButton *store2000Button;
//@property (weak, nonatomic) IBOutlet UIButton *store4500Button;
//@property (weak, nonatomic) IBOutlet UIButton *store10000Button;
//@property (weak, nonatomic) IBOutlet UIButton *storeBuildADisButton;
//@property (weak, nonatomic) IBOutlet UIButton *storePickUpPallButton;

- (IBAction)onPurchase:(id)sender;
- (void) refreshRubyCount;

@end
