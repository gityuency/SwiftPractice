//
//  WBWelcomeView.swift
//  练手微博
//
//  Created by yuency on 10/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit
import SDWebImage
class WBWelcomeView: UIView {
    
    
    //    override init(frame: CGRect) {
    //        super.init(frame: frame)
    //        backgroundColor = UIColor.blue
    //    }
    //
    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var bottomCons: NSLayoutConstraint!
    
    //从 XIB 加载,上面的那些函数就都不要了 写一个类方法   使用类名直接调用
    class func welcomeView() -> WBWelcomeView {
        
        let nib = UINib(nibName: "WBWelcomeView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBWelcomeView //后面写[0] 就不需要解包了
        
        //从 XIB 加载的视图,view 默认的是 600 * 600,不然界面会拉伸 因为这个 XIB 最外层没有参照的东西
        v.frame = UIScreen.main.bounds
        
        return v
    }
    
    
    /// 设置头像, 从 XIB 中设置头像
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //只是刚刚从 XIB 的二进制文件将数据加载完成, 
        //没有和代码连线, 建立联系, 开发不要在这个方法中处理 UI
        print("aDecoder + \(iconView)")  // nil
        
    }
    
    // 在这个函数中可以处理 UI
    override func awakeFromNib() {
        
        guard let urlString = WBNetworkManager.shared.userAccount.avatar_large,
            let url = URL(string: urlString) else {
                return
        }
        
        //设置头像 - 如果不指定站位头像,. 之前设置的头像会被清空
        iconView.sd_setImage(with: url, placeholderImage: UIImage(named: "avatar_default_big"))

        //在 XIB keypath 中设置了圆角
        // 在这个里面需要注意控件的尺寸是否已经设置 如果没有设置的话是这里赋值将会无效
        //self.layer.cornerRadius = iconView.bounds.width * 0.5
        //self.layer.masksToBounds = true
        
        //clioToBounds 是 View 的
        //maskToBounds 是 layer 的
        
    }
    
    
    /// 自动布局系统更新完成约束后,会自动调用这个方法
    //    override func layoutSubviews() {
    //        //通常是对子视图布局进行修改
    //    }
    
    
    /// 视图被添加到 Window上表示视图已经显示, 但是这时候, frame 还没有计算好
    override func didMoveToWindow() {
        
        //视图是使用自动布局来设置的, 只是设置了约束
        //- 当视图被添加到窗口的时候,根据父视图的大小,计算约束值,更新控件的位置
        //- layoutIfNeeded 会直接按照当前的约束直接更新控件的位置, 执行之后,控件所在的位置,就是 XIB 中布局的位置
        self.layoutIfNeeded()
        
        
        bottomCons.constant = bounds.size.height - 200
        
        
        //如果控件们的 frame 还没有计算好, 所有的约束会一起动画!!!!
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            
            //更新约束
            self.layoutIfNeeded()
            
        }) { (_) in
            
            UIView.animate(withDuration: 1.0, animations: {
                self.tipLabel.alpha = 1
            }, completion: { (_) in
                //移除自己
                self.removeFromSuperview()
            })
            
        }
    }
    
    
    
}
