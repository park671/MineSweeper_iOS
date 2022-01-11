//
//  ViewController.m
//  MineSweeper
//
//  Created by youngpark on 2020/2/26.
//  Copyright © 2020 youngpark. All rights reserved.
//

#import "ViewController.h"
#import "StateSetter.h"

@implementation ViewController

SystemSoundID  checkSound = 1;
SystemSoundID  markSound = 1;
SystemSoundID  winSound = 1;
SystemSoundID  startSound = 1;
SystemSoundID  boomSound = 1;

CGFloat screenWidth, screenHeight;
CGFloat statusBarHeight,nagviBarHeight;

MyThread *timeThread;
UILabel *timeLabel;

// 提示错误信息
- (void)showDialog: (NSString *)title :(NSString *)message {
    // 1.弹框提醒
    // 初始化对话框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    // 弹出对话框
    [self presentViewController:alert animated:true completion:nil];
}

-(void)showInputDialog{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"自定义地图"
                                                                   message:@"输入地图大小和雷数"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //响应事件
                                                         //得到文本信息
                                                         for(UITextField *text in alert.textFields){
                                                             if([text.placeholder isEqualToString:@"地图大小"]){
                                                                 NSString *mapSizeString = [text text];
                                                                 mapSize = [mapSizeString intValue];
                                                             }else{
                                                                 NSString *boomNumString = [text text];
                                                                 boomNum = [boomNumString intValue];
                                                             }
                                                         }
                                                         [self restart];
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                             NSLog(@"取消");
                                                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"地图大小";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"地雷数量";
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)initSound{
    //3、创建一个系统声音服务
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([[NSBundle mainBundle]URLForResource:@"check.wav" withExtension:nil ]), &checkSound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([[NSBundle mainBundle]URLForResource:@"marking.wav" withExtension:nil ]), &markSound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([[NSBundle mainBundle]URLForResource:@"bomb.wav" withExtension:nil ]), &boomSound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([[NSBundle mainBundle]URLForResource:@"start.wav" withExtension:nil ]), &startSound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([[NSBundle mainBundle]URLForResource:@"win.wav" withExtension:nil ]), &winSound);
}

-(void)initNavigationBar{
    UINavigationController *navigationController = [[MyNavigationController alloc] initWithRootViewController:self];
    [navigationController setTitle:@"扫雷"];
    [UIApplication sharedApplication].delegate.window.rootViewController = navigationController;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:00/255.0 green:87/255.0 blue:75/255.0 alpha:1.0];
    [self setTitle:@"扫雷"];
}

-(void)initGameView{
    float viewSize = screenWidth - 10;
    CGRect pos = CGRectMake(5, nagviBarHeight + statusBarHeight + 5,
                            viewSize ,
                            viewSize);
    self.gameView = [GameView new];
    [self.gameView setFrame:pos];
    [self.gameView setStateSetter:self];
    [self.view addSubview:self.gameView];
}

-(void)initScreenParams{
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    statusBarHeight = rectStatus.size.height;
    nagviBarHeight =self.navigationController.navigationBar.frame.size.height;
}

-(void)initButtons{
    CGFloat marginTop = 70.f;
    
    UIButton *setFlagButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [setFlagButton setTitle:isFlag?@"标记":@"非标记" forState:UIControlStateNormal];
    [[setFlagButton layer]setCornerRadius:10.f];
    [setFlagButton setBackgroundColor:[UIColor whiteColor]];
    [setFlagButton addTarget:self action:@selector(setFlag:) forControlEvents:UIControlEventTouchUpInside];
    [setFlagButton setFrame:CGRectMake((screenWidth/4)*1 - 40, screenWidth + statusBarHeight +nagviBarHeight + marginTop, 80, 30)];
    [self.view addSubview:setFlagButton];
    
    timeLabel = [UILabel new];
    [timeLabel setFrame:CGRectMake((screenWidth/4)*2 - 40, screenWidth + statusBarHeight +nagviBarHeight + marginTop, 100, 30)];
    [timeLabel setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:timeLabel];
    
    UIButton *newRoundButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [newRoundButton setTitle:@"开始新局" forState:UIControlStateNormal];
    [[newRoundButton layer]setCornerRadius:10.f];
    [newRoundButton setBackgroundColor:[UIColor whiteColor]];
    [newRoundButton addTarget:self action:@selector(setLevel:) forControlEvents:UIControlEventTouchUpInside];
    [newRoundButton setFrame:CGRectMake((screenWidth/4)*3 - 40, screenWidth + statusBarHeight +nagviBarHeight + marginTop, 80, 30)];
    [self.view addSubview:newRoundButton];
}

-(void) initTimeCount{
    timeThread = [MyThread new];
    [timeThread setTimeLable:timeLabel];
    [timeThread setIsStart:true];
    [timeThread start];
}

UIImageView *boomCount1, *boomCount2, *boomCount3;
UIImageView *flagCount1, *flagCount2, *flagCount3;

UIImage *greenNums[10], *redNums[10];

