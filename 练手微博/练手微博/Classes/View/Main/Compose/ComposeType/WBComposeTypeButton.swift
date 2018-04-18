//
//  WBComposeTypeButton.swift
//  练手微博
//
//  Created by yuency on 17/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit


/// UIControl 内置了 touchiupinside 事件
class WBComposeTypeButton: UIControl {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    //点击按钮要展现的控制器的类型
    var clsName: String?
    
    /// 使用 图像名称/标题 创建按钮, 按钮从 XIB 创建
    class func composeTypeButton(imageName: String, title: String) -> WBComposeTypeButton {
        
        let nib = UINib(nibName: "WBComposeTypeButton", bundle: nil)
        let btn = nib.instantiate(withOwner: nil, options: nil)[0] as! WBComposeTypeButton
        
        btn.imageView.image = UIImage(named: imageName)
        btn.titleLabel.text = title
        
        return btn
    }
    

}
