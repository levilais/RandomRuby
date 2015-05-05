//
//  StoreViewController.m
//  RandomRuby
//
//  Created by BrightSun on 9/5/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import "StoreViewController.h"
#import "Global.h"
#import "MKStoreManager.h"

//NSString *msgOfPurchase[] = {
//    @"+350 Rubies",
//    @"Random Ruby: PRO",
//    @"+750 Rubies",
//    @"+2,000 Rubies",
//    @"+4,500 Rubies",
//    @"+10,000 Rubies",
//    @"Build-A-Dis",
//    @"Pick-Up-Pal"
//};
//float priceOfPurchase[] = {0.99f, 1.99f, 1.99f, 4.99f, 9.99f, 19.99f, 0, 0};


@interface StoreViewController ()

@end

@implementation StoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    g_StoreViewer = self;
    loadSettingFromiCloud();
    
    // Do any additional setup after loading the view from its nib.
    
    // Top nav view
    m_MenuBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, G_SWIDTH, VAL_R(40))];
    m_MenuBar.backgroundColor = [UIColor clearColor];
    
    // Background
    UIImageView *bgNav = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, G_SWIDTH, m_MenuBar.frame.size.height)];
    bgNav.image = [UIImage imageNamed:@"bg_menubar.png"];
    bgNav.backgroundColor = [UIColor clearColor];
    [m_MenuBar addSubview:bgNav];
    
    // --- Back Button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(VAL_R(5), VAL_R(5), VAL_R(30), VAL_R(30))];
    [backButton setBackgroundImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [m_MenuBar addSubview:backButton];
    
    // --- Store Label
    UIImageView *labelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(G_SWIDTH / 2 - VAL_R(42), VAL_R(5), VAL_R(83), VAL_R(30))];
    labelImageView.image = [UIImage imageNamed:@"label_store.png"];
    labelImageView.backgroundColor = [UIColor clearColor];
    [m_MenuBar addSubview:labelImageView];
    
    // --- RubyCount Button
    rubyCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rubyCountButton.frame = CGRectMake(G_SWIDTH - VAL_R(85), VAL_R(5), VAL_R(81), VAL_R(30));
    rubyCountButton.backgroundColor = [UIColor clearColor];
    rubyCountButton.userInteractionEnabled = NO;
    [rubyCountButton setBackgroundImage:[UIImage imageNamed:@"btn_ruby_count.png"] forState:UIControlStateNormal];
    [rubyCountButton setTitle:[NSString stringWithFormat:@"%d", g_GameInfo.rubyCounts] forState:UIControlStateNormal];
    [rubyCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rubyCountButton.titleLabel setFont:[UIFont boldSystemFontOfSize:VAL_R(16.0f)]];
    [rubyCountButton setTitleEdgeInsets:UIEdgeInsetsMake(0, VAL_R(25), 0, 0)];
    [m_MenuBar addSubview:rubyCountButton];

    [self.view insertSubview:m_MenuBar aboveSubview:self.contentScrollView];

    [self.contentScrollView addSubview:self.contentView];
    [self.contentScrollView setContentSize:self.contentView.frame.size];
    
    g_bRestore = false;
    if (g_GameInfo.proVersion) {
        [self.storeRRProButton setBackgroundImage:[UIImage imageNamed:@"btn_store_pro_purchased.png"] forState:UIControlStateNormal];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    loadSettingFromiCloud();
}

