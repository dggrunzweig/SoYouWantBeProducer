//
//  functionGenerator.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#ifndef __UWantBProducer__functionGenerator__
#define __UWantBProducer__functionGenerator__

#include <stdio.h>
#import "effectSuperClass.h"
enum functionGeneratorWaveTypes
{
    kFunctionGeneratorSineWaveVol = 0, //tells the function to use the sine wave, value should be the frequency
    kFunctionGeneratorTriangleWaveVol = 1, //tells the function to use a triangle wave, value should be the frequency
    kFunctionGeneratorDrumLoopVol = 2,
};


class functionGenerator
{
private:
    int mPosition;
    int mSamplesPerCycle;
    int mNumFrames;
    int mSampleRate;
    float mSquareVol;
    float mPrevSquareVol;
    float mTriVol;
    float mPrevTriVol;
    float mDrumVol;
    float * mParaGlideBuff;
    void generateSine(float frequency, float* buffer);
    void generateTri(float frequency, float* buffer);
    void generateSquare(float frequency, float * buffer);

    void setDrumLoopVolume(float amplitude, float buffer[]);
public:
    void initialize(int numFrames, int sampleRate);
    void setEffectParameter(int effectParameterID, float value);
    void getEffectParameter(int effectParameterID, float value);
    void generate(float * buffer, float freq);
    void clearBuffer(float * buffer);

};

#endif /* defined(__UWantBProducer__functionGenerator__) */
