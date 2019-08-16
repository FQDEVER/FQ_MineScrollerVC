//
//  FQ_MineScrollerVC.m
//  FQ_MineScrollerVC
//
//  Created by mac on 2017/7/10.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "FQ_MineScrollerVC.h"
#import "FQ_LineColorView.h"

@implementation FQ_ScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.contentOffset.x <= 0) {
        if ([otherGestureRecognizer.delegate isKindOfClass:NSClassFromString(@"FQ_ScrollView")]) {
            return YES;
        }
    }
    return NO;
}

@end


@interface FQ_MineScrollerBtn()

@property (nonatomic, strong) CALayer *redView;

@property (nonatomic, assign) CGFloat progress;

@end

@implementation FQ_MineScrollerBtn

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self creatRedDot];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
        [self creatRedDot];
    }
    return self;
}

-(void)creatRedDot{
    //新建小红点
    self.redView = [[CALayer alloc]init];
    self.redView.cornerRadius = 4;
    self.redView.masksToBounds = YES;
    self.redView.backgroundColor = [UIColor redColor].CGColor;
    self.redView.frame = CGRectMake(0, 0, 8, 8);
    [self.layer addSublayer:self.redView];
    self.redView.hidden = YES;
    if (self.selected) {
        self.titleLabel.font = self.selectFont;
    }else{
        self.titleLabel.font = self.normalFont;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect titleRect = self.titleLabel.frame;
    
    CGFloat titleRectH = titleRect.size.height;
    
    CGFloat titleRectY = titleRect.origin.y;
    
    CGFloat titleRectMaxX = CGRectGetMaxX(titleRect);
    
    self.redView.frame = CGRectMake(titleRectMaxX + 4, (titleRectH - 8) * 0.5 + titleRectY, 8, 8);
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    //因为文本需要变大变小.重新设置font.所以在设置select的时候.只有进度完成时/或未开始时设定
    if (self.progress == 0 || self.progress == 1) {
        if (selected) {
            self.titleLabel.font = self.selectFont;
        }else{
            self.titleLabel.font = self.normalFont;
        }
    }
}

-(void)setIsShowRedDot:(BOOL)isShowRedDot
{
    _isShowRedDot = isShowRedDot;
    
    self.redView.hidden = !isShowRedDot;
}

/**
 更新字体的大小
 
 @param progress 进度判断
 @param isAdd 是否增大
 */
-(void)changeFontWithOffset:(CGFloat)progress isAdd:(BOOL)isAdd
{
    _progress = progress;
    CGFloat selFontSize = [self.selectFont pointSize];
    CGFloat norFontSize = [self.normalFont pointSize];
    NSString *selFontName = [self.selectFont fontName];
    NSString *norFontName = [self.normalFont fontName];
    CGFloat offFont = selFontSize - norFontSize;
    UIFont *tempFont = [UIFont systemFontOfSize:15];
    
    if (isAdd) {
        if(self.selected){
            tempFont = [UIFont fontWithName:selFontName size:norFontSize + offFont * progress];
        }else{
            tempFont = [UIFont fontWithName:norFontName size:norFontSize + offFont * progress];
        }
    }else{
        
        if(self.selected){
            tempFont = [UIFont fontWithName:selFontName size:selFontSize - offFont * progress];
        }else{
            tempFont = [UIFont fontWithName:norFontName size:selFontSize - offFont * progress];
        }
    }
    
    if (self.selected && progress == 1) {
        self.titleLabel.font = self.selectFont;
    }else if (!self.selected && progress == 1){
        self.titleLabel.font = self.normalFont;
    }else{
        self.titleLabel.font = tempFont;
    }
}

@end

@interface FQ_MineScrollerVC ()<UIScrollViewDelegate>
{
    struct {
        unsigned int enterChilderVc   :1;
        unsigned int firstEnterChilderVc :1;
        unsigned int noneFirstEnterChilderVc :1;
    }_delegateFlags;
}

//子控制器集合
@property (strong, nonatomic) FQ_ScrollView *childsView;
//标题集合.可以布局标题
@property (strong, nonatomic) FQ_ScrollView *titleView;
//拉伸选中线条样式
@property (strong, nonatomic) FQ_LineColorView *lineColorView;
//默认选中线条样式
@property (strong, nonatomic) UIView *lineView;
//添加一个分割线
@property (strong, nonatomic) UIView *separatorView;
//添加一个可变字典.纪录是否第一次进入子控制器(字典中@"0"代表未进入过.字典中@"1"代表进入过)
@property (nonatomic, strong) NSMutableDictionary *enterDataDict;
//记录那个是选中按钮
@property (nonatomic, strong) FQ_MineScrollerBtn * selectBtn;

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
            self.titleView.frame = CGRectMake(0, IS_IPHONE_X_SERIES ? 88 : 64, ScreenW, TitleViewH);
            
        }
    }
    
    NSMutableArray * titlesCenterX = [NSMutableArray array];
    for (int i = 1; i <= titleArr.count; i++) {
        
        NSNumber * titleLength = self.scrollerModel.titlesLength[i-1];
        CGFloat titleW = titleLength.floatValue + self.scrollerModel.titleMargin + marginW;
        
        if (self.scrollerModel.titleViewType == TitleViewStatusType_Full_Left || self.scrollerModel.titleViewType == TitleViewStatusType_Full_Right || self.scrollerModel.titleViewType == TitleViewStatusType_Full_Center) {
            titleW = titleLength.floatValue + self.scrollerModel.titleMargin;
        }
        BOOL isShowRed = NO;
        if (self.scrollerModel.titleRedDotArr.count > i - 1) {
            isShowRed = [self.scrollerModel.titleRedDotArr[i-1] boolValue];
        }
        
        FQ_MineScrollerBtn * titleBtn = [FQ_MineScrollerBtn buttonWithType:UIButtonTypeCustom];
        [titleBtn setTitle:titleArr[i - 1] forState:UIControlStateNormal];
        [titleBtn setTitleColor:self.scrollerModel.defaultColor forState:UIControlStateNormal];
        [titleBtn setTitleColor:self.scrollerModel.selectColor forState:UIControlStateSelected];
        titleBtn.tag = TitleBtnTag + i;
        titleBtn.selected = NO;
        titleBtn.isShowRedDot = isShowRed;
        titleBtn.frame = CGRectMake(titleBtnX, 0, titleW, titleBtnH);
        titleBtn.selectFont = self.scrollerModel.selTitleFont;
        titleBtn.normalFont = self.scrollerModel.norTitleFont;
        titleBtn.titleLabel.font = self.scrollerModel.norTitleFont;
        [titleBtn addTarget:self action:@selector(clickTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:titleBtn];
        [titlesCenterX addObject:@(titleBtn.center.x / self.titleView.contentSize.width)];
        if (self.scrollerModel.selectIndex == i - 1) {
            titleBtn.selected = YES;
            self.selectBtn = titleBtn;
        }
        titleBtnX += titleW;
    }
    
    if (self.scrollerModel.lineType == BottomLineTypeDefault || self.scrollerModel.lineType == BottomLineTypeDefault_Up) {
        
        UIView * selectView = [self.titleView viewWithTag:(self.scrollerModel.selectIndex + TitleBtnTag + 1)];
        CGFloat lineViewX = selectView.frame.origin.x;
        CGFloat lineViewW = selectView.frame.size.width;
        
        if (self.scrollerModel.lineLength) {
            lineViewX = lineViewX + (selectView.frame.size.width - self.scrollerModel.lineLength) * 0.5;
            lineViewW = self.scrollerModel.lineLength;
            self.lineView = [[UIView alloc]initWithFrame:CGRectMake(lineViewX,self.scrollerModel.lineType == BottomLineTypeDefault ? self.titleView.bounds.size.height - self.scrollerModel.lineHeight + self.scrollerModel.titleLineMargin : 0, lineViewW, self.scrollerModel.lineHeight)];
        }else{
            self.lineView = [[UIView alloc]initWithFrame:CGRectMake(lineViewX, self.scrollerModel.lineType == BottomLineTypeDefault ? self.titleView.bounds.size.height - self.scrollerModel.lineHeight + self.scrollerModel.titleLineMargin : 0, lineViewW, self.scrollerModel.lineHeight)];
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
            self.lineColorView = [[FQ_LineColorView alloc]initWithFrame:CGRectMake(0,self.titleView.bounds.size.height - 8 + self.scrollerModel.titleLineMargin, self.titleView.contentSize.width, self.scrollerModel.lineHeight) StartPoint:selectView.center startLength:self.scrollerModel.lineLength endPoint:nextView.center endLength:self.scrollerModel.lineLength Colors:self.scrollerModel.line_Scaling_colors locations:titlesCenterX];
        }else{
            //随着文字大小变化的
            self.lineColorView = [[FQ_LineColorView alloc]initWithFrame:CGRectMake(0,self.titleView.bounds.size.height - 8 + self.scrollerModel.titleLineMargin, self.titleView.contentSize.width, self.scrollerModel.lineHeight) StartPoint:selectView.center startLength:selectLength.floatValue endPoint:nextView.center endLength:nextLength.floatValue Colors:self.scrollerModel.line_Scaling_colors locations:titlesCenterX];
        }
        
        [self.titleView addSubview:self.lineColorView];
        
    }
}

