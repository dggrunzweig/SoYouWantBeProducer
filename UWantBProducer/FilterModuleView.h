//
//  FilterModuleView.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/9/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../effectsBank.h"

@interface FilterModuleView : UIViewController

@property float mCutoffFreq;
@property float mQ;
@property float mLFORate;
@property BOOL isHighPass;
@property IBOutlet UIImageView* background;
@property UIImage* highpassImage;
@property UIImage* lowpassImage;
@property IBOutlet UIButton* switchButton;
@property IBOutlet UIPanGestureRecognizer* mPanGestureRecognizer;
@property IBOutlet UIImageView* mCutoffFreqKnob;
@property IBOutlet UIImageView* mQKnob;
@property IBOutlet UIImageView* mLFORateKnob;
@property IBOutlet UILabel* faderMax;
@property IBOutlet UILabel* faderMin;
@property IBOutlet UIImageView* cutOffStatus;
@property IBOutlet UIImageView* QStatus;
@property IBOutlet UIImageView* LFOStatus;
@property IBOutlet UIImageView* TypeStatus;
@property UIImage* greenLight;
@property UIImage* redLight;
@property BOOL mCutoffCorrect;
@property BOOL mQCorrect;
@property BOOL mLFOCorrect;
@property BOOL mHighPassCorrect;
@property BOOL mFinished;
@property IBOutlet UIButton* nextScreen;



@end
