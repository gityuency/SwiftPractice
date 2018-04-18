//
//  CZEmotiocnTipView.swift
//  练手微博
//
//  Created by yuency on 24/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit
import pop

/// 表情选择提示视图
class CZEmotiocnTipView: UIImageView {
    
    
    /// 长按手势在点击按住晃悠的时候会频繁触发手势事件,为了不那么频繁发送事件, 记录一下表情有没有更新
    private var preEmoticon: CZEmoticon?
    
    var emoticon: CZEmoticon? {
        didSet{

            //判断表情是否变化
            if emoticon == preEmoticon {
                return
            }
            //记录当前的表情
            preEmoticon = emoticon
            
            //设置表情数据
            tipButton.setTitle(emoticon?.emoji, for: [])
            tipButton.setImage(emoticon?.image, for: [])
            
            //表情的动画 - 弹力动画的结束时间是根据速度自动计算的, 不需要也不能指定 duration
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim.fromValue = 30
            anim.toValue = 8
            anim.springBounciness = 20
            anim.springSpeed = 20
            tipButton.layer.pop_add(anim, forKey: nil)
            
            print("设置碧青")
        }
    }
    

    /// 私有控件
    private lazy var tipButton = UIButton()
    
    
    /// 构造函数
    init() {
        let bundle = CZEmoticonManager.shared.bundel
        let image = UIImage(named: "emoticon_keyboard_magnifier", in:  bundle, compatibleWith: nil)
        //[[UIImageView alloc] initWithImage:iamge] 会根据图像大小设置图像视图的大小
        super.init(image: image)
        
        //设置锚点, 定义的就是中心点..., 就不用去 cell 里面算图片的坐标了
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.2)
        
        //添加按钮
        tipButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        tipButton.frame = CGRect(x: 0, y: 8, width: 36, height: 36)
        tipButton.center.x = bounds.width * 0.5
        tipButton.setTitle("😆", for: [])
        tipButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        addSubview(tipButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
