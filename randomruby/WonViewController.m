//
//  WonViewController.m
//  RandomRuby
//
//  Created by BrightSun on 9/5/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import "WonViewController.h"
#import "GameViewController.h"
#import "Global.h"
#import <RevMobAds/RevMobAds.h>

NSString *strCongratulatoryText[] = {
    @"That’s Right!",
    @"Great Job!",
    @"Obviously!!",
    @"Of Course!!"
};

@interface WonViewController ()

@end

@implementation WonViewController

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
    loadSettingFromiCloud();
    
    // Do any additional setup after loading the view from its nib.
    //CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if (g_GameInfo.level <= g_nTotalLevel) {
        if (g_GameInfo.level % 3 == 0 && !g_GameInfo.proVersion) {
            [[RevMobAds session] showFullscreen];
        }
        
        g_GameInfo.level++;
        g_GameInfo.rubyCounts += SOLVED_RUBY_NUM;
        saveGameInfo();
        
        //Flurry
        trackFlurryForBuyRubies([NSString stringWithFormat:@"You earned %d rubies by passing level%d", SOLVED_RUBY_NUM, g_GameInfo.level - 1]);
    }

    if (g_GameInfo.level > g_nTotalLevel) {
        [self.descriptionView.layer setCornerRadius:VAL_R(10.0f)];
        [self.descriptionBgView.layer setCornerRadius:VAL_R(5.0f)];
        [self.descriptionView setBackgroundColor:[UIColor colorWithRed:0.0f green:166.0f/255 blue:81.0f/255 alpha:1.0f]];
        
        [self.congratulationScrollView addSubview:self.congratulationContentView];
        [self.congratulationScrollView setContentSize:self.congratulationContentView.frame.size];

        self.view = self.congratulationView;
    } else {
        m_RubyCount = [[UILabel alloc]initWithFrame:CGRectMake(VAL_R(45), VAL_R(8), VAL_R(40), VAL_R(20))];
        [m_RubyCount setText:[NSString stringWithFormat:@" x %d", SOLVED_RUBY_NUM]];
        [m_RubyCount setFont:[UIFont boldSystemFontOfSize:VAL_R(20.0f)]];
        [m_RubyCount setTextColor:[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0]];
        [m_RubyCount setBackgroundColor:[UIColor clearColor]];
        [m_RubyCount setTextAlignment:NSTextAlignmentCenter];
        [self.rubyCountImage addSubview:m_RubyCount];
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    loadSettingFromiCloud();
    
    if (g_GameInfo.level == 11 && g_GameInfo.level < g_nTotalLevel) {
        confirmFunView = [[UIAlertView alloc] initWithTitle:@"Having Fun?!"
                                                    message:[NSString stringWithFormat:@"Are you enjoying your time with Random Ruby?"]
                                                   delegate:self
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:@"NO", nil];
        [confirmFunView show];
        
        // Feedback controller
        emailController = [[UIViewController alloc]init];
        emailController.view.frame = CGRectMake(emailController.view.frame.origin.x, G_SHEIGHT, emailController.view.frame.size.width, emailController.view.frame.size.height);
        [self.view addSubview:emailController.view];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (g_GameInfo.level >= g_nTotalLevel) {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
//}

- (IBAction)onPlayNext:(id)sender {
    // Replay Game
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.375];
    [self.navigationController popViewControllerAnimated:NO];
    [UIView commitAnimations];
    
//    NSArray *viewControllers = [self.navigationController viewControllers];
//    for (int i = 0; i < [viewControllers count]; i++) {
//        id obj = [viewControllers objectAtIndex:i];
//        if ([obj isKindOfClass:[GameViewController class]]){
    //[self.navigationController popViewControllerAnimated:NO];
//            return;
//        }
//    }
}

- (IBAction)onStartOver:(id)sender {
    confirmStartoverView = [[UIAlertView alloc] initWithTitle:@"Start Over"
                                                         message:[NSString stringWithFormat:@"Do you want start over?"]
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"OK", nil];
    [confirmStartoverView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == confirmStartoverView && buttonIndex == 1) {
        g_GameInfo.level = 1;
        g_GameInfo.overReset = YES;
        saveGameInfo();
        
        [self.navigationController popToRootViewControllerAnimated:NO];
    } else if (alertView == confirmFunView) {
        if (buttonIndex == 0) {
            confirmRateView = [[UIAlertView alloc] initWithTitle:@"We're glad to hear it!"
                                                        message:[NSString stringWithFormat:@"Please take a moment of your time to rate our app! Those 5-Star reviews help us keep our lights on!"]
                                                       delegate:self
                                              cancelButtonTitle:@"No Thanks"
                                              otherButtonTitles:@"Rate Random Ruby", nil];
            [confirmRateView show];
        } else {
            confirmFeedbackView = [[UIAlertView alloc] initWithTitle:@"We're sorry to hear that!"
                                                         message:[NSString stringWithFormat:@"Please take a moment to email us your feedback. We'd love to know what we could do better!"]
                                                        delegate:self
                                               cancelButtonTitle:@"No Thanks"
                                               otherButtonTitles:@"Give Feedback", nil];
            [confirmFeedbackView show];
        }
    } else if (alertView == confirmRateView && buttonIndex == 1) {
        NSURL *url = [[NSURL alloc] initWithString:RANDOM_RUBY_LINK_URL];
        [[UIApplication sharedApplication] openURL:url];
    } else if (alertView == confirmFeedbackView && buttonIndex == 1) {
        if ([MFMailComposeViewController canSendMail])
        {
            picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            [picker setToRecipients:[[NSArray alloc] initWithObjects:FEEDBACK_EMAIL, nil ]];
            
            [emailController presentViewController:picker animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Your device doesn't support the composer sheet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
        }
    }
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
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


@end
