# FQ_MineScrollerVC
[![Version](https://img.shields.io/cocoapods/v/FQ_MineScrollerVC.svg?style=flat)](http://cocoapods.org/pods/FQ_MineScrollerVC)
[![License](https://img.shields.io/cocoapods/l/FQ_MineScrollerVC.svg?style=flat)](http://cocoapods.org/pods/FQ_MineScrollerVC)
[![Platform](https://img.shields.io/cocoapods/p/FQ_MineScrollerVC.svg?style=flat)](http://cocoapods.org/pods/FQ_MineScrollerVC)

###简介

1.快捷创建多控制器侧滑控制器

2.可使用pod 'FQ_MineScrollerVC'加载

###使用

     -(void)creatUI{
            //添加控制器
            FQ_MineScrollerModel * scrollerModel = [[FQ_MineScrollerModel alloc]init];
            UIViewController * dynamicVc = [[UIViewController alloc]init];
            dynamicVc.view.backgroundColor = [UIColor redColor];
            UIViewController * fansVc = [[UIViewController alloc]init];
            fansVc.view.backgroundColor = [UIColor greenColor];
            UIViewController * focusVc = [[UIViewController alloc]init];
            focusVc.view.backgroundColor = [UIColor orangeColor];
            //初始化状态
            scrollerModel.selectIndex = 0;
            scrollerModel.titlesArr = @[@"动态",@"粉丝",@"关注"];
            scrollerModel.childVCArr = @[dynamicVc,fansVc,focusVc];
            scrollerModel.lineType = BottomLineTypeScaling;
            scrollerModel.lineLength  = 15;
            scrollerModel.titleRedDotArr = @[@1,@1,@1];
            scrollerModel.isEnterHiddenRedDot = NO;
            scrollerModel.titleViewType = TitleViewStatusType_Full_Right;
            scrollerModel.selectColor = [UIColor redColor];
            scrollerModel.defaultColor = [UIColor grayColor];
            scrollerModel.titleFont = [UIFont systemFontOfSize:15];
            self.scrollerModel = scrollerModel;
            //重新布局childview
            self.childsView.frame = CGRectMake(0, NAVIGATION_HEIGHT + 44, ScreenW , ScreenH - NAVIGATION_HEIGHT - 44);
            self.childsView.contentSize = CGSizeMake(scrollerModel.titlesArr.count * ScreenW, 0);
            //重新布局titleView
            self.titleView.frame = CGRectMake(0, NAVIGATION_HEIGHT, ScreenW, 44);
            self.titleView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:self.titleView];
        }
3.相关代理回调:`<FQ_MineScrollerVCDelegate>`

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
