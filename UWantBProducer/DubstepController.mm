//
//  DubstepController.m
//  UWantBProducer
//
//  Created by David Grunzweig on 2/17/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import "DubstepController.h"

@interface DubstepController ()

@end


@implementation DubstepController
@synthesize mTextArea, mTapGestureRecognizer, mTitleArea;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextScreen:)];
    [mTitleArea setText:@""];
    [mTextArea setText:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSString* informationString;

    int currentPreset = [[effectsBank sharedEffectsBank] getPresetValue];
    
    if (currentPreset == kEffectBankDubstepPreset)
    {
        [mTitleArea setText:@"Dubstep"];
        informationString = [NSString alloc];
        informationString = @"Dubstep was a style of dance music first created in Croydon, UK in the early 2000s. One major hallmark of the style was very low basslines with a slow LFO. LFO stands for Low Frequency Oscillator and is an oscillator used for changing the parameter of a certain effect over time. In this case, it is changing the frequency cut off on the filter by the rate set in the LFO Rate section of the filter module. Recommended Listening: Midnight Request Line - Skream, Cockney Thug - Rusko";
        [mTextArea setText:informationString];
    } else if (currentPreset == kEffectBankAcidPreset)
    {
        [mTitleArea setText:@"Acid Bass"];
        informationString = [NSString alloc];
        informationString = @"Acid House as a style is charactarized by the use of house style beats and the Roland TB-303 bass synth. The TB-303 was a simple sequencer with envelope, resonance, and cut off frequency knobs and Acid house is charactized by fast, running basslines and the infamous 303 squelching tone. This demo focuses on something called Resonance. Resonance or Q is used to control the sharpness of the filter and induces a whistle or squelch like sound. Recommended Listening: Acid Tracks - PHuture, Land of Confusion - Armando";
        [mTextArea setText:informationString];
        
    } else if (currentPreset == kEffectBankSubbass)
    {
        [mTitleArea setText:@"House Subbass"];
        informationString = [NSString alloc];
        informationString = @"House music is defined by a strong four on the floor bass kick and a high hat between each kick. When bass synths are used in house, they are often used to play melodies in the bass line in the frequency range below or around the kick. This demo focusees on the effect of using a fast LFO on the filter. Listen to how the sound changes from the dubstep demo with a faster LFO Rate. Recommended listening: Can You Feel It? - Mr Fingers";
        [mTextArea setText:informationString];
        
        
    } else if (currentPreset == kEffectBankTrancePreset)
    {
        [mTitleArea setText:@"Classic Lead"];
        informationString = [NSString alloc];
        informationString = @"Many electrohouse, trance, and progressive house songs feature a melody line played by a synth rather than vocals. The synth often utilizes the higher registers (so you should use which type of filter?...) to play the melody and echo effects to make the synth sound fuller. In this demo you will hear the result of blending two types of sound waves and using echo to build a lead.";
        [mTextArea setText:informationString];
    }
}

- (void)nextScreen:(UITapGestureRecognizer*)tap
{
    
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
