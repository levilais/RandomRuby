//
//  HomeViewController.m
//  RandomRuby
//
//  Created by BrightSun on 8/29/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import "HomeViewController.h"
#import "GameViewController.h"
#import "InfoViewController.h"
#import "WonViewController.h"
#import "StoreViewController.h"
#import "AppDelegate.h"
#import "MKStoreManager.h"
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>

@interface HomeViewController ()

@end

@implementation HomeViewController

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
    
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES];
    m_fTimeCount = 0;
    
    // Top nav view
    m_MenuBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, G_SWIDTH, VAL_R(40))];
    m_MenuBar.backgroundColor = [UIColor clearColor];
    
    // Background
    UIImageView *bgNav = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, G_SWIDTH, m_MenuBar.frame.size.height)];
    bgNav.image = [UIImage imageNamed:@"bg_menubar.png"];
    bgNav.backgroundColor = [UIColor clearColor];
    [m_MenuBar addSubview:bgNav];
    
    UIButton *infButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [infButton setFrame:CGRectMake(VAL_R(5), VAL_R(5), VAL_R(30), VAL_R(30))];
    [infButton setBackgroundImage:[UIImage imageNamed:@"icon_info.png"] forState:UIControlStateNormal];
    [infButton addTarget:self action:@selector(onInfo:) forControlEvents:UIControlEventTouchUpInside];
    [m_MenuBar addSubview:infButton];
    
    UIImageView *levelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(G_SWIDTH / 2 - VAL_R(25), 0, VAL_R(50), VAL_R(38))];
    levelImageView.image = [UIImage imageNamed:@"icon_star.png"];
    levelImageView.backgroundColor = [UIColor clearColor];
    m_CurrentLevelText = [[UILabel alloc]initWithFrame:CGRectMake(VAL_R(6), VAL_R(10), VAL_R(40), VAL_R(20))];
    m_CurrentLevelText.font = [UIFont systemFontOfSize:VAL_R(12.0)];
    m_CurrentLevelText.textColor = [UIColor colorWithRed:(20/255) green:(100/255) blue:(200/255) alpha:1.0f];
    m_CurrentLevelText.backgroundColor = [UIColor clearColor];
    m_CurrentLevelText.textAlignment = NSTextAlignmentCenter;
    [levelImageView addSubview:m_CurrentLevelText];
    [m_MenuBar addSubview:levelImageView];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setFrame:CGRectMake(G_SWIDTH - VAL_R(81), VAL_R(6), VAL_R(76), VAL_R(28))];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"btn_more.png"] forState:UIControlStateNormal];
    [moreButton setTitle:@"" forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    [m_MenuBar addSubview:moreButton];
    
    [self.view addSubview:m_MenuBar];
    
    m_AdsTimer = [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(adsTimer) userInfo:nil repeats:YES];
    
    [self.adsScrollView addSubview:self.adsContentView];
    [self.adsScrollView setContentSize:self.adsContentView.frame.size];
    self.adsScrollView.delegate = self;
    
    // Pop up
    [self.popupScrollView addSubview:self.popupContentView];
    [self.popupScrollView setContentSize:self.popupContentView.frame.size];
    
    if (!g_bLoadediCloudData) {
        m_LoadMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, G_SWIDTH, G_SHEIGHT)];
        [m_LoadMaskView setBackgroundColor:[UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.5f]];
        m_LoadIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [m_LoadIndicator setFrame:CGRectMake((G_SWIDTH - m_LoadIndicator.bounds.size.width) / 2, (G_SHEIGHT - m_LoadIndicator.bounds.size.height) / 2, m_LoadIndicator.bounds.size.width, m_LoadIndicator.bounds.size.height)];
        [m_LoadMaskView addSubview:m_LoadIndicator];
        [self.view addSubview:m_LoadMaskView];
        [m_LoadIndicator startAnimating];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    loadSettingFromiCloud();
    
    m_CurrentLevelText.text = [NSString stringWithFormat:@"%d", g_GameInfo.level];
    if (m_LoadMaskView == nil) {
        [self displayHowtoPopup];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    if (m_bShowPopUp) {
        [self.howtoplayPopupView removeFromSuperview];
        m_bShowPopUp = NO;
    }
}

- (void) displayHowtoPopup {
    m_bShowPopUp = NO;
    if (g_GameInfo.level == 1 && !g_GameInfo.overReset) {
        m_bShowPopUp = YES;
        [self showHowToPlayPopUp];
    }
}

