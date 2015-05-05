//
//  GameViewController.m
//  RandomRuby
//
//  Created by BrightSun on 9/15/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import "GameViewController.h"
#import "AppDelegate.h"
#import "SpeakMessageView.h"
#import "StoreViewController.h"
#import "WonViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>


float fSolveBoxWidth = 35;
float fSolveBoxPadding = 4;
float fSolveBoxMargin = 6;
float fTailRackButtonWidth = 50;
float fTailRackButtonPadding = 10;
float fTailRackButtonMargin = 15;
float fTailHelpButtonWidth = 90;

@interface GameViewController ()

@end

@implementation GameViewController

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
    loadSettingFromiCloud();
    
    if (IS_IPAD()) {
        fSolveBoxWidth = 80;
        fSolveBoxPadding = 12;
        fSolveBoxMargin = 22;
        fTailRackButtonWidth = 100;
        fTailRackButtonPadding = 35;
        fTailRackButtonMargin = 64;
        fTailHelpButtonWidth = 190;
    }
    
    m_SolveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [m_SolveButton setBackgroundImage:[UIImage imageNamed:@"btn_solve.png"] forState:UIControlStateNormal];
    [m_SolveButton setFrame:CGRectMake(G_SWIDTH - VAL_BOTH(65, 150), self.talkingRoundLayer.frame.size.height + VAL_R(20), VAL_R(50), VAL_R(50))];
    [m_SolveButton setTitle:@"" forState:UIControlStateNormal];
    [m_SolveButton setBackgroundColor:[UIColor clearColor]];
    [m_SolveButton addTarget:self action:@selector(onSolve) forControlEvents:UIControlEventTouchUpInside];
    //[dialogContentView addSubview:solveButton];
    [self.talkingRoundLayer addSubview:m_SolveButton];
    
    // Top nav view
    m_MenuBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, G_SWIDTH, VAL_R(40))];
    m_MenuBar.backgroundColor = [UIColor clearColor];
    
    // Background
    UIImageView *bgNav = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, G_SWIDTH, m_MenuBar.frame.size.height)];
    bgNav.image = [UIImage imageNamed:@"bg_menubar.png"];
    bgNav.backgroundColor = [UIColor clearColor];
    [m_MenuBar addSubview:bgNav];

    // --- Back Button
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectMake(VAL_R(5), VAL_R(5), VAL_R(30), VAL_R(30))];
    [homeButton setBackgroundImage:[UIImage imageNamed:@"icon_home.png"] forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(onHome:) forControlEvents:UIControlEventTouchUpInside];
    [m_MenuBar addSubview:homeButton];
    
    // --- Level
    UIImageView *levelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(G_SWIDTH / 2 - VAL_R(25), 0, VAL_R(50), VAL_R(38))];
    levelImageView.image = [UIImage imageNamed:@"icon_star.png"];
    levelImageView.backgroundColor = [UIColor clearColor];
    m_CurrentLevel = [[UILabel alloc]initWithFrame:CGRectMake(VAL_R(6), VAL_R(10), VAL_R(40), VAL_R(20))];
    m_CurrentLevel.text = [NSString stringWithFormat:@"%d", g_GameInfo.level];
    m_CurrentLevel.font = [UIFont systemFontOfSize:VAL_R(12.0f)];
    m_CurrentLevel.textColor = [UIColor colorWithRed:(20/255) green:(100/255) blue:(200/255) alpha:1.0f];
    m_CurrentLevel.backgroundColor = [UIColor clearColor];
    m_CurrentLevel.textAlignment = NSTextAlignmentCenter;
    [levelImageView addSubview:m_CurrentLevel];
    [m_MenuBar addSubview:levelImageView];
    
    // --- RubyCount Button
    m_RubyCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    m_RubyCountButton.frame = CGRectMake(G_SWIDTH - VAL_R(85), VAL_R(5), VAL_R(81), VAL_R(30));
    m_RubyCountButton.backgroundColor = [UIColor clearColor];
    [m_RubyCountButton setBackgroundImage:[UIImage imageNamed:@"btn_ruby_count.png"] forState:UIControlStateNormal];
    [m_RubyCountButton addTarget:self action:@selector(onStore:) forControlEvents:UIControlEventTouchUpInside];
    [m_RubyCountButton setTitle:[NSString stringWithFormat:@"%d", g_GameInfo.rubyCounts] forState:UIControlStateNormal];
    [m_RubyCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [m_RubyCountButton.titleLabel setFont:[UIFont boldSystemFontOfSize:VAL_R(16.0f)]];
    [m_RubyCountButton setTitleEdgeInsets:UIEdgeInsetsMake(0, VAL_R(25), 0, 0)];
    [m_MenuBar addSubview:m_RubyCountButton];
    
    [self.view insertSubview:m_MenuBar aboveSubview:self.talkingRoundLayer];
    
    // --- Coffee steam
    NSArray * coffeeImageArray  = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"pic_coffee_steam_1.png"],
                                   [UIImage imageNamed:@"pic_coffee_steam_2.png"],
                                   [UIImage imageNamed:@"pic_coffee_steam_3.png"],
                                   [UIImage imageNamed:@"pic_coffee_steam_4.png"],
                                   nil];
    
    UIImageView * coffeeImage = [[UIImageView alloc] initWithFrame:CGRectMake(VAL_BOTH(293 * G_RX, 705), VAL_BOTH(110, 228) , VAL_BOTH(12, 28), VAL_BOTH(24, 57))];
    coffeeImage.animationImages = coffeeImageArray;
    coffeeImage.animationDuration = 0.7;
    //coffeeImage.animationRepeatCount = 1; // one time looping only
    [self.centerLayer addSubview:coffeeImage];
    [coffeeImage startAnimating];
    
    // init variable
    m_nGameState = STATE_NEW;
    m_nSpeakStep = SPEAK_NONE;
    m_fSpeakDelay = 1.0f;
    m_arrLevelShareTileBox = [[NSMutableArray alloc]init];
}