- (void) onBack:(UIButton*) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) refreshRubyCount
{
    [rubyCountButton setTitle:[NSString stringWithFormat:@"%d", g_GameInfo.rubyCounts] forState:UIControlStateNormal];
    if (g_GameInfo.proVersion) {
        [self.storeRRProButton setBackgroundImage:[UIImage imageNamed:@"btn_store_pro_purchased.png"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPurchase:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
//    NSString *price = (priceOfPurchase[btn.tag] == 0) ? @"FREE" : [NSString stringWithFormat:@"$%.2f", priceOfPurchase[btn.tag]];
    m_nSelectedIndex = btn.tag;
    
    if (btn.tag == 1) {
        if (g_GameInfo.proVersion) {
            alertMessage(@"You have purchased PRO version.", @"Warning");
            return;
        }
        
        purchaseProPopupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, G_SWIDTH, G_SHEIGHT)];
        [purchaseProPopupView setBackgroundColor:[UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.5f]];
        [self.view addSubview:purchaseProPopupView];
        
        UIView *popupContentView = [[UIView alloc] initWithFrame:CGRectMake(VAL_BOTH(40, 84), VAL_BOTH(70 * G_RY, 160), VAL_BOTH(240, 600), VAL_BOTH(320, 670))];
        [popupContentView.layer setCornerRadius:VAL_R(15.0f)];
        [popupContentView setBackgroundColor:[UIColor colorWithRed:31/255.0f green:148/255.0f blue:233/255.0f alpha:1.0f]];
        [purchaseProPopupView addSubview:popupContentView];
        
        UIView *bgProView = [[UIView alloc] initWithFrame:CGRectMake(VAL_BOTH(10, 20), VAL_BOTH(10, 20), VAL_BOTH(220, 560), VAL_BOTH(300, 630))];
        [bgProView.layer setCornerRadius:VAL_R(10.0f)];
        [bgProView setBackgroundColor:[UIColor colorWithRed:141/255.0f green:204/255.0f blue:67/255.0f alpha:1.0f]];
        [popupContentView addSubview:bgProView];
        
        UILabel *lblCaption = [[UILabel alloc]initWithFrame:CGRectMake(VAL_BOTH(10, 30), VAL_BOTH(10, 30), VAL_BOTH(200, 500), VAL_BOTH(25.0f, 50.0f))];
        [lblCaption setText:@"Random Ruby: PRO"];
        [lblCaption setFont:[UIFont boldSystemFontOfSize:VAL_R(20.0f)]];
        [lblCaption setTextColor:[UIColor whiteColor]];
        [lblCaption setTextAlignment:NSTextAlignmentCenter];
        [lblCaption setBackgroundColor:[UIColor clearColor]];
        [bgProView addSubview:lblCaption];
        
        UIImageView *proIcon = [[UIImageView alloc]initWithFrame:CGRectMake(VAL_BOTH(60, 180), VAL_BOTH(45, 110), VAL_BOTH(100, 200), VAL_BOTH(100, 200))];
        [proIcon setImage:[UIImage imageNamed:@"icon_randomruby_pro.png"]];
        [bgProView addSubview:proIcon];
        
        UIView *subContentView = [[UIView alloc]initWithFrame:CGRectMake(VAL_BOTH(10, 30), VAL_BOTH(155, 330), VAL_BOTH(200, 500), VAL_BOTH(135, 270))];
        [subContentView setBackgroundColor:[UIColor colorWithRed:31/255.0f green:148/255.0f blue:233/255.0f alpha:1.0f]];
        [subContentView.layer setCornerRadius:VAL_R(10.0f)];
        [bgProView addSubview:subContentView];
        
        UIImageView *noAdsIcon = [[UIImageView alloc]initWithFrame:CGRectMake(VAL_BOTH(15, 30), VAL_BOTH(10, 20), VAL_BOTH(30, 60), VAL_BOTH(30, 60))];
        [noAdsIcon setImage:[UIImage imageNamed:@"icon_noads.png"]];
        [subContentView addSubview:noAdsIcon];
        
        UILabel *lblNoads = [[UILabel alloc]initWithFrame:CGRectMake(VAL_BOTH(55, 110), VAL_BOTH(10, 20), VAL_BOTH(125, 370), VAL_BOTH(30.0f, 60))];
        [lblNoads setText:@"No Ads"];
        [lblNoads setFont:[UIFont systemFontOfSize:VAL_R(24.0f)]];
        [lblNoads setTextColor:[UIColor whiteColor]];
        [subContentView addSubview:lblNoads];
        
        UIImageView *purchaseRubyIcon = [[UIImageView alloc]initWithFrame:CGRectMake(VAL_BOTH(15, 30), VAL_BOTH(50, 100), VAL_BOTH(30, 60), VAL_BOTH(30, 60))];
        [purchaseRubyIcon setImage:[UIImage imageNamed:@"icon_purchase_ruby.png"]];
        [subContentView addSubview:purchaseRubyIcon];
        
        UILabel *lblRuby = [[UILabel alloc]initWithFrame:CGRectMake(VAL_BOTH(55, 110), VAL_BOTH(50, 100), VAL_BOTH(125, 370), VAL_BOTH(30.0f, 60))];
        [lblRuby setText:@"500 Rubies"];
        [lblRuby setFont:[UIFont systemFontOfSize:VAL_R(24.0f)]];
        [lblRuby setTextColor:[UIColor whiteColor]];
        [subContentView addSubview:lblRuby];
        
        UIButton *btnBuy = [[UIButton alloc]initWithFrame:CGRectMake(VAL_BOTH(15, 30), VAL_BOTH(95, 190), VAL_BOTH(80, 210), VAL_BOTH(30, 60))];
        [btnBuy setTitle:@"Buy Now!" forState:UIControlStateNormal];
        [btnBuy setBackgroundImage:[UIImage imageNamed:@"btn_temp_green.png"] forState:UIControlStateNormal];
        [btnBuy.titleLabel setFont:[UIFont boldSystemFontOfSize:VAL_R(12.0f)]];
        [btnBuy addTarget:self action:@selector(onBuyRRPro:) forControlEvents:UIControlEventTouchUpInside];
        [subContentView addSubview:btnBuy];
        
        UIButton *btnNothanks = [[UIButton alloc]initWithFrame:CGRectMake(VAL_BOTH(105, 260), VAL_BOTH(95, 190), VAL_BOTH(80, 210), VAL_BOTH(30, 60))];
        [btnNothanks setTitle:@"No Thanks!" forState:UIControlStateNormal];
        [btnNothanks setBackgroundImage:[UIImage imageNamed:@"btn_temp_green.png"] forState:UIControlStateNormal];
        [btnNothanks.titleLabel setFont:[UIFont boldSystemFontOfSize:VAL_R(12.0f)]];
        [btnNothanks addTarget:self action:@selector(onNothanks:) forControlEvents:UIControlEventTouchUpInside];
        [subContentView addSubview:btnNothanks];
    } else if (btn.tag == 6) {
        // Build A Dis
        NSURL *url = [[NSURL alloc] initWithString:BUILD_A_DIS_LINK_URL];
        [[UIApplication sharedApplication] openURL:url];
    } else if (btn.tag == 7) {
        // Pick Up Pal
        NSURL *url = [[NSURL alloc] initWithString:PICK_UP_PAL_LINK_URL];
        [[UIApplication sharedApplication] openURL:url];
    } else {
//        UIAlertView *msgConfirm = [[UIAlertView alloc] initWithTitle:@"Confirm Your In-App Purchase!"
//                                                           message:[NSString stringWithFormat:@"Do you want to buy \"%@\" for %@?", msgOfPurchase[btn.tag], price]
//                                                          delegate:self
//                                                 cancelButtonTitle:@"Cancel"
//                                                 otherButtonTitles:@"Buy", nil];
//        [msgConfirm show];
        [self runPurchase];
    }
}

- (void) runPurchase
{
    switch (m_nSelectedIndex) {
        case 0:
        {
            [[MKStoreManager sharedManager] buyFeatureRubies350];
        }
            break;
        case 1:
        {
            [[MKStoreManager sharedManager] buyFeatureRubiesPRO];
        }
            break;
        case 2:
        {
            [[MKStoreManager sharedManager] buyFeatureRubies750];
        }
            break;
        case 3:
        {
            [[MKStoreManager sharedManager] buyFeatureRubies2000];
        }
            break;
        case 4:
        {
            [[MKStoreManager sharedManager] buyFeatureRubies4500];
        }
            break;
        case 5:
        {
            [[MKStoreManager sharedManager] buyFeatureRubies10000];
        }
            break;
        default:
            break;
    }
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
//    if([title isEqualToString:@"Cancel"]) {
//        return;
//    }
//    
//    [self runPurchase];
//
//    //NSLog(@"Clicked: %d", m_nSelectedIndex);
//    // In-App Purchase functional
//}

- (void) onBuyRRPro:(id)sender {
    // Purchase for PRO version
    [purchaseProPopupView removeFromSuperview];
    purchaseProPopupView = nil;
    
//    NSString *price = (priceOfPurchase[m_nSelectedIndex] == 0) ? @"FREE" : [NSString stringWithFormat:@"$%.2f", priceOfPurchase[m_nSelectedIndex]];
//    UIAlertView *msgConfirm = [[UIAlertView alloc] initWithTitle:@"Confirm Your In-App Purchase!"
//                                                         message:[NSString stringWithFormat:@"Do you want to buy \"%@\" for %@?", msgOfPurchase[m_nSelectedIndex], price]
//                                                        delegate:self
//                                               cancelButtonTitle:@"Cancel"
//                                               otherButtonTitles:@"Buy", nil];
//    [msgConfirm show];
    [self runPurchase];
}

- (void) onNothanks:(id)sender {
    [purchaseProPopupView removeFromSuperview];
    purchaseProPopupView = nil;
}


@end
