#import "IosAudioController.h"
#import <Accelerate/Accelerate.h>


#define kOutputBus 0
#define kInputBus 1

IosAudioController* iosAudio;

void checkStatus(int status, NSString* returnedBy){
	if (status) {
		printf("Status not 0! %d returned by %s \n", status, [returnedBy cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
//		exit(1);
	}
}



static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags, 
                                  const AudioTimeStamp *inTimeStamp, 
                                  UInt32 inBusNumber, 
                                  UInt32 inNumberFrames, 
                                  AudioBufferList *ioData) {
    
    //call back structure for record
   	
    return noErr;
}

/**
 This callback is called when the audioUnit needs new data to play through the
 speakers. If you don't have any, just don't write anything in the buffers
 */
static OSStatus playbackCallback(void *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, 
								 UInt32 inNumberFrames, 
								 AudioBufferList *ioData) {

//callback for playback or both play and record
    [[effectsBank sharedEffectsBank] sendSignalThroughBank:(SInt16*)ioData->mBuffers[0].mData];
    //printf("%i, %i\n", ioData->mBuffers[0].mNumberChannels, ioData->mBuffers[0].mDataByteSize);
//    for (int i = 0; i < inNumberFrames; ++i)
//    {
//        printf("%i, ", ((SInt16*)ioData->mBuffers[0].mData)[i]);
//    }
    return noErr;
}


//............................................................................................
//implementation

@implementation IosAudioController

@synthesize mSampleRate, mChannels, mAudioUnit, mBufferLength, mDataSizeBytes, mInputBuffer, mSplitComplex, playing, interruptedDuringPlayback, mFftsetup, LOG_N, mEffectsBank;

#pragma mark --FFT function

- (void) getFFT:(float*) inputBuffer withLength:(int)bufferLength returnMagnitude:(float*)mag andPhase:(float*)phase
{
    //used to get FFT of an input buffer and give you frequency with highest magnitude
    memset(mag, 0, bufferLength/2);
    memset(phase, 0, bufferLength/2);

    iosAudio.LOG_N = ceil(log2(bufferLength));
    
    vDSP_ctoz((DSPComplex*)inputBuffer, 2, &mSplitComplex, 1, bufferLength/2);
    // Do real->complEx forward FFT
    vDSP_fft_zrip(iosAudio.mFftsetup, &mSplitComplex, 1, iosAudio.LOG_N, kFFTDirection_Forward);
   
    vDSP_zvabs(&mSplitComplex, 1, mag, 1, bufferLength/2);
    vDSP_zvphas(&mSplitComplex, 1, phase, 1, bufferLength/2);
}


#pragma mark --set up the ioAudioUnit
- (id) init {
    self = [super init];
    
    iosAudio = [IosAudioController alloc];
    mSampleRate = 44100;
    iosAudio.mSampleRate = 44100;
    mDataSizeBytes = 2; //16 bit integer linear PCM;
    mChannels = 2; //set later by the av session data
    mBufferLength = 512;
    iosAudio.mSampleRate = mSampleRate;
    iosAudio.mChannels = mChannels;
    iosAudio.mBufferLength = mBufferLength;
    iosAudio.mDataSizeBytes = mDataSizeBytes;
    
   
    
    //for FFT
    
    mSplitComplex.realp = new float[mBufferLength/2];
    mSplitComplex.imagp = new float[mBufferLength/2];

    iosAudio.mSplitComplex = mSplitComplex;
    
    iosAudio.LOG_N = ceil(log2(mBufferLength));
    iosAudio.mFftsetup = vDSP_create_fftsetup(iosAudio.LOG_N, kFFTRadix2);

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(routeChanged)
               name:AVAudioSessionRouteChangeNotification
             object:nil];
    
    //set up the AVAudioSession
    
    [self setupAVAudioSession];
    
    //set up the audioUnit
    
    [[effectsBank sharedEffectsBank] initialize:mBufferLength withSampleRate:mSampleRate numChannels:mChannels];
    
    [self configureAndInitializeAudioUnits];
    
    return self;
}

- (void)routeChanged
{
//handler for the audio route changing
    //this selector is called if teh output device changes
}

#pragma mark --set up audio services
-(void) setupAVAudioSession{
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    
    // Assign the Playback category to the audio session.
    NSError *audioSessionError = nil;
    
    if (audioSessionError != nil) {
        
        NSLog (@"Error setting audio session category.");
        return;
    }
    
    // Request the desired hardware sample rate.
    [mySession setPreferredSampleRate:mSampleRate error:&audioSessionError];
    
    if (audioSessionError != nil) {
        
        NSLog (@"Error setting preferred hardware sample rate.");
        return;
    }
    
    //set the buffer size
    NSTimeInterval bufferLength = (float)mBufferLength/(float)mSampleRate;
    [mySession setPreferredIOBufferDuration:bufferLength error:&audioSessionError];
    
    
    // Activate the audio session
    [mySession setActive: YES
                   error: &audioSessionError];
    
    if (audioSessionError != nil) {
        
        NSLog (@"Error activating audio session during initial setup.");
        return;
    }
    int numChan = [mySession outputNumberOfChannels];
    iosAudio.mChannels = numChan;
    mChannels = numChan;
    
    if (numChan == 1)
    {
        //for av sessions, play and record does not work if the iphone is expected to use the mic as the input
        [mySession setCategory:AVAudioSessionCategoryPlayback error:&audioSessionError];
    }
    else
    {
        //if you're using headphones or ext speakers
        [mySession setCategory:AVAudioSessionCategoryPlayAndRecord error:&audioSessionError];
    }
    
    if (audioSessionError != nil)
    {
        NSLog (@"Error activating audio session during initial setup.");
        return;
    }
}


