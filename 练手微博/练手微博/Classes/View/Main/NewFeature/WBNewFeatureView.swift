//
//  WBNewFeatureView.swift
//  练手微博
//
//  Created by yuency on 10/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit


/// 新特性视图
class WBNewFeatureView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var entetButton: UIButton!
    
    /// 用户交互已经在 XIB 文件中隐藏
    @IBOutlet weak var pageControl: UIPageControl!
    
    /// 进入微博
    @IBAction func enterStatus(_ sender: UIButton) {
        
        UIView.animate(withDuration: 1.0, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    //从 XIB 加载,上面的那些函数就都不要了 写一个类方法   使用类名直接调用
    class func newFeatureView() -> WBNewFeatureView {
        
        let nib = UINib(nibName: "WBNewFeatureView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBNewFeatureView //后面写[0] 就不需要解包了
        
        //从 XIB 加载的视图,view 默认的是 600 * 600,不然界面会拉伸 因为这个 XIB 最外层没有参照的东西
        v.frame = UIScreen.main.bounds
        
        return v
    }


    override func awakeFromNib() {
        
        //如果使用自动布局设置的界面, 从 XIB 加载默认是600 * 600大小
        //添加4个图像视图
        let count = 4
        let rect = UIScreen.main.bounds
        
        for i in 0..<count {
            
            let imangeName = "new_feature_\(i + 1)"
            let iv = UIImageView(image: UIImage(named: imangeName))
            
            //设置大小
            iv.frame = rect.offsetBy(dx: CGFloat(i) * rect.width, dy: 0)
            scrollView.addSubview(iv)
        }
        
        //指定滚动视图的属性
        scrollView.contentSize = CGSize(width: CGFloat(count + 1) * rect.width, height: rect.height) // +1是为了多滚动一个屏幕
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.delegate = self
        
        //隐藏按钮
        entetButton.isHidden = true
        
        print(bounds)
    }
}


extension WBNewFeatureView: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //滚动到最后一屏,让视图删除
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        //判断是否是最后一页
        if page == scrollView.subviews.count {
            removeFromSuperview()
        }
        
        //如果是倒数第二页,显示按钮
        entetButton.isHidden = (page != scrollView.subviews.count - 1)
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //一旦滚动就隐藏按钮, 消除页面切换按钮还在显示的场合
        entetButton.isHidden = true
        
        //就散当前的偏移量  +0.5是为了让 分页控制器在过度的时候显得自然(在分页的过程中切换,而不是在页面停止的时候切换)
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width + 0.5)
     
        //设置分页控件
        pageControl.currentPage = page
        
        //分页控件的隐藏
        pageControl.isHidden = (page == scrollView.subviews.count)
    }
}

