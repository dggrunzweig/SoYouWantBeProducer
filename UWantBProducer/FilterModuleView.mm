//
//  FilterModuleView.m
//  UWantBProducer
//
//  Created by David Grunzweig on 2/9/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import "FilterModuleView.h"

@interface FilterModuleView ()

@end

@implementation FilterModuleView

@synthesize isHighPass, mCutoffFreq, mLFORate, mQ, mCutoffFreqKnob, mLFORateKnob, mQKnob, highpassImage, lowpassImage, faderMax, faderMin, background, mPanGestureRecognizer, switchButton, QStatus, cutOffStatus, LFOStatus, TypeStatus, greenLight, redLight,
mCutoffCorrect, mQCorrect, mHighPassCorrect, mLFOCorrect, nextScreen, mFinished;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isHighPass = false;
    mLFOCorrect = false;
    mCutoffCorrect = false;
    mQCorrect = false;
    mFinished = false;
    mHighPassCorrect = false;
    [nextScreen setEnabled:false];
    if (([[effectsBank sharedEffectsBank] getPresetValue] == kEffectBankFreeMode))
        [nextScreen setEnabled:true];
    // Do any additional setup after loading the view from its nib.
    if (highpassImage == nil){
        highpassImage = [UIImage imageNamed:@"Hi Pass Faceplate.jpg"];
        lowpassImage = [UIImage imageNamed:@"Low Pass Faceplate.jpg"];
        redLight = [UIImage imageNamed:@"Red Light.png"];
        greenLight = [UIImage imageNamed:@"Green Light.png"];
        [cutOffStatus setImage:redLight];
        [QStatus setImage:redLight];
        [LFOStatus setImage:redLight];
        [TypeStatus setImage:redLight];
    }
   
//    [background setFrame:self.view.frame];
//    [self.view insertSubview:background atIndex:0];
//    
//    [background addSubview:switchButton];
    
    mPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(knobMove:)];
    [self.view addGestureRecognizer:mPanGestureRecognizer];
    
    
    float base = faderMax.frame.origin.y;
    float range = faderMin.frame.origin.y - faderMax.frame.origin.y;
    float knobWidth = mCutoffFreqKnob.bounds.size.width;
    float knobHeight = mCutoffFreqKnob.bounds.size.height;
    mCutoffFreq = [[effectsBank sharedEffectsBank] getCurrentSetting:kFilterModule withParameter:kSetCutOffFrequency];
    mQ = [[effectsBank sharedEffectsBank] getCurrentSetting:kFilterModule withParameter:kSetResonanceFrequency];
    mLFORate = [[effectsBank sharedEffectsBank] getCurrentSetting:kFilterModule withParameter:kSetLFORate];
    float y = range * (1-mCutoffFreq) + base;
    [mCutoffFreqKnob setFrame:CGRectMake(mCutoffFreqKnob.frame.origin.x, y, knobWidth, knobHeight)];
    y = (1-mQ)*range + base;
    [mQKnob setFrame:CGRectMake(mQKnob.frame.origin.x, y, knobWidth, knobHeight)];
    y = (1-mLFORate)*range + base;
    [mLFORateKnob setFrame:CGRectMake(mLFORateKnob.frame.origin.x, y, knobWidth, knobHeight)];
    isHighPass = [[effectsBank sharedEffectsBank] getCurrentSetting:kFilterModule withParameter:kSetFilterType];
    
    if (isHighPass) {
        [background setImage:highpassImage];
    } else
    {
        [background setImage:lowpassImage];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchFilterType:(id)sender
{
    isHighPass = !isHighPass;
    if (!isHighPass)
    {
        [background setImage:lowpassImage];
        [[effectsBank sharedEffectsBank] setEffectParameters:kFilterModule withParameter:kSetFilterType updateWithValue:kUseLowPass];
    }
    else
    {
        [background setImage:highpassImage];
        [[effectsBank sharedEffectsBank] setEffectParameters:kFilterModule withParameter:kSetFilterType updateWithValue:kUseHighPass];
    }
    mHighPassCorrect = [[effectsBank sharedEffectsBank] checkCorrectEffectSetting:kFilterModule withParameter:kSetFilterType settingValue:isHighPass];
    if (mHighPassCorrect)
    {
        [TypeStatus setImage:greenLight];
    } else {
        [TypeStatus setImage:redLight];
    }
    
    if (mLFOCorrect && mQCorrect && mHighPassCorrect && mCutoffCorrect && !mFinished)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                        message:@"You may procede to the next module!."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [nextScreen setEnabled:true];
        mFinished = true;
    }
 

}

