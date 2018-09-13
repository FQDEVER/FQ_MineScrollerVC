//
//  ViewController.m
//  FQ_MineScrollerVCDemo
//
//  Created by fanqi on 2018/9/13.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "ViewController.h"
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

    FQ_MineScrollerModel * scrollerModel = [[FQ_MineScrollerModel alloc]init];
    UIViewController * dynamicVc = [[UIViewController alloc]init];
    dynamicVc.view.backgroundColor = [UIColor redColor];
    UIViewController * fansVc = [[UIViewController alloc]init];
    fansVc.view.backgroundColor = [UIColor greenColor];
    UIViewController * focusVc = [[UIViewController alloc]init];
    focusVc.view.backgroundColor = [UIColor orangeColor];

    scrollerModel.selectIndex = 0;
    scrollerModel.titlesArr = @[@"动态",@"粉丝",@"关注"];
    scrollerModel.childVCArr = @[dynamicVc,fansVc,focusVc];
    scrollerModel.lineType = BottomLineTypeScaling;
    scrollerModel.lineLength  = 15;

    scrollerModel.titleViewType = TitleViewStatusType_Full_Right;
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC enterChilderVc:(UIViewController *)childerVc {
    NSLog(@"-------->反正是有进入%@",childerVc);
}

-(void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC firstEnterChilderVc:(UIViewController *)childerVc
{
    NSLog(@"-------->是第一次进入%@",childerVc);
}

-(void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC noneFirstEnterChilderVc:(UIViewController *)childerVc
{
    NSLog(@"-------->不是第一进入%@",childerVc);
}


@end