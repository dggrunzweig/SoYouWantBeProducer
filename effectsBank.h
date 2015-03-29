//
//  effectsBank.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "echoEffect.h"
#import "functionGenerator.h"
#import "reverbEffect.h"
#import "lfo.h"
#import "phaser.h"
#import "filter.h"
#import "sequencer.h"
#import "EffectBankSettingManager.h"

enum effectTypes
{
    kSequencerModule = 0,
    kFunctionGenerator = 1,
    kFilterModule = 2,
    kEchoEffect = 3,
    kPhaserEffect = 4,
    kReverbEffect = 5,
} ;

@interface effectsBank : NSObject
{
    EffectBankSettingManager mManager;
    echoEffect echo;
    reverbEffect reverb;
    filter filterModule;
    functionGenerator fg;
    sequencer mSequencer;
    
    float * mFloatMonoBuffer;
    float * mFloatStereoBuffer;
    int mNumFrames;
    int mNumChannels;
    int mCurrentPreset;
}



+ (id)sharedEffectsBank;

- (void) initialize:(UInt32)numFrames withSampleRate:(UInt32)sampleRate numChannels:(UInt32)channels;
- (void) setEffectParameters:(UInt32)effectID withParameter:(UInt32) effectParameter updateWithValue:(float) value;
- (void) sendSignalThroughBank:(SInt16*)buffer;
- (void) loadEffectBankSettings:(UInt32)effectSetting;
- (BOOL) checkCorrectEffectSetting:(UInt32)effectID withParameter:(UInt32) effectParameter settingValue:(float)setting;
- (float) getCurrentSetting:(UInt32)effectID withParameter:(UInt32) effectParameter;
- (int) getPresetValue;
- (void) resetSettings;


@end
