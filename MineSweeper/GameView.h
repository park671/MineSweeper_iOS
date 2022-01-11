//
//  GameView.h
//  MineSweeper
//
//  Created by youngpark on 2020/2/26.
//  Copyright © 2020 youngpark. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "GameEngineNative.h"
#import "StateSetter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GameView : UIView

@property id<SetState> stateSetter;

+(void)setStartPoint:(int) pos;

@end

NS_ASSUME_NONNULL_END
