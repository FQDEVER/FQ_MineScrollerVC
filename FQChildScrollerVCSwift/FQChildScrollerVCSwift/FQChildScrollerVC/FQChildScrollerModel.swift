//
//  FQChildScrollerModel.swift
//  FQChildScrollerVCSwift
//
//  Created by 星砺达 on 2020/11/9.
//

import UIKit

class FQChildScrollerModel: NSObject {

    var titlesArr : [String] = []//标题集合
    var childVCArr : [UIViewController] = [] //通过控制器实现
    var defaultColor : UIColor = UIColor.darkText//默认文本的颜色
    var selectColor : UIColor = UIColor.red//选中文本的颜色
    var selTitleFont : UIFont = UIFont.systemFont(ofSize: 14)//选中文本的字体
    var norTitleFont : UIFont = UIFont.systemFont(ofSize: 14)//默认文本的字体
    
    var titleEdgeLR : CGFloat = 40.0 //文本自身的内间距,即左右各20.
    var lineColor : UIColor = UIColor.black //线条的颜色
    var lineColors : [CGColor] = [UIColor.blue.cgColor,UIColor.orange.cgColor] //渐变颜色
    var lineLocations : [NSNumber] = []
    var lineLength : CGFloat = 0 //默认为0.则随着文字长度变化
    var lineHeight : CGFloat = 2 //线的高度.默认为2
    var titleLineMargin : CGFloat = 0 //文本与线的纵向间隙
    var selectIndex : Int = 0 //当前选中的索引
    var hasShowBgLine : Bool = false
    
    var lineType : BottomLineType = .None //底部线条的类型
    var titleViewType : TitleViewStatusType = .Left //标题布局的样式默认样式
    var titleContentSizeW : CGFloat = 0 //不用自己计算.布局的时候.直接赋值即可
    
    init(titleEdgeLR:CGFloat) {
        self.titleEdgeLR = titleEdgeLR
    }
}
