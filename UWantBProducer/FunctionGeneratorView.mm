//
//  FunctionGeneratorView.m
//  UWantBProducer
//
//  Created by David Grunzweig on 2/7/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import "FunctionGeneratorView.h"

@interface FunctionGeneratorView ()

@end

@implementation FunctionGeneratorView

@synthesize mDecayTime, mSineVol, mTriVol, background, backgroundImage, mPanGestureRecognizer, mDecayKnob, mSineKnob, mTriKnob, faderMax, faderMin, sineStatus, triStatus, decayStatus, redLight, greenLight,
mDecayCorrect, mTriCorrect, mSineCorrect, nextScreen, mFinished;

- (void)viewDidLoad {
    [super viewDidLoad];
    mTriCorrect = false;
    mSineCorrect = false;
    mDecayCorrect = false;
    mFinished = false;
    [nextScreen setEnabled:false];
    
    if (([[effectsBank sharedEffectsBank] getPresetValue] == kEffectBankFreeMode))
        [nextScreen setEnabled:true];
    // Do any additional setup after loading the view from its nib.
    if (greenLight == nil){
        backgroundImage = [UIImage imageNamed:@"SourceFaceplate.jpg"];
        [sineStatus setImage:[UIImage imageNamed:@"Red Light.png"]];
        greenLight = [UIImage imageNamed:@"Green Light.png"];
        redLight = [UIImage imageNamed:@"Red Light.png"];
        [triStatus setImage:redLight];
        [decayStatus setImage:redLight];
    }

    [background setImage:backgroundImage];
    
    mPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(knobMove:)];
    [self.view addGestureRecognizer:mPanGestureRecognizer];
    float base = faderMax.frame.origin.y;
    float range = faderMin.frame.origin.y - faderMax.frame.origin.y;
    float knobWidth = mSineKnob.bounds.size.width;
    float knobHeight = mSineKnob.bounds.size.height;
    mSineVol = [[effectsBank sharedEffectsBank] getCurrentSetting:kFunctionGenerator withParameter:kFunctionGeneratorSineWaveVol];
    mTriVol = [[effectsBank sharedEffectsBank] getCurrentSetting:kFunctionGenerator withParameter:kFunctionGeneratorTriangleWaveVol];
    mDecayTime = [[effectsBank sharedEffectsBank] getCurrentSetting:kSequencerModule withParameter:kSequencerDecayTime];
    float y = range * (1-mSineVol) + base;
    [mSineKnob setFrame:CGRectMake(mSineKnob.frame.origin.x, y, knobWidth, knobHeight)];
    y = (1-mTriVol)*range + base;
    [mTriKnob setFrame:CGRectMake(mTriKnob.frame.origin.x, y, knobWidth, knobHeight)];
    y = (1-mDecayTime)*range + base;
    [mDecayKnob setFrame:CGRectMake(mDecayKnob.frame.origin.x, y, knobWidth, knobHeight)];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)knobMove:(UIPanGestureRecognizer *)swipeGestureRecognizer
{
    CGPoint location = [swipeGestureRecognizer locationInView:background];
    float sineX = mSineKnob.frame.origin.x;
    float triX = mTriKnob.frame.origin.x;
    float decayX = mDecayKnob.frame.origin.x;
    float knobWidth = mSineKnob.bounds.size.width;
    float knobHeight = mSineKnob.bounds.size.height;
    float range = faderMin.frame.origin.y - faderMax.frame.origin.y;
    float base = faderMax.frame.origin.y;
    if (location.x > sineX && location.x < sineX+knobWidth)
    {
        if (location.y > faderMax.frame.origin.y && location.y < faderMin.frame.origin.y){
            [mSineKnob setFrame:CGRectMake(sineX, location.y, knobWidth, knobHeight)];
            mSineVol = 1 - (location.y - base)/range;
            mSineVol = mSineVol < .05? 0: mSineVol;
            [[effectsBank sharedEffectsBank] setEffectParameters:kFunctionGenerator withParameter:kFunctionGeneratorSineWaveVol updateWithValue:mSineVol];
            mSineCorrect = [[effectsBank sharedEffectsBank] checkCorrectEffectSetting:kFunctionGenerator withParameter:kFunctionGeneratorSineWaveVol settingValue:mSineVol];
            if (mSineCorrect)
            {
                [sineStatus setImage:greenLight];
            } else {
                [sineStatus setImage:redLight];
            }
        }
    }
     else if (location.x > triX && location.x < triX+knobWidth)
    {
        if (location.y > faderMax.frame.origin.y && location.y < faderMin.frame.origin.y){
            [mTriKnob setFrame:CGRectMake(triX, location.y, knobWidth, knobHeight)];
            mTriVol = 1 - (location.y - base)/range;
            mTriVol = mTriVol < .05? 0: mTriVol;
            [[effectsBank sharedEffectsBank] setEffectParameters:kFunctionGenerator withParameter:kFunctionGeneratorTriangleWaveVol updateWithValue:mTriVol];
            mTriCorrect = [[effectsBank sharedEffectsBank] checkCorrectEffectSetting:kFunctionGenerator withParameter:kFunctionGeneratorTriangleWaveVol settingValue:mTriVol];
            if (mTriCorrect)
            {
                [triStatus setImage:[UIImage imageNamed:@"Green Light.png"]];
            } else {
                [triStatus setImage:redLight];
            }
        }
    }
    else if (location.x > decayX && location.x < decayX+knobWidth)
    {
        if (location.y > faderMax.frame.origin.y && location.y < faderMin.frame.origin.y) {
            [mDecayKnob setFrame:CGRectMake(decayX, location.y, knobWidth, knobHeight)];
            mDecayTime = 1 - (location.y - base)/range;
            [[effectsBank sharedEffectsBank] setEffectParameters:kSequencerModule withParameter:kSequencerDecayTime updateWithValue:mDecayTime];
            mDecayCorrect = [[effectsBank sharedEffectsBank] checkCorrectEffectSetting:kSequencerModule withParameter:kSequencerDecayTime settingValue:mDecayTime];
            if (mDecayCorrect)
            {
                [decayStatus setImage:[UIImage imageNamed:@"Green Light.png"]];
            }else {
                [decayStatus setImage:redLight];
            }
        }
    }

    
    if (mTriCorrect && mDecayCorrect && mSineCorrect && !mFinished)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                        message:@"You may procede to the next module!."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [nextScreen setEnabled:TRUE];
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