- (void) adsTimer {
    if (!self.adsScrollView.tracking) {
        [self.adsScrollView setContentOffset:CGPointMake(self.adsScrollView.contentOffset.x + VAL_R(1.0f), self.adsScrollView.contentOffset.y)];
    }
    
    if (!g_bLoadediCloudData && m_fTimeCount < 3) {
        if (!g_bEnablediCloud) {
            g_bLoadediCloudData = YES;
        } else if (g_bReceivediCloudData) {
            loadSettingFromiCloud();
            m_CurrentLevelText.text = [NSString stringWithFormat:@"%d", g_GameInfo.level];
            
            g_bLoadediCloudData = YES;
            NSLog(@"iCloud data receved!!!");
        }
        m_fTimeCount += 0.03;
    } else if (m_LoadMaskView != nil) {
        [m_LoadMaskView removeFromSuperview];
        m_LoadMaskView = nil;
        [self displayHowtoPopup];
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"%f", scrollView.contentOffset.x);
    if (scrollView.contentOffset.x > VAL_BOTH(1000, 1490)) {
        scrollView.contentOffset = CGPointMake(VAL_BOTH(340, 310), scrollView.contentOffset.y);
    } else if (scrollView.contentOffset.x < 0) {
        scrollView.contentOffset = CGPointMake(VAL_BOTH(670, 1195), scrollView.contentOffset.y);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showHowToPlayPopUp
{
    self.howtoplayPopupView.frame = CGRectMake(0, G_SHEIGHT, G_SWIDTH, VAL_BOTH(380 * G_RY, 824));
    [self.view insertSubview:self.howtoplayPopupView atIndex:6];
    [UIView beginAnimations:@"PopUpView Appear" context:(void*)self.howtoplayPopupView];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationDelegate:self];
    self.howtoplayPopupView.frame = CGRectMake(0, m_MenuBar.frame.size.height * G_RY, self.howtoplayPopupView.frame.size.width, self.howtoplayPopupView.frame.size.height);
    [UIView commitAnimations];
    
    [self blinkAnimation:@"CloseButtonAnimate" finished:YES target:self.closePopupButton];
}

- (void) blinkAnimation:(NSString *)animationId finished:(BOOL)finished target:(UIView *)target {
    if (m_bShowPopUp) {
        [UIView beginAnimations:animationId context:(void*)target];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(blinkAnimation:finished:target:)];
        if ([target alpha] == 1.0f)
            [target setAlpha:0.5f];
        else
            [target setAlpha:1.0f];
        [UIView commitAnimations];
    }
}


- (void) onInfo:(UIButton*) sender
{
    InfoViewController *infoView = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    
    [self.navigationController pushViewController:infoView animated:YES];
}

- (void) onMore:(UIButton*) sender
{
    StoreViewController *storeView = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil];
    
    [self.navigationController pushViewController:storeView animated:YES];
}

- (IBAction)onPlay:(id)sender {
    if (g_GameInfo.level > g_nTotalLevel) {
        WonViewController *wonView = [[WonViewController alloc] initWithNibName:@"WonViewController" bundle:nil];
        [self.navigationController pushViewController:wonView animated:YES];
    } else {
        GameViewController *gameView = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
        [self.navigationController pushViewController:gameView animated:YES];
    }
}

