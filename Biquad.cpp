//
//  DSBiquad.cpp
//  RondoCore
//
//  Created by David Grunzweig on 2/9/15.
//  Copyright (c) 2015 Dysonics. All rights reserved.
//

#include "DSBiquad.h"

void DSBiquad::createFilter(int cutOffFrequency, int sampleRate, float Q, int bandWidth, float gainDb, int taps, int filterType, int filterDesign)
{
    if (filterDesign == kUseButtersworthFilter) {
        if (filterType == kLowPassFilter)
            butterworth->generateLowPassCoeffs(cutOffFrequency, sampleRate, Q);
        else if (filterType == kHighPassFilter)
            butterworth->generateHighPassCoeffs(cutOffFrequency, sampleRate, Q);
        else
            butterworth->generateBandPassCoeffs(cutOffFrequency, sampleRate, Q, bandWidth, gainDb);
        
        mSetup = vDSP_biquad_CreateSetup(butterworth->mCoeffs, (unsigned long)taps);
    }
    
}
void DSBiquad::filterBuffer(float * buffer, int numFrames)
{
    vDSP_biquad(mSetup, mDelay, buffer, 1, mBuffer, 1, numFrames); // Operate
    cblas_scopy(numFrames, mBuffer, 1, buffer, 1);
}

DSBiquad::~DSBiquad()
{
    vDSP_biquad_DestroySetup(mSetup); // Destroy

}