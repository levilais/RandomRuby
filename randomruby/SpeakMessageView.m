//
//  SpeakMessageView.m
//  RandomRuby
//
//  Created by BrightSun on 9/12/13.
//  Copyright (c) 2013 org. All rights reserved.
//

#import "SpeakMessageView.h"
#import "QuartzCore/QuartzCore.h"

@implementation SpeakMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        datasToShow = [[NSMutableArray alloc]init];
        messageText = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [messageText setBackgroundColor:[UIColor clearColor]];
        [self addSubview:messageText];
        writingSpeed = MESSAGE_WRITING_SPEED_NORMAL;
    }
    return self;
}

- (void) setSpeakMessageInfoFor:(NSString *)message
                   withFontSize:(int)size
                     ColorWithR:(int)r
                              G:(int)g
                              B:(int)b
                     IsBlinking:(BOOL)blink
             IsWritingAnimation:(BOOL)isWritingAnimation
                   WritingSpeed:(float)speed
{
	[self setHidden:FALSE];
	
	if (message && message.length > 0)
	{
		NSMutableDictionary * Info = [[NSMutableDictionary alloc]init];
		[Info setObject:message forKey:@"Message"];
		[Info setObject:[NSNumber numberWithInt:size] forKey:@"FontSize"];
		[Info setObject:[NSNumber numberWithInt:r] forKey:@"RGB_r"];
		[Info setObject:[NSNumber numberWithInt:g] forKey:@"RGB_g"];
		[Info setObject:[NSNumber numberWithInt:b] forKey:@"RGB_b"];
		[Info setObject:[NSNumber numberWithBool:blink] forKey:@"Blink"];
		[Info setObject:[NSNumber numberWithBool:isWritingAnimation] forKey:@"IsWritingAnimation"];
        
        writingSpeed = speed;
		//[Info setObject:[NSValue valueWithCGRect:Frame] forKey:@"Frame"];
		[datasToShow addObject:Info];
	}
	
	if (datasToShow.count > 0 && (!isAlreadyShowing))
	{
		isCancelled = FALSE;
		isAlreadyShowing = TRUE;
		[messageText.layer removeAllAnimations];
		[messageText setAlpha:1.0f];
		
		NSMutableDictionary* Info  = [datasToShow objectAtIndex:0];
		
		if (((NSNumber*)[Info objectForKey:@"Blink"]).boolValue)
			[self blinking];
		
		//[messageText setShowsVerticalScrollIndicator:TRUE];
		messageText.layer.cornerRadius = 10.0;
		messageText.layer.masksToBounds = YES;
		messageText.opaque = NO;
		
		textToDisplay = [Info objectForKey:@"Message"];
        
		if (!((NSNumber*)[Info objectForKey:@"IsWritingAnimation"]).boolValue) {
			[messageText setText:textToDisplay];
		} else {
			noOfCharacters = textToDisplay.length;
			charPos = 0;
			[self writingAnimation];
		}
		
		[messageText setTextColor:[UIColor whiteColor]];
		
		[messageText setTextColor:[UIColor colorWithRed:((NSNumber*)[Info objectForKey:@"RGB_r"]).intValue green:((NSNumber*)[Info objectForKey:@"RGB_g"]).intValue blue:((NSNumber*)[Info objectForKey:@"RGB_b"]).intValue alpha:1]];
		
		[messageText setFont:[UIFont fontWithName:@"Marker Felt" size:((NSNumber*)[Info objectForKey:@"FontSize"]).floatValue]];
		
		[messageText setShowsVerticalScrollIndicator:FALSE];
		
		[datasToShow removeObjectAtIndex:0];
	}
}

- (void) cleanUp
{
    isCancelled = TRUE;
    messageText.text = @"";
    isAlreadyShowing = FALSE;
    [self setHidden:TRUE];
    [datasToShow removeAllObjects];
}

- (void) blinking
{
	[messageText setAlpha:0.0];
	[UIView beginAnimations:@"Blink" context:nil];
	
	[UIView setAnimationDuration:.2];
	[UIView setAnimationRepeatAutoreverses:YES];
	
	[UIView setAnimationRepeatCount:640];
	
	[UIView setAnimationDelegate:self];
	
	[messageText setAlpha:1.0f];
	
	[UIView commitAnimations];
}

- (void) writingAnimation
{
	if (isCancelled) {
        return;
    }
	
	if ((charPos + 1) <= noOfCharacters) {
		[messageText setText:[NSString stringWithFormat:@"%@",[textToDisplay substringToIndex: charPos]]];
	} else {
		[messageText setText:[NSString stringWithFormat:@"%@",textToDisplay]];
    }
	
	charPos++;
	
	if (charPos <= noOfCharacters)
	{
        [NSTimer scheduledTimerWithTimeInterval:writingSpeed
                                         target:self
                                       selector:@selector(writingAnimation)
                                       userInfo:nil
                                        repeats:NO];
	}
}


@end