- (IBAction)onClickLink:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
    switch (btn.tag) {
        case 0:
        case 4:
        {
            // Build-A-Dis
            NSURL *url = [[NSURL alloc] initWithString:BUILD_A_DIS_LINK_URL];
            [[UIApplication sharedApplication] openURL:url];
        }
            break;
            
        case 1:
        case 5:
        {
            // Pick-Up_Pal
            NSURL *url = [[NSURL alloc] initWithString:PICK_UP_PAL_LINK_URL];
            [[UIApplication sharedApplication] openURL:url];
        }
            break;
            
        case 2:
        case 6:
        {
            shareToFacebook(@"Random Ruby", @" ", @"Try it now for free!!");
            // Share App To Facebook
//            self.userCustomTextView.text = @"";
//            self.userCustomTextView.font = [UIFont systemFontOfSize:VAL_R(14.0f)];
//            
//            self.FBAppShareView.frame = CGRectMake(0, -G_SHEIGHT, G_SWIDTH, G_SHEIGHT - m_MenuBar.frame.size.height);
//            [self.view insertSubview:self.FBAppShareView atIndex:7];
//            [UIView beginAnimations:@"LevelShareView Appear" context:(void*)self.FBAppShareView];
//            [UIView setAnimationDuration:0.7f];
//            [UIView setAnimationDelegate:self];
//            self.FBAppShareView.frame = CGRectMake(0, m_MenuBar.frame.size.height, self.FBAppShareView.frame.size.width, self.FBAppShareView.frame.size.height);
//            [UIView commitAnimations];
        }
            break;
            
        case 3:
        case 7:
        {
            if (g_GameInfo.proVersion) {
                alertMessage(@"You have purchased PRO version.", @"Warning");
                return;
            }
            // Upgrade
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
            
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)onShareAppOK:(id)sender {
//    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
//    {
//        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//        
//        [controller setInitialText:self.userCustomTextView.text];
//        [controller addImage:[UIImage imageNamed:@"Icon@2x.png"]];
//        [controller addURL:[NSURL URLWithString:RANDOM_RUBY_LINK_URL]];
//        
//        [controller setCompletionHandler:^(SLComposeViewControllerResult result)
//         {
//             switch (result) {
//                 case SLComposeViewControllerResultCancelled:
//                     NSLog(@"Post Canceled");
//                     break;
//                 case SLComposeViewControllerResultDone:
//                 {
//                     alertMessage(@"Post Success!!!", @"Success");
//                     NSLog(@"Facebook Share Success.");
//                 }
//                     break;
//                     
//                 default:
//                     break;
//             }
//             [self onShareAppCancel:sender];
//         }];
//        [self presentViewController:controller animated:YES completion:nil];
//    } else {
//        NSLog(@"Unavailable FB service");
//    }
}

- (IBAction)onShareAppCancel:(id)sender {
    [self.FBAppShareView removeFromSuperview];
}

- (IBAction)onClosePopup:(id)sender {
    [self.howtoplayPopupView removeFromSuperview];
    m_bShowPopUp = NO;
}

- (void) onBuyRRPro:(id)sender {
    // Purchase for PRO version
    [purchaseProPopupView removeFromSuperview];
    purchaseProPopupView = nil;
    
//    UIAlertView *msgConfirm = [[UIAlertView alloc] initWithTitle:@"Confirm Your In-App Purchase!"
//                                                         message:@"Do you want to buy \"Random Ruby: PRO\" for $1.99?"
//                                                        delegate:self
//                                               cancelButtonTitle:@"Cancel"
//                                               otherButtonTitles:@"Buy", nil];
//    [msgConfirm show];
    [[MKStoreManager sharedManager] buyFeatureRubiesPRO];

}

- (void) onNothanks:(id)sender {
    [purchaseProPopupView removeFromSuperview];
    purchaseProPopupView = nil;
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
//    if([title isEqualToString:@"Cancel"]) {
//        return;
//    }
//        
//    [[MKStoreManager sharedManager] buyFeatureRubiesPRO];
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    //NSLog(@"touchesBegan:withEvent:");
//    [self.view endEditing:YES];
//    [super touchesBegan:touches withEvent:event];
//}
//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    //NSLog(@"touchesEnd:withEvent:");
//    [super touchesEnded:touches withEvent:event];
//}
//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
//    //NSLog(@"textViewShouldBeginEditing:");
//    return YES;
//}
//- (void)textViewDidBeginEditing:(UITextView *)textView {
//    //NSLog(@"textViewDidBeginEditing:");
//    textView.backgroundColor = [UIColor greenColor];
//}
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
//    //NSLog(@"textViewShouldEndEditing:");
//    textView.backgroundColor = [UIColor whiteColor];
//    return YES;
//}
//- (void)textViewDidEndEditing:(UITextView *)textView{
//    //NSLog(@"textViewDidEndEditing:");
//}
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
//    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
//    NSUInteger location = replacementTextRange.location;
//    if (textView.text.length + text.length > 140){
//        if (location != NSNotFound){
//            [textView resignFirstResponder];
//        }
//        return NO;
//    }
//    else if (location != NSNotFound){
//        [textView resignFirstResponder];
//        return NO;
//    }
//    return YES;
//}
//- (void)textViewDidChange:(UITextView *)textView{
//    //NSLog(@"textViewDidChange:");
//}
//- (void)textViewDidChangeSelection:(UITextView *)textView{
//    //NSLog(@"textViewDidChangeSelection:");
//}

@end
