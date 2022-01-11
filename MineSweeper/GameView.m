//
//  GameView.m
//  MineSweeper
//
//  Created by youngpark on 2020/2/26.
//  Copyright © 2020 youngpark. All rights reserved.
//

#import "GameView.h"
static int startPoint = 0;
static float cellSize;

@implementation GameView

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void)setStartPoint:(int)pos{
    startPoint = pos;
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"drawRect");
    CGFloat width = [self frame].size.width;
    CGFloat height = [self frame].size.height;
    NSLog(@"width=%.0f,height=%.0f",width,height);
    cellSize = width / mapSize;
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /**背景清空**/
    CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);//填充颜色
    CGRect bgRect = CGRectMake(0, 0, width, width);
    CGContextFillRect(context, bgRect);
    /**背景清空**/
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);//笔触的颜色
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);//填充颜色
    CGContextSetLineWidth(context, 5.0);//设置线条宽度
    CGContextSetLineCap(context, kCGLineCapRound);//设置顶点样式
    CGContextSetLineJoin(context, kCGLineJoinBevel);//设置连接点样式
    //保存图形状态
    CGContextSaveGState(context);
    
    UIImage *tileMaskImg = [UIImage imageNamed:@"tile_mask.png"];
    UIImage *tileDownImg = [UIImage imageNamed:@"tile_down.png"];
    UIImage *tileFlagImg = [UIImage imageNamed:@"tile_d.png"];
    UIImage *tileBaseImg = [UIImage imageNamed:@"tile_base.png"];
    UIImage *tileBoomImg = [UIImage imageNamed:@"tile_b2.png"];
    UIImage *tileBoomRmImg = [UIImage imageNamed:@"tile_b3.png"];
    UIImage *tileBoomExpImg = [UIImage imageNamed:@"tile_b.png"];
    
    UIImage *tileNumImgs[9];
    CGImageRef tileNumImgsRef[9];
    
    for(int i = 1;i<=8;i++){
        NSString* imgName = [NSString stringWithFormat:@"tile_%d.png",i];
        tileNumImgs[i] = [UIImage imageNamed:imgName];
        tileNumImgsRef[i] = [tileNumImgs[i] CGImage];
    }
    
    UIGraphicsPushContext(context);
    
    for(int i = 0;i<mapSize;i++){
        for(int j = 0;j<mapSize;j++){
            CGRect imgRect = CGRectMake(i * cellSize, j * cellSize, cellSize, cellSize);
            if (show[i][j] == 0) {
                [tileMaskImg drawInRect:imgRect];
            } else if (show[i][j] == -1 || show[i][j] == -2) {
                [tileDownImg drawInRect:imgRect];
            } else if (show[i][j] == 2) {
                [tileFlagImg drawInRect:imgRect];
            } else {
                switch (mapArray[i][j]) {
                    case 0:
                        [tileBaseImg drawInRect:imgRect];
                        break;
                    case -1:
                        [tileBoomImg drawInRect:imgRect];
                        break;
                    case -2:
                        [tileBoomExpImg drawInRect:imgRect];
                        break;
                    case -3:
                        [tileBoomRmImg drawInRect:imgRect];
                        break;
                    default:
                        [tileNumImgs[mapArray[i][j]] drawInRect:imgRect];
                        break;
                }
            }
        }
    }
    UIGraphicsPopContext();
}

/**
 * 触摸事件处理
 *
 **/

static int pressedX = -1;
static int pressedY = -1;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(!gameFinish){
        UITouch* touch = touches.anyObject;
        CGPoint point = [touch locationInView:self];
        int posX = point.x / cellSize;
        int posY = point.y / cellSize;
        if(GameEnginePressPos(posX, posY)){
            pressedX = posX;
            pressedY = posY;
            [[self stateSetter]setGameCount:boomNum :flagNum];
            [self setNeedsDisplay];
            
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(!gameFinish){
        UITouch* touch = touches.anyObject;
        CGPoint point = [touch locationInView:self];
        int posX = point.x / cellSize;
        int posY = point.y / cellSize;
        if(posX != pressedX || posY != pressedY){
            GameEngineReleasePos(pressedX, pressedY);
            [self setNeedsDisplay];
            return;
        }
        if(isFlag){
            [[self stateSetter]playSound:1];
            if(!GameEngineFlag(posX, posY)){
                GameEngineReleasePos(pressedX, pressedY);
            }
        }else{
            [[self stateSetter]playSound:2];
            if(GameEngineSelectPos(posX, posY) == false){
                [[self stateSetter]setState:false];
                [self setNeedsDisplay];
                return;
            }else if(GameEngineWin()){
                [[self stateSetter]setState:true];
            }
        }
        [[self stateSetter]setGameCount:boomNum :flagNum];
        [self setNeedsDisplay];
    }
}

@end