-(void)creatChildView
{
    CGFloat childsViewW = ScreenW;
    CGFloat childsViewH = ScreenH - TitleViewH;
    
    NSArray * childsViewArr;
    if (self.scrollerModel.childVCArr.count > 0) {
        childsViewArr = self.scrollerModel.childVCArr;
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
                    if (self.scrollerModel.isEnterHiddenRedDot) {
                        FQ_MineScrollerBtn *btn = [self.titleView viewWithTag:(i + TitleBtnTag)];
                        btn.isShowRedDot = NO;
                    }
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
    }else if (self.scrollerModel.childViewArr.count > 0){
        childsViewArr = self.scrollerModel.childViewArr;
        for (int i = 1; i <= childsViewArr.count; i++) {
            UIView * childView = childsViewArr[i - 1];
            
            childView.frame = CGRectMake((i-1)*childsViewW, 0, childsViewW, childsViewH);
            [self.childsView addSubview:childView];
        }
    }
    self.childsView.contentSize = CGSizeMake(childsViewW * childsViewArr.count, 0);
}


-(void)creatSeparatorView{
    
    self.separatorView= [[UIView alloc]initWithFrame:CGRectZero];
    self.separatorView.backgroundColor = RGB(220.0, 220.0, 220.0);
    [self.view addSubview:self.separatorView];
}

