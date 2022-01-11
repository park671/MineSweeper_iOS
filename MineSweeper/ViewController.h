//
//  ViewController.h
//  MineSweeper
//
//  Created by youngpark on 2020/2/26.
//  Copyright © 2020 youngpark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GameView.h"
#include "GameEngineNative.h"
#import "StateSetter.h"
#import "MyThread.h"
#import "MyNavigationController.h"

@interface ViewController : UIViewController <SetState>

@property GameView *gameView;

-(void)playSound:(int)sound;

@end

