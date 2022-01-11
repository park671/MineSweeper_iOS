//
//  MyNavigationController.m
//  MineSweeper
//
//  Created by youngpark on 2020/2/29.
//  Copyright © 2020 youngpark. All rights reserved.
//

#import "MyNavigationController.h"

@interface MyNavigationController ()

@end

@implementation MyNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad called!");
    // Do any additional setup after loading the view.
}

// 状态栏字体 白色 重写preferredStatusBarStyle 方法
- (UIStatusBarStyle)preferredStatusBarStyle
{
    // UIStatusBarStyleLightContent 白色
    // UIStatusBarStyleDefault      黑色
    NSLog(@"preferredStatusBarStyle called!");
    return UIStatusBarStyleLightContent;
}

@end
