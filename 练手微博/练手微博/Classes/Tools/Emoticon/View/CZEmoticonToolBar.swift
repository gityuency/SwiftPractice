//
//  CZEmoticonToolBar.swift
//  POD
//
//  Created by yuency on 20/07/2017.
//  Copyright © 2017 yuency yang. All rights reserved.
//

import UIKit

@objc protocol CZEmoticonToolBarDelegate: NSObjectProtocol {

    
    /// 表情工具栏选中分组索引
    ///
    /// - Parameters:
    ///   - toolBar: 工具栏
    ///   - index: 索引
    func emoticonToolBarDidSelectedItemIndex(toolBar: CZEmoticonToolBar, index: Int)
    
}


/// 表情键盘底部工具栏
class CZEmoticonToolBar: UIView {

    
    /// 弱引用 变量 可选 代理
    weak var delegate: CZEmoticonToolBarDelegate?
    
    
    /// 选中分组的索引 
    var selectedIndex: Int = 0 {
        didSet{
            //1.取消所有的选中状态
            for btn in subviews as! [UIButton] {
                btn.isSelected = false
            }
            //2.设置 index 对应的选中状态
            (subviews[selectedIndex] as! UIButton).isSelected = true
        }
    }
    
    
    override func awakeFromNib() {
        
        setupUI()
    }
    
    
    /// 布局所有按钮
    override func layoutSubviews() {
        super.layoutSubviews() //要调用父类
        
        let count = subviews.count
        
        let w = bounds.width / CGFloat(count)
        
        let rect = CGRect(x: 0, y: 0, width: w, height: bounds.height)
        
        for (i, btn) in subviews.enumerated() {
            
            btn.frame = rect.offsetBy(dx: CGFloat(i) * w, dy: 0)
        }
    }
    
    func setupUI() -> Void {
        //获取表情包管理单例
        let manager = CZEmoticonManager.shared
        
        //从表情包的分组 设置按钮
        for (i, p) in manager.packages.enumerated() {
            
            let btn = UIButton()
            
            btn.setTitle(p.groupName, for: [])
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            //按钮标题
            btn.setTitleColor(UIColor.white, for: [])
            btn.setTitleColor(UIColor.darkGray, for: .highlighted)
            btn.setTitleColor(UIColor.darkGray, for: .selected)
            //按钮图片
            let imageName = "compose_emotion_table_\(p.bgImageName ?? "")_normal"
            let imageNameHL = "compose_emotion_table_\(p.bgImageName ?? "")_selected"
            var image = UIImage(named: imageName, in: manager.bundel, compatibleWith: nil)
            var imageHL = UIImage(named: imageNameHL, in: manager.bundel, compatibleWith: nil)

            //拉伸图像
            let size = image?.size ?? CGSize()
            let inset = UIEdgeInsets(top: size.height * 0.5, left: size.width * 0.5, bottom: size.height * 0.5, right: size.width * 0.5)
            image = image?.resizableImage(withCapInsets: inset)
            imageHL = imageHL?.resizableImage(withCapInsets: inset)
            
            //设置按钮的背景图片
            btn.setBackgroundImage(image, for: [])
            btn.setBackgroundImage(imageHL, for: .highlighted)
            btn.setBackgroundImage(imageHL, for: .selected)
            
            btn.sizeToFit()
            addSubview(btn)
            
            //设置按钮的 tag
            btn.tag = i
            
            //事件
            btn.addTarget(self, action: #selector(clickItem(button:)), for: .touchUpInside)
        }
        
        //默认选中第0个按钮
        (subviews[0] as! UIButton).isSelected = true
    }
    
    
    
    // MARK: - 点击分组项按钮 
    @objc private func clickItem(button: UIButton) {
        //通知代理执行协议方法
        delegate?.emoticonToolBarDidSelectedItemIndex(toolBar: self, index: button.tag)
    
    }
    
    
}
