//
//  ViewController.m
//  FQ_MineScrollerVCDemo
//
//  Created by fanqi on 2018/9/13.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "ViewController.h"
#define NAVIGATION_HEIGHT 64
@interface ViewController ()<FQ_MineScrollerVCDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.mineDelegate = self;
    [self creatUI];
}

-(void)creatUI{
    
    FQ_MineScrollerModel * scrollerModel = [[FQ_MineScrollerModel alloc]initWithTitleMargin:40];
    UIViewController * dynamicVc = [[UIViewController alloc]init];
    dynamicVc.view.backgroundColor = [UIColor redColor];
    UIViewController * fansVc = [[UIViewController alloc]init];
    fansVc.view.backgroundColor = [UIColor greenColor];
    UIViewController * focusVc = [[UIViewController alloc]init];
    focusVc.view.backgroundColor = [UIColor orangeColor];
    
    scrollerModel.selectIndex = 0;
    scrollerModel.lineType = BottomLineTypeScaling;
    scrollerModel.lineHeight  = 15;
    scrollerModel.titleLineMargin = 0;
    scrollerModel.titleMargin = 100;
    scrollerModel.titleViewType = TitleViewStatusType_Full_Center;
    scrollerModel.selectColor = [UIColor blackColor];
    scrollerModel.defaultColor = [UIColor grayColor];
    scrollerModel.lineColor = UIColor.orangeColor;
    scrollerModel.selTitleFont = [UIFont boldSystemFontOfSize:25];
    scrollerModel.norTitleFont = [UIFont boldSystemFontOfSize:15];
    scrollerModel.line_Scaling_colors = @[RGB(55.0, 201.0, 105.0),RGB(40, 168, 152)];
    
    scrollerModel.titlesArr = @[@"消息中心",@"报警提醒",@"动态",@"消息中心",@"报警提醒",@"动态"];
    scrollerModel.childVCArr = @[fansVc,focusVc,dynamicVc,fansVc,focusVc,dynamicVc];
    self.scrollerModel = scrollerModel;
    
    //重新布局childview
    self.childsView.frame = CGRectMake(0, 64 + 30, ScreenW , ScreenH - 64 - 30);
    self.childsView.contentSize = CGSizeMake(scrollerModel.titlesArr.count * ScreenW, 0);
    //重新布局titleView
    self.titleView.frame = CGRectMake(0, 44, ScreenW, 50);
    self.titleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.titleView];
    
    //    self.childsView.frame = CGRectMake(0, NAVIGATION_HEIGHT + 44, ScreenW , ScreenH - NAVIGATION_HEIGHT - 44);
    //    self.childsView.contentSize = CGSizeMake(scrollerModel.titlesArr.count * ScreenW, 0);
    //
    //
    //    UIView *separatorView= [[UIView alloc]init];
    //    separatorView.backgroundColor = [UIColor blueColor];
    //    [self.titleView addSubview:separatorView];
    //    separatorView.frame = CGRectMake(0, 54 - 0.5, ScreenW, 0.5);
    //
    //    self.titleView.frame = CGRectMake(0, NAVIGATION_HEIGHT, ScreenW, 54);
    //    self.titleView.backgroundColor = [UIColor whiteColor];
    //    [self.view addSubview:self.titleView];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self changRedDotStatusWithArr:@[@0,@1,@0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC enterChilderVc:(UIViewController *)childerVc {
    NSLog(@"-------->反正是有进入%@",childerVc);
}

-(void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC firstEnterChilderVc:(UIViewController *)childerVc
{
    NSLog(@"-------->是第一次进入%@==%zd",childerVc,self.scrollerModel.selectIndex);
    
    //根据请求:隐藏
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hiddenRedDotWithIndexArr:@[@(self.scrollerModel.selectIndex)]];
    });
}
//
//-(void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC noneFirstEnterChilderVc:(UIViewController *)childerVc
//{
//    NSLog(@"-------->不是第一进入%@",childerVc);
//}


@end
