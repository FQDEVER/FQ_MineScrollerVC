//
//  FQChildScrollerVC.swift
//  FQChildScrollerVCSwift
//
//  Created by 星砺达 on 2020/11/9.
//

import UIKit

//这里是给分类添加属性的方法
public extension UIViewController{
    private struct AssociatedKey {
        static var hasEnter: Bool = false
    }
    //记录是否有进入控制器
    var hasEnter : Bool?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKey.hasEnter) as? Bool
        }set{
            return objc_setAssociatedObject(self, &AssociatedKey.hasEnter, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

class FQChildScrollerVC: UIViewController,UIScrollViewDelegate {
    
    weak var delegate : FQChildScrollerVCDelegate?
    var scrollerModel : FQChildScrollerModel?
    var childsView : FQScrollView?
    var titlesView : UIScrollView?
    var lineColorView : FQLineColorView? //渐变下划线
    var lineView : UIView?//默认下划线
    var separatorView : UIView?//分割线
    var selectBtn : FQTitleBtn?//当前选中的按钮
    var bgLineView : UIView?//下划线底部的背景视图
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.creatUI()
    }
    
    
    func creatUI() {
        
        self.titlesView = UIScrollView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: M_ScreenW, height: TitleViewH))
        self.titlesView?.backgroundColor = UIColor.white
        self.titlesView?.bounces = false
        self.titlesView?.delegate = self
        self.titlesView?.showsHorizontalScrollIndicator = false
        self.titlesView?.showsVerticalScrollIndicator = false
        self.view.addSubview(self.titlesView!)
        self.childsView = FQScrollView.init(frame: CGRect.init(x: 0, y: self.titlesView!.frame.maxY, width: M_ScreenW, height: M_ScreenH - self.titlesView!.frame.maxY))
        self.childsView?.backgroundColor = UIColor.white
        self.childsView?.bounces = false
        self.childsView?.delegate = self
        self.childsView?.isPagingEnabled = true
        self.childsView?.showsHorizontalScrollIndicator = false
        self.childsView?.showsVerticalScrollIndicator = false
        self.view.addSubview(self.childsView!)
        self.separatorView = UIView.init(frame: CGRect.zero)
        self.separatorView?.backgroundColor = RGBA(220.0, 220.0, 220.0, 1.0)
        self.view.addSubview(self.separatorView!)
        
        self.bgLineView = UIView.init(frame: CGRect.zero)
        self.bgLineView?.backgroundColor = UIColor.gray.withAlphaComponent(0.32)
        self.titlesView?.addSubview(self.bgLineView!)
        self.initTitlesView()
        self.initChildsView()
    }
    
    func initTitlesView() {
        
        guard self.scrollerModel != nil else {
            print("请设置scrollerModel配置")
            return
        }
        
        let titleBtnH = TitleViewH
        var titleBtnX : CGFloat = 0.0
        var marginW : CGFloat = 0.0 //布局的间隙
        var lengthW : CGFloat = 0.0 //文本的总宽度
        var defaultTag = TitleBtnTag //默认的tag值
        
        if let titleArr = self.scrollerModel?.titlesArr {
            for string : String in titleArr {
                let btn : FQTitleBtn = FQTitleBtn.getCustomBtn(title: string, titleColor: self.scrollerModel!.defaultColor, font: self.scrollerModel!.norTitleFont, bgColor: UIColor.clear, hasRadius:false ,radius: 0, self, action: #selector(clickTitleBtn(_:))) as! FQTitleBtn
                btn.setTitleColor(self.scrollerModel!.selectColor, for: .selected)
                btn.norTitleColor = self.scrollerModel!.defaultColor
                btn.selTitleColor = self.scrollerModel!.selectColor
                btn.norFont = self.scrollerModel!.norTitleFont
                btn.selFont = self.scrollerModel!.selTitleFont
                btn.tag = defaultTag
                btn.sizeToFit()
                lengthW += btn.bounds.size.width
                defaultTag += 1
                self.titlesView?.addSubview(btn)
            }
            var sumW = M_ScreenW
            if self.scrollerModel?.titleViewType == TitleViewStatusType.Full {
                marginW = CGFloat((M_ScreenW - lengthW))/(CGFloat(titleArr.count) * 1.0)
            }else{
                sumW = CGFloat(titleArr.count) * self.scrollerModel!.titleEdgeLR + lengthW
                marginW = self.scrollerModel!.titleEdgeLR
                
                if sumW <= M_ScreenW {//才有居中与居右的情况
                    if self.scrollerModel?.titleViewType == TitleViewStatusType.Center{
                        titleBtnX = (M_ScreenW - sumW) * 0.5
                    }else if(self.scrollerModel?.titleViewType == TitleViewStatusType.Right){
                        titleBtnX = (M_ScreenW - sumW)
                    }else{
                        titleBtnX = 0
                    }
                }else{//否则全部都是居左的情况
                    titleBtnX = 0
                }
            }
            
            //更新其赋值为最新的内间距
            self.scrollerModel?.titleEdgeLR = marginW
            let startX = titleBtnX
            
            for index : Int in 0 ... titleArr.count {
                if let btn = self.titlesView!.viewWithTag(index + TitleBtnTag) as? UIButton {
                    btn.frame = CGRect.init(x: titleBtnX, y: 0, width: btn.bounds.size.width + marginW, height: titleBtnH)
                    titleBtnX += btn.bounds.size.width
                }
            }
            //记录总宽度
            self.scrollerModel!.titleContentSizeW = titleBtnX - startX
        }
        
        if self.scrollerModel?.titleViewType == TitleViewStatusType.Full {
            self.titlesView?.isScrollEnabled = false
        }else if(titleBtnX <= M_ScreenW){
            self.titlesView?.isScrollEnabled = false
        }else{
            self.titlesView?.isScrollEnabled = true
        }
        
        //后续将这串定义到按钮中
        self.selectBtn = (self.titlesView?.viewWithTag(self.scrollerModel!.selectIndex + TitleBtnTag) as! FQTitleBtn)
        self.selectBtn?.isSelected = true
        self.selectBtn?.titleLabel?.font = self.scrollerModel?.selTitleFont
        
        self.titlesView?.contentSize = CGSize.init(width: self.scrollerModel!.titleContentSizeW, height: 0)
        self.initLineView()
        
    }
    
    func initLineView() {
        if self.scrollerModel?.lineType == BottomLineType.Default || self.scrollerModel?.lineType == BottomLineType.DefaultUp {
            let selectBtn = self.selectBtn
            var lineViewX = selectBtn!.frame.origin.x
            var lineViewW = selectBtn!.frame.size.width
            let lineViewY = self.scrollerModel?.lineType == BottomLineType.Default ? self.titlesView!.bounds.size.height - self.scrollerModel!.lineHeight + self.scrollerModel!.titleLineMargin : 0
            
            if self.scrollerModel!.lineLength != 0 {
                lineViewX = lineViewX + ((selectBtn?.frame.size.width)! - self.scrollerModel!.lineLength) * 0.5
                lineViewW = self.scrollerModel!.lineLength
                self.lineView = UIView.init(frame: CGRect.init(x: lineViewX, y: lineViewY , width: lineViewW, height: self.scrollerModel!.lineHeight))
            }else{
                self.lineView = UIView.init(frame: CGRect.init(x: lineViewX, y: lineViewY, width: lineViewW, height: self.scrollerModel!.lineHeight))
            }
            self.lineView?.backgroundColor = self.scrollerModel?.lineColor
            self.titlesView?.addSubview(self.lineView!)
        }else if(self.scrollerModel?.lineType == BottomLineType.Scaling){
            
            let selectIndex = self.scrollerModel!.selectIndex
            let selectBtn = self.titlesView?.viewWithTag(TitleBtnTag + selectIndex)
            let nextBtn = self.titlesView?.viewWithTag(TitleBtnTag + selectIndex + 1)//可能为nil
            let selectTitleW = (selectBtn?.frame.size.width ?? 0) - self.scrollerModel!.titleEdgeLR
            let nextTitleW = (nextBtn?.frame.size.width ?? 0) - self.scrollerModel!.titleEdgeLR
            
            let lineRect = CGRect.init(x: 0, y: TitleViewH - 1 + self.scrollerModel!.titleLineMargin , width: max(self.titlesView!.contentSize.width, M_ScreenW), height: self.scrollerModel!.lineHeight)
            if self.scrollerModel!.lineLength != 0 {//有值
                
                guard nextBtn != nil else {
                    return
                }
                
                self.lineColorView = FQLineColorView.init(frame: lineRect, startPoint: selectBtn!.center, startLength: self.scrollerModel!.lineLength, endPoint: nextBtn!.center, endLength: self.scrollerModel!.lineLength, colors: self.scrollerModel!.lineColors, locations: self.scrollerModel!.lineLocations)
                
            }else{
                
                guard nextBtn != nil else {
                    return
                }
                
                self.lineColorView = FQLineColorView.init(frame: lineRect, startPoint: selectBtn!.center, startLength: selectTitleW, endPoint: nextBtn!.center, endLength: nextTitleW, colors: self.scrollerModel!.lineColors, locations: self.scrollerModel!.lineLocations)
                
            }
            self.titlesView?.addSubview(self.lineColorView!)
            
        }else if(self.scrollerModel?.lineType == BottomLineType.BackColor){
            self.lineView = UIView.init()
            self.lineView?.backgroundColor = self.scrollerModel?.lineColor
            self.lineView?.layer.cornerRadius = self.scrollerModel!.lineHeight * 0.5
            let x = self.selectBtn!.center.x - (self.scrollerModel!.lineLength != 0 ? self.scrollerModel!.lineLength : self.selectBtn!.bounds.size.width) * 0.5
            let y = (self.selectBtn!.bounds.size.height - self.scrollerModel!.lineHeight) * 0.5
            let lineW = (self.scrollerModel!.lineLength != 0 ? self.scrollerModel!.lineLength : self.selectBtn!.bounds.size.width)
            self.lineView?.frame = CGRect.init(x: x, y: y, width: lineW , height: self.scrollerModel!.lineHeight)
            self.titlesView?.insertSubview(self.lineView!, at: 0)
        }
        
        //添加背景色
        if self.scrollerModel!.hasShowBgLine {
            var bgLineRect = CGRect.zero
            if self.lineView != nil {
                bgLineRect = self.lineView!.frame
            }else{
                bgLineRect = self.lineColorView!.frame
            }
            
            let firstBtn = self.titlesView?.viewWithTag(TitleBtnTag)
            let lastBtn = self.titlesView?.viewWithTag(TitleBtnTag + self.scrollerModel!.titlesArr.count - 1)
            
            if firstBtn != nil && lastBtn != nil {
                var bgLineX : CGFloat = 0
                var bgLastMaxX : CGFloat = 0
                if self.scrollerModel!.lineLength != 0 {
                    bgLineX = firstBtn!.center.x - self.scrollerModel!.lineLength * 0.5
                    bgLastMaxX = lastBtn!.center.x + self.scrollerModel!.lineLength * 0.5
                }else{
                    bgLineX = firstBtn!.center.x - firstBtn!.frame.size.width * 0.5
                    bgLastMaxX = lastBtn!.center.x + lastBtn!.frame.size.width * 0.5
                }
                self.bgLineView?.frame = CGRect.init(x:bgLineX , y: bgLineRect.origin.y + bgLineRect.size.height * 0.5 - 0.5, width:bgLastMaxX - bgLineX, height: 1.0)
                self.titlesView?.insertSubview(self.bgLineView!, at: 0)
            }
        }
    }
    
    func initChildsView() {
        guard self.scrollerModel != nil else {
            print("请设置scrollerModel配置")
            return
        }
        guard self.scrollerModel?.childVCArr.count != 0 else{
            return
        }
        
        let childsViewW = M_ScreenW
        let childsViewH = M_ScreenH - TitleViewH
        var index = 0
        
        for vc : UIViewController in self.scrollerModel!.childVCArr {
            self.addChild(vc)
            vc.view.frame = CGRect.init(x: CGFloat(index) * childsViewW, y: 0, width: childsViewW, height: childsViewH)
            self.childsView?.addSubview(vc.view)
            
            if self.scrollerModel!.selectIndex == index {
                
                //统一在做滚动操作时更新
                self.childsView?.setContentOffset(CGPoint.init(x: CGFloat(index) * childsViewW, y: 0), animated: true)
                self.reloadChildVc(vc: vc)
            }
            index += 1
        }
        self.childsView?.contentSize = CGSize.init(width: childsViewW * CGFloat(self.scrollerModel!.childVCArr.count), height: 0)
        
    }
    
    
    /// 更新并且回调当前控制器的状态
    /// - Parameter vc: 当前控制器
    func reloadChildVc(vc : UIViewController) {
        //记录是否已进入
        self.delegate?.childScrollerVc(self, enterChildVc: vc)
        
        if vc.hasEnter == false || vc.hasEnter == nil {
            vc.hasEnter = true
            //第一次进入
            self.delegate?.childScrollerVc(self, firstEnterChilderVc: vc)
            
        }else{
            //非第一次进入
            self.delegate?.childScrollerVc(self, notFirstEnterChilderVc: vc)
        }
    }
    
    //MARK:滚动代理
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.custom_scrollviewDidScroll(scrollView:scrollView)
        let offsetX = scrollView.contentOffset.x
        var currentIndex = self.scrollerModel!.selectIndex
        guard self.scrollerModel != nil else {
            return
        }
        //做内部操作
        if scrollView == self.childsView! {
            let offset : CGFloat = offsetX / M_ScreenW
            var nextIndex = 0
            if self.scrollerModel!.selectIndex < self.scrollerModel!.titlesArr.count {
                if CGFloat(self.scrollerModel!.selectIndex) < offset {
                    nextIndex = currentIndex + 1
                }else if(CGFloat(self.scrollerModel!.selectIndex) > offset){
                    nextIndex = currentIndex - 1
                }else{
                    nextIndex = currentIndex
                }
            }
            
            //根据偏移值同步选中值
            if (offset - CGFloat(self.scrollerModel!.selectIndex) >= 1) {
                currentIndex = Int(offset)
                let titleBtn = self.titlesView!.viewWithTag(currentIndex + TitleBtnTag) as! FQTitleBtn
                self.reloadSelectBtn(sender: titleBtn)
            }
            if (CGFloat(self.scrollerModel!.selectIndex) - offset >= 1) {
                currentIndex = Int(offset)
                let titleBtn = self.titlesView!.viewWithTag(currentIndex + TitleBtnTag) as! FQTitleBtn
                self.reloadSelectBtn(sender: titleBtn)
            }
            
            let selectLength = self.selectBtn!.frame.size.width - self.scrollerModel!.titleEdgeLR
            print(nextIndex)
            guard nextIndex < self.scrollerModel!.titlesArr.count else {
                return
            }
            
            guard let nextBtn = self.titlesView!.viewWithTag(nextIndex + TitleBtnTag) as? FQTitleBtn else {
                return
            }
            
            guard self.selectBtn != nil else {
                return
            }
            
            let nextLength : CGFloat = nextBtn.frame.size.width - self.scrollerModel!.titleEdgeLR
            var progress  = offset - floor(offset)
            if floor(offset) - offset == 0 && offset != CGFloat(self.scrollerModel!.selectIndex){
                if CGFloat(self.scrollerModel!.selectIndex) - offset > 0 {//变小
                    progress = 0
                    self.reloadSelectBtn(sender: nextBtn)
                }
                
                if offset - CGFloat(self.scrollerModel!.selectIndex) > 0{
                    progress = 1
                    self.reloadSelectBtn(sender: nextBtn)
                }
            }
            
            //MARK:待处理
            let titleProgress = currentIndex < nextIndex ? progress : (1 - progress)
            if titleProgress != 0 {
                self.selectBtn?.changeTitleStatus(progress: titleProgress)
                nextBtn.changeTitleStatus(progress: 1 - titleProgress)
            }
            if progress != 0 {
                progress = currentIndex < nextIndex ? progress : (1 - progress)
            }
            
            if self.scrollerModel!.lineType == BottomLineType.Default || self.scrollerModel!.lineType == BottomLineType.DefaultUp {
                
                var lineRect = self.lineView!.frame
                if self.scrollerModel!.lineLength != 0 {
                    let nextLineX = nextBtn.frame.origin.x + (nextBtn.frame.size.width - self.scrollerModel!.lineLength) * 0.5
                    let currentLineX = self.selectBtn!.frame.origin.x + (self.selectBtn!.frame.size.width - self.scrollerModel!.lineLength) * 0.5
                    lineRect.origin.x = currentLineX + (nextLineX - currentLineX) * progress
                    lineRect.size.width = self.scrollerModel!.lineLength
                    self.lineView!.frame = lineRect
                }else{
                    lineRect.origin.x = self.selectBtn!.frame.origin.x + (nextBtn.frame.origin.x - self.selectBtn!.frame.origin.x) * progress
                    lineRect.size.width = selectBtn!.frame.size.width + (nextBtn.frame.size.width - self.selectBtn!.frame.size.width) * progress
                    self.lineView!.frame = lineRect
                }
            }else if(self.scrollerModel!.lineType == BottomLineType.Scaling){
                if self.scrollerModel!.lineLength != 0 {
                    self.lineColorView!.setShapeLayerWithStartPoint(startPoint : self.selectBtn!.center,startLength : self.scrollerModel!.lineLength,endPoint:nextBtn.center,endLength:self.scrollerModel!.lineLength,progress:progress)
                }else{
                    self.lineColorView!.setShapeLayerWithStartPoint(startPoint : self.selectBtn!.center,startLength : selectLength,endPoint:nextBtn.center,endLength:nextLength,progress:progress)
                }
            }else if(self.scrollerModel!.lineType == BottomLineType.BackColor){
                var lineRect = self.lineView!.frame
                if self.scrollerModel!.lineLength != 0 {
                    let nextLineX = nextBtn.frame.origin.x + (nextBtn.frame.size.width - self.scrollerModel!.lineLength) * 0.5
                    let currentLineX = self.selectBtn!.frame.origin.x + (self.selectBtn!.frame.size.width - self.scrollerModel!.lineLength) * 0.5
                    lineRect.origin.x = currentLineX + (nextLineX - currentLineX) * progress
                    lineRect.size.width = self.scrollerModel!.lineLength
                    self.lineView!.frame = lineRect
                }else{
                    lineRect.origin.x = self.selectBtn!.frame.origin.x + (nextBtn.frame.origin.x - self.selectBtn!.frame.origin.x) * progress
                    lineRect.size.width = selectBtn!.frame.size.width + (nextBtn.frame.size.width - self.selectBtn!.frame.size.width) * progress
                    self.lineView!.frame = lineRect
                }
            }
            
            if (self.titlesView!.contentSize.width) >= M_ScreenW {
                //保障在中间显示
                let centerX = nextBtn.center.x
                let sumTitleW = self.titlesView!.contentSize.width
                if centerX < M_ScreenW * 0.5 {
                    self.titlesView!.setContentOffset(CGPoint.zero,animated:true)
                }else if(sumTitleW - centerX - M_ScreenW * 0.5 < 0){
                    self.titlesView!.setContentOffset(CGPoint.init(x: sumTitleW - M_ScreenW, y: 0),animated:true)
                }else{
                    self.titlesView!.setContentOffset(CGPoint.init(x: centerX - M_ScreenW * 0.5, y: 0),animated:true)
                }
            }else{
                self.titlesView!.setContentOffset(CGPoint.zero,animated:true)
            }
        }
    }
    
    func changChildsViewWithIndex(selectIndex : Int) -> CGFloat {
        let selectBtn : UIButton = self.titlesView?.viewWithTag(selectIndex + TitleBtnTag) as! UIButton
        return selectBtn.frame.origin.x
    }
    
    //MARK:事件处理
    
    @objc func clickTitleBtn(_ sender : FQTitleBtn) {
        //点击了标题按钮
        self.reloadSelectBtn(sender: sender)
        //        let selectIndex = self.selectBtn!.tag - TitleBtnTag
        //        self.scrollerModel?.selectIndex = selectIndex
        self.childsView?.setContentOffset(CGPoint.init(x: CGFloat(self.scrollerModel!.selectIndex) * M_ScreenW, y: 0), animated: false)
    }
    
    func reloadSelectBtn(sender : FQTitleBtn) {
        self.selectBtn?.isSelected = false
        self.selectBtn?.changeTitleStatus(progress: 1)
        self.selectBtn = sender
        self.selectBtn?.isSelected = true
        self.selectBtn?.changeTitleStatus(progress: 0)
        self.scrollerModel!.selectIndex = self.selectBtn!.tag - TitleBtnTag
        //不用管更改.会在进度滚动的时候统一更改
        let vc : UIViewController = self.scrollerModel!.childVCArr[self.scrollerModel!.selectIndex]
        self.reloadChildVc(vc: vc)
    }
    
    
    //MARK:公开方法
    
    /**
     设置当前选中索引.会跳转到相关视图
     
     @param selectIndex 设置选中索引
     */
    func setCurrent(selectIndex:Int) {
        //        //设置当前索引.更新当前视图
        self.scrollerModel!.selectIndex = selectIndex
        let selectBtn : FQTitleBtn = self.titlesView!.viewWithTag(selectIndex + TitleBtnTag) as! FQTitleBtn
        self.reloadSelectBtn(sender: selectBtn)
        self.childsView?.setContentOffset(CGPoint.init(x: CGFloat(selectIndex) * M_ScreenW, y: 0), animated: true)
    }
    
    /**
     供子类继承并自定义
     
     @param scrollView 当前滚动scrollView
     */
    func custom_scrollviewDidScroll(scrollView : UIScrollView) {
        //子类调用使用
        
    }
    
}