#pragma mark ============ 关于标签处红点处理 ==========
/**
 显示标题上对应索引数组的红点
 
 @param indexArr 索引数组
 */
-(void)showRedDotWithIndexArr:(NSArray *)indexArr
{
    for (NSNumber *index in indexArr) {
        if (self.scrollerModel.titlesArr.count > index.integerValue) {
            FQ_MineScrollerBtn * btn = [self.titleView viewWithTag:(index.integerValue + TitleBtnTag + 1)];
            btn.isShowRedDot = YES;
        }
    }
}

/**
 隐藏标题上对应索引数组的红点
 
 @param indexArr 索引数组
 */
-(void)hiddenRedDotWithIndexArr:(NSArray *)indexArr
{
    for (NSNumber *index in indexArr) {
        if (self.scrollerModel.titlesArr.count > index.integerValue) {
            FQ_MineScrollerBtn * btn = [self.titleView viewWithTag:(index.integerValue + TitleBtnTag + 1)];
            btn.isShowRedDot = NO;
        }
    }
}

/**
 更新红点状态数组
 
 @param redDotArr 红点状态数组
 */
-(void)changRedDotStatusWithArr:(NSArray *)redDotArr
{
    for (int i = 0; i <redDotArr.count ; ++i) {
        NSNumber *redDotStatus = redDotArr[i];
        FQ_MineScrollerBtn * btn = [self.titleView viewWithTag:(i + TitleBtnTag + 1)];
        btn.isShowRedDot = redDotStatus.boolValue;
    }
}


#pragma mark ============ Scroller代理 ==============

