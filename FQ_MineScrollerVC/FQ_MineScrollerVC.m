//
//  FQ_MineScrollerVC.m
//  FQ_MineScrollerVC
//
//  Created by mac on 2017/7/10.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "FQ_MineScrollerVC.h"
#import "FQ_LineColorView.h"

@interface FQ_MineScrollerVC ()<UIScrollViewDelegate>
{
    struct {
        unsigned int enterChilderVc   :1;
        unsigned int firstEnterChilderVc :1;
        unsigned int noneFirstEnterChilderVc :1;
    }_delegateFlags;
}

//子控制器集合
@property (strong, nonatomic) UIScrollView *childsView;
//标题集合.可以布局标题
@property (strong, nonatomic) UIScrollView *titleView;
//拉伸选中线条样式
@property (strong, nonatomic) FQ_LineColorView *lineColorView;
//默认选中线条样式
@property (strong, nonatomic) UIView *lineView;
//添加一个分割线
@property (strong, nonatomic) UIView *separatorView;
//添加一个可变字典.纪录是否第一次进入子控制器(字典中@"0"代表未进入过.字典中@"1"代表进入过)
@property (nonatomic, strong) NSMutableDictionary *enterDataDict;

@end

@implementation FQ_MineScrollerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *))
    {
        self.childsView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

-(void)setScrollerModel:(FQ_MineScrollerModel *)scrollerModel
{
    _scrollerModel = scrollerModel;
    
    [self.view addSubview:self.childsView];
    [self.view addSubview:self.titleView];
    
    [self getEnterDataDictWithTitleArr:scrollerModel.titlesArr];
    
    [self creatTitleView];
    [self creatChildView];
//    [self creatSeparatorView];
}

-(void)setMineDelegate:(id<FQ_MineScrollerVCDelegate>)mineDelegate
{
    _mineDelegate = mineDelegate;

    _delegateFlags.enterChilderVc = [mineDelegate respondsToSelector:@selector(mineScrollerVC:enterChilderVc:)];
    _delegateFlags.firstEnterChilderVc = [mineDelegate respondsToSelector:@selector(mineScrollerVC:firstEnterChilderVc:)];
    _delegateFlags.noneFirstEnterChilderVc = [mineDelegate respondsToSelector:@selector(mineScrollerVC:noneFirstEnterChilderVc:)];
}

/**
 获取是否进入子控制器的字典数据

 @param titleStrArr 标题数据
 */
-(void)getEnterDataDictWithTitleArr:(NSArray *)titleStrArr{
    
    for (NSString * titleStr in titleStrArr) {
        [self.enterDataDict setObject:@"0" forKey:titleStr];
    }
}

#pragma mark ============ 创建titleView 和 childVc ==============

-(void)creatTitleView
{
    NSArray * titleArr = self.scrollerModel.titlesArr;
    
    CGFloat titleBtnH = TitleViewH;
    
    CGFloat titleBtnX = 0;
    
    //contentsize
    CGFloat marginW = 0.0f;

    self.titleView.contentSize = CGSizeMake(self.scrollerModel.titleContentSizeW, TitleViewH);
    //不超过屏宽的情况.重新布局titleView
    if (self.scrollerModel.titleContentSizeW < ScreenW) {
        self.titleView.contentSize = CGSizeMake(ScreenW, TitleViewH);
        if (self.scrollerModel.titleViewType == TitleViewStatusType_Full_Left) {
            titleBtnX = 0;
        }else if (self.scrollerModel.titleViewType == TitleViewStatusType_Full_Right) {
            titleBtnX = ScreenW - self.scrollerModel.titleContentSizeW;
        }else if (self.scrollerModel.titleViewType == TitleViewStatusType_Full_Center) {
            titleBtnX = (ScreenW - self.scrollerModel.titleContentSizeW) * 0.5;
        }else{
            marginW = (ScreenW - self.scrollerModel.titleContentSizeW)/titleArr.count;
            self.titleView.frame = CGRectMake(0, IS_IPHONE_X ? 88 : 64, ScreenW, TitleViewH);

        }
    }
    
    NSMutableArray * titlesCenterX = [NSMutableArray array];
    for (int i = 1; i <= titleArr.count; i++) {
        
        NSNumber * titleLength = self.scrollerModel.titlesLength[i-1];
        CGFloat titleW = titleLength.floatValue + TitleMargin + marginW;
        
        if (self.scrollerModel.titleViewType == TitleViewStatusType_Full_Left || self.scrollerModel.titleViewType == TitleViewStatusType_Full_Right || self.scrollerModel.titleViewType == TitleViewStatusType_Full_Center) {
            titleW = titleLength.floatValue + TitleMargin;
        }
        
        UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleBtn setTitle:titleArr[i - 1] forState:UIControlStateNormal];
        [titleBtn setTitleColor:self.scrollerModel.defaultColor forState:UIControlStateNormal];
        [titleBtn setTitleColor:self.scrollerModel.selectColor forState:UIControlStateSelected];
        titleBtn.tag = TitleBtnTag + i;
        titleBtn.selected = NO;
        titleBtn.frame = CGRectMake(titleBtnX, 0, titleW, titleBtnH);
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:TitleViewFontSize];
        [titleBtn addTarget:self action:@selector(clickTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:titleBtn];
        [titlesCenterX addObject:@(titleBtn.center.x / self.titleView.contentSize.width)];
        if (self.scrollerModel.selectIndex == i - 1) {
            titleBtn.selected = YES;
        }
        titleBtnX += titleW;
    }
    
    if (self.scrollerModel.lineType == BottomLineTypeDefault) {
        
        UIView * selectView = [self.titleView viewWithTag:(self.scrollerModel.selectIndex + TitleBtnTag + 1)];
        CGFloat lineViewX = selectView.frame.origin.x;
        CGFloat lineViewW = selectView.frame.size.width;
        
        if (self.scrollerModel.lineLength) {
            lineViewX = lineViewX + (selectView.frame.size.width - self.scrollerModel.lineLength) * 0.5;
            lineViewW = self.scrollerModel.lineLength;
            self.lineView = [[UIView alloc]initWithFrame:CGRectMake(lineViewX, self.titleView.bounds.size.height - 2, lineViewW, 2)];
        }else{
            self.lineView = [[UIView alloc]initWithFrame:CGRectMake(lineViewX, self.titleView.bounds.size.height - 2, lineViewW, 2)];
        }
        self.lineView.backgroundColor = self.scrollerModel.lineColor;
        [self.titleView addSubview:self.lineView];
        
    }else if(self.scrollerModel.lineType == BottomLineTypeScaling){
        
        NSArray * titleBtnsW = self.scrollerModel.titlesLength;
        NSInteger selectIndex = self.scrollerModel.selectIndex;
        NSNumber * selectLength = titleBtnsW[selectIndex];
        NSNumber * nextLength = titleBtnsW[selectIndex + 1];
        UIView * selectView = [self.titleView viewWithTag:(selectIndex + TitleBtnTag + 1)];
        UIView * nextView = [self.titleView viewWithTag:(selectIndex + TitleBtnTag + 2)];
        
        if (self.scrollerModel.lineLength) { //有值
            //固定线宽的
            self.lineColorView = [[FQ_LineColorView alloc]initWithFrame:CGRectMake(0,self.titleView.bounds.size.height - 8, self.titleView.contentSize.width, 2) StartPoint:selectView.center startLength:self.scrollerModel.lineLength endPoint:nextView.center endLength:self.scrollerModel.lineLength Colors:self.scrollerModel.line_Scaling_colors locations:titlesCenterX];
        }else{
            //随着文字大小变化的
            self.lineColorView = [[FQ_LineColorView alloc]initWithFrame:CGRectMake(0,self.titleView.bounds.size.height - 8, self.titleView.contentSize.width, 2) StartPoint:selectView.center startLength:selectLength.floatValue endPoint:nextView.center endLength:nextLength.floatValue Colors:self.scrollerModel.line_Scaling_colors locations:titlesCenterX];
        }
        
        [self.titleView addSubview:self.lineColorView];
        
    }
}

