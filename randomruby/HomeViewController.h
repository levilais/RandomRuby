//
//  HomeViewController.h
//  RandomRuby
//
//  Created by BrightSun on 8/29/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITextViewDelegate ,UIScrollViewDelegate> {
    UIView  *m_MenuBar;
    UILabel *m_CurrentLevelText;
    UIActivityIndicatorView *m_LoadIndicator;
    UIView *m_LoadMaskView;
    BOOL m_bShowPopUp;
    NSTimer *m_AdsTimer;
    UIView  *purchaseProPopupView;
    float   m_fTimeCount;
}

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIScrollView *adsScrollView;
@property (strong, nonatomic) IBOutlet UIView *adsContentView;
@property (strong, nonatomic) IBOutlet UIView *FBAppShareView;
@property (weak, nonatomic) IBOutlet UITextView *userCustomTextView;
@property (strong, nonatomic) IBOutlet UIView *howtoplayPopupView;
@property (weak, nonatomic) IBOutlet UIButton *closePopupButton;
@property (weak, nonatomic) IBOutlet UIScrollView *popupScrollView;
@property (strong, nonatomic) IBOutlet UIView *popupContentView;

- (IBAction)onPlay:(id)sender;
- (IBAction)onClickLink:(id)sender;
- (IBAction)onShareAppOK:(id)sender;
- (IBAction)onShareAppCancel:(id)sender;
- (IBAction)onClosePopup:(id)sender;

@end