-(void)mineScroller_scrollviewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offSetX = scrollView.contentOffset.x;
    if ([scrollView isEqual:self.childsView]) {
        
        NSArray * titleBtnsW = self.scrollerModel.titlesLength;
        CGFloat offSet = offSetX / ScreenW;
        NSInteger currentIndex = self.scrollerModel.selectIndex;
        NSInteger nextIndex = 0;
        if (self.scrollerModel.selectIndex <= offSet && self.scrollerModel.selectIndex < titleBtnsW.count - 1) { //则<--滑动
            nextIndex = currentIndex + 1;
        }else{
            nextIndex = currentIndex - 1;
        }
        
        if (offSet - self.scrollerModel.selectIndex >= 1) {
            currentIndex = offSet;
        }
        if (self.scrollerModel.selectIndex - offSet >= 1) {
            currentIndex = offSet;
        }
        
        CGFloat lineViewSet = [self changChildsViewWithIndex:currentIndex];
        NSInteger selectIndex = self.scrollerModel.selectIndex;
        NSNumber * selectLength = titleBtnsW[selectIndex];
        FQ_MineScrollerBtn * selectView = [self.titleView viewWithTag:(selectIndex + TitleBtnTag + 1)];
        
        NSNumber * nextLength;
        FQ_MineScrollerBtn * nextView;
        if (selectIndex + 1 > titleBtnsW.count) {
            nextLength = 0;
            nextView = nil;
        }else{
            nextLength = titleBtnsW[nextIndex];
            nextView = [self.titleView viewWithTag:(nextIndex + TitleBtnTag + 1)];
        }
        
        CGFloat progress = offSet - (int)offSet;

        CGFloat titleProgress = selectIndex < nextIndex ? progress : (1-progress);
        [selectView changeFontWithOffset:titleProgress isAdd:NO];
        [nextView changeFontWithOffset:titleProgress isAdd:YES];
        
        if (progress != 0) {
            progress = selectIndex < nextIndex ? progress : (1-progress);
        }
        
        //线是默认样式
        if (self.scrollerModel.lineType == BottomLineTypeDefault || self.scrollerModel.lineType == BottomLineTypeDefault_Up) {
            
            CGRect lineRect = self.lineView.frame;
            
            
            if (self.scrollerModel.lineLength) {
                
                CGFloat nextLineX = nextView.frame.origin.x + (nextView.frame.size.width - self.scrollerModel.lineLength) * 0.5;
                CGFloat currentLineX = selectView.frame.origin.x + (selectView.frame.size.width - self.scrollerModel.lineLength) * 0.5;
                
                lineRect.origin.x = currentLineX + (nextLineX - currentLineX) * progress;
                lineRect.size.width = self.scrollerModel.lineLength;
                
                self.lineView.frame = lineRect;
            }else{
                lineRect.origin.x = selectView.frame.origin.x + (nextView.frame.origin.x - selectView.frame.origin.x) * progress;
                
                lineRect.size.width = selectView.frame.size.width + (nextView.frame.size.width - selectView.frame.size.width) * progress;
                self.lineView.frame = lineRect;
            }
            
        }else if(self.scrollerModel.lineType == BottomLineTypeScaling){
            
            if (self.scrollerModel.lineLength) { //有值
                //固定线宽的
                [self.lineColorView setShapeLayerWithStartPoint:selectView.center startLength:self.scrollerModel.lineLength endPoint:nextView.center endLength:self.scrollerModel.lineLength andProgress:progress];
            }else{
                //随文字长度变化
                [self.lineColorView setShapeLayerWithStartPoint:selectView.center startLength:selectLength.floatValue endPoint:nextView.center endLength:nextLength.floatValue andProgress:progress];
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
    NSInteger selectIndex = scrollView.contentOffset.x / ScreenW;
    if (self.childViewControllers.count > selectIndex) {
        UIViewController*viewC = self.childViewControllers[selectIndex];
        if (_delegateFlags.enterChilderVc) {
            [_mineDelegate mineScrollerVC:self enterChilderVc:viewC];
        }
        
        if (self.scrollerModel.isEnterHiddenRedDot) {
            FQ_MineScrollerBtn *btn = [self.titleView viewWithTag:(selectIndex + 1 + TitleBtnTag)];
            btn.isShowRedDot = NO;
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
}


//滑动子控制器调用
-(CGFloat)changChildsViewWithIndex:(NSInteger)selectIndex
{
//    FQ_MineScrollerBtn * selectBtn = [self.titleView viewWithTag:(self.scrollerModel.selectIndex + 1 + TitleBtnTag)];
//    selectBtn.selected = NO;
    self.selectBtn.selected = NO;
    
    FQ_MineScrollerBtn * selBtn = [self.titleView viewWithTag:(selectIndex + 1 + TitleBtnTag)];
    selBtn.selected = YES;
    self.selectBtn = selBtn;
    self.scrollerModel.selectIndex = selectIndex;
    return selBtn.frame.origin.x;
}

//点击按钮调用
-(void)changTitleViewWithIndex:(NSInteger)selectIndex
{
//    FQ_MineScrollerBtn * selectBtn = [self.titleView viewWithTag:(self.scrollerModel.selectIndex + 1 + TitleBtnTag)];
//    selectBtn.selected = NO;
    self.selectBtn.selected = NO;
    
    FQ_MineScrollerBtn * selBtn = [self.titleView viewWithTag:(selectIndex + 1 + TitleBtnTag)];
    selBtn.selected = YES;
    self.selectBtn = selBtn;
    self.scrollerModel.selectIndex = selectIndex;
    UIViewController*viewC = self.childViewControllers[selectIndex];
    if (_delegateFlags.enterChilderVc) {
        [_mineDelegate mineScrollerVC:self enterChilderVc:viewC];
    }
    
    if ([_enterDataDict[self.scrollerModel.titlesArr[selectIndex]] integerValue] == 0) {
        if (self.scrollerModel.isEnterHiddenRedDot) {
            FQ_MineScrollerBtn *btn = [self.titleView viewWithTag:(selectIndex + 1 + TitleBtnTag)];
            btn.isShowRedDot = NO;
        }
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


-(void)clickTitleBtn:(FQ_MineScrollerBtn *)selectBtn
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
        
        _childsView = [[FQ_ScrollView alloc]initWithFrame:CGRectMake(0, TitleViewH + (IS_IPHONE_X_SERIES ? 88 : 64),ScreenW, ScreenH - TitleViewH)];
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
        _titleView = [[FQ_ScrollView alloc]initWithFrame:CGRectMake(0, IS_IPHONE_X_SERIES ? 88 : 64, ScreenW, TitleViewH)];
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
