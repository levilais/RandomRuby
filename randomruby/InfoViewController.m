//
//  InfoViewController.m
//  RandomRuby
//
//  Created by BrightSun on 9/4/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import "InfoViewController.h"
#import "AppDelegate.h"
#import "StoreViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "GameViewController.h"
#import "WonViewController.h"
#import "MKStoreManager.h"


@interface InfoViewController ()

@end

@implementation InfoViewController

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
    g_InfoViewer = self;
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
    
    // --- Info Label
    UIImageView *labelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(G_SWIDTH / 2 - VAL_R(33), VAL_R(5), VAL_R(65), VAL_R(30))];
    labelImageView.image = [UIImage imageNamed:@"label_info.png"];
    labelImageView.backgroundColor = [UIColor clearColor];
    [m_MenuBar addSubview:labelImageView];
    
    // --- RubyCount Button
    rubyCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rubyCountButton.frame = CGRectMake(G_SWIDTH - VAL_R(85), VAL_R(5), VAL_R(81), VAL_R(30));
    rubyCountButton.backgroundColor = [UIColor clearColor];
    [rubyCountButton setBackgroundImage:[UIImage imageNamed:@"btn_ruby_count.png"] forState:UIControlStateNormal];
    [rubyCountButton addTarget:self action:@selector(onStore:) forControlEvents:UIControlEventTouchUpInside];
    [rubyCountButton setTitle:[NSString stringWithFormat:@"%d", g_GameInfo.rubyCounts] forState:UIControlStateNormal];
    [rubyCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rubyCountButton.titleLabel setFont:[UIFont boldSystemFontOfSize:VAL_R(16.0f)]];
    [rubyCountButton setTitleEdgeInsets:UIEdgeInsetsMake(0, VAL_R(25), 0, 0)];
    [m_MenuBar addSubview:rubyCountButton];
    
    [self.view insertSubview:m_MenuBar aboveSubview:self.contentScrollView];

    [self.contentScrollView setContentSize:self.contentView.frame.size];
    [self.contentScrollView addSubview:self.contentView];
    
    [self.howtoplayView.layer setCornerRadius:VAL_R(10.0f)];
    [self.howtoplayView setBackgroundColor:[UIColor colorWithRed:0.0f green:166.0f/255 blue:81.0f/255 alpha:1.0f]];
    [self.bgView.layer setCornerRadius:VAL_R(5.0f)];
    
    // Feedback controller
    emailController = [[UIViewController alloc]init];
    emailController.view.frame = CGRectMake(emailController.view.frame.origin.x, G_SHEIGHT, emailController.view.frame.size.width, emailController.view.frame.size.height);
    [self.view addSubview:emailController.view];
}

- (void) viewDidAppear:(BOOL)animated
{
    loadSettingFromiCloud();
    
    if (g_GameInfo.level <= g_nTotalLevel) {
        self.playButton.hidden = NO;
        self.startOverButton.hidden = YES;
    } else {
        self.playButton.hidden = YES;
        self.startOverButton.hidden = NO;
    }
    g_bRestore = false;
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

- (IBAction)onRestorePurchases:(id)sender {
    if (g_GameInfo.proVersion) {
        alertMessage(@"Can not restore purchase. Current app is PRO version.", @"Warning");
        return;
    }
    [[MKStoreManager sharedManager] restore];
}

- (IBAction)onStartOver:(id)sender {
    UIAlertView *msgConfirm = [[UIAlertView alloc] initWithTitle:@"Start Over"
                                                         message:[NSString stringWithFormat:@"Do you want start over?"]
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"OK", nil];
    [msgConfirm show];
}

- (IBAction)onFeedback:(id)sender {
    // Send email for feedback
    if ([MFMailComposeViewController canSendMail])
    {
        m_Picker = [[MFMailComposeViewController alloc] init];
        m_Picker.mailComposeDelegate = self;
        
        [m_Picker setToRecipients:[[NSArray alloc] initWithObjects:FEEDBACK_EMAIL, nil ]];
        
        [emailController presentViewController:m_Picker animated:YES completion:nil];
    }
    else
    {
        alertMessage(@"Your device doesn't support the composer sheet", @"Failure");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Cancel"]) {
        return;
    }
    g_GameInfo.level = 1;
    g_GameInfo.overReset = YES;
    saveGameInfo();
    
    GameViewController *gameView = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    [self.navigationController pushViewController:gameView animated:YES];
}

- (void) onBack:(UIButton*) sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) onStore:(UIButton*) sender
{
    StoreViewController *storeView = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil];
    
    [self.navigationController pushViewController:storeView animated:YES];
}

- (void) refreshRubyCount
{
    [rubyCountButton setTitle:[NSString stringWithFormat:@"%d", g_GameInfo.rubyCounts] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MFMailComposeController delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved: you saved the email message in the Drafts folder");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail failed: the email message was nog saved or queued, possibly due to an error");
			break;
		default:
			NSLog(@"Mail not sent");
			break;
	}
    
	//[m_Picker dismissModalViewControllerAnimated:YES];
    [m_Picker dismissViewControllerAnimated:YES completion:nil];
    
}
@end
