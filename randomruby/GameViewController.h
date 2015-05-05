//
//  GameViewController.h
//  RandomRuby
//
//  Created by BrightSun on 9/15/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

#define TAIL_RACK_NUM 10
#define SOLVE_BOX_NUM 8
#define SOLVE_CYCLE_TIME    8
#define REVEAL_CORRECT_PER_RUBIES   60
#define REMOVE_INCORRECT_PER_RUBIES 80


enum {
    SPEAK_NONE,
    SPEAK_BILL,
    SPEAK_BOB,
    SPEAK_RUBY,
    SPEAK_DONE,
    SPEAK_STOP,
};

enum GAME_STATE {
    STATE_NEW,
    STATE_SPEAKING,
    STATE_SOLVE,
    STATE_COMPLETE_SOLVE,
};

typedef struct _solve_box_info_ {
    int srcIndex;
    bool locked;
    bool mark;
} SOLVE_BOX_INFO;

@interface GameViewController : UIViewController <UITextViewDelegate> {
    int     m_nSpeakStep;
    NSTimer *m_Timer;
    float   m_fSpeakDelay;
    
    UIImageView *speakBox;
    UIImageView *m_RubyImage;
    UIImageView *m_BillCharactor;
    UIImageView *m_BobCharactor;
    
    UIView      *m_MenuBar;
    UIButton    *m_SolveButton;
    UIButton    *m_RubyCountButton;
    UILabel     *m_CurrentLevel;
    
    BOOL        m_bShouldContinueBlinking;
    NSMutableArray *m_arrSolveBox;
    NSMutableArray *m_arrRackBox;
    NSMutableArray *m_arrFuncBox;
    //int         m_anSrcIndexOfSolve[SOLVE_BOX_NUM];
    SOLVE_BOX_INFO m_asSolveBoxInf[SOLVE_BOX_NUM];
    int         m_nSolveCount;
    int         m_nGameState;
    float       m_fSolveCycleTime;
    BOOL        m_bPulsAlarm;
    int         m_nHelpButtonTag;
    int         m_nRemoveLatterNum;
    int         m_nRevealLatterNum;
    NSMutableArray *m_arrLevelShareTileBox;
}
@property (weak, nonatomic) IBOutlet UIView *topLayer;
@property (weak, nonatomic) IBOutlet UIView *centerLayer;
@property (weak, nonatomic) IBOutlet UIView *talkingRoundLayer;

@property (strong, nonatomic) IBOutlet UIView *solveView;
@property (weak, nonatomic) IBOutlet UIView *solveTailView;
@property (weak, nonatomic) IBOutlet UITextView *bobTalkComment;
@property (weak, nonatomic) IBOutlet UITextView *rubyTalkComment;

@property (strong, nonatomic) IBOutlet UIView *FBLevelShareView;
@property (weak, nonatomic) IBOutlet UITextView *userCommentText;
@property (weak, nonatomic) IBOutlet UITextView *titleText;
@property (weak, nonatomic) IBOutlet UITextView *bobsComment;
@property (weak, nonatomic) IBOutlet UITextView *rubysComment;
- (IBAction)onCancelLevelShare:(id)sender;
- (IBAction)onFBLevelShare:(id)sender;

@end
