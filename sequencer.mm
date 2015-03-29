//
//  sequencer.cpp
//  UWantBProducer
//
//  Created by David Grunzweig on 2/10/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#include "sequencer.h"

void sequencer::initialize(int numSteps, int tempo, int numFrames, int sampleRate, float decayPercent)
{
   
    mNumSteps = numSteps;
    mSteps = (int*)malloc(numSteps*sizeof(int));
    for (int i =0 ; i < numSteps; i++)
        mSteps[i] = 1;
    mTempo = tempo;
    mSampleRate = sampleRate;
    mNumFrames = numFrames;
    quarterNote = 60.0f/(4*tempo) * sampleRate;
    mDecayLengthSamples = floor(decayPercent*quarterNote);
    mDecayRamp = (float*)malloc(mDecayLengthSamples*sizeof(float));
    float rampInterval;
    if (decayPercent > 2)
        rampInterval = 0;
    else
        rampInterval = -1.0f/mDecayLengthSamples;
    float one = 1;
    vDSP_vramp(&one, &rampInterval, mDecayRamp, 1, mDecayLengthSamples);
    
    mPosition = 0;
    mPrevStep = 0;
    //freqs of chromatic scale starting at c
    mScale[0] = 0;
    mScale[1] = 130.813; //c
    mScale[2] = mScale[1] * pow(2, (1.0/12.0)); //c#
    mScale[3] = mScale[1] * pow(2, (2.0/12.0)); //D
    mScale[4] = mScale[1] * pow(2, (3.0/12.0)); //eb
    mScale[5] = mScale[1] * pow(2, (4.0/12.0)); //e
    mScale[6] = mScale[1] * pow(2, (5.0/12.0)); //f
    mScale[7] = mScale[1] * pow(2, (6.0/12.0)); //f#
    mScale[8] = mScale[1] * pow(2, (7.0/12.0)); //g
    mScale[9] = mScale[1] * pow(2, (8.0/12.0)); //g#
    mScale[10] = mScale[1] * pow(2, (9.0/12.0)); //a
    mScale[11] = mScale[1] * pow(2, (10.0/12.0)); //Bb
    mScale[12] = mScale[1] * pow(2, (11.0/12.0)); //B
    mScale[13] = mScale[1] * pow(2, (12.0/12.0)); //C
    mScale[14] = mScale[1] * pow(2, (13.0/12.0)); //C#
    mScale[15] = mScale[1] * pow(2, (14.0/12.0)); //D
    mScale[16] = mScale[1] * pow(2, (15.0/12.0)); //D#
    mScale[17] = mScale[1] * pow(2, (16.0/12.0)); //E
    mScale[18] = mScale[1] * pow(2, (17.0/12.0)); //F
    mScale[19] = mScale[1] * pow(2, (18.0/12.0)); //F#
    mScale[20] = mScale[1] * pow(2, (19.0/12.0)); //G
    mScale[21] = mScale[1] * pow(2, (20.0/12.0)); //G#
    mScale[22] = mScale[1] * pow(2, (21.0/12.0)); //A
    mScale[23] = mScale[1] * pow(2, (22.0/12.0)); //A#
    mScale[24] = mScale[1] * pow(2, (23.0/12.0)); //B
    mScale[25] = mScale[1] * pow(2, (24.0/12.0)); //C
    
    

}

void sequencer::setStep(int note, int step)
{
    if (note < 19 && step < mNumSteps)
    {
        if (note == 0)
            mSteps[step] = 0;
        else
            mSteps[step] = note;
   }
}

