#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import "effectsBank.h"



@interface IosAudioController : NSObject <AVAudioSessionDelegate>  {
//    AudioComponentInstance mAudioUnit;
//    AudioBuffer mInputBuffer;

}

@property effectsBank* mEffectsBank;
@property AudioComponentInstance mAudioUnit;
@property (readonly) AudioBuffer mInputBuffer;
@property int mSampleRate;
@property int mDataSizeBytes;
@property int mChannels;
@property int mBufferLength;
@property BOOL interruptedDuringPlayback;
@property BOOL playing;

@property AUGraph processingGraph;
@property FFTSetup mFftsetup;
@property int LOG_N;
@property DSPSplitComplex mSplitComplex;


- (void) startAudioEngine;
- (void) stopAudioEngine;


@end

// setup a global iosAudio variable, accessible everywhere
extern IosAudioController* iosAudio;