-(void)creatChildView
{
    CGFloat childsViewW = ScreenW;
    CGFloat childsViewH = ScreenH - TitleViewH;
    NSArray * childsViewArr = self.scrollerModel.childVCArr;
    
    for (int i = 1; i <= childsViewArr.count; i++) {
        UIViewController * Vc = childsViewArr[i - 1];
        [self addChildViewController:Vc];
        Vc.view.frame = CGRectMake((i-1)*childsViewW, 0, childsViewW, childsViewH);
        [self.childsView addSubview:Vc.view];
        
        if (self.scrollerModel.selectIndex == i - 1) {
            [self.childsView setContentOffset:CGPointMake((i - 1) * childsViewW, 0) animated:YES];

            if (_delegateFlags.enterChilderVc) {
                [_mineDelegate mineScrollerVC:self enterChilderVc:Vc];
            }
            
            if ([_enterDataDict[self.scrollerModel.titlesArr[i - 1]] integerValue] == 0) {
                if (_delegateFlags.firstEnterChilderVc) {
                    [_mineDelegate mineScrollerVC:self firstEnterChilderVc:Vc];
                }
                [_enterDataDict setObject:@"1" forKey:self.scrollerModel.titlesArr[i - 1]];
            }else{
                if (_delegateFlags.noneFirstEnterChilderVc) {
                    [_mineDelegate mineScrollerVC:self noneFirstEnterChilderVc:Vc];
                }
            }
        }
    }
    self.childsView.contentSize = CGSizeMake(childsViewW * childsViewArr.count, 0);
}

