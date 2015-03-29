//
//  functionGenerator.cpp
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#include "functionGenerator.h"

inline static void parameterGlide(float val1, float val2, float * buffer, int bufferLength)
{
    float diff = (val2 - val1)/bufferLength;
    vDSP_vramp(&val1, &diff, buffer, 1, bufferLength);
}

void functionGenerator::clearBuffer(float * buffer)
{
    memset(buffer, 0, mNumFrames);
}
void functionGenerator::generateSine(float frequency, float * buffer)
{
   // parameterGlide(mPrevSineVol, mSineVol, mParaGlideBuff, mNumFrames);
    for (int i = 0; i < mNumFrames; ++i)
    {
        if (mPosition + i > FLT_MAX)
            mPosition = 0;
        buffer[i] = mParaGlideBuff[i]*sinf(2*M_PI*frequency*((float)(mPosition+i)/mSampleRate));
    }
   // mPrevSineVol = mSineVol;
}

void functionGenerator::generateSquare(float frequency, float * buffer)
{
    int period = (int)floor(1.0f/frequency * mSampleRate);
    int halfPeriod = period/2;
    int rem = 0;
    parameterGlide(mPrevSquareVol, mSquareVol, mParaGlideBuff, mNumFrames);
    for (int i = 0; i < mNumFrames; ++i)
    {
        if (mPosition + i > FLT_MAX)
            mPosition = 0;
        rem = i%period;
        if (rem > halfPeriod)
            buffer[i] = mParaGlideBuff[i];
        else
            buffer[i] = 0;
    }
    mPrevSquareVol = mSquareVol;
}
void functionGenerator::generateTri(float frequency, float * buffer)
{
    
    parameterGlide(mPrevTriVol, mTriVol, mParaGlideBuff, mNumFrames);
    if (frequency != 0){
        int period = (int)floor(1.0f/frequency * mSampleRate);
    
        for (int i = 0; i < mNumFrames; ++i)
        {
            if (mPosition + i > FLT_MAX)
                mPosition = 0;
            buffer[i] =  buffer[i] + ((float)mParaGlideBuff[i]/(2*period))*(period - abs(i % (2*period) - period));
        }
    } else
    {
        float zero = 0;
        vDSP_vfill(&zero, buffer, 1, mNumFrames);
    }
    mPosition += mNumFrames;
    mPrevTriVol = mTriVol;

}
void functionGenerator::setDrumLoopVolume(float amplitude, float * buffer)
{
    
}

void functionGenerator::initialize(int numFrames, int sampleRate)
{
    mNumFrames = numFrames;
    mPosition = 0;
    mSampleRate = sampleRate;
    mSquareVol = 0;
    mTriVol = 0;
    mDrumVol = 0;
    mPrevSquareVol = 0;
    mPrevTriVol = 0;
    mParaGlideBuff = (float *)malloc(mNumFrames*sizeof(float));
    memset(mParaGlideBuff, 0, mNumFrames);
}

void functionGenerator::setEffectParameter(int effectParameterID, float value)
{
    if (effectParameterID == kFunctionGeneratorSineWaveVol)
    {
        mPrevSquareVol = mSquareVol;
        mSquareVol = value;
    } else if (effectParameterID == kFunctionGeneratorTriangleWaveVol){
        mPrevTriVol = mTriVol;
        mTriVol = value;
    } else if (effectParameterID == kFunctionGeneratorDrumLoopVol) {
        mDrumVol = value;
    } else {
        NSLog(@"Unknown effect parameter");
    }
}

void functionGenerator::getEffectParameter(int effectParameterID, float value)
{
    
}

void functionGenerator::generate(float* buffer, float freq){
    clearBuffer(buffer);
    //generateSine(freq, buffer);
    generateSquare(freq, buffer);
    generateTri(freq, buffer);
}
