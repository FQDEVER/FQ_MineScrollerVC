//
//  FQLineColorView.swift
//  FQChildScrollerVCSwift
//
//  Created by 星砺达 on 2020/11/9.
//

import UIKit

class FQLineColorView: UIView {

    var lineLayer : CAShapeLayer = CAShapeLayer.init()
    var path : UIBezierPath = UIBezierPath.init()
    var colorsLayer : CAGradientLayer = CAGradientLayer.init()
    var startPoint : CGPoint = CGPoint.zero
    var endPoint : CGPoint = CGPoint.zero
    var startLength : CGFloat = 0
    var endLength : CGFloat = 0
    var colors : [CGColor] = []
    var locations : [NSNumber] = [0,1]
    

    /// 初始化拉伸底部线条
    /// - Parameters:
    ///   - frame: 布局frame
    ///   - startPoint: 开始点
    ///   - startLength: 开始长度
    ///   - endPoint: 结束点
    ///   - endLength: 结束长度
    ///   - colors: 渐变颜色数组
    ///   - locations: 渐变颜色分段间隙
    init(frame: CGRect,startPoint:CGPoint,startLength:CGFloat,endPoint:CGPoint?,endLength:CGFloat?,colors:Array<CGColor>,locations:Array<NSNumber>) {
        guard endPoint != nil && endLength != nil else {
            //需要先实现初始化
            super.init(frame: frame)
            return
        }
        self.startPoint = startPoint
        self.endPoint = endPoint!
        self.startLength = startLength
        self.endLength = endLength!
        self.colors = colors
        self.locations = locations
        //需要先实现初始化
        super.init(frame: frame)
        //初始化相关UI
        self.creatUI()
    }
    
    func creatUI() {
        self.colorsLayer.frame = self.bounds
        self.colorsLayer.startPoint = CGPoint.init(x: 0, y: 1)
        self.colorsLayer.endPoint = CGPoint.init(x: 1, y: 1)
        self.colorsLayer.colors = self.colors
        self.colorsLayer.locations = self.locations
        self.layer.addSublayer(self.colorsLayer)
        
        self.path.move(to: CGPoint.init(x: startPoint.x - startLength * 0.5, y: self.bounds.size.height * 0.5))
        self.path.addLine(to: CGPoint.init(x: startPoint.x + startLength * 0.5, y: self.bounds.size.height * 0.5))
        
        self.lineLayer.frame = self.bounds
        self.lineLayer.lineWidth = 6.0
        self.lineLayer.path = self.path.cgPath
        self.lineLayer.lineCap = CAShapeLayerLineCap.round
        self.layer.mask = self.lineLayer
        self.lineLayer.fillColor = UIColor.clear.cgColor
        self.lineLayer.strokeColor = UIColor.black.cgColor

    }

    
    /// 通过起始点和结束点.还有线条的长度以及当前进度来更新视图
    /// - Parameters:
    ///   - startPoint: 起始中心点
    ///   - startLength: 起始线长
    ///   - endPoint: 结束时中心点
    ///   - endLength: 结束线长
    ///   - progress: 起始与结束的进度
    func setShapeLayerWithStartPoint(startPoint : CGPoint,startLength : CGFloat,endPoint:CGPoint,endLength:CGFloat,progress:CGFloat) {
        self.path.removeAllPoints()
        let hasChangBig = endPoint.x > startPoint.x
        var lineMargin = endPoint.x - startPoint.x - startLength * 0.5 - endLength * 0.5

        if hasChangBig {
            if progress < 0.5 {
                self.path.move(to: CGPoint.init(x: startPoint.x - startLength * 0.5, y: self.bounds.size.height * 0.5))
                self.path.addLine(to: CGPoint.init(x: startPoint.x + startLength * 0.5 + (lineMargin + endLength) * progress * 2.0, y: self.bounds.size.height * 0.5))
            }else{
                self.path.move(to: CGPoint.init(x: startPoint.x - startLength * 0.5 + (startLength + lineMargin) * (progress - 0.5) * 2.0, y: self.bounds.size.height * 0.5))
                self.path.addLine(to: CGPoint.init(x: endPoint.x + endLength * 0.5, y: self.bounds.size.height * 0.5))
            }
        }else{
            lineMargin = startPoint.x - endPoint.x - startLength * 0.5 - endLength * 0.5
            if progress < 0.5 {
                self.path.move(to: CGPoint.init(x: startPoint.x + startLength * 0.5, y: self.bounds.size.height * 0.5))
                self.path.addLine(to: CGPoint.init(x: startPoint.x - startLength * 0.5 - (lineMargin + endLength) * progress * 2.0, y: self.bounds.size.height * 0.5))
            }else{
                self.path.move(to: CGPoint.init(x: startPoint.x + startLength * 0.5-(startLength + lineMargin) * (progress - 0.5) * 2.0, y: self.bounds.size.height * 0.5))
                self.path.addLine(to: CGPoint.init(x: endPoint.x - endLength * 0.5, y: self.bounds.size.height * 0.5))
            }
        }
        self.lineLayer.path = self.path.cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
