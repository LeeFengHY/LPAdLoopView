//
//  AdLoopView.swift
//  LPAdLoopView
//
//  Created by QFWangLP on 2016/10/28.
//  Copyright © 2016年 LeeFengHY. All rights reserved.
//

import UIKit

let TimeInterval = 2.0
let imageHeight:CGFloat = 200

public protocol AdLoopViewDelegate {
    
    func didTapImageOfIndex(index:Int)
}

class AdLoopView: UIView{
    
    var currentImageView: UIImageView!
    var lastImageView:    UIImageView!
    var nextImageView:    UIImageView!
    var pageIndicator:    UIPageControl!
    var timer:            Timer?
    var contentScrollView: UIScrollView!
    var imageArray:[AnyObject]! {
        
        willSet(newValue) {
            self.imageArray = newValue;
        }
        
        didSet{
            contentScrollView.isScrollEnabled = !(imageArray.count == 1)
            pageIndicator.frame = CGRect.init(x: self.frame.size.width - CGFloat(20*self.imageArray.count), y: self.frame.size.height - 30, width: 0 * CGFloat(self.imageArray.count), height: 20)
            pageIndicator.numberOfPages = self.imageArray.count
            pageIndicator.currentPageIndicatorTintColor = UIColor.blue;
        }
    }
    var urlImageArray: [String]! {
        willSet(newValue) {
           self.urlImageArray = newValue
        }
        
        didSet {
            for urlStr in self.urlImageArray {
                let urlImage = NSURL(string: urlStr)
                if urlImage == nil {break}
                let dataImage = NSData.init(contentsOf:urlImage! as URL)
                if dataImage == nil {break}
                let tempImage = UIImage.init(data: dataImage! as Data)
                if tempImage == nil {break}
                imageArray.append(tempImage!)
            }
        }
    }
    
    var indexOfCurrentImage: Int! {
        didSet {
            self.pageIndicator.currentPage = indexOfCurrentImage
        }
    }
    //MARK! 代理
    var delegate: AdLoopViewDelegate?
    //MARK: 实例
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
   
    
    convenience init(frame: CGRect, imageArray: [AnyObject]?) {
        self.init(frame:frame)
        self.imageArray = imageArray
        self.indexOfCurrentImage = 0
        configAdView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: privite method
    private func configAdView(){
        self.contentScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        contentScrollView.contentSize = CGSize.init(width: self.frame.size.width * 3, height: 0)
        contentScrollView.delegate = self
        contentScrollView.bounces = false
        contentScrollView.isPagingEnabled = true
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.isScrollEnabled = !(imageArray.count == 1)
        self.addSubview(contentScrollView)
        
        currentImageView = UIImageView()
        currentImageView.frame = CGRect.init(x: self.frame.size.width, y: 0, width: self.frame.size.width, height: imageHeight)
        currentImageView.isUserInteractionEnabled = true
        currentImageView.contentMode = UIViewContentMode.scaleAspectFill
        contentScrollView.addSubview(currentImageView)
        let imageTap = UITapGestureRecognizer.init(target: self, action: #selector(imageTapAction(tap:)))
        currentImageView.addGestureRecognizer(imageTap)
        
        lastImageView = UIImageView()
        lastImageView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: imageHeight)
        lastImageView.contentMode = UIViewContentMode.scaleAspectFill
        lastImageView.clipsToBounds = true
        contentScrollView.addSubview(lastImageView)
        
        nextImageView = UIImageView()
        nextImageView.frame = CGRect.init(x: self.frame.size.width * 2, y: 0, width: self.frame.size.width, height: imageHeight)
        nextImageView.contentMode = UIViewContentMode.scaleAspectFill
        nextImageView.clipsToBounds = true
        contentScrollView.addSubview(nextImageView)
        
        setScrollViewOfImage()
        contentScrollView.setContentOffset(CGPoint.init(x: self.frame.size.width, y: 0), animated: false)
        
        self.pageIndicator = UIPageControl()
        pageIndicator.frame =  CGRect.init(x: self.frame.size.width - CGFloat(20*imageArray.count), y: self.frame.size.height - 30, width: CGFloat(20 * imageArray.count), height: CGFloat(20))
        pageIndicator.hidesForSinglePage = true
        pageIndicator.numberOfPages = imageArray.count
        pageIndicator.backgroundColor = UIColor.clear
        pageIndicator.currentPageIndicatorTintColor = UIColor.purple
        pageIndicator.pageIndicatorTintColor = UIColor.yellow
        self.addSubview(pageIndicator)
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
    }
    
    //MARK! 设置图片
    func setScrollViewOfImage(){
        currentImageView.image = self.imageArray[self.indexOfCurrentImage] as? UIImage
        lastImageView.image = self.imageArray[getLastImageIndex(indexOfCurrentImage: indexOfCurrentImage)] as? UIImage
        nextImageView.image = self.imageArray[getNextImageIndex(indexOfCurrentImage: indexOfCurrentImage)] as? UIImage
    }
    
   func getLastImageIndex(indexOfCurrentImage index: Int) -> Int {
        var tempIdex = index - 1
        if tempIdex == -1 {
            tempIdex = self.imageArray.count - 1
        }
        return tempIdex
    }
   func getNextImageIndex(indexOfCurrentImage index:Int) -> Int {
        var tempIndex = index + 1
        if tempIndex == self.imageArray.count {
            tempIndex = 0
        }
        return tempIndex
    }
    //MARK! 图片点击事件
    func imageTapAction(tap:UITapGestureRecognizer){
        delegate?.didTapImageOfIndex(index: self.indexOfCurrentImage)
    }
    
    //MARK! 定时器事件
    func timerAction() {
       print("timer action")
        contentScrollView.setContentOffset(CGPoint.init(x: self.frame.size.width * 2, y: 0), animated: true)
    }
}
//MARK! UIScrollViewDelegate
extension AdLoopView:UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
        timer = nil
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //如果用户手动拖动到了一个整数页的位置就不会发生滑动了 所以需要判断手动调用滑动停止滑动方法
        if !decelerate {
           scrollViewDidEndDecelerating(scrollView)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        if offSet == 0 {
            self.indexOfCurrentImage = getLastImageIndex(indexOfCurrentImage: self.indexOfCurrentImage)
        }else if offSet == self.frame.size.width * 2 {
            self.indexOfCurrentImage = getNextImageIndex(indexOfCurrentImage: self.indexOfCurrentImage)
        }
        setScrollViewOfImage()
        scrollView.setContentOffset(CGPoint.init(x: self.frame.size.width , y: 0), animated: false)
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    //时间触发器 设置滑动时动画true，会触发的方法
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(contentScrollView)
    }
    
}
