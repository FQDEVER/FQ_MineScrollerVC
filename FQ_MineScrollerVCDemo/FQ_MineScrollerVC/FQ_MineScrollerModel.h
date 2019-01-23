//
//  FQ_MineScrollerModel.h
//  FQ_MineScrollerVC
//
//  Created by mac on 2017/7/10.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#define  M_ScreenW self.bounds.size.width
#define  M_ScreenH self.bounds.size.height
#define ScreenW  [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
//是否是 iphone X
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
// 判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
// 判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
// 判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

//所有流海屏幕
#define IS_IPHONE_X_SERIES  IS_IPHONE_X || IS_IPHONE_Xr || IS_IPHONE_Xs || IS_IPHONE_Xs_Max

#define TitleMargin 40
#define TitleViewH 44
#define TitleViewFontSize 15
#define TitleViewW ScreenW-60

#define TitleBtnTag 10000
#define ChildViewTag 20000
#define RandomColor [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0]

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

typedef enum : NSInteger{
    BottomLineTypeNone, //无下划线
    BottomLineTypeDefault = 0, //默认-bottom
    BottomLineTypeScaling, //拉伸
    BottomLineTypeDefault_Up, //在顶部
}BottomLineType;

typedef enum : NSInteger{
    TitleViewStatusType_None = 0, // 无.占满屏宽
    TitleViewStatusType_Full_Left, //titleView全屏.按钮内容居左
    TitleViewStatusType_Full_Right, //titleView全屏.按钮内容居右
    TitleViewStatusType_Full_Center, //titleView全屏.按钮内容居中
}TitleViewStatusType;


@interface FQ_MineScrollerModel : NSObject

//标题数组
@property (strong, nonatomic) NSArray<NSString *> *titlesArr;

/**
 标题红点数组.默认均为@0.即不产生红点.如果有五组标题.值传入4组红点状态.最后一组默认为@0
 */
@property (nonatomic, strong) NSArray<NSNumber *> *titleRedDotArr;

//子控制器数组
@property (strong, nonatomic) NSArray<UIViewController *> *childVCArr;

//子视图数组
@property (strong, nonatomic) NSArray<UIView *> *childViewArr;

//是否第一次进入就红点消失.默认为yes.如果为yes.即代表进入控制器就隐藏响应红点.如果为no.需要自己手动隐藏(例如:在网络请求成功以后才隐藏红点时.)
@property (nonatomic, assign) BOOL isEnterHiddenRedDot;

//titleView默认颜色
@property (strong, nonatomic) UIColor *defaultColor;

//titleView选中颜色
@property (strong, nonatomic) UIColor *selectColor;

//titleView的文字
@property (nonatomic, strong) UIFont *titleFont;

//下划线样式.默认:BottomLineTypeDefault
@property (assign, nonatomic) BottomLineType lineType;

//普通下滑线的颜色
@property (strong, nonatomic) UIColor *lineColor;

//下滑线使用Scaling拉伸样式.渐变颜色.CGColor.或者UIColor对象.不设置则使用随机色
@property (strong, nonatomic) NSArray *line_Scaling_colors;

//使用拉伸时可设置线长.默认为0.随文字长度变化!一旦设置所有下划线长度均固定
@property (assign, nonatomic) CGFloat lineLength;

//线的高度.默认为2.
@property (assign, nonatomic) CGFloat lineHeight;

//titleView选中的索引
@property (assign, nonatomic) NSInteger selectIndex;

//计算属性.获取titlesLength的长度
@property (strong, nonatomic) NSArray *titlesLength;

//获取总的titleViewContentSize
@property (assign, nonatomic) NSInteger titleContentSizeW;

/**
 只针对titleView总长度不超过屏宽的情况,titleView显示的样式.默认居左
 */
@property (assign, nonatomic) TitleViewStatusType titleViewType;

@end

