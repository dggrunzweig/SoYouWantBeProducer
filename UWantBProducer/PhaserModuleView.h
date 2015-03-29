//
//  PhaserModuleView.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/10/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhaserModuleView : UIViewController

@property float mSpeed;
@property float mRange;
@property float mMix;
@property IBOutlet UIPanGestureRecognizer* mPanGestureRecognizer;
@property IBOutlet UIImageView* mSpeedKnob;
@property IBOutlet UIImageView* mRangeKnob;
@property IBOutlet UIImageView* mMixKnob;
@property IBOutlet UILabel* faderMax;
@property IBOutlet UILabel* faderMin;

@end
