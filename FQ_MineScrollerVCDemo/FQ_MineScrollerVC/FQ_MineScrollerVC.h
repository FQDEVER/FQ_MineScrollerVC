//
//  FQ_MineScrollerVC.h
//  FQ_MineScrollerVC
//
//  Created by mac on 2017/7/10.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQ_MineScrollerModel.h"

@interface FQ_MineScrollerBtn : UIButton

@property (nonatomic, assign) BOOL isShowRedDot;

@end

@class FQ_MineScrollerVC;

/*
  如果需要监听第一次进入处理一些事情.可遵守该代理.并实现相关方法.
 */
@protocol FQ_MineScrollerVCDelegate <NSObject>

@optional
/**
 进入当前选中控制器

 @param scrollerVC scrollerVC容器控制器
 @param childerVc 当前选中子控制器
 */
-(void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC enterChilderVc:(UIViewController *)childerVc;

/**

 第一次进入该选中控制器
 
 @param scrollerVC scrollerVC容器控制器
 @param childerVc 当前选中子控制器
 */
-(void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC firstEnterChilderVc:(UIViewController *)childerVc;

/**
 
 不是第一次进入该选中控制器
 
 @param scrollerVC scrollerVC容器控制器
 @param childerVc 当前选中子控制器
 */
-(void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC noneFirstEnterChilderVc:(UIViewController *)childerVc;

@end

@interface FQ_MineScrollerVC : UIViewController

@property (nonatomic, weak) id<FQ_MineScrollerVCDelegate> mineDelegate;

/**
 配置模型
 */
@property (strong, nonatomic) FQ_MineScrollerModel *scrollerModel;

/**
 子控制器显示集合视图
 */
@property (strong, nonatomic ,readonly) UIScrollView *childsView;

/**
 标题显示集合视图
 */
@property (strong, nonatomic ,readonly) UIScrollView *titleView;

/**
 设置当前选中索引.会跳转到相关视图

 @param selectIndex 设置选中索引
 */
-(void)setCurrentSelectIndex:(NSInteger)selectIndex;

/**
 供子类继承并自定义

 @param scrollView 当前滚动scrollView
 */
-(void)mineScroller_scrollviewDidScroll:(UIScrollView *)scrollView;

/**
 显示标题上对应索引数组的红点

 @param indexArr 索引数组
 */
-(void)showRedDotWithIndexArr:(NSArray<NSNumber *> *)indexArr;

/**
 隐藏标题上对应索引数组的红点

 @param indexArr 索引数组
 */
-(void)hiddenRedDotWithIndexArr:(NSArray<NSNumber *> *)indexArr;

/**
 更新红点状态数组

 @param redDotArr 红点状态数组
 */
-(void)changRedDotStatusWithArr:(NSArray<NSNumber *> *)redDotArr;

@end