- (void) viewDidAppear:(BOOL)animated
{
    loadSettingFromiCloud();

    if (m_nGameState == STATE_NEW) {
        [self loadLevelInfo];
        [self displaySpeakBox:SPEAK_NONE];
        
        m_fSpeakDelay = 1.0f;
        m_nSpeakStep = SPEAK_NONE;
        m_nSolveCount = 0;
        m_nGameState = STATE_SPEAKING;
        m_bShouldContinueBlinking = NO;
        m_SolveButton.alpha = 1.0;
        [m_SolveButton setFrame:CGRectMake(m_SolveButton.frame.origin.x, (self.talkingRoundLayer.frame.size.height - m_SolveButton.frame.size.height) / 2, m_SolveButton.frame.size.width, m_SolveButton.frame.size.height)];
        m_nRemoveLatterNum = 0;
        m_nRevealLatterNum = 0;
        
        // Initialize solve box
        for (int i = 0; i < SOLVE_BOX_NUM; i++) {
            m_asSolveBoxInf[i].srcIndex = -1;
            m_asSolveBoxInf[i].locked = false;
            m_asSolveBoxInf[i].mark = false;
        }
        
        self.bobTalkComment.text = g_strBobWord;
        //self.bobTalkComment.font = [UIFont systemFontOfSize:14.0f];
        self.bobTalkComment.font = [UIFont fontWithName:@"Arial" size:VAL_R(14.0f)];
        self.rubyTalkComment.text = g_strRubyWord;
        self.rubyTalkComment.font = [UIFont fontWithName:@"Arial" size:VAL_R(14.0f)];
        
        [self showCharactors:SPEAK_NONE];

        m_Timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(tick) userInfo:nil repeats:YES];
    }
    
    m_CurrentLevel.text = [NSString stringWithFormat:@"%d", g_GameInfo.level];
    [m_RubyCountButton setTitle:[NSString stringWithFormat:@"%d", g_GameInfo.rubyCounts] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadLevelInfo
{
    if (g_GameInfo.level > g_nTotalLevel) {
        WonViewController *wonView = [[WonViewController alloc] initWithNibName:@"WonViewController" bundle:nil];
        [self.navigationController pushViewController:wonView animated:NO];
        return;
    }
    
    //NSString *strLine = (NSString *) [g_arrDatas objectAtIndex:g_GameInfo.level];
    NSArray *orgItems = [g_arrDatas objectAtIndex:g_GameInfo.level];
    //NSArray *items = [strLine componentsSeparatedByString:@","];
    NSMutableArray *items = [[NSMutableArray alloc]init];
    
    NSString *strNew = nil;
    // Replice " to \"
    for (int i = 0; i < [orgItems count]; i++)
    {
        NSString *strTmp = (NSString*)[orgItems objectAtIndex:i];
        
        if (strTmp == nil || strTmp.length == 0) {
            continue;
        }
        if (strNew && strNew.length > 0) {
            if ([[strTmp substringWithRange:NSMakeRange(strTmp.length - 1, 1)] isEqualToString:@"\""]) {
                strNew = [NSString stringWithFormat:@"%@, %@", strNew, [strTmp substringWithRange:NSMakeRange(0, strTmp.length - 1)]];
                [items addObject:strNew];
                strNew = nil;
            } else {
                strNew = [NSString stringWithFormat:@"%@, %@", strNew, strTmp];
            }
        } else if ([[strTmp substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"\""]) {
            strNew = [strTmp substringWithRange:NSMakeRange(1, strTmp.length - 1)];
        } else {
            [items addObject:strTmp];
        }
    }
    g_strDifficult =[[[NSString alloc] initWithString:[(NSString*)[items objectAtIndex:0] stringByReplacingOccurrencesOfString:@"\n" withString:@""]] uppercaseString];
    g_strBillWord = [[NSString alloc] initWithString:[(NSString*)[items objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    g_strBobWord = [[NSString alloc] initWithString:[(NSString*)[items objectAtIndex:2] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    g_strRubyWord = [[NSString alloc] initWithString:[(NSString*)[items objectAtIndex:3] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    
    [g_strProblem removeAllObjects];
    for (int i = 0; i < TAIL_RACK_NUM; i++) {
        NSString *str = [[NSString alloc] initWithString:[(NSString*)[items objectAtIndex:5	 + i] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        //g_strProblem = [NSString stringWithFormat:@"%@%@", g_strProblem, [str lowercaseString]];
        [g_strProblem addObject:str];
    }
    g_strSolve = [[NSString alloc] initWithString:[(NSString*)[items objectAtIndex:5 + TAIL_RACK_NUM] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    g_strSolve = [g_strSolve lowercaseString];
}

- (void) tick
{
    if (m_fSpeakDelay <= 0 && m_nSpeakStep != SPEAK_STOP) {
        if (m_nSpeakStep == SPEAK_NONE) {
            [self displaySpeakBox:SPEAK_BILL];
            m_nSpeakStep = SPEAK_BILL;
            m_fSpeakDelay = g_strBillWord.length / 50.0f * 3.0f;
            if (m_fSpeakDelay < 3) m_fSpeakDelay = 3.0f;
        } else if (m_nSpeakStep == SPEAK_BILL) {
            [self displaySpeakBox:SPEAK_BOB];
            m_nSpeakStep = SPEAK_BOB;
            m_fSpeakDelay = g_strBobWord.length / 50.0f * 3.0f;
            if (m_fSpeakDelay < 3) m_fSpeakDelay = 3.0f;
        } else if (m_nSpeakStep == SPEAK_BOB) {
            [self displaySpeakBox:SPEAK_RUBY];
            m_nSpeakStep = SPEAK_RUBY;
            m_fSpeakDelay = g_strRubyWord.length / 50.0f * 3.0f;
            if (m_fSpeakDelay < 3) m_fSpeakDelay = 3.0f;
        } else if (m_nSpeakStep == SPEAK_RUBY) {
            //[self displaySpeakBox:SPEAK_DONE];
            m_nSpeakStep = SPEAK_DONE;
            //m_fSpeakDelay = 3.0f;
        } else if (m_nSpeakStep == SPEAK_DONE) {
            m_nSpeakStep = SPEAK_STOP;
            if (m_nGameState < STATE_SOLVE) {
                [self onSolve];
            }
        }
        
        [self showCharactors:m_nSpeakStep];
    } else {
        m_fSpeakDelay -= 0.1;
    }
    
    if (m_nGameState == STATE_SOLVE) {
        if (m_fSolveCycleTime <= 0) {
            // Pulsing effect
            [self pulsingAnimation];
            m_fSolveCycleTime = SOLVE_CYCLE_TIME;
        }
        m_fSolveCycleTime -= 0.1;
        
        // Check solve
        if (m_nSolveCount < g_strSolve.length) {
            int idx = 0;
            for (UIButton* solveBox in m_arrSolveBox) {
                if (m_asSolveBoxInf[idx].locked) {
                    solveBox.titleLabel.textColor = [UIColor blueColor];
                } else {
                    solveBox.titleLabel.textColor = [UIColor whiteColor];
                }
                idx++;
            }
            return;
        }
        
        NSString *strSolve = @"";
        for (int i = 0; i < m_nSolveCount; i++) {
            UIButton *solveBox = [m_arrSolveBox objectAtIndex:i];
            strSolve = [NSString stringWithFormat:@"%@%@", strSolve, solveBox.titleLabel.text];
        }
        
        if ([g_strSolve isEqualToString:[strSolve lowercaseString]]) {
            // Correct
            for (UIButton* solveBox in m_arrSolveBox) {
                solveBox.titleLabel.textColor = [UIColor blueColor];
            }

            m_fSolveCycleTime = 0.8f;
            m_nGameState = STATE_COMPLETE_SOLVE;
        } else {
            int idx = 0;
            for (UIButton* solveBox in m_arrSolveBox) {
                if (m_asSolveBoxInf[idx].locked) {
                    solveBox.titleLabel.textColor = [UIColor blueColor];
                } else {
                    solveBox.titleLabel.textColor = [UIColor redColor];
                }
                idx++;
            }
        }
    }
    
    if (m_nGameState == STATE_COMPLETE_SOLVE) {
        if (m_fSolveCycleTime < 0) {
            [m_Timer invalidate];
            m_Timer = nil;
            
            m_nGameState = STATE_NEW;
            
            [self.solveView removeFromSuperview];
            [self displaySpeakBox:SPEAK_NONE];
            
            // Correct!
            WonViewController *wonView = [[WonViewController alloc] initWithNibName:@"WonViewController" bundle:nil];
            [self.navigationController pushViewController:wonView animated:YES];
        }
        m_fSolveCycleTime -= 0.1f;
    }
}

- (void) displaySpeakBox:(int) target
{
    if (speakBox) {
        [speakBox removeFromSuperview];
        speakBox = nil;
    }
    
    float fontSize = VAL_R(16.0f);
    [self showRuby:NO];
    if (target == SPEAK_BILL) {
        speakBox = [[UIImageView alloc]initWithFrame:CGRectMake(VAL_BOTH(10, 30), 0, VAL_BOTH(230, 540), VAL_R(100) * G_RY)];
        [speakBox setImage:[UIImage imageNamed:@"bg_speak_bill.png"]];
        speakBox.backgroundColor = [UIColor clearColor];
        speakBox.tag = SPEAK_BILL;
        
        if (g_strBillWord.length >= 100) fontSize = VAL_R(13.0f);
        else if (g_strBillWord.length >= 90) fontSize = VAL_R(14.0f);
        else if (g_strBillWord.length >= 80) fontSize = VAL_R(15.0f);
        SpeakMessageView *msgView = [[SpeakMessageView alloc]initWithFrame:CGRectMake(VAL_R(10), VAL_R(25) * G_RY, VAL_BOTH(210, 500), VAL_R(70) * G_RY)];
        [msgView setSpeakMessageInfoFor:g_strBillWord withFontSize:fontSize ColorWithR:0.25 G:0.25 B:0.25 IsBlinking:NO IsWritingAnimation:YES WritingSpeed:MESSAGE_WRITING_SPEED_FAST];
        [speakBox addSubview:msgView];
        
        [self.talkingRoundLayer addSubview:speakBox];
    } else if (target == SPEAK_BOB) {
        if (!m_bShouldContinueBlinking) {
            m_bShouldContinueBlinking = YES;
            [self blinkAnimation:@"SolveAnimate" finished:YES target:m_SolveButton];
        }
        
        speakBox = [[UIImageView alloc]initWithFrame:CGRectMake(VAL_BOTH(10, 30), 0, VAL_BOTH(230, 540), VAL_R(100) * G_RY)];
        [speakBox setImage:[UIImage imageNamed:@"bg_speak_bob.png"]];
        speakBox.backgroundColor = [UIColor clearColor];
        speakBox.tag = SPEAK_BOB;
        
        if (g_strBobWord.length >= 100) fontSize = VAL_R(13.0f);
        else if (g_strBobWord.length >= 90) fontSize = VAL_R(14.0f);
        else if (g_strBobWord.length >= 80) fontSize = VAL_R(15.0f);
        SpeakMessageView *msgView = [[SpeakMessageView alloc]initWithFrame:CGRectMake(VAL_R(10), VAL_R(25) * G_RY, VAL_BOTH(210, 500), VAL_R(70) * G_RY)];
        [msgView setSpeakMessageInfoFor:g_strBobWord withFontSize:fontSize ColorWithR:0.25 G:0.25 B:0.25 IsBlinking:NO IsWritingAnimation:YES WritingSpeed:MESSAGE_WRITING_SPEED_FAST];
        [speakBox addSubview:msgView];
        
        [self.talkingRoundLayer addSubview:speakBox];
    } else if (target == SPEAK_RUBY) {
        [self showRuby:YES];
        
        speakBox = [[UIImageView alloc]initWithFrame:CGRectMake(VAL_BOTH(10, 30), VAL_R(20) * G_RY, VAL_BOTH(230, 540), VAL_R(80) * G_RY)];
        [speakBox setImage:[UIImage imageNamed:@"bg_speak_ruby.png"]];
        speakBox.backgroundColor = [UIColor clearColor];
        speakBox.tag = SPEAK_RUBY;
        
        if (g_strRubyWord.length >= 100) fontSize = VAL_R(13.0f);
        else if (g_strRubyWord.length >= 90) fontSize = VAL_R(14.0f);
        else if (g_strRubyWord.length >= 80) fontSize = VAL_R(15.0f);
        SpeakMessageView *msgView = [[SpeakMessageView alloc]initWithFrame:CGRectMake(VAL_BOTH(30, 80), VAL_R(5) * G_RY, VAL_BOTH(210, 420), VAL_R(70) * G_RY)];
        [msgView setSpeakMessageInfoFor:g_strRubyWord withFontSize:fontSize ColorWithR:0.25 G:0.25 B:0.25 IsBlinking:NO IsWritingAnimation:YES WritingSpeed:MESSAGE_WRITING_SPEED_FAST];
        [speakBox addSubview:msgView];
        
        [self.talkingRoundLayer addSubview:speakBox];
    }
    
}

- (void) showCharactors:(int) state
{
    if (m_BillCharactor != nil) {
        [m_BillCharactor removeFromSuperview];
        m_BillCharactor = nil;
    }
    if (m_BobCharactor != nil) {
        [m_BobCharactor removeFromSuperview];
        m_BobCharactor = nil;
    }
    
    CGRect bill_back = (IS_IPAD()) ? CGRectMake(92, 140, 207, 456) : CGRectMake(37 * G_RX, 64, 87 * G_RX, 214);
    CGRect bill_turn = (IS_IPAD()) ? CGRectMake(90, 140, 279, 449) : CGRectMake(36 * G_RX, 67, 117 * G_RX, 211);
    CGRect bill_mouth = (IS_IPAD()) ? CGRectMake(84, 92, 57, 40) : CGRectMake(34 * G_RX, 42, 26, 21);
    CGRect bob_back = (IS_IPAD()) ? CGRectMake(492, 140, 208, 454) : CGRectMake(205 * G_RX, 65, 87 * G_RX, 213);
    CGRect bob_turn = (IS_IPAD()) ? CGRectMake(457, 119, 255.5, 470) : CGRectMake(190 * G_RX, 57, 107 * G_RX, 221);
    CGRect bob_mouth = (IS_IPAD()) ? CGRectMake(113.5f, 100.5f, 49, 29) : CGRectMake(46.5f * G_RX, 45.5f, 22.5, 16.5);
    
    if (state == SPEAK_NONE)
    {
        m_BillCharactor = [[UIImageView alloc] initWithFrame:bill_back];
        m_BillCharactor.image = [UIImage imageNamed:@"pic_bill_back.png"];
        m_BillCharactor.backgroundColor = [UIColor clearColor];
        
        m_BobCharactor = [[UIImageView alloc] initWithFrame:bob_back];
        m_BobCharactor.image = [UIImage imageNamed:@"pic_bob_back.png"];
        m_BobCharactor.backgroundColor = [UIColor clearColor];
    }
    else if (state == SPEAK_BILL)
    {
        m_BillCharactor = [[UIImageView alloc] initWithFrame:bill_turn];
        [m_BillCharactor setImage:[UIImage imageNamed:@"pic_bill_turn.png"]];
        m_BillCharactor.backgroundColor = [UIColor clearColor];
        
        NSArray * imageArray  = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"pic_bill_mouth_1.png"],
                                 [UIImage imageNamed:@"pic_bill_mouth_2.png"],
                                 [UIImage imageNamed:@"pic_bill_mouth_3.png"],
                                 [UIImage imageNamed:@"pic_bill_mouth_2.png"],
                                 [UIImage imageNamed:@"pic_bill_mouth_3.png"],
                                 [UIImage imageNamed:@"pic_bill_mouth_2.png"],
                                 [UIImage imageNamed:@"pic_bill_mouth_3.png"],
                                 [UIImage imageNamed:@"pic_bill_mouth_2.png"],
                                 nil];
        
        UIImageView * image = [[UIImageView alloc] initWithFrame:bill_mouth];
        image.animationImages = imageArray;
        image.animationDuration = 2.0;
        [m_BillCharactor addSubview:image];
        [image startAnimating];
        
        // Bob
        m_BobCharactor = [[UIImageView alloc] initWithFrame:bob_back];
        m_BobCharactor.image = [UIImage imageNamed:@"pic_bob_back.png"];
        m_BobCharactor.backgroundColor = [UIColor clearColor];
    }
    else if (state == SPEAK_BOB)
    {
        // Bill
        m_BillCharactor = [[UIImageView alloc] initWithFrame:bill_turn];
        [m_BillCharactor setImage:[UIImage imageNamed:@"pic_bill_turn.png"]];
        m_BillCharactor.backgroundColor = [UIColor clearColor];
        
        UIImageView * image = [[UIImageView alloc] initWithFrame:bill_mouth];
        image.image = [UIImage imageNamed:@"pic_bill_mouth_1.png"];
        image.backgroundColor = [UIColor clearColor];
        [m_BillCharactor addSubview:image];

        // Bob
        m_BobCharactor = [[UIImageView alloc] initWithFrame:bob_turn];
        [m_BobCharactor setImage:[UIImage imageNamed:@"pic_bob_turn.png"]];
        m_BobCharactor.backgroundColor = [UIColor clearColor];

        NSArray * imageArray  = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"pic_bob_mouth_1.png"],
                                 [UIImage imageNamed:@"pic_bob_mouth_2.png"],
                                 [UIImage imageNamed:@"pic_bob_mouth_3.png"],
                                 [UIImage imageNamed:@"pic_bob_mouth_2.png"],
                                 [UIImage imageNamed:@"pic_bob_mouth_3.png"],
                                 [UIImage imageNamed:@"pic_bob_mouth_2.png"],
                                 [UIImage imageNamed:@"pic_bob_mouth_3.png"],
                                 [UIImage imageNamed:@"pic_bob_mouth_2.png"],
                                 nil];
        
        UIImageView * image1 = [[UIImageView alloc] initWithFrame:bob_mouth];
        image1.animationImages = imageArray;
        image1.animationDuration = 2.0;
        [m_BobCharactor addSubview:image1];
        [image1 startAnimating];
    }
    else
    {
        m_BillCharactor = [[UIImageView alloc] initWithFrame:bill_turn];
        [m_BillCharactor setImage:[UIImage imageNamed:@"pic_bill_turn.png"]];
        m_BillCharactor.backgroundColor = [UIColor clearColor];
        
        UIImageView * image = [[UIImageView alloc] initWithFrame:bill_mouth];
        image.image = [UIImage imageNamed:@"pic_bill_mouth_1.png"];
        image.backgroundColor = [UIColor clearColor];
        [m_BillCharactor addSubview:image];

        m_BobCharactor = [[UIImageView alloc] initWithFrame:bob_turn];
        [m_BobCharactor setImage:[UIImage imageNamed:@"pic_bob_turn.png"]];
        m_BobCharactor.backgroundColor = [UIColor clearColor];
        
        UIImageView * image1 = [[UIImageView alloc] initWithFrame:bob_mouth];
        image1.image = [UIImage imageNamed:@"pic_bob_mouth_1.png"];
        image1.backgroundColor = [UIColor clearColor];
        [m_BobCharactor addSubview:image1];
    }

    [self.centerLayer addSubview:m_BillCharactor];
    [self.centerLayer addSubview:m_BobCharactor];
}

- (void) onSolve
{
    m_bShouldContinueBlinking = NO;
    m_SolveButton.alpha = 1.0;
    m_nGameState = STATE_SOLVE;
    m_fSolveCycleTime = 3;
    m_bPulsAlarm = NO;
    
    // Show Solve layer
    for (UIView *subView in self.solveTailView.subviews)
    {
        [subView removeFromSuperview];
    }
    
    [self loadSolveBoxButtons];
    [self loadTailRackButtons];
    [self loadHelpFuncButtons];
    [self showSolveView];
}

- (void) onHome:(UIButton*) sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) onStore:(UIButton*) sender
{
    StoreViewController *storeView = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil];
    
    [self.navigationController pushViewController:storeView animated:YES];
}

- (void) showRuby:(BOOL) visible
{
    if (m_RubyImage) {
        [m_RubyImage removeFromSuperview];
        m_RubyImage = nil;
    }
    
    if (!visible) {
        return;
    }
    
    int rand = arc4random() % 8;
    CGPoint targetPos;
    float rubyWidth = VAL_R(74), rubyHeight = VAL_R(80);
    
    UIImage *rubyCharactorImage = [UIImage imageNamed:@"icon_ruby_character.png"];
    
    if (rand < 2) { // from left
        m_RubyImage = [[UIImageView alloc]initWithFrame:CGRectMake(-rubyWidth, self.topLayer.frame.size.height - rubyHeight, rubyWidth, rubyHeight)];
        targetPos = CGPointMake(VAL_BOTH(10, 25), m_RubyImage.frame.origin.y);
    } else if (rand < 4) { // from left bottom
        m_RubyImage = [[UIImageView alloc]initWithFrame:CGRectMake(VAL_BOTH(10, 25), self.topLayer.frame.size.height, rubyWidth, rubyHeight)];
        targetPos = CGPointMake(m_RubyImage.frame.origin.x, m_RubyImage.frame.origin.y - rubyHeight);
    } else if (rand < 6) { // from right
        m_RubyImage = [[UIImageView alloc]initWithFrame:CGRectMake(G_SWIDTH, self.topLayer.frame.size.height - rubyHeight, rubyWidth, rubyHeight)];
        targetPos = CGPointMake(G_SWIDTH - (rubyWidth + VAL_BOTH(10, 25)), m_RubyImage.frame.origin.y);
    } else { // from right bottom
        m_RubyImage = [[UIImageView alloc]initWithFrame:CGRectMake(G_SWIDTH - (rubyWidth + VAL_BOTH(10, 25)), self.topLayer.frame.size.height, rubyWidth, rubyHeight)];
        targetPos = CGPointMake(m_RubyImage.frame.origin.x, m_RubyImage.frame.origin.y - rubyHeight);
    }
    m_RubyImage.image = rubyCharactorImage;
    m_RubyImage.backgroundColor = [UIColor clearColor];
    [self.topLayer addSubview:m_RubyImage];
    
//    [UIView beginAnimations:@"UIImage Move" context:NULL];
//    [UIView setAnimationDuration:1.0];
//    m_RubyImage.frame = CGRectMake(targetPos.x, targetPos.y, m_RubyImage.frame.size.width, m_RubyImage.frame.size.height);
//    [UIView commitAnimations];
    [self moveAnimation:@"Ruby Moving" Duration:1.0f TARGET:m_RubyImage POSITION:CGPointMake(targetPos.x, targetPos.y)];
}

- (void) moveAnimation:(NSString *)animationId Duration:(float)duration TARGET:(UIView*)target POSITION:(CGPoint)pos
{
    [UIView beginAnimations:animationId context:(void*)target];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:self];
    target.frame = CGRectMake(pos.x, pos.y, target.frame.size.width, target.frame.size.height);
    [UIView commitAnimations];
}

- (void) blinkAnimation:(NSString *)animationId finished:(BOOL)finished target:(UIView *)target {
    if (m_bShouldContinueBlinking) {
        [UIView beginAnimations:animationId context:(void*)target];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(blinkAnimation:finished:target:)];
        if ([target alpha] == 1.0f)
            [target setAlpha:0.3f];
        else
            [target setAlpha:1.0f];
        [UIView commitAnimations];
    }
}

- (void) pulsingAnimation
{
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shake.fromValue = [NSNumber numberWithFloat:-0.1];
    shake.toValue = [NSNumber numberWithFloat:+0.1];
    shake.duration = 0.07;
    shake.autoreverses = YES;
    shake.repeatCount = 8;
    
    for (UIButton *btn in m_arrFuncBox) {
        [btn.layer addAnimation:shake forKey:[NSString stringWithFormat:@"Solve Func %d", btn.tag]];
        btn.alpha = 1.0;
    }
    
    [UIView animateWithDuration:2.0 delay:2.0 options:UIViewAnimationOptionCurveEaseIn animations:nil completion:nil];
}

- (void) showSolveView
{
    m_bShouldContinueBlinking = NO;
    m_SolveButton.alpha = 1.0;

    self.solveView.frame = CGRectMake(0, G_SHEIGHT, G_SWIDTH, G_SHEIGHT - m_MenuBar.frame.size.height);
    [self.view insertSubview:self.solveView atIndex:5];
    [self moveAnimation:@"SoloveButton Move" Duration:1.0f TARGET:m_SolveButton POSITION:CGPointMake(m_SolveButton.frame.origin.x, m_SolveButton.frame.origin.y - G_SHEIGHT)];
    [self moveAnimation:@"SoloveView Appear" Duration:1.0f TARGET:self.solveView POSITION:CGPointMake(0, m_MenuBar.frame.size.height)];
}

- (void) loadSolveBoxButtons
{
    if (m_arrSolveBox && [m_arrSolveBox count] > 0) {
        [m_arrSolveBox removeAllObjects];
    }
    m_arrSolveBox = [[NSMutableArray alloc]init];
    
    int nSolveBoxCount = (g_strSolve.length > SOLVE_BOX_NUM) ? SOLVE_BOX_NUM : g_strSolve.length;
    float startPosX = (G_SWIDTH - (nSolveBoxCount * fSolveBoxWidth + (nSolveBoxCount - 1) * fSolveBoxPadding + fSolveBoxMargin * 2)) / 2;
    startPosX += fSolveBoxMargin;
    
    for (int i = 0; i < nSolveBoxCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(startPosX, VAL_R(10 * G_RY), fSolveBoxWidth, fSolveBoxWidth);
        btn.backgroundColor = [UIColor clearColor];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_tail_solve.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onSolveBox:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:VAL_R(20.0f)]];
        btn.tag = i;
        [self.solveTailView addSubview:btn];
        [m_arrSolveBox addObject:btn];
        
        startPosX += (fSolveBoxWidth + fSolveBoxPadding);
    }
}

- (void) loadTailRackButtons
{
    if (m_arrRackBox && [m_arrRackBox count] > 0) {
        [m_arrRackBox removeAllObjects];
    }
    m_arrRackBox = [[NSMutableArray alloc]init];
    
    float startPosX = fTailRackButtonMargin;
    float startPosY = VAL_R(20) * G_RY + fSolveBoxWidth;
    
    NSMutableArray *arrTmp = [[NSMutableArray alloc]init];
    for (int i = 0; i < [g_strProblem count]; i++) {
        [arrTmp addObject:[g_strProblem objectAtIndex:i]];
    }
    
    for (int i = 0; i < TAIL_RACK_NUM; i++) {
        if (i == TAIL_RACK_NUM / 2) {
            startPosX = fTailRackButtonMargin;
            startPosY += VAL_R(5) + fTailRackButtonWidth;
        }
        
        int idx = arc4random() % [arrTmp count];
        NSString *lbl = [arrTmp objectAtIndex:idx];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(startPosX, startPosY, fTailRackButtonWidth, fTailRackButtonWidth);
        btn.backgroundColor = [UIColor clearColor];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_tail_rack.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onTailRack:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:lbl forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:VAL_R(20.0f)]];
        btn.tag = i;
        [self.solveTailView addSubview:btn];
        [m_arrRackBox addObject:btn];
        
        [arrTmp removeObjectAtIndex:idx];
        startPosX += (fTailRackButtonWidth + fTailRackButtonPadding);
    }
    [arrTmp removeAllObjects];
}

- (void) loadHelpFuncButtons
{
    if (m_arrFuncBox && [m_arrFuncBox count] > 0) {
        [m_arrFuncBox removeAllObjects];
    }
    m_arrFuncBox = [[NSMutableArray alloc]init];

    float startPosX = fTailRackButtonMargin;
    float startPosY = VAL_R(20) * G_RY + VAL_R(10) + fTailRackButtonWidth * 2 + fSolveBoxWidth;
    NSString *strLabel[] = {@"btn_help_fb.png", @"btn_help_reveal.png", @"btn_help_remove.png"};
    
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(startPosX, startPosY, fTailHelpButtonWidth, fTailRackButtonWidth);
        btn.backgroundColor = [UIColor clearColor];
        [btn setBackgroundImage:[UIImage imageNamed:strLabel[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onHelpFunc:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:VAL_R(20.0f)]];
        btn.tag = i;
        [self.solveTailView addSubview:btn];
        [m_arrFuncBox addObject:btn];
        
        startPosX += (fTailHelpButtonWidth + fTailRackButtonPadding);
    }
}

- (void) onSolveBox:(UIButton*) sender
{
    if (sender.titleLabel.text.length == 0 || m_asSolveBoxInf[sender.tag].srcIndex == -1 ||
        m_asSolveBoxInf[sender.tag].locked) {
        return;
    }
    
    for (UIButton* rackBtn in m_arrRackBox) {
        if (rackBtn.tag == m_asSolveBoxInf[sender.tag].srcIndex) {
            [sender setTitle:@"" forState:UIControlStateNormal];
            sender.titleLabel.text = @"";
            m_asSolveBoxInf[sender.tag].srcIndex = -1;
            m_asSolveBoxInf[sender.tag].locked = false;
            m_asSolveBoxInf[sender.tag].mark = false;
            m_nSolveCount--;
            rackBtn.hidden = NO;
        }
    }
//    sender.titleLabel.textColor = [UIColor redColor];
}

- (void) onTailRack:(UIButton*) sender
{
    if (m_nSolveCount >= g_strSolve.length) {
        return;
    }
    
    for (int i = 0; i < g_strSolve.length; i++) {
        UIButton *solveBox = [m_arrSolveBox objectAtIndex:i];
        //NSLog(@"%@ - %d", solveBox.titleLabel.text, solveBox.titleLabel.text.length);
        if (solveBox.titleLabel.text.length > 0)
            continue;
        
        [solveBox setTitle:sender.titleLabel.text forState:UIControlStateNormal];
        m_asSolveBoxInf[i].srcIndex = sender.tag;
        m_asSolveBoxInf[i].mark = false;
        m_asSolveBoxInf[i].locked = false;
        m_nSolveCount++;
        sender.hidden = YES;
        break;
    }
}

- (void) onHelpFunc:(UIButton*) sender
{
    if (sender.tag == 0) {
        // Facebook
        NSString *text = @"Help! Please help me find the common thread!";
        text = [text stringByAppendingString:[NSString stringWithFormat:@"\n\nBob: %@\nRuby: %@", g_strBobWord, g_strRubyWord]];

        NSString *availableLetters = @"\n\n";
        for (int i = 0; i < TAIL_RACK_NUM; i++) {
            UIButton *btnRack = [m_arrRackBox objectAtIndex:i];
            availableLetters = [availableLetters stringByAppendingString:[NSString stringWithFormat:@"%@ ", btnRack.titleLabel.text]];
        }
        text = [text stringByAppendingString:availableLetters];
        
        NSString *solveLetters = @"";
        for (int i = 0; i < g_strSolve.length; i++) {
            solveLetters = [solveLetters stringByAppendingString:@"_ "];
        }
        //solveLetters = [solveLetters stringByAppendingString:[NSString stringWithFormat:@"(%d Letters)", g_strSolve.length]];
        text = [text stringByAppendingString:[NSString stringWithFormat:@"\n%@ (%d Letters)", solveLetters, g_strSolve.length]];
        
//        NSString *desc = [NSString stringWithFormat:@"%@<center></center>%@<center></center><i>Download Random Ruby now!!</i><center></center>It's Free!", availableLetters, solveLetters];
        text = [text stringByAppendingString:@"\n\nDownload Random Ruby now!! It's Free!\n"];
        //shareToFacebook(@"Help! Please help me find the common thread!", caption, desc);
        
        UIImage *shareImage = [UIImage imageNamed:@"icon_rr_256.png"];
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];

            [controller setInitialText:text];
            [controller addImage:shareImage];
            [controller addURL:[NSURL URLWithString:RANDOM_RUBY_LINK_URL]];

            [controller setCompletionHandler:^(SLComposeViewControllerResult result)
             {
                 switch (result) {
                     case SLComposeViewControllerResultCancelled:
                         NSLog(@"Post Canceled");
                         break;
                     case SLComposeViewControllerResultDone:
                     {
                         alertMessage(@"Post Success!!!", @"Success");
                         NSLog(@"Facebook Share Success.");
                     }
                         break;

                     default:
                         break;
                 }
                 [self onCancelLevelShare:sender];
             }];
            [self presentViewController:controller animated:YES completion:nil];
        } else {
            NSLog(@"Unavailable FB service");
        }

        
//        self.userCommentText.text = @"";
//        //self.userCommentText.returnKeyType = UIReturnKeyDone;
//        self.userCommentText.font = [UIFont systemFontOfSize:VAL_R(14.0f)];
//        self.titleText.text = @"Help! Please help me find the common thread!";
//        self.titleText.font = [UIFont systemFontOfSize:VAL_R(14.0f)];
//        self.bobsComment.text = g_strBobWord;
//        self.bobsComment.font = [UIFont systemFontOfSize:VAL_BOTH(14.0f, 24.0f)];
//        self.rubysComment.text = g_strRubyWord;
//        self.rubysComment.font = [UIFont systemFontOfSize:VAL_BOTH(14.0f, 24.0f)];
//        
//        while ([m_arrLevelShareTileBox count] > 0) {
//            UIButton * box = [m_arrLevelShareTileBox objectAtIndex:0];
//            [m_arrLevelShareTileBox removeObject:box];
//            [box removeFromSuperview];
//        }
//        
//        float posX = VAL_BOTH(10, 28);
//        for (int i = 0; i < TAIL_RACK_NUM; i++) {
//            UIButton *btnRack = [m_arrRackBox objectAtIndex:i];
//            
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            btn.frame = CGRectMake(posX, VAL_BOTH(250 * G_RY, 500), VAL_BOTH(27, 64), VAL_BOTH(27, 64));
//            btn.backgroundColor = [UIColor clearColor];
//            [btn setBackgroundImage:[UIImage imageNamed:@"btn_tail_rack.png"] forState:UIControlStateNormal];
//            [btn setTitle:btnRack.titleLabel.text forState:UIControlStateNormal];
//            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:VAL_BOTH(16.0f, 34.0f)]];
//            btn.tag = i;
//            [self.FBLevelShareView addSubview:btn];
//            [m_arrLevelShareTileBox addObject:btn];
//
//            posX += VAL_BOTH(30, 72);
//        }
//        
//        float width = VAL_BOTH(40, 90);
//        posX = (G_SWIDTH - g_strSolve.length * width) / 2 + 5;
//        for (int i = 0; i < g_strSolve.length; i++) {
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            btn.frame = CGRectMake(posX, VAL_BOTH(285 * G_RY, 590), VAL_BOTH(30, 80), VAL_BOTH(30, 80));
//            btn.backgroundColor = [UIColor clearColor];
//            [btn setBackgroundImage:[UIImage imageNamed:@"btn_tail_solve.png"] forState:UIControlStateNormal];
//            btn.tag = i;
//            [self.FBLevelShareView addSubview:btn];
//            [m_arrLevelShareTileBox addObject:btn];
//            
//            posX += width;
//        }
//        
//        self.FBLevelShareView.frame = CGRectMake(0, -G_SHEIGHT, G_SWIDTH, G_SHEIGHT - m_MenuBar.frame.size.height);
//        [self.view insertSubview:self.FBLevelShareView atIndex:7];
//        [self moveAnimation:@"LevelShareView Appear" Duration:0.7f TARGET:self.FBLevelShareView POSITION:CGPointMake(0, m_MenuBar.frame.size.height)];
    } else if (sender.tag == 1) {
        if (g_GameInfo.rubyCounts < REVEAL_CORRECT_PER_RUBIES) {
            alertMessage(@"You don't have enough Rubies! Go to the Store to buy more!!!", @"Warning!");
        } else if (m_nRevealLatterNum == g_strSolve.length) {
            alertMessage(@"Revealed all correct letters.", @"Warning!");
        } else {
            UIAlertView *msgConfirm = [[UIAlertView alloc] initWithTitle:@"Reveal A Latter"
                                                    message:[NSString stringWithFormat:@"Reveal a correct letter for %d Rubies?", REVEAL_CORRECT_PER_RUBIES]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
            m_nHelpButtonTag = sender.tag;
            [msgConfirm show];
        }
    } else if (sender.tag == 2) {
        if (g_GameInfo.rubyCounts < REVEAL_CORRECT_PER_RUBIES) {
            alertMessage(@"You don't have enough Rubies! Go to the Store to buy more!!!", @"Warning!");
        } else if (TAIL_RACK_NUM - g_strSolve.length - m_nRemoveLatterNum == 0) {
            alertMessage(@"Removed all incorrect letters.", @"Warning!");
        } else {
            UIAlertView *msgConfirm = [[UIAlertView alloc] initWithTitle:@"Remove A Latter"
                                                    message:[NSString stringWithFormat:@"Remove an incorrect letter for %d Rubies?", REMOVE_INCORRECT_PER_RUBIES]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
            m_nHelpButtonTag = sender.tag;
            [msgConfirm show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Cancel"] || m_nHelpButtonTag == 0) {
        return;
    }
    
    if (m_nHelpButtonTag == 1) {
        // Reveal a Correct Letters
        g_GameInfo.rubyCounts -= REVEAL_CORRECT_PER_RUBIES;
        saveGameInfo();
        //Flurry
        trackFlurryForUseRubies(REVEAL_CORRECT_PER_RUBIES);
        
        [m_RubyCountButton setTitle:[NSString stringWithFormat:@"%d", g_GameInfo.rubyCounts] forState:UIControlStateNormal];

        NSString *chSolve = @"";
        int selNo = 0;
        bool fFound = false;
        int cnt = 0;
        
        for (int n = 0; n < g_strSolve.length; n++) {
            UIButton *solveBox = [m_arrSolveBox objectAtIndex:n];
            if (m_asSolveBoxInf[n].locked) continue;
            
            if (m_asSolveBoxInf[n].srcIndex != -1 && [[[g_strSolve substringWithRange:NSMakeRange(n, 1)] uppercaseString] isEqual:solveBox.titleLabel.text]) {
                m_asSolveBoxInf[n].mark = true;
                continue;
            }
            cnt++;
        }
        
        selNo = arc4random() % cnt;
        int idx = 0;
        
        for (int i = 0; i < g_strSolve.length; i++) {
            UIButton *solveBox = [m_arrSolveBox objectAtIndex:i];
            
            if (m_asSolveBoxInf[i].locked || m_asSolveBoxInf[i].mark) {
                continue;
            }
            
            if (selNo == idx) {
                if (m_asSolveBoxInf[i].srcIndex != -1) {
                    [self onSolveBox:solveBox];
                }
                chSolve = [[g_strSolve substringWithRange:NSMakeRange(i, 1)] uppercaseString];
                selNo = i;
                fFound = true;
                break;
            }
            idx++;
        }
        
        for (int j = 0; j < TAIL_RACK_NUM; j++) {
            UIButton *btnRack = [m_arrRackBox objectAtIndex:j];
            if (![chSolve isEqual:btnRack.titleLabel.text]) {
                continue;
            }
            if (btnRack.hidden) {
                bool flag = false;
                for (int k = 0; k < g_strSolve.length; k++) {
                    if (m_asSolveBoxInf[k].srcIndex == btnRack.tag) {
                        if (m_asSolveBoxInf[k].locked || m_asSolveBoxInf[k].mark) {
                            flag = true;
                        } else {
                            UIButton *solveBox = [m_arrSolveBox objectAtIndex:k];
                            [self onSolveBox:solveBox];
                        }
                        break;
                    }
                }
                if (flag) {
                    continue;
                }
            }
            
            //[self onTailRack:btnRack];
            UIButton *solveBox = [m_arrSolveBox objectAtIndex:selNo];
            [solveBox setTitle:chSolve forState:UIControlStateNormal];
            solveBox.titleLabel.textColor = [UIColor blueColor];
            m_asSolveBoxInf[selNo].srcIndex = btnRack.tag;
            m_asSolveBoxInf[selNo].locked = true;
            m_asSolveBoxInf[selNo].mark = true;
            m_nSolveCount++;
            btnRack.hidden = YES;
            m_nRevealLatterNum++;
            break;
        }
    
    } else if (m_nHelpButtonTag == 2) {
        // Remove an Incorrect Letters
        g_GameInfo.rubyCounts -= REMOVE_INCORRECT_PER_RUBIES;
        saveGameInfo();
        //Flurry
        trackFlurryForUseRubies(REVEAL_CORRECT_PER_RUBIES);
        
        [m_RubyCountButton setTitle:[NSString stringWithFormat:@"%d", g_GameInfo.rubyCounts] forState:UIControlStateNormal];
        
        int idx = 0;
        int nRemoveTarget = arc4random() % (TAIL_RACK_NUM - g_strSolve.length - m_nRemoveLatterNum);
        bool arrFindFlag[g_strSolve.length];
        memset(&arrFindFlag, 0, sizeof(bool) * g_strSolve.length);
        
        for (int i = 0; i < TAIL_RACK_NUM; i++) {
            UIButton *btnRack = [m_arrRackBox objectAtIndex:i];
            bool isSolveLatter = false;
            
            for (int j = 0; j < g_strSolve.length; j++) {
                if (arrFindFlag[j])
                    continue;
                
                NSString *strSolve = [g_strSolve substringWithRange:NSMakeRange(j, 1)];
                if ([[strSolve uppercaseString] isEqual:btnRack.titleLabel.text]) {
                    arrFindFlag[j] = true;
                    isSolveLatter = true;
                    break;
                }
            }
            if (isSolveLatter) {
                continue;
            }
            
            if (btnRack.hidden) {
                bool flag = false;
                for (int k = 0; k < g_strSolve.length; k++) {
                    if (m_asSolveBoxInf[k].srcIndex != btnRack.tag)
                        continue;
                    
                    if (idx == nRemoveTarget) {
                        UIButton *solveBox = [m_arrSolveBox objectAtIndex:k];
                        [self onSolveBox:solveBox];
                        flag = true;
                    } else {
                        idx++;
                    }
                    break;
                }
                if (flag) {
                    btnRack.hidden = YES;
                    m_nRemoveLatterNum++;
                    break;
                }
            } else if (idx == nRemoveTarget) {
                btnRack.hidden = YES;
                m_nRemoveLatterNum++;
                break;
            } else {
                idx++;
            }
        }
    }
}

- (UIImage*)screenshot
{
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    float gTopPos = m_MenuBar.bounds.size.height + VAL_BOTH(75 * G_RY, 150);
//    CGRect clippedRect = CGRectMake(0, gTopPos * image.scale, image.size.width * image.scale, VAL_BOTH(310 * G_RY, 690) * image.scale);
//    
//    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
//    UIImage *resultImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
//    CGImageRelease(imageRef);
//    
//    return resultImage;
    return image;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
    
    // Check touch speakbox
    if (!speakBox) return;
    
    UITouch *touch1 = [touches anyObject];
    CGPoint touchLocation = [touch1 locationInView:self.talkingRoundLayer];
    CGRect startRect = [[[speakBox layer] presentationLayer] frame];
    if (CGRectContainsPoint(startRect, touchLocation)) {
        //NSLog(@"%d", speakBox.tag);
        if (speakBox.tag >= SPEAK_BILL && speakBox.tag <= SPEAK_RUBY) {
            m_fSpeakDelay = 0;
        }
    }
}
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

- (IBAction)onCancelLevelShare:(id)sender {
    [self.FBLevelShareView removeFromSuperview];
}

- (IBAction)onFBLevelShare:(id)sender {
//    UIImage *shareImage = [self screenshot];
//    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
//    {
//        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//        
//        [controller setInitialText:self.userCommentText.text];
//        [controller addImage:shareImage];
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
//             [self onCancelLevelShare:sender];
//         }];
//        [self presentViewController:controller animated:YES completion:nil];
//    } else {
//        NSLog(@"Unavailable FB service");
//    }
    
    // Test code
//    UIImage *screenImg = [self screenshot];
//    UIImageView *testImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, VAL_R(40), screenImg.size.width, screenImg.size.height)];
//    testImg.image = screenImg;
//    testImg.backgroundColor = [UIColor clearColor];
//    
//    [self.view insertSubview:testImg aboveSubview:self.solveView];
//    
//    [self.FBLevelShareView removeFromSuperview];
}

@end