protocol FQChildScrollerVCDelegate : NSObjectProtocol {
    
    
    /// 进入当前选中的控制器
    /// - Parameters:
    ///   - scrollVc: scrollerVC容器控制器
    ///   - enterChildVc: 当前选中子控制器
    func childScrollerVc(_ scrollVc : FQChildScrollerVC,enterChildVc : UIViewController)
    
    /// 第一次进入当前控制器
    /// - Parameters:
    ///   - scrollVc: scrollerVC容器控制器
    ///   - firstEnterChilderVc: firstEnterChilderVc 第一次进入的子控制器
    func childScrollerVc(_ scrollVc : FQChildScrollerVC,firstEnterChilderVc : UIViewController)
    
    /// 非第一次进入当前控制器
    /// - Parameters:
    ///   - scrollVc: scrollerVC容器控制器
    ///   - notFirstEnterChilderVc: notFirstEnterChilderVc 第一次进入的子控制器
    func childScrollerVc(_ scrollVc : FQChildScrollerVC,notFirstEnterChilderVc : UIViewController)
    
}


class FQScrollView: UIScrollView,UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        if self.contentOffset.x <= 0 {
            if otherGestureRecognizer.delegate?.isKind(of: FQScrollView.self) == true {
                return true
            }
        }
        return false
    }
    
}


