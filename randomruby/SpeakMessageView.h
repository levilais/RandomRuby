//
//  SpeakMessageView.h
//  RandomRuby
//
//  Created by BrightSun on 9/12/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MESSAGE_WRITING_SPEED_SLOW 0.2
#define MESSAGE_WRITING_SPEED_NORMAL 0.1
#define MESSAGE_WRITING_SPEED_FAST 0.02

@interface SpeakMessageView : UIView {
    UITextView *messageText;
    
	NSMutableArray *datasToShow;
	BOOL isAlreadyShowing;
	NSString *textToDisplay;
	int noOfCharacters;
	int charPos;
	BOOL isCancelled;
    float writingSpeed;
}

-(void) setSpeakMessageInfoFor:(NSString*)message
                  withFontSize:(int)size
                    ColorWithR:(int)r
                             G:(int)g
                             B:(int)b
                    IsBlinking:(BOOL)blink
            IsWritingAnimation:(BOOL)isWritingAnimation
                  WritingSpeed:(float)speed;
-(void)cleanUp;

@end
