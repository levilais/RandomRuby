//
//  Global.h
//  RandomRuby
//
//  Created by JMI on 7/30/13.
//  Copyright 2013 JMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreViewController.h"
#import "InfoViewController.h"


#ifdef UI_USER_INTERFACE_IDIOM//()
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD() (NO)
#endif

#define G_SWIDTH    (IS_IPAD() ? 768: [[UIScreen mainScreen] bounds].size.width)  //Screen width
#define G_SHEIGHT   (IS_IPAD() ? 1024: [[UIScreen mainScreen] bounds].size.height)   //Screen height

#define G_RX    (IS_IPAD() ? 1: G_SWIDTH / 320)
#define G_RY    (IS_IPAD() ? 1: G_SHEIGHT / 480)

#define VAL_R(val)  (IS_IPAD() ? val * 2: val)
#define VAL_BOTH(phone, pad) (IS_IPAD() ? pad: phone)

////////////////////////////

#define FONT_INFO_TEXT    @"Arial"
#define SOLVED_RUBY_NUM     4

#define BUILD_A_DIS_LINK_URL    (IS_IPAD() ? @"https://itunes.apple.com/cn/app/build-a-dis-for-ipad/id593389538?l=en&mt=8" : @"https://itunes.apple.com/cn/app/build-dis-insult-generator/id614141134?l=en&mt=8")
#define PICK_UP_PAL_LINK_URL    (IS_IPAD() ? @"https://itunes.apple.com/cn/app/pick-up-pal-for-ipad/id593393799?l=en&mt=8" : @"https://itunes.apple.com/cn/app/pick-up-pal-pick-up-line-generator/id570136209?l=en&mt=8")
#define RANDOM_RUBY_LINK_URL    @"https://itunes.apple.com/us/app/random-ruby/id782684115?ls=1&mt=8"

#define RANDOM_RUBY_ICON_URL    @"https://s1.mzstatic.com/us/r30/Purple/v4/16/f1/73/16f17372-a4c8-e9b0-5e0f-ec5d3421b161/icon256x256.png"


#define FEEDBACK_EMAIL @"info@appvolks.com"


# pragma Glabal Variables

//extern float    g_fWidth;
//extern float    g_fHeight;
//extern float    g_fx;
//extern float    g_fy;
extern NSString *g_strDifficult;
extern NSString *g_strBillWord;
extern NSString *g_strBobWord;
extern NSString *g_strRubyWord;
extern NSString *g_strSolve;
extern NSMutableArray *g_strProblem;
extern int      g_nTotalLevel;
extern NSArray  *g_arrDatas;
extern bool     g_bRestore;
extern BOOL     g_bEnablediCloud;
extern BOOL     g_bLoadediCloudData;
extern BOOL     g_bReceivediCloudData;

//extern bool g_bMusicOn;
//extern bool g_bSoundOn;
extern StoreViewController *g_StoreViewer;
extern InfoViewController *g_InfoViewer;

# pragma Structs

typedef struct _GAME_INFO_ {
    int     level;
    int     rubyCounts;
    BOOL    overReset;
    BOOL    proVersion;
    BOOL    isFirst;
    int     timestamp;
} GAME_INFO;

GAME_INFO g_GameInfo;
extern int g_nLastTimestamp;

# pragma Global Functions

void initGameInfo();
void loadGameInfo();
void saveGameInfo();
void alertMessage(NSString *msg, NSString *title);
void loadDataFromFile();
void trackFlurryForUseRubies(int amount);
void trackFlurryForBuyRubies(NSString *strContent);
void loadSettingFromiCloud();
void saveSettingToiCloud();
int timestampNow();
NSString* convertTimestampToDateFormat(int timestamp);
void shareToFacebook(NSString* name, NSString* caption, NSString* description);
NSDictionary* parseURLParams(NSString *query);
