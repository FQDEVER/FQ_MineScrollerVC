//
//  FQ_MineScrollerVC.m
//  FQ_MineScrollerVC
//
//  Created by mac on 2017/7/10.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "FQ_MineScrollerVC.h"
#import "FQ_LineColorView.h"


#define TitleBtnTag 10000
#define ChildViewTag 20000
#define SJScreenH [UIScreen mainScreen].bounds.size.height
#define SJScrrenW [UIScreen mainScreen].bounds.size.width
#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

@interface FQ_MineScrollerVC ()<UIScrollViewDelegate>

//子控制器集合
@property (strong, nonatomic) UIScrollView *childsView;
//标题集合
@property (strong, nonatomic) UIScrollView *titleView;
//拉伸选中线条样式
@property (strong, nonatomic) FQ_LineColorView *lineColorView;
//默认选中线条样式
@property (strong, nonatomic) UIView *lineView;
//添加一个分割线
@property (strong, nonatomic) UIView *separatorView;


@end

@implementation FQ_MineScrollerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

-(void)setScrollerModel:(FQ_MineScrollerModel *)scrollerModel
{
    _scrollerModel = scrollerModel;

    [self.view addSubview:self.childsView];
    [self.view addSubview:self.titleView];
    
    [self creatTitleView];
    [self creatChildView];
    [self creatSeparatorView];
}

#pragma mark ============ 创建titleView 和 childVc ==============

-(void)creatTitleView
{
    NSArray * titleArr = self.scrollerModel.titlesArr;
    
    CGFloat titleBtnH = TitleViewH;
    
    CGFloat titleBtnX = 0;
    
    //contentsize
    CGFloat marginW = 0.0f;
    if (self.scrollerModel.titleContentSizeW < SJScrrenW) {
        marginW = (SJScrrenW - self.scrollerModel.titleContentSizeW) / titleArr.count;
        self.titleView.contentSize = CGSizeMake(SJScrrenW, TitleViewH);
    }else{
        self.titleView.contentSize = CGSizeMake(self.scrollerModel.titleContentSizeW, TitleViewH);
    }
    NSMutableArray * titlesCenterX = [NSMutableArray array];
    for (int i = 1; i <= titleArr.count; i++) {
        
        NSNumber * titleLength = self.scrollerModel.titlesLength[i-1];
        CGFloat titleW = titleLength.floatValue + TitleMargin + marginW;
        
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
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(lineViewX, self.titleView.bounds.size.height - 2, lineViewW, 2)];
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
    CGFloat childsViewW = SJScrrenW;
    CGFloat childsViewH = SJScreenH - TitleViewH;
    NSArray * childsViewArr = self.scrollerModel.childVCArr;

    for (int i = 1; i <= childsViewArr.count; i++) {
        UIViewController * Vc = childsViewArr[i - 1];
        [self addChildViewController:Vc];
        Vc.view.frame = CGRectMake((i-1)*childsViewW, 0, childsViewW, childsViewH);
        [self.childsView addSubview:Vc.view];
        
        if (self.scrollerModel.selectIndex == i - 1) {
            [self.childsView setContentOffset:CGPointMake((i - 1) * childsViewW, 0) animated:YES];
        }
    }
    self.childsView.contentSize = CGSizeMake(childsViewW * childsViewArr.count, childsViewH);
}

-(void)creatSeparatorView{
    self.separatorView= [[UIView alloc]initWithFrame:CGRectMake(0,TitleViewH - 1.5, self.titleView.contentSize.width, 1)];
    self.separatorView.backgroundColor = [UIColor grayColor];
    [self.titleView insertSubview:self.separatorView belowSubview:self.lineView];
}

#pragma mark ============ Scroller代理 ==============

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    CGFloat offSetX = scrollView.contentOffset.x;
    if ([scrollView isEqual:self.childsView]) {
        CGFloat offSet = offSetX / SJScrrenW;
        CGFloat lineViewSet = [self changChildsViewWithIndex:offSetX / SJScrrenW];
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
            lineRect.origin.x = selectView.frame.origin.x + (nextView.frame.origin.x - selectView.frame.origin.x) * (offSet - (int)offSet);
            
            lineRect.size.width = selectView.frame.size.width + (nextView.frame.size.width - selectView.frame.size.width) * (offSet - (int)offSet);
            self.lineView.frame = lineRect;
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
        if (centerX - SJScrrenW * 0.5 <= 0 ) {
            [self.titleView setContentOffset:CGPointZero animated:YES];
        }else if(self.titleView.contentSize.width - SJScrrenW * 0.5 <= centerX)
        {
            [self.titleView setContentOffset:CGPointMake(self.titleView.contentSize.width - SJScrrenW, 0) animated:YES];
        }else{
            [self.titleView setContentOffset:CGPointMake(centerX - SJScrrenW * 0.5, 0) animated:YES];
        }

        
    }
}

-(CGFloat)changChildsViewWithIndex:(NSInteger)selectIndex
{
    UIButton * selectBtn = [self.titleView viewWithTag:(self.scrollerModel.selectIndex + 1 + TitleBtnTag)];
    selectBtn.selected = NO;
    UIButton * selBtn = [self.titleView viewWithTag:(selectIndex + 1 + TitleBtnTag)];
    selBtn.selected = YES;
    self.scrollerModel.selectIndex = selectIndex;
    
    return selBtn.frame.origin.x;
}


-(void)changTitleViewWithIndex:(NSInteger)selectIndex
{
    UIButton * selectBtn = [self.titleView viewWithTag:(self.scrollerModel.selectIndex + 1 + TitleBtnTag)];
    selectBtn.selected = NO;
    
    UIButton * selBtn = [self.titleView viewWithTag:(selectIndex + 1 + TitleBtnTag)];
    selBtn.selected = YES;
    self.scrollerModel.selectIndex = selectIndex;
    
    [self.childsView setContentOffset:CGPointMake(selectIndex * SJScrrenW, 0) animated:NO];
    
}

-(void)clickTitleBtn:(UIButton *)selectBtn
{
    [self changTitleViewWithIndex:(selectBtn.tag - TitleBtnTag - 1)];
}


#pragma mark ============ 懒加载 ==============

-(UIScrollView *)childsView
{
    if (!_childsView) {
        _childsView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, TitleViewH + (KIsiPhoneX ? 88 : 64),SJScrrenW, SJScreenH - TitleViewH)];
        _childsView.backgroundColor = [UIColor blueColor];
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
        _titleView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, KIsiPhoneX ? 88 : 64, SJScrrenW, TitleViewH)];
        _titleView.backgroundColor = [UIColor whiteColor];
        _titleView.bounces = NO;
        _titleView.delegate = self;
        _titleView.showsHorizontalScrollIndicator = NO;
        _titleView.showsVerticalScrollIndicator = NO;
    }
    return _titleView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