-(void)creatSeparatorView{

    self.separatorView= [[UIView alloc]initWithFrame:CGRectZero];
    self.separatorView.backgroundColor = RGB(220.0, 220.0, 220.0);
    [self.view addSubview:self.separatorView];    
}

#pragma mark ============ Scroller代理 ==============

-(void)mineScroller_scrollviewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offSetX = scrollView.contentOffset.x;
    if ([scrollView isEqual:self.childsView]) {
        CGFloat offSet = offSetX / ScreenW;
        CGFloat lineViewSet = [self changChildsViewWithIndex:offSetX / ScreenW];
        NSArray * titleBtnsW = self.scrollerModel.titlesLength;
        NSInteger selectIndex = self.scrollerModel.selectIndex;
        NSNumber * selectLength = titleBtnsW[selectIndex];
        UIView * selectView = [self.titleView viewWithTag:(selectIndex + TitleBtnTag + 1)];
        
        NSNumber * nextLength;
        UIView * nextView;
        if (selectIndex + 1 >= titleBtnsW.count) {
            nextLength = 0;
            nextView = nil;
        }else{
            nextLength = titleBtnsW[selectIndex + 1];
            nextView = [self.titleView viewWithTag:(selectIndex + TitleBtnTag + 2)];
        }
        
        //线是默认样式
        if (self.scrollerModel.lineType == BottomLineTypeDefault) {
            
            CGRect lineRect = self.lineView.frame;
            
            
            if (self.scrollerModel.lineLength) {
                
                CGFloat nextLineX = nextView.frame.origin.x + (nextView.frame.size.width - self.scrollerModel.lineLength) * 0.5;
                CGFloat currentLineX = selectView.frame.origin.x + (selectView.frame.size.width - self.scrollerModel.lineLength) * 0.5;
                
                lineRect.origin.x = currentLineX + (nextLineX - currentLineX) * (offSet - (int)offSet);
                lineRect.size.width = self.scrollerModel.lineLength;
                
                self.lineView.frame = lineRect;
            }else{
                lineRect.origin.x = selectView.frame.origin.x + (nextView.frame.origin.x - selectView.frame.origin.x) * (offSet - (int)offSet);
                
                lineRect.size.width = selectView.frame.size.width + (nextView.frame.size.width - selectView.frame.size.width) * (offSet - (int)offSet);
                self.lineView.frame = lineRect;
            }
            
        }else if(self.scrollerModel.lineType == BottomLineTypeScaling){
            
            if (self.scrollerModel.lineLength) { //有值
                //固定线宽的
                [self.lineColorView setShapeLayerWithStartPoint:selectView.center startLength:self.scrollerModel.lineLength endPoint:nextView.center endLength:self.scrollerModel.lineLength andProgress:(offSet - (int)offSet)];
            }else{
                //随文字长度变化
                [self.lineColorView setShapeLayerWithStartPoint:selectView.center startLength:selectLength.floatValue endPoint:nextView.center endLength:nextLength.floatValue andProgress:(offSet - (int)offSet)];
            }
            
        }
        CGFloat centerX = lineViewSet + selectView.frame.size.width * 0.5;
        if (centerX - ScreenW * 0.5 <= 0 ) {
            [self.titleView setContentOffset:CGPointZero animated:YES];
        }else if(self.titleView.contentSize.width - ScreenW * 0.5 <= centerX)
        {
            [self.titleView setContentOffset:CGPointMake(self.titleView.contentSize.width - ScreenW, 0) animated:YES];
        }else{
            [self.titleView setContentOffset:CGPointMake(centerX - ScreenW * 0.5, 0) animated:YES];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self mineScroller_scrollviewDidScroll:scrollView];
}


