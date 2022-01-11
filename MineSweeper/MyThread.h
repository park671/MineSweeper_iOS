//
//  MyThread.h
//  MineSweeper
//
//  Created by youngpark on 2020/2/26.
//  Copyright © 2020 youngpark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "StateSetter.h"

@interface MyThread : NSThread

@property(weak) UILabel* timeLable;
@property bool isStart;

-(void) main;

@end