-(void)initGameCount{
    CGFloat marginTop = 10.f;
    
    for(int i = 0;i<10;i++){
        NSString *greenNumName = [NSString stringWithFormat:@"gnumber_%d.png",i];
        greenNums[i] =[UIImage imageNamed:greenNumName];
        NSString *redNumName = [NSString stringWithFormat:@"number_%d.png",i];
        redNums[i] =[UIImage imageNamed:redNumName];
    }
    
    boomCount1  = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth/4)*1 - 30, screenWidth + statusBarHeight +nagviBarHeight + marginTop, 25, 50)];
    boomCount2  = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth/4)*1 - 5, screenWidth + statusBarHeight +nagviBarHeight + marginTop, 25, 50)];
    boomCount3  = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth/4)*1 + 20, screenWidth + statusBarHeight +nagviBarHeight + marginTop, 25, 50)];
    
    [boomCount1 setImage:[UIImage imageNamed:@"number_dash.png"]];
    [boomCount2 setImage:[UIImage imageNamed:@"number_dash.png"]];
    [boomCount3 setImage:[UIImage imageNamed:@"number_dash.png"]];
    
    [self.view addSubview:boomCount1];
    [self.view addSubview:boomCount2];
    [self.view addSubview:boomCount3];
    
    flagCount1  = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth/4)*3 - 30, screenWidth + statusBarHeight +nagviBarHeight + marginTop, 25, 50)];
    flagCount2  = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth/4)*3 - 5, screenWidth + statusBarHeight +nagviBarHeight + marginTop, 25, 50)];
    flagCount3  = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth/4)*3 + 20, screenWidth + statusBarHeight +nagviBarHeight + marginTop, 25, 50)];
    
    [flagCount1 setImage:[UIImage imageNamed:@"gnumber_dash.png"]];
    [flagCount2 setImage:[UIImage imageNamed:@"gnumber_dash.png"]];
    [flagCount3 setImage:[UIImage imageNamed:@"gnumber_dash.png"]];
    
    [self.view addSubview:flagCount1];
    [self.view addSubview:flagCount2];
    [self.view addSubview:flagCount3];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    GameEngineInit();
    
    [self initNavigationBar];
    [self initScreenParams];
    
    [self initSound];
    [self initGameView];
    [self initGameCount];
    [self initButtons];
    [self initTimeCount];
    [self restart];
}

- (void)setFlag:(UIButton *)sender{
    isFlag = !isFlag;
    AudioServicesPlaySystemSound(isFlag?markSound : checkSound);
    [sender setTitle:isFlag?@"标记":@"非标记" forState:UIControlStateNormal];
    [sender setTitleColor:isFlag?[UIColor redColor]:[UIColor blueColor] forState:UIControlStateNormal];
}
-(void)setGameCount:(int)boomNum : (int) flagNum{
    [boomCount3 setImage:redNums[boomNum % 10]];
    [boomCount2 setImage:redNums[(boomNum / 10)%10]];
    [boomCount1 setImage:redNums[(boomNum / 100)%10]];
    
    [flagCount3 setImage:greenNums[flagNum % 10]];
    [flagCount2 setImage:greenNums[(flagNum / 10) % 10]];
    [flagCount1 setImage:greenNums[(flagNum / 100) % 10]];
}

-(void)restart{
    GameEngineInit();
    [timeThread setIsStart:false];
    [[self gameView]setNeedsDisplay];
    [self initTimeCount];
    [self setGameCount:boomNum :flagNum];
    AudioServicesPlaySystemSound(startSound);
}

- (void)setLevel:(UIButton *)sender{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"选择难度"
                                                                   message:@"难度等级."
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    UIAlertAction* easyAction = [UIAlertAction actionWithTitle:@"简单" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           NSLog(@"action = %@", action);
                                                           mapSize  = 11;
                                                           boomNum = 15;
                                                           [self restart];
                                                       }];
    UIAlertAction* midAction = [UIAlertAction actionWithTitle:@"中等" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          NSLog(@"action = %@", action);
                                                          mapSize = 15;
                                                          boomNum = 50;
                                                          [self restart];
                                                      }];
    UIAlertAction* hardAction = [UIAlertAction actionWithTitle:@"困难" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           mapSize = 17;
                                                           boomNum = 80;
                                                           [self restart];
                                                       }];
    UIAlertAction* impossableAction = [UIAlertAction actionWithTitle:@"不可能" style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * action) {
                                                           mapSize = 17;
                                                           boomNum = 110;
                                                           [self restart];
                                                       }];
    UIAlertAction* custom = [UIAlertAction actionWithTitle:@"自定义" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self showInputDialog];
                                                       }];
    [alert addAction:cancelAction];
    [alert addAction:easyAction];
    [alert addAction:midAction];
    [alert addAction:hardAction];
    [alert addAction:impossableAction];
    [alert addAction:custom];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setState:(bool)win{
    [timeThread setIsStart:false];
    if(win){
        AudioServicesPlaySystemSound(winSound);
        [self showDialog:@"恭喜您" : @"成功通关!🎉"];
    }else{
        AudioServicesPlaySystemSound(boomSound);
        [self showDialog:@"很遗憾" : @"请再接再厉！"];
    }
}

- (void)playSound:(int)sound{
    switch (sound) {
        case 1:
            AudioServicesPlaySystemSound(markSound);
            break;
        case 2:
            AudioServicesPlaySystemSound(checkSound);
        default:
            break;
    }
}

@end