class FQTitleBtn: UIButton {
    var norFont : UIFont?
    var selFont : UIFont?
    var norTitleColor : UIColor?
    var selTitleColor : UIColor?
    
    func changeTitleStatus(progress : CGFloat) {
        let currentColor = self.getCurrentColorWithProgress(startColor: selTitleColor ?? UIColor.red, endColor: norTitleColor ?? UIColor.gray, progress: progress)
        self.setTitleColor(currentColor, for: .normal)
        self.setTitleColor(currentColor, for: .selected)
        
        let norF = self.norFont?.pointSize
        let selF = self.selFont?.pointSize
        let norName = self.norFont?.familyName
        let currentF = CGFloat((selF ?? 0) - (norF ?? 0)) * (1 - progress) + (norF ?? 0)
        self.titleLabel?.font = UIFont.init(name: norName ?? UIFont.systemFont(ofSize: 10).familyName, size:currentF)
    }
    
    //MARK:获取指定颜色值
    
    func getCurrentColorWithProgress(startColor:UIColor,endColor:UIColor,progress:CGFloat) -> UIColor {
        let marginArr = self.transColorBeginColor(startColor: startColor, endColor: endColor)
        let currentColor = self.getColorWithColor(beginColor: startColor, progress: progress, marginArr: marginArr)
        return currentColor
    }
    
