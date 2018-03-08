//
//  ViewController.m
//  FQ_MineScrollerVC
//
//  Created by mac on 2017/7/10.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "FQ_MineScrollerVC.h"
#import "FQ_MineScrollerModel.h"
#import "TestViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    
    FQ_MineScrollerModel * scrollerModel = [[FQ_MineScrollerModel alloc]init];
    
    TestViewController * testVC1 = [[TestViewController alloc]init];
    testVC1.view.backgroundColor = [UIColor orangeColor];
    
    TestViewController * testVC2 = [[TestViewController alloc]init];
    testVC2.view.backgroundColor = [UIColor whiteColor];
    
    TestViewController * testVC3 = [[TestViewController alloc]init];
    testVC3.view.backgroundColor = [UIColor redColor];
    
    TestViewController * testVC4 = [[TestViewController alloc]init];
    testVC4.view.backgroundColor = [UIColor blueColor];
    
    TestViewController * testVC5 = [[TestViewController alloc]init];
    testVC5.view.backgroundColor = [UIColor grayColor];
    
    TestViewController * testVC6 = [[TestViewController alloc]init];
    testVC6.view.backgroundColor = [UIColor greenColor];
    
    scrollerModel.titlesArr = @[@"开始",@"历史的轨迹",@"新",@"快乐的时刻",@"信息",@"新闻时刻"];
    scrollerModel.childVCArr = @[testVC1,testVC2,testVC3,testVC4,testVC5,testVC6];
    scrollerModel.lineType = BottomLineTypeScaling;
    scrollerModel.lineLength  = 5;
    scrollerModel.line_Scaling_colors = @[(id)[UIColor cyanColor].CGColor,(id)[UIColor redColor].CGColor,(id)[UIColor yellowColor].CGColor,(id)[UIColor greenColor].CGColor,(id)[UIColor orangeColor].CGColor,(id)[UIColor blueColor].CGColor,];
    
    self.scrollerModel = scrollerModel;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
