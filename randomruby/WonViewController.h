//
//  WonViewController.h
//  RandomRuby
//
//  Created by BrightSun on 9/5/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface WonViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    UILabel     *m_RubyCount;
    UIAlertView *confirmStartoverView;
    UIAlertView *confirmFunView;
    UIAlertView *confirmRateView;
    UIAlertView *confirmFeedbackView;

    MFMailComposeViewController *picker;
    UIViewController    *emailController;
}

@property (strong, nonatomic) IBOutlet UIView *awesomeView;
@property (weak, nonatomic) IBOutlet UIImageView *rubyCountImage;
@property (weak, nonatomic) IBOutlet UIButton *playNextButton;
@property (strong, nonatomic) IBOutlet UIView *congratulationView;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIScrollView *congratulationScrollView;
@property (strong, nonatomic) IBOutlet UIView *congratulationContentView;
@property (weak, nonatomic) IBOutlet UIView *descriptionBgView;
@property (weak, nonatomic) IBOutlet UIView *descriptionView;

- (IBAction)onPlayNext:(id)sender;
- (IBAction)onStartOver:(id)sender;
@end
