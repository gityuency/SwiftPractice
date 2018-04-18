//
//  WBTitleButton.swift
//  练手微博
//
//  Created by yuency on 10/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

class WBTitleButton: UIButton {

   
    /// 重载构造函数 如果是 nil 就是 "首页" 不是 nil 就显示 昵称和箭头
    init (title: String?) {
        super.init(frame: CGRect()) //CGRectZero
        
        if title == nil {
            setTitle("首页", for: [])
        } else {
            setTitle(title! + " ", for: .normal)
            setImage(UIImage(named: "navigationbar_arrow_down"), for: .normal)
            setImage(UIImage(named: "navigationbar_arrow_up"), for: .selected)
        }
        
        //设置字体和颜色
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        setTitleColor(UIColor.darkGray, for: [])
        
        //设置大小,不然会丢失箭头
        sizeToFit()
   }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 这个代码 - 重新布局子视图
    override func layoutSubviews() {
        //如果不写下面这句. 就会怀疑人生
        super.layoutSubviews()

        guard let label = titleLabel, let imageView = imageView else {
            return
        }
        
        print("按钮布局调整 \(label) \(imageView)")
        //将 label 的 x 移动 imageview 的宽度. 将 imageview 的 x向右移动 label 的宽度
        
        //OC 中不允许直接修改内部的值, Swift 中可以直接修改
        label.frame.origin.x = 0
        imageView.frame.origin.x = label.bounds.width
        
    }
}