    func transColorBeginColor(startColor:UIColor,endColor:UIColor) -> [CGFloat] {
        let beginArr = self.getRGBDictionaryByColor(originColor: startColor)
        let endArr = self.getRGBDictionaryByColor(originColor: endColor)
        return [endArr[0] - beginArr[0],endArr[1] - beginArr[1],endArr[2] - beginArr[2]]
    }
    
    func getRGBDictionaryByColor(originColor:UIColor) -> [CGFloat] {
        var r : CGFloat = 0
        var g : CGFloat = 0
        var b : CGFloat = 0
        var a : CGFloat = 0
        originColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return [r,g,b];
    }
    
    func getColorWithColor(beginColor:UIColor,progress:CGFloat,marginArr:[CGFloat]) -> UIColor {
        let beginArr = self.getRGBDictionaryByColor(originColor: beginColor)
        let r : CGFloat = beginArr[0] + progress * marginArr[0]
        let g : CGFloat = beginArr[1] + progress * marginArr[1]
        let b : CGFloat = beginArr[2] + progress * marginArr[2]
        return UIColor.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
}

extension UIButton {
    class func getCustomBtn(title:String,titleColor:UIColor,font:UIFont,bgColor:UIColor,hasRadius:Bool,radius:CGFloat,_ target: Any?, action: Selector) -> UIButton {
        let btn = self.init(type: UIButton.ButtonType.custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(titleColor, for: .normal)
        btn.titleLabel?.font = font
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.backgroundColor = bgColor
        if hasRadius {
            btn.layer.cornerRadius = radius
            btn.layer.masksToBounds = true
        }
        return btn
    }
}

extension UILabel{
    class func getCustomLab(title:String,titleColor:UIColor,font:UIFont) -> UILabel {
        let lab = self.init()
        lab.text = title
        lab.textColor = titleColor
        lab.font = font
        return lab
    }
}

