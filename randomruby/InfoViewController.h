//
//  InfoViewController.h
//  RandomRuby
//
//  Created by BrightSun on 9/4/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    UIView          *m_MenuBar;
    MFMailComposeViewController *m_Picker;
    UIViewController    *emailController;
    UIButton *rubyCountButton;
}

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *restorePurchasesButton;
@property (weak, nonatomic) IBOutlet UIButton *startOverButton;
@property (weak, nonatomic) IBOutlet UIView *howtoplayView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

- (IBAction)onPlay:(id)sender;
- (IBAction)onRestorePurchases:(id)sender;
- (IBAction)onStartOver:(id)sender;
- (IBAction)onFeedback:(id)sender;
- (void) refreshRubyCount;

@end
