//
//  EchoModuleView.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/10/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "effectsBank.h"

@interface EchoModuleView : UIViewController

@property float mFeedback;
@property float mTime;
@property float mMix;
@property IBOutlet UIPanGestureRecognizer* mPanGestureRecognizer;
@property IBOutlet UIImageView* mFeedbackKnob;
@property IBOutlet UIImageView* mTimeKnob;
@property IBOutlet UIImageView* mMixKnob;
@property IBOutlet UILabel* faderMax;
@property IBOutlet UILabel* faderMin;
@property UIImage* greenLight;
@property UIImage* redLight;
@property IBOutlet UIImageView* feedbackStatus;
@property IBOutlet UIImageView* timeStatus;
@property IBOutlet UIImageView* mixStatus;
@property BOOL mTimeCorrect;
@property BOOL mFeedbackCorrect;
@property BOOL mMixCorrect;
@property BOOL mFinished;

@property IBOutlet UIButton* nextScreen;



@end
