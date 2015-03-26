//
//  DSBiquad.h
//  RondoCore
//
//  Created by David Grunzweig on 2/9/15.
//  Copyright (c) 2015 Dysonics. All rights reserved.
//

#ifndef __RondoCore__DSBiquad__
#define __RondoCore__DSBiquad__

#include <stdio.h>
#import "DSButterworthFilter.h"
#import <Accelerate/Accelerate.h>
enum filterDesign {
    kUseButtersworthFilter = 0,
    kUseChebychevFilter = 1,
};

enum filterType {
    kHighPassFilter = 0,
    kLowPassFilter = 1,
    kBandPassFilter = 2,
};

class DSBiquad
{
private:
    double * mCoeffs;
    float * mBuffer;
    float * mDelay;
    vDSP_biquad_Setup mSetup;
    DSButterworthFilter* butterworth;
public:
    void createFilter(int cutOffFrequency, int sampleRate, float Q, int bandWidth, float gainDb, int taps, int filterType, int filterDesign);
    void filterBuffer(float * buffer, int numFrames);
    ~DSBiquad();

};

#endif /* defined(__RondoCore__DSBiquad__) */