-(void)knobMove:(UIPanGestureRecognizer *)swipeGestureRecognizer
{
    CGPoint location = [swipeGestureRecognizer locationInView:background];
    float cutoffX = mCutoffFreqKnob.frame.origin.x;
    float QX = mQKnob.frame.origin.x;
    float lfoX = mLFORateKnob.frame.origin.x;
    float knobWidth = mCutoffFreqKnob.bounds.size.width;
    float knobHeight = mCutoffFreqKnob.bounds.size.height;
    float range = faderMin.frame.origin.y - faderMax.frame.origin.y;
    float base = faderMax.frame.origin.y;
    if (location.x > cutoffX && location.x < cutoffX+knobWidth)
    {
        if (location.y > faderMax.frame.origin.y && location.y < faderMin.frame.origin.y){
            [mCutoffFreqKnob setFrame:CGRectMake(cutoffX, location.y, knobWidth, knobHeight)];
            mCutoffFreq = (1 - (location.y - base)/range);
            mCutoffFreq = mCutoffFreq < .05? 0: mCutoffFreq;

            [[effectsBank sharedEffectsBank] setEffectParameters:kFilterModule withParameter:kSetCutOffFrequency updateWithValue:mCutoffFreq];
        }
        mCutoffCorrect = [[effectsBank sharedEffectsBank] checkCorrectEffectSetting:kFilterModule withParameter:kSetCutOffFrequency settingValue:mCutoffFreq];
        if (mCutoffCorrect)
        {
            [cutOffStatus setImage:greenLight];
        } else {
            [cutOffStatus setImage:redLight];
        }

    }
    else if (location.x > QX && location.x < QX+knobWidth)
    {
        if (location.y > faderMax.frame.origin.y && location.y < faderMin.frame.origin.y){
            [mQKnob setFrame:CGRectMake(QX, location.y, knobWidth, knobHeight)];
            mQ = 1 - (location.y - base)/range;
            mQ = mQ < .05? 0: mQ;

            [[effectsBank sharedEffectsBank] setEffectParameters:kFilterModule withParameter:kSetResonanceFrequency updateWithValue:mQ];
        }
        mQCorrect = [[effectsBank sharedEffectsBank] checkCorrectEffectSetting:kFilterModule withParameter:kSetResonanceFrequency settingValue:mQ];
        if (mQCorrect)
        {
            [QStatus setImage:greenLight];
        } else {
            [QStatus setImage:redLight];
        }
    }
    else if (location.x > lfoX && location.x < lfoX+knobWidth)
    {
        if (location.y > faderMax.frame.origin.y && location.y < faderMin.frame.origin.y) {
            [mLFORateKnob setFrame:CGRectMake(lfoX, location.y, knobWidth, knobHeight)];
            mLFORate = 1 - (location.y - base)/range;
            mLFORate = mLFORate < .05? 0: mLFORate;

            [[effectsBank sharedEffectsBank] setEffectParameters:kFilterModule withParameter:kSetLFORate updateWithValue:mLFORate];
        }
        mLFOCorrect = [[effectsBank sharedEffectsBank] checkCorrectEffectSetting:kFilterModule withParameter:kSetLFORate settingValue:mLFORate];
        if (mLFOCorrect)
        {
            [LFOStatus setImage:greenLight];
        } else {
            [LFOStatus setImage:redLight];
        }
    }
    

    
    if (mLFOCorrect && mQCorrect && mHighPassCorrect && mCutoffCorrect && !mFinished )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                        message:@"You may procede to the next module!."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [nextScreen setEnabled:true];
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
