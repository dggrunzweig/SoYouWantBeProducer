//
//  ReverbModuleView.m
//  UWantBProducer
//
//  Created by David Grunzweig on 2/10/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import "ReverbModuleView.h"

@interface ReverbModuleView ()

@end

@implementation ReverbModuleView

@synthesize mTime, mTimeKnob, mMix, mMixKnob, mFeedback, mFeedbackKnob, mPanGestureRecognizer, faderMin, faderMax;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(knobMove:)];
    [self.view addGestureRecognizer:mPanGestureRecognizer];
    

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
            [[effectsBank sharedEffectsBank] setEffectParameters:kEchoEffect withParameter:kEchoEffectTimeInMS updateWithValue:mTime];
        }
    }
    else if (location.x > feedX && location.x < feedX+knobWidth)
    {
        if (location.y > faderMax.frame.origin.y && location.y < faderMin.frame.origin.y){
            [mFeedbackKnob setFrame:CGRectMake(feedX, location.y, knobWidth, knobHeight)];
            mFeedback = 1 - (location.y - base)/range;
            [[effectsBank sharedEffectsBank] setEffectParameters:kEchoEffect withParameter:kEchoEffectFeedback updateWithValue:mFeedback];
        }
    }
    else if (location.x > mixX && location.x < mixX+knobWidth)
    {
        if (location.y > faderMax.frame.origin.y && location.y < faderMin.frame.origin.y) {
            [mMixKnob setFrame:CGRectMake(mixX, location.y, knobWidth, knobHeight)];
            mMix = (location.y - base)/range;
            [[effectsBank sharedEffectsBank] setEffectParameters:kReverbEffect withParameter:kEchoEffectMix updateWithValue:mMix];
        }
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
