//
//  FQChildScrollerHeaderView.swift
//  FQChildScrollerVCSwift
//
//  Created by 星砺达 on 2020/11/9.
//

import UIKit


let M_ScreenW = UIScreen.main.bounds.size.width
let M_ScreenH = UIScreen.main.bounds.size.height


// 判断是否设备是iphoneX系列
func is_iPhoneXSeries() -> (Bool) {
    let boundsSize = UIScreen.main.bounds.size;
    // iPhoneX,XS
    let x_xs = CGSize(width: 375, height: 812);
    if (__CGSizeEqualToSize(boundsSize, x_xs)) {
        return true;
    }
    // iPhoneXS Max,XR
    let xsmax_xr = CGSize(width: 414, height: 896);
    if (__CGSizeEqualToSize(boundsSize, xsmax_xr)) {
        return true;
    }
    return false;
}
 
func CompareIPhoneSize(size: CGSize) -> (Bool) {
    if (!is_iPad()) {
        guard let currentSize = UIScreen.main.currentMode?.size else {
            return false;
        }
        if (__CGSizeEqualToSize(size, currentSize)) {
            return true;
        }
    }
    return false;

}

// 设备是否是iPad
func is_iPad() -> (Bool) {
    if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
        return true;
    }
    return false;
}

// 判断iPhoneX
func is_iPhoneX() -> (Bool) {
    return CompareIPhoneSize(size: CGSize(width: 1125, height: 2436));
}
 
// 判断iPhoneXS
func is_iPhoneXS() -> (Bool) {
    return CompareIPhoneSize(size: CGSize(width: 1125, height: 2436));
}
 
// 判断iPHoneXR
func is_iPhoneXR() -> (Bool) {
    return CompareIPhoneSize(size: CGSize(width: 828, height: 1792));
}
 
// 判断iPhoneXS Max
func is_iPhoneXSMax() -> (Bool) {
    return CompareIPhoneSize(size: CGSize(width: 1242, height: 2688));
}


let TitleViewH : CGFloat = 44.0
let TitleViewFontSize = 15.0
let TitleViewW = M_ScreenW - 60

let TitleBtnTag = 10000
let ChildViewTag = 20000

func RGBA(_ r : CGFloat,_ g : CGFloat,_ b : CGFloat,_ a : CGFloat) -> UIColor {
    UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}
func RGB(r : CGFloat,g : CGFloat,b : CGFloat) -> UIColor {
    RGBA(r,g,b,1.0)
}

enum BottomLineType {
    case None //无效划线
    case Default //默认在底部
    case Scaling //拉伸
    case DefaultUp //在顶部
    case BackColor //选中样式为背景色块
}

enum TitleViewStatusType {
    case Left  //内容居左.即布局在左侧
    case Right //内容居右.即布局在右侧
    case Center //内容居中.即布局在中间
    case Full   //占满屏幕宽.即根据屏宽.标题的宽.获取间隙.保障在一个屏幕内展示完.如果设定该类型.那么titleMargin内间距就会随着内容发生变化.不在是固定值
}