/**
 滑动结束调用
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"------->滑动结束调用");
    NSInteger selectIndex = scrollView.contentOffset.x / ScreenW;
    UIViewController*viewC = self.childViewControllers[selectIndex];
    if (_delegateFlags.enterChilderVc) {
        [_mineDelegate mineScrollerVC:self enterChilderVc:viewC];
    }
    
    if ([_enterDataDict[self.scrollerModel.titlesArr[selectIndex]] integerValue] == 0) {
        if (_delegateFlags.firstEnterChilderVc) {
            [_mineDelegate mineScrollerVC:self firstEnterChilderVc:viewC];
        }
        [_enterDataDict setObject:@"1" forKey:self.scrollerModel.titlesArr[selectIndex]];
    }else{
        if (_delegateFlags.noneFirstEnterChilderVc) {
            [_mineDelegate mineScrollerVC:self noneFirstEnterChilderVc:viewC];
        }
    }
}


//滑动子控制器调用
-(CGFloat)changChildsViewWithIndex:(NSInteger)selectIndex
{
    UIButton * selectBtn = [self.titleView viewWithTag:(self.scrollerModel.selectIndex + 1 + TitleBtnTag)];
    selectBtn.selected = NO;
    UIButton * selBtn = [self.titleView viewWithTag:(selectIndex + 1 + TitleBtnTag)];
    selBtn.selected = YES;
    self.scrollerModel.selectIndex = selectIndex;
    return selBtn.frame.origin.x;
}

//点击按钮调用
-(void)changTitleViewWithIndex:(NSInteger)selectIndex
{
    UIButton * selectBtn = [self.titleView viewWithTag:(self.scrollerModel.selectIndex + 1 + TitleBtnTag)];
    selectBtn.selected = NO;
    
    UIButton * selBtn = [self.titleView viewWithTag:(selectIndex + 1 + TitleBtnTag)];
    selBtn.selected = YES;
    self.scrollerModel.selectIndex = selectIndex;
    UIViewController*viewC = self.childViewControllers[selectIndex];
    if (_delegateFlags.enterChilderVc) {
        [_mineDelegate mineScrollerVC:self enterChilderVc:viewC];
    }
    
    if ([_enterDataDict[self.scrollerModel.titlesArr[selectIndex]] integerValue] == 0) {
        if (_delegateFlags.firstEnterChilderVc) {
            [_mineDelegate mineScrollerVC:self firstEnterChilderVc:viewC];
        }
        [_enterDataDict setObject:@"1" forKey:self.scrollerModel.titlesArr[selectIndex]];
    }else{
        if (_delegateFlags.noneFirstEnterChilderVc) {
            [_mineDelegate mineScrollerVC:self noneFirstEnterChilderVc:viewC];
        }
    }
    [self.childsView setContentOffset:CGPointMake(selectIndex * ScreenW, 0) animated:NO];
    
}


-(void)clickTitleBtn:(UIButton *)selectBtn
{
    [self changTitleViewWithIndex:(selectBtn.tag - TitleBtnTag - 1)];
}

-(void)setCurrentSelectIndex:(NSInteger)selectIndex
{
    [self changTitleViewWithIndex:selectIndex];
}

#pragma mark ============ 懒加载 ==============

-(UIScrollView *)childsView
{
    if (!_childsView) {

        _childsView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, TitleViewH + (IS_IPHONE_X ? 88 : 64),ScreenW, ScreenH - TitleViewH)];
        _childsView.bounces = NO;
        _childsView.pagingEnabled = YES;
        _childsView.delegate = self;
        _childsView.showsHorizontalScrollIndicator = NO;
        _childsView.showsVerticalScrollIndicator = NO;
    }
    return _childsView;
}

-(UIScrollView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, IS_IPHONE_X ? 88 : 64, ScreenW, TitleViewH)];
        _titleView.backgroundColor = [UIColor whiteColor];
        _titleView.bounces = NO;
        _titleView.delegate = self;
        _titleView.showsHorizontalScrollIndicator = NO;
        _titleView.showsVerticalScrollIndicator = NO;
    }
    return _titleView;
}

-(NSMutableDictionary *)enterDataDict
{
    if (!_enterDataDict) {
        _enterDataDict = [NSMutableDictionary dictionary];
    }
    return _enterDataDict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
