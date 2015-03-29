//
//  EchoModuleView.m
//  UWantBProducer
//
//  Created by David Grunzweig on 2/10/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import "EchoModuleView.h"

@interface EchoModuleView ()

@end

@implementation EchoModuleView

@synthesize mFeedback, mFeedbackKnob, mMix, mMixKnob, mTime, mTimeKnob, mPanGestureRecognizer, faderMax, faderMin, greenLight, redLight, mixStatus, timeStatus, feedbackStatus, mTimeCorrect, mMixCorrect, mFeedbackCorrect, nextScreen, mFinished;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mTimeCorrect = false;
    mMixCorrect = false;
    mFeedbackCorrect = false;
    mFinished = false;
    
    [nextScreen setEnabled:false];
    
    if (([[effectsBank sharedEffectsBank] getPresetValue] == kEffectBankFreeMode))
        [nextScreen setEnabled:true];
    
    
    mPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(knobMove:)];
    [self.view addGestureRecognizer:mPanGestureRecognizer];
    
    greenLight = [UIImage imageNamed:@"Green Light.png"];
    redLight = [UIImage imageNamed:@"Red Light.png"];
    
    [feedbackStatus setImage:redLight];
    [timeStatus setImage:redLight];
    [mixStatus setImage:redLight];
    
    float base = faderMax.frame.origin.y;
    float range = faderMin.frame.origin.y - faderMax.frame.origin.y;
    float knobWidth = mFeedbackKnob.bounds.size.width;
    float knobHeight = mFeedbackKnob.bounds.size.height;
    mFeedback = [[effectsBank sharedEffectsBank] getCurrentSetting:kEchoEffect withParameter:kEchoEffectFeedback];
    mTime = [[effectsBank sharedEffectsBank] getCurrentSetting:kEchoEffect withParameter:kEchoEffectTimeInMS];
    mMix = [[effectsBank sharedEffectsBank] getCurrentSetting:kEchoEffect withParameter:kEchoEffectMix];
    float y = range * (1-mFeedback) + base;
    [mFeedbackKnob setFrame:CGRectMake(mFeedbackKnob.frame.origin.x, y, knobWidth, knobHeight)];
    y = (1-mTime)*range + base;
    [mTimeKnob setFrame:CGRectMake(mTimeKnob.frame.origin.x, y, knobWidth, knobHeight)];
    y = (1-mMix)*range + base;
    [mMixKnob setFrame:CGRectMake(mMixKnob.frame.origin.x, y, knobWidth, knobHeight)];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)knobMove:(UIPanGestureRecognizer *)swipeGestureRecognizer
{
    CGPoint location = [swipeGestureRecognizer locationInView:self.view];
    float timeX = mTimeKnob.frame.origin.x;
    float feedX = mFeedbackKnob.frame.origin.x;
    float mixX = mMixKnob.frame.origin.x;
    float knobWidth = mTimeKnob.bounds.size.width;
    float knobHeight = mTimeKnob.bounds.size.height;
    float range = faderMin.frame.origin.y - faderMax.frame.origin.y;
    float base = faderMax.frame.origin.y;
    if (location.x > timeX && location.x < timeX+knobWidth)
    {
        if (location.y > faderMax.frame.origin.y && location.y < faderMin.frame.origin.y){
            [mTimeKnob setFrame:CGRectMake(timeX, location.y, knobWidth, knobHeight)];
            mTime = (1 - (location.y - base)/range);
            mTime = mTime < .05? 0: mTime;
            [[effectsBank sharedEffectsBank] setEffectParameters:kEchoEffect withParameter:kEchoEffectTimeInMS updateWithValue:mTime];
        }
        mTimeCorrect = [[effectsBank sharedEffectsBank] checkCorrectEffectSetting:kEchoEffect withParameter:kEchoEffectTimeInMS settingValue:mTime];
        if (mTimeCorrect)
        {
            [timeStatus setImage:greenLight];
        } else {
            [timeStatus setImage:redLight];
        }

    }
    else if (location.x > feedX && location.x < feedX+knobWidth)
    {
        if (location.y > faderMax.frame.origin.y && location.y < faderMin.frame.origin.y){
            [mFeedbackKnob setFrame:CGRectMake(feedX, location.y, knobWidth, knobHeight)];
            mFeedback = 1 - (location.y - base)/range;
            mFeedback = mFeedback < .05? 0: mFeedback;

            [[effectsBank sharedEffectsBank] setEffectParameters:kEchoEffect withParameter:kEchoEffectFeedback updateWithValue:mFeedback];
        }
        mFeedbackCorrect = [[effectsBank sharedEffectsBank] checkCorrectEffectSetting:kEchoEffect withParameter:kEchoEffectFeedback settingValue:mFeedback];
        if (mFeedbackCorrect)
        {
            [feedbackStatus setImage:greenLight];
        } else {
            [feedbackStatus setImage:redLight];
        }

    }
    else if (location.x > mixX && location.x < mixX+knobWidth)
    {
        if (location.y > faderMax.frame.origin.y && location.y < faderMin.frame.origin.y) {
            [mMixKnob setFrame:CGRectMake(mixX, location.y, knobWidth, knobHeight)];
            mMix = 1-(location.y - base)/range;
            mMix = mMix < .05? 0: mMix;

            [[effectsBank sharedEffectsBank] setEffectParameters:kEchoEffect withParameter:kEchoEffectMix updateWithValue:mMix];
        }
        mMixCorrect = [[effectsBank sharedEffectsBank] checkCorrectEffectSetting:kEchoEffect withParameter:kEchoEffectMix settingValue:mMix];
        if (mMixCorrect)
        {
            [mixStatus setImage:greenLight];
        } else {
            [mixStatus setImage:redLight];
        }

    }
    

    if (mTimeCorrect && mMixCorrect && mFeedbackCorrect && !mFinished)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                        message:@"You have finished this level, you are now in free play mode!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [nextScreen setEnabled:true];
        [[effectsBank sharedEffectsBank] loadEffectBankSettings:kEffectBankFreeMode];
        mFinished = true;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
