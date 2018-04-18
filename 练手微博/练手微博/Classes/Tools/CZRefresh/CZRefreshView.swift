//
//  CZRefreshView.swift
//  练手微博
//
//  Created by yuency on 14/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

/// 刷新视图 负责刷新相关的 UI 显示和动画
class CZRefreshView: UIView {

    /// 刷新状态
    /*
     iOS 系统中 UIView 封装的旋转动画
     - 默认的是顺时针旋转
     - 就近原则
     - 要想实现同方向旋转,需要调整一个非常小的数字
     - 想实现360旋转. 需要核心动画 CABaseAnimaton
     */
    var refreshState: CZRefreshState = .Normal {
        didSet{
            switch refreshState {
            case .Normal:
                
                tipIcon?.isHidden = false
                indecator?.stopAnimating()
                tipLabel?.text = "继续使劲啦"
                UIView.animate(withDuration: 0.25, animations: {
                    self.tipIcon?.transform = CGAffineTransform.identity //转回之前的角度
                })
            case .Pulling:
                tipLabel?.text = "放手就刷新"
                UIView.animate(withDuration: 0.25, animations: {
                    //这里用一个非常贱的方法  - 0.001 ,这就会让苹果使用就近原则. 逆时针转回来,而不是顺时针赚\转回来
                    self.tipIcon?.transform = CGAffineTransform(rotationAngle: CGFloat.pi - 0.001)
                })
            case .WillRefresh:
                tipLabel?.text = "正在刷新中"
                //隐藏提示图标
                tipIcon?.isHidden = true
                //显示菊花
                indecator?.startAnimating()
            }
        }
    }
    
    
    /// 父视图的高度/ 为了刷新控件不需要关心当前的具体刷新视图是谁
    var parentViewHeight: CGFloat = 0
    
    /// 指示器
    @IBOutlet weak var indecator: UIActivityIndicatorView?
    
    /// 提示图标
    @IBOutlet weak var tipIcon: UIImageView?
    
    /// 提示标签
    @IBOutlet weak var tipLabel: UILabel?
    

    /// 从 XIB 里面生成的控件, 一般我们使用这样的方法让外界去加载它 
    class func refreshView() -> CZRefreshView {
        let nib = UINib(nibName: "CZMeituanRefresh", bundle: nil)  //子类继承的时候, 把上面的属性设置成为可选型,因为子类是没有这些 XIB 控件的
        return nib.instantiate(withOwner: nil, options: nil)[0] as! CZRefreshView //[0]就不用解包了
    }
    
    
}
