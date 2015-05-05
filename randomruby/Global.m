//
//  Global.m
//  RandomRuby
//
//  Created by JMI on 7/30/13.
//  Copyright 2013 JMI. All rights reserved.
//

#import "Global.h"
#import "CSVParser.h"
#import "Flurry.h"
#import "MKiCloudSync.h"
#import <FacebookSDK/FacebookSDK.h>

float    g_fWidth;
float    g_fHeight;
float    g_fx;
float    g_fy;

NSString *g_strDifficult;
NSString *g_strBillWord;
NSString *g_strBobWord;
NSString *g_strRubyWord;
NSString *g_strSolve;
NSMutableArray *g_strProblem;
NSArray  *g_arrDatas;
int     g_nTotalLevel = 0;
float   g_fRate = 1.0f;
bool    g_bRestore = false;
BOOL    g_bEnablediCloud = NO;
BOOL    g_bLoadediCloudData = NO;
BOOL    g_bReceivediCloudData = NO;

//bool g_bMusicOn = true;
//bool g_bSoundOn = true;

StoreViewController *g_StoreViewer = nil;
InfoViewController *g_InfoViewer = nil;


NSString *iCloudTimestampKey	= @"iCloudTimestampKey";
NSString *iCloudRubyCountsKey	= @"iCloudRubyCountsKey";
NSString *iCloudLevelKey        = @"iCloudLevelKey";
NSString *iCloudEnabledProKey	= @"iCloudEnabledProKey";


void initGameInfo()
{
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//	
//    g_fWidth = screenRect.size.width;
//    g_fHeight = screenRect.size.height;
//    
//    
//    g_fx = g_fWidth / 320.0f;
//    g_fy = g_fHeight / 480.0f;
    
    g_strBillWord   = @"";
    g_strBobWord    = @"";
    g_strProblem    = [[NSMutableArray alloc]init];
    g_strSolve      = @"";
    
    loadGameInfo();
    
    // Load csv file
    loadDataFromFile();
    loadSettingFromiCloud();
}

void loadGameInfo()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *szFile = [documentsDirectory stringByAppendingPathComponent: @"gameinfo.dat"];
	
	FILE *fp = fopen([szFile cStringUsingEncoding:NSASCIIStringEncoding],"rb+");
	
	if (fp == nil)
    {
        g_GameInfo.level = 1;
        g_GameInfo.rubyCounts = 400;
        g_GameInfo.overReset = NO;
        g_GameInfo.proVersion = NO;
        g_GameInfo.isFirst = NO;
        g_GameInfo.timestamp = 0;
    }
    else
    {
        fread(&g_GameInfo, sizeof(GAME_INFO), 1, fp);
    }
    
    // For test
//    if (g_GameInfo.rubyCounts < 100) {
//        g_GameInfo.rubyCounts += 1000;
//    }
    
	fclose(fp);
}

void saveGameInfo()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *szFile = [documentsDirectory stringByAppendingPathComponent:@"gameinfo.dat"];
	
	FILE *fp = fopen([szFile cStringUsingEncoding:NSASCIIStringEncoding],"wb+");
	
	if (fp == nil)
		return;
    
    fwrite(&g_GameInfo, sizeof(GAME_INFO), 1, fp);
    
    fclose(fp);
    
    saveSettingToiCloud();
}

void alertMessage(NSString *msg, NSString *title)
{
    UIAlertView *msgView = [[UIAlertView alloc] initWithTitle:title
                                            message:msg
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
    [msgView show];
}

void loadDataFromFile()
{
    NSString *file = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"csv"];
    g_arrDatas = [CSVParser parseCSVIntoArrayOfArraysFromFile:file withSeparatedCharacterString:@"," quoteCharacterString:nil];
    g_nTotalLevel = [g_arrDatas count] - 1;
    NSLog(@"count: %d", g_nTotalLevel);
//	NSString *contents = [NSString stringWithContentsOfFile:
//						  [[NSBundle mainBundle] pathForResource:@"data" ofType:@"csv"] encoding:NSASCIIStringEncoding error:nil];
//    if (contents == nil) {
//        alertMessage(@"Can not found data file.", @"Error");
//		return;
//    }
//    
//    g_arrDatas = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\r"]];
//    g_nQuestionTotalCount = [g_arrDatas count] - 1;
//    
//    if (g_nQuestionTotalCount <= 0) {
//        alertMessage(@"There is not data in file.", @"Error");
//    }
}

void trackFlurryForUseRubies(int amount)
{
    [Flurry logEvent:[NSString stringWithFormat:@"Used %d rubies at Level%d.", amount, g_GameInfo.level]];
}

void trackFlurryForBuyRubies(NSString *strContent)
{
    [Flurry logEvent:strContent];
}

void loadSettingFromiCloud()
{
    if (!g_bEnablediCloud) return;
    
    NSUserDefaults *local = [NSUserDefaults standardUserDefaults];
    // Timestamp
    NSString *strTmp = (NSString *)[local objectForKey:iCloudTimestampKey];
    if (strTmp != nil) {
        g_GameInfo.timestamp = [strTmp intValue];
    }
    // Rubie Amount
    strTmp = (NSString *)[local objectForKey:iCloudRubyCountsKey];
	if (strTmp != nil) {
        g_GameInfo.rubyCounts = [strTmp intValue];
    }
    // Level
    strTmp = (NSString *)[local objectForKey:iCloudLevelKey];
    if (strTmp != nil) {
        g_GameInfo.level = [strTmp intValue];
    }
    // PRO version state
    strTmp = (NSString *)[local objectForKey:iCloudEnabledProKey];
    if (strTmp != nil) {
        g_GameInfo.proVersion = [strTmp boolValue];
    }
}

void saveSettingToiCloud()
{
    if (!g_bEnablediCloud) return;
    
	NSUserDefaults *local = [NSUserDefaults standardUserDefaults];
    
	[local setInteger:g_GameInfo.rubyCounts forKey:iCloudRubyCountsKey];
	[local setInteger:g_GameInfo.level forKey:iCloudLevelKey];
	[local setBool:g_GameInfo.proVersion forKey:iCloudEnabledProKey];
	[local setInteger:timestampNow() forKey:iCloudTimestampKey];

	[local synchronize];
}

int timestampNow()
{
    NSTimeInterval currTime = [[NSDate date] timeIntervalSince1970];
    return (int)currTime;
}

NSString* convertTimestampToDateFormat(int timestamp)
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

void shareToFacebook(NSString* name, NSString* caption, NSString* description)
{
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:RANDOM_RUBY_LINK_URL];
    params.name = name;
    params.caption = caption;
    params.picture = [NSURL URLWithString:RANDOM_RUBY_ICON_URL];
    params.description = description;
    
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                         name:params.name
                                      caption:params.caption
                                  description:params.description
                                      picture:params.picture
                                  clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       name, @"name",
                                       caption, @"caption",
                                       RANDOM_RUBY_LINK_URL, @"link",
                                       RANDOM_RUBY_ICON_URL, @"picture",
                                       description, @"description",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = parseURLParams([resultURL query]);
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User canceled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }

}

NSDictionary* parseURLParams(NSString *query)
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