#pragma mark --set up audio processing graph

- (void) configureAndInitializeAudioUnits {
    
    // RemoteIO node description
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    

    //set up components
    // Get component
    OSStatus status;
    AudioComponent component = AudioComponentFindNext(NULL, &desc);
    // Get audio units
    status = AudioComponentInstanceNew(component, &mAudioUnit);
    checkStatus(status, @"AudioComponentInstanceNew");
    
    // Enable IO for recording
    UInt32 flag = 1;
    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status, @"AudioUnit Set Property Input");
    
    // Enable IO for playback
    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status, @"AudioUnit Set Property Output");
    
    // Describe output format
    AudioStreamBasicDescription outputFormat = {0};
    outputFormat.mSampleRate			= mSampleRate;
    outputFormat.mFormatID			= kAudioFormatLinearPCM;
    outputFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    outputFormat.mFramesPerPacket	= 1;
    outputFormat.mChannelsPerFrame	= mChannels;
    outputFormat.mBitsPerChannel    = mDataSizeBytes * 8;
    outputFormat.mBytesPerPacket	= mDataSizeBytes * mChannels;
    outputFormat.mBytesPerFrame		= mDataSizeBytes * mChannels;
    
    // Apply format to output
    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &outputFormat,
                                  sizeof(outputFormat));
    checkStatus(status, @"AudioUnit Set Property: Output Format");
    
//    //apply format to input
    //TODO correct for always mono input SInt16
    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &outputFormat,
                                  sizeof(outputFormat));
    checkStatus(status, @"AudioUnit Set Property: Input Format");
  
    // Setup input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);

    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
   
    
    // Set output callback
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
    
    status = AudioUnitSetProperty(mAudioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));

    checkStatus(status, @"AudioUnitSetPropertyOutputCallback");

    
    status = AudioUnitInitialize(mAudioUnit);
    checkStatus(status, @"AudioUnit Initialize");
    
}


#pragma mark -
#pragma mark Playback control

- (void) startAudioEngine
{
    NSLog (@"Starting audio processing graph");
    OSStatus result =  AudioOutputUnitStart(mAudioUnit);
    checkStatus(result, @"Start Output Unit");
    self->playing = YES;
}

- (void) stopAudioEngine
{
    
    NSLog (@"Stopping audio processing graph");
    OSStatus result = AudioOutputUnitStop(mAudioUnit);
    checkStatus(result, @"Stop Output Unit");
    self->playing = NO;
}

#pragma mark -
#pragma mark Audio Session Delegate Methods
// Respond to having been interrupted. This method sends a notification to the
//    controller object, which in turn invokes the playOrStop: toggle method. The
//    interruptedDuringPlayback flag lets the  endInterruptionWithFlags: method know
//    whether playback was in progress at the time of the interruption.
- (void) beginInterruption {
    
    NSLog (@"Audio session was interrupted.");
    
    if (playing) {
        
        self.interruptedDuringPlayback = YES;
        
        NSString *MixerHostAudioObjectPlaybackStateDidChangeNotification = @"MixerHostAudioObjectPlaybackStateDidChangeNotification";
        [[NSNotificationCenter defaultCenter] postNotificationName: MixerHostAudioObjectPlaybackStateDidChangeNotification object: self];
    }
}


// Respond to the end of an interruption. This method gets invoked, for example,
//    after the user dismisses a clock alarm.
- (void) endInterruptionWithFlags: (NSUInteger) flags {
    
    // Test if the interruption that has just ended was one from which this app
    //    should resume playback.
    if (flags & AVAudioSessionInterruptionTypeEnded) {
        
        NSError *endInterruptionError = nil;
        [[AVAudioSession sharedInstance] setActive: YES
                                             error: &endInterruptionError];
        if (endInterruptionError != nil) {
            
            NSLog (@"Unable to reactivate the audio session after the interruption ended.");
            return;
            
        } else {
            
            NSLog (@"Audio session reactivated after interruption.");
            
            if (interruptedDuringPlayback) {
                
                self.interruptedDuringPlayback = NO;
                
                // Resume playback by sending a notification to the controller object, which
                //    in turn invokes the playOrStop: toggle method.
                NSString *MixerHostAudioObjectPlaybackStateDidChangeNotification = @"MixerHostAudioObjectPlaybackStateDidChangeNotification";
                [[NSNotificationCenter defaultCenter] postNotificationName: MixerHostAudioObjectPlaybackStateDidChangeNotification object: self];
                
            }
        }
    }
}


/**
 Clean up.
 */
- (void) dealloc {
	AudioUnitUninitialize(mAudioUnit);
	free(mInputBuffer.mData);
    vDSP_destroy_fftsetup(mFftsetup);

}




@end
