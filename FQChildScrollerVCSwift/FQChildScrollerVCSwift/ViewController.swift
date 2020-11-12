//
//  ViewController.swift
//  FQChildScrollerVCSwift
//
//  Created by 星砺达 on 2020/11/9.
//

import UIKit

extension ViewController : FQChildScrollerVCDelegate{
    func setName() {
        print("xxxx")
    }
    
    func childScrollerVc(_ scrollVc: FQChildScrollerVC, enterChildVc: UIViewController) {
        print("enterChildvc")
    }
    
    func childScrollerVc(_ scrollVc: FQChildScrollerVC, firstEnterChilderVc: UIViewController) {
        print("firstEnterChilderVc")
    }
    
    func childScrollerVc(_ scrollVc: FQChildScrollerVC, notFirstEnterChilderVc: UIViewController) {
        print("notFirstEnterChilderVc")
    }
    
    
}

class ViewController: FQChildScrollerVC {

    override func viewDidLoad() {
        self.initScrollerModel()
        super.viewDidLoad()
    }
    
    func initScrollerModel() {
        self.scrollerModel = FQChildScrollerModel.init(titleEdgeLR: 40)
        self.scrollerModel?.selectIndex = 0
        self.scrollerModel?.titlesArr = ["Charging Status","Pro Status","Charging Status","Pro Status","Charging Status","Pro Status"]
        self.scrollerModel?.childVCArr = [TestOneViewController.init(),TestTwoViewController.init(),TestOneViewController.init(),TestTwoViewController.init(),TestOneViewController.init(),TestTwoViewController.init()]
        self.scrollerModel?.lineType = BottomLineType.Scaling
        self.scrollerModel?.lineHeight = 2.0
        self.scrollerModel?.lineLength = 20.0
        self.scrollerModel?.titleLineMargin = 0
        self.scrollerModel?.titleEdgeLR = 20
        self.scrollerModel?.titleViewType = TitleViewStatusType.Center
        self.scrollerModel?.lineColor = UIColor.orange
        self.scrollerModel?.defaultColor = UIColor.gray
        self.scrollerModel?.selectColor = UIColor.red
        self.scrollerModel?.selTitleFont = UIFont.systemFont(ofSize: 14)
        self.scrollerModel?.norTitleFont = UIFont.systemFont(ofSize: 12)
        self.scrollerModel?.lineColors = [UIColor.blue.cgColor,UIColor.red.cgColor,UIColor.green.cgColor,UIColor.orange.cgColor,UIColor.gray.cgColor]
        self.scrollerModel?.lineLocations = [0,0.3,0.4,0.7,1]
        self.scrollerModel?.hasShowBgLine = false
        self.delegate = self
    
    }


}

