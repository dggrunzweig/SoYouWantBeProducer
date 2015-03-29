//
//  FunctionGeneratorView.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/7/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "effectsBank.h"

@interface FunctionGeneratorView : UIViewController

@property float mSineVol;
@property float mTriVol;
@property float mDecayTime;
@property IBOutlet UIImageView* background;
@property UIImage* backgroundImage;
@property IBOutlet UIPanGestureRecognizer* mPanGestureRecognizer;
@property IBOutlet UIImageView* mSineKnob;
@property IBOutlet UIImageView* mTriKnob;
@property IBOutlet UIImageView* mDecayKnob;
@property IBOutlet UILabel* faderMax;
@property IBOutlet UILabel* faderMin;
@property IBOutlet UIImageView* sineStatus;
@property IBOutlet UIImageView* triStatus;
@property IBOutlet UIImageView* decayStatus;
@property UIImage* greenLight;
@property UIImage* redLight;
@property BOOL mSineCorrect;
@property BOOL mTriCorrect;
@property BOOL mDecayCorrect;
@property BOOL mFinished;

@property IBOutlet UIButton* nextScreen;


@end
