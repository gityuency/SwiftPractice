//
//  CZMeituanRefreshView.swift
//  练手微博
//
//  Created by yuency on 17/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

class CZMeituanRefreshView: CZRefreshView {
    
    @IBOutlet weak var buildingIconView: UIImageView!
    @IBOutlet weak var earthIconView: UIImageView!
    @IBOutlet weak var kangarooIconView: UIImageView!
    
    /// 袋鼠的变大是依据父视图的高度来计算的,定义一个属性来给袋鼠传递数据
    /// 父视图给子视图传递,定义属性   子视图给父视图传递,使用代理, block
   
    override var parentViewHeight: CGFloat {
        didSet{
            if parentViewHeight < 23 {
                return
            }

            //32 -> 126   0.1->1  最高度差 /
            var scale: CGFloat
            if parentViewHeight > 126 {
                scale = 1
            } else {
                scale = 1 - ((126 - parentViewHeight) / (126 - 23))
            }
            kangarooIconView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    

    /// 设置刷新控件的动画
    override func awakeFromNib() {
        
        /// 房子动画
        let  bImage1 = #imageLiteral(resourceName: "icon_building_loading_1")
        let  bImage2 = #imageLiteral(resourceName: "icon_building_loading_2")
        buildingIconView.image = UIImage.animatedImage(with: [bImage1,bImage2], duration: 0.5)
        
        /// 地球旋转动画
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = -2 * Double.pi //反向旋转加负号
        anim.repeatCount = MAXFLOAT
        anim.duration = 3
        anim.isRemovedOnCompletion = false
        earthIconView.layer.add(anim, forKey: nil)
        
        /// 袋鼠动画
        let  kImage1 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_1")
        let  kImage2 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_2")
        kangarooIconView.image = UIImage.animatedImage(with: [kImage1,kImage2], duration: 0.5)
        
        //设置锚点, 0~1
        kangarooIconView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        //是设置中心点
        let x = self.bounds.width * 0.5
        let y = self.bounds.height - 32
        kangarooIconView.center = CGPoint(x: x, y: y)
        //缩放
        kangarooIconView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2) //设置缩放
    }
    
}
