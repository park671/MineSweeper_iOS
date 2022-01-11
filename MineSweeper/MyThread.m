//
//  MyThread.m
//  MineSweeper
//
//  Created by youngpark on 2020/2/26.
//  Copyright © 2020 youngpark. All rights reserved.
//

#import "MyThread.h"

@implementation MyThread

- (void)main{
    float timeUsed = 0;
    while ([self isStart]) {
        NSString *timeString = [NSString stringWithFormat:@"已用时间:%.1f",timeUsed];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:timeString waitUntilDone:false];
        timeUsed += 0.1f;
        [NSThread sleepForTimeInterval:0.1];
    }
}

-(void)updateUI:(NSString *) timeString{
    [self.timeLable setText:timeString];
    [self.timeLable setNeedsDisplay];
}

@end
