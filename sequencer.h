//
//  sequencer.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/10/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#ifndef __UWantBProducer__sequencer__
#define __UWantBProducer__sequencer__

#include <stdio.h>
#include "effectSuperClass.h"
#include "functionGenerator.h"
#import "EffectBankSettingManager.h"

enum sequencerSettings
{
    kSequencerDecayTime = 0,
};

class sequencer
{
private:
    int * mSteps;
    float mScale[26];
    int mTempo;
    int mNumSteps;
    int mSampleRate;
    int mNumFrames;
    int mPosition;
    int mDecayLengthSamples;
    float * mDecayRamp;
    int mDecayPosition;
    int mPrevStep;
    
public:
    float quarterNote;
    void initialize(int numSteps, int tempo, int numFrames, int sampleRate, float decayPercent);
    void setStep(int note, int step);
    void setSequence(UInt32 preset);
    void setDecayLength(float decayPercent);
    void runSequencer(functionGenerator * fg, float * buffer);
    void setEffectParameter(UInt32 parameter, float value);
    void getEffectParameter(int effectParameterID, float value);

 
};

#endif /* defined(__UWantBProducer__sequencer__) */
