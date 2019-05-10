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

    FQ_MineScrollerModel * scrollerModel = [[FQ_MineScrollerModel alloc]initWithTitleMargin:20];
    UIViewController * dynamicVc = [[UIViewController alloc]init];
    dynamicVc.view.backgroundColor = [UIColor redColor];
    UIViewController * fansVc = [[UIViewController alloc]init];
    fansVc.view.backgroundColor = [UIColor greenColor];
    UIViewController * focusVc = [[UIViewController alloc]init];
    focusVc.view.backgroundColor = [UIColor orangeColor];

    scrollerModel.selectIndex = 0;
//    scrollerModel.titlesArr = @[@"动态",@"粉丝",@"关注"];
    scrollerModel.titlesArr = @[@"强度分钟数",@"最大摄氧量",@"乳酸阈值"];
    scrollerModel.childVCArr = @[dynamicVc,fansVc,focusVc];
    scrollerModel.lineType = BottomLineTypeScaling;
    scrollerModel.lineLength  = 15;
    scrollerModel.lineHeight = 4.0f;
    scrollerModel.titleRedDotArr = @[@1,@1,@1];
//    scrollerModel.isEnterHiddenRedDot = NO;
    scrollerModel.titleViewType = TitleViewStatusType_Full_Center;
    scrollerModel.selectColor = [UIColor redColor];
    scrollerModel.defaultColor = [UIColor grayColor];
    scrollerModel.titleFont = [UIFont systemFontOfSize:15];
    self.scrollerModel = scrollerModel;

    self.childsView.frame = CGRectMake(0, NAVIGATION_HEIGHT + 44, ScreenW , ScreenH - NAVIGATION_HEIGHT - 44);
    self.childsView.contentSize = CGSizeMake(scrollerModel.titlesArr.count * ScreenW, 0);


    UIView *separatorView= [[UIView alloc]init];
    separatorView.backgroundColor = [UIColor blueColor];
    [self.titleView addSubview:separatorView];
    separatorView.frame = CGRectMake(0, 44 - 0.5, ScreenW, 0.5);

    self.titleView.frame = CGRectMake(0, NAVIGATION_HEIGHT, ScreenW, 44);
    self.titleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.titleView];
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
