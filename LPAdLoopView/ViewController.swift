//
//  ViewController.swift
//  LPAdLoopView
//
//  Created by QFWangLP on 2016/10/28.
//  Copyright © 2016年 LeeFengHY. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AdLoopViewDelegate{

    var adLoopView:AdLoopView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "广告图轮播"
        self.automaticallyAdjustsScrollViewInsets = false
        let imageArray: [AnyObject] = [UIImage(named: "first.jpg")!, UIImage(named: "second.jpg")!, UIImage(named: "third.jpg")!]
        adLoopView = AdLoopView.init(frame: CGRect.init(x: 0, y: 64, width: self.view.frame.size.width, height: 200), imageArray: imageArray)
        adLoopView.delegate = self
        self.view.addSubview(adLoopView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didTapImageOfIndex(index: Int) {
        print("currentImage idex is \(index)")
    }

}

