//
//  FQ_MineScrollerVC.h
//  FQ_MineScrollerVC
//
//  Created by mac on 2017/7/10.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQ_MineScrollerModel.h"

@class FQ_MineScrollerVC;
@protocol FQ_MineScrollerVCDelegate <NSObject>

@required
/**
 进入当前控制器
 */
-(void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC enterChilderVc:(UIViewController *)childerVc;

@optional
/**
 第一次进入该控制器时调用
 */
-(void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC firstEnterChilderVc:(UIViewController *)childerVc;

/**
 不是第一次进入该控制器时调用
 */
-(void)mineScrollerVC:(FQ_MineScrollerVC *)scrollerVC noneFirstEnterChilderVc:(UIViewController *)childerVc;

@end

@interface FQ_MineScrollerVC : UIViewController

@property (nonatomic, weak) id<FQ_MineScrollerVCDelegate> mineDelegate;

@property (strong, nonatomic) FQ_MineScrollerModel *scrollerModel;
//子控制器集合
@property (strong, nonatomic ,readonly) UIScrollView *childsView;
//标题集合.可以布局标题
@property (strong, nonatomic ,readonly) UIScrollView *titleView;

//设置当前选中索引
-(void)setCurrentSelectIndex:(NSInteger)selectIndex;
//供子类继承并自定义
-(void)mineScroller_scrollviewDidScroll:(UIScrollView *)scrollView;

@end

