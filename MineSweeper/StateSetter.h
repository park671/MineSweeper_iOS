//
//  StateSetter.h
//  MineSweeper
//
//  Created by youngpark on 2020/2/27.
//  Copyright © 2020 youngpark. All rights reserved.
//

#ifndef StateSetter_h
#define StateSetter_h

@protocol SetState

@required -(void)setState:(bool)win;
@required -(void)playSound:(int)sound;// 1-mark  2-check
@required -(void)setGameCount:(int)boomNum : (int) flagNum;

@end

#endif /* StateSetter_h */