void sequencer::setSequence(UInt32 preset)
{
    if (preset == kEffectBankDubstepPreset)
    {
        mTempo = 70;
        quarterNote = 60.0f/(4*mTempo) * mSampleRate;

        setStep(6, 0);
        setStep(6, 1);
        setStep(6, 2);
        setStep(6, 3);
        setStep(6, 4);
        setStep(6, 5);
        setStep(6, 6);
        setStep(0, 7);
        setStep(6, 8);
        setStep(6, 9);
        setStep(6, 10);
        setStep(6, 11);
        setStep(1, 12);
        setStep(1, 13);
        setStep(1, 14);
        setStep(1, 15);
    } else if (preset == kEffectBankAcidPreset)
    {
        mTempo = 125;
        quarterNote = 60.0f/(4*mTempo) * mSampleRate;
        
        setStep(8, 0);
        setStep(23, 1);
        setStep(20, 2);
        setStep(18, 3);
        setStep(16, 4);
        setStep(13, 5);
        setStep(1, 6);
        setStep(24, 7);
        setStep(16, 8);
        setStep(16, 9);
        setStep(18, 10);
        setStep(20, 11);
        setStep(23, 12);
        setStep(20, 13);
        setStep(13, 14);
        setStep(20, 15);
     
    } else if (preset == kEffectBankTrancePreset)
    {
        mTempo = 120;
        quarterNote = 60.0f/(4*mTempo) * mSampleRate;

        setStep(13, 0);
        setStep(13, 1);
        setStep(13, 2);
        setStep(13, 3);
        setStep(13, 4);
        setStep(13, 5);
        setStep(13, 6);
        setStep(13, 7);
        setStep(16, 8);
        setStep(16, 9);
        setStep(16, 10);
        setStep(16, 11);
        setStep(18, 12);
        setStep(18, 13);
        setStep(18, 14);
        setStep(18, 15);
    } else if (preset == kEffectBankSubbass)
    {
        mTempo = 115;
        quarterNote = 60.0f/(4*mTempo) * mSampleRate;
        setStep(0, 0);
        setStep(0, 1);
        setStep(1, 2);
        setStep(1, 3);
        setStep(0, 4);
        setStep(0, 5);
        setStep(8, 6);
        setStep(8, 7);
        setStep(0, 8);
        setStep(0, 9);
        setStep(12, 10);
        setStep(12, 11);
        setStep(0, 12);
        setStep(1, 13);
        setStep(8, 14);
        setStep(12, 15);
    }
}

void sequencer::setEffectParameter(UInt32 parameter, float value)
{
    if (parameter == kSequencerDecayTime)
    {
        setDecayLength(2*value);
    }
}

void sequencer::getEffectParameter(int effectParameterID, float value)
{
    if (effectParameterID == kSequencerDecayTime)
    {
        value = mDecayLengthSamples;
    }
}

void sequencer::setDecayLength(float decayPercent)
{
    mDecayLengthSamples = floor(decayPercent*quarterNote);
    mDecayRamp = (float*)malloc(mDecayLengthSamples*sizeof(float));
    float rampInterval;
    if (decayPercent > 2)
        rampInterval = 0;
    else
        rampInterval = -1.0f/mDecayLengthSamples;
    float one = 1;
    vDSP_vramp(&one, &rampInterval, mDecayRamp, 1, mDecayLengthSamples);
    

}

void sequencer::runSequencer(functionGenerator * fg, float * buffer)
{
    int step = (int)floor(mPosition / quarterNote) % mNumSteps;
    if (step != mPrevStep)
    {
        mDecayPosition = 0;
    }
    float freq = mScale[mSteps[step]];
    fg->generate(buffer, freq);
    if (mDecayPosition+mNumFrames < mDecayLengthSamples)
        vDSP_vmul(buffer, 1, mDecayRamp+mDecayPosition, 1, buffer, 1, mNumFrames);
    else if (mDecayPosition < mDecayLengthSamples && mDecayPosition + mNumFrames > mDecayLengthSamples) {
        vDSP_vmul(buffer, 1, mDecayRamp+mDecayPosition, 1, buffer, 1, mDecayLengthSamples-mDecayPosition);
    }
    else if (mDecayPosition >= mDecayLengthSamples)
    {
        float zero = 0;
        vDSP_vsmul(buffer, 1, &zero, buffer, 1, mNumFrames);
    }
    mPrevStep = step;
    mDecayPosition += mNumFrames;
    mPosition += mNumFrames;
}
