//
//  WBWordViewController.swift
//  练手微博
//
//  Created by yuency on 18/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit


/**
 关于文件夹的拖拽的问题
 
 1.黄色文件夹, 打包的时候, 不会建立目录, 主要保存程序文件
    - 素材不允许重名,不同文件夹下的相同文件名的文件不会再次加载,只保留第一个
 
 2.蓝色的文件夹, 打包的时候,会建立目录,可以分目录的存储素材
    - 代码文件不能放在这个目录, 在安装包里面可以看到原码, 在工程里面无法调用代码文件
    - 素材可以重名
    - 游戏的场景, background.png[草地/雪地/高山/坟墓]
    - 手机应用的换皮肤 白天/夜间模式
    - 切忌: 不要把程序文件放在蓝色的文件夹中!
  
 3.Bundle (本质就是一个文件夹), 完美融合了素材文件的拖拽保留目录, 代码文件的添加使用.
    - 代码文件会被编译掉,素材文件会存在于包中.
    - 通常用在第三方框架的素材
    - 可以按照黄色文件夹的方式拖拽,同时会保留住目录结构
    - 可以避免文件重名 logo.png
 */


class WBWordViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        // 图片附件
        let attachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "tabbar_compose_background_icon_close")   //这里弄图片
        
        
        let height = label.font.lineHeight
        attachment.bounds = CGRect(x: 0, y: -4, width: height, height: height) //如果表情没有和文字对齐,设置一个 -4
        
        //1.创建属性文本
        let imageStr = NSAttributedString(attachment: attachment)
        
        //2.可变的图文字符串
        let attrStrM = NSMutableAttributedString(string: "我")
        attrStrM.append(imageStr)
        attrStrM.append(NSAttributedString(string: "要打死你 A 561"))
        
        //3.设置 label
        label.attributedText = attrStrM
    }
    
    private func setupUI() {
        self.title = "图文混排"
        view.backgroundColor = UIColor.cz_random()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", target:  self, action: #selector(close))
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
}
