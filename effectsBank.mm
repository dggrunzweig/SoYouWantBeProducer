//
//  effectsBank.m
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import "effectsBank.h"


@implementation effectsBank

+ (id)sharedEffectsBank {
    static effectsBank *sharedEffectsBank = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEffectsBank = [[self alloc] init];
    });
    return sharedEffectsBank;
}

- (void) initialize:(UInt32)numFrames withSampleRate:(UInt32)sampleRate numChannels:(UInt32)channels
{
    mManager.initialize();
    
    fg.initialize(numFrames, sampleRate);
    
    mSequencer.initialize(16, 120, numFrames, sampleRate, 2.1);

    filterModule.initialize(numFrames, sampleRate, 300, NO);
    
    echo.initialize(numFrames, 500, .75, sampleRate);
    echo.setEffectParameters(kEchoEffectMix, 0);
    
//    reverb.initialize(sampleRate, numFrames, 20, 0.75);
//    reverb.setEffectParameter(kReverbEffectMix, 0);

    
    mFloatMonoBuffer = (float*)malloc(sizeof(float)*numFrames);
    mFloatStereoBuffer = (float*)malloc(sizeof(float)*2*numFrames);
    
    mNumFrames = numFrames;
    mNumChannels = channels;
}


- (void) setEffectParameters:(UInt32)effectID withParameter:(UInt32) effectParameter updateWithValue:(float) value
{
    if (effectID == kFunctionGenerator){
        fg.setEffectParameter(effectParameter, value);
    } else if (effectID == kFilterModule) {
        filterModule.setEffectParameter(effectParameter, value);
    } else if (effectID == kSequencerModule) {
        mSequencer.setEffectParameter(kSequencerDecayTime, value);
    } else if (effectID == kEchoEffect) {
        echo.setEffectParameters(effectParameter, value);
    } else if (effectID == kReverbEffect) {
        reverb.setEffectParameter(effectParameter, value);
    } else {
        NSLog(@"EffectID not recognized");
    }
}

- (void) resetSettings
{
    fg.setEffectParameter(kFunctionGeneratorSineWaveVol, 0.0);
    fg.setEffectParameter(kFunctionGeneratorTriangleWaveVol, 0.0);
    mSequencer.setEffectParameter(kSequencerDecayTime, 0.0);
    filterModule.setEffectParameter(kSetCutOffFrequency, 0.1);
    filterModule.setEffectParameter(kSetResonanceFrequency, 0.0);
    filterModule.setEffectParameter(kSetLFORate, 0.0);
    filterModule.setEffectParameter(kSetFilterType, 0);
    echo.setEffectParameters(kEchoEffectFeedback, 0.0);
    echo.setEffectParameters(kEchoEffectMix, 0.0);
    echo.setEffectParameters(kEchoEffectTimeInMS, 0.0);
    mManager.resetCurrentSettings();
}

- (void) sendSignalThroughBank:(SInt16*)buffer
{
    //all signals start with sine wave

    mSequencer.runSequencer(&fg, mFloatMonoBuffer);
    //implement effects here:
    filterModule.applyEffect(mFloatMonoBuffer);
    
    echo.applyEffect(mFloatMonoBuffer);
//    
//    reverb.applyEffect(mFloatMonoBuffer);
    
    //convert float 32 buffer back for the output;
    float mult = powf(2,14);
    float max = 1;
    float min = -1;
    vDSP_vclip(mFloatMonoBuffer, 1, &min, &max, mFloatMonoBuffer, 1, mNumFrames);
    vDSP_vsmul(mFloatMonoBuffer, 1, &mult, mFloatMonoBuffer, 1, mNumFrames);
    
    if (mNumChannels == 2) {
        vDSP_vfix16(mFloatMonoBuffer, 1, buffer, 2, mNumFrames);
        for (int i = 0; i < mNumFrames; ++i){
            buffer[2*i+1] = buffer[2*i];
        }
    } else {
        vDSP_vfix16(mFloatMonoBuffer, 1, buffer, 1, mNumFrames);
    }
}

- (void) convertFromMonoToStereo:(float*)monoBuffer toStereoBuffer:(float*)stereoBuffer;
{
    float one = 1;
    vDSP_vsmul(monoBuffer, 1, &one, stereoBuffer, 2, mNumFrames);
    vDSP_vsmul(monoBuffer, 1, &one, stereoBuffer+1, 2, mNumFrames);
}

- (BOOL) checkCorrectEffectSetting:(UInt32)effectID withParameter:(UInt32) effectParameter settingValue:(float)setting
{
    /*settings array
     0 = sequence number
     1 = sineLevel
     2 = triLevel
     3 = decayTime
     4 = cutoff
     5 = q
     6 = LFOrate
     7 = filterType
     8 = echo feedback
     9 = echo time
     10 = echo mix
     */
    return mManager.checkSettingOfCurrentPreset(effectID, effectParameter, setting);
}

-(void) loadEffectBankSettings:(UInt32)effectSetting
{
    mCurrentPreset = effectSetting;
    mManager.loadPreset(effectSetting);
    mSequencer.setSequence(effectSetting);
}

- (int) getPresetValue
{
    return mCurrentPreset;
}

- (float) getCurrentSetting:(UInt32)effectID withParameter:(UInt32) effectParameter
{
    return mManager.getCurrentSetting(effectID, effectParameter);
}


@end
