//
//  WBVisitorView.swift
//  练手微博
//
//  Created by yuency yang on 05/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit


/// 访客视图
class WBVisitorView: UIView {
    
    /// 使用字典设置访客视图的信息
    /// dic: [imageName / message] 如果是首页,就是 imageNanme = ""
    var visitorInfo: [String:String]? {
    
        didSet{
            guard let imageName = visitorInfo?["imageName"], let message = visitorInfo?["message"] else {
                return
            }
            tipLabel.text = message
            if imageName == "" {
                startAnimation()
                return
            }
            iconView.image = UIImage(named: imageName)
            
            //其他的控制器不需要显示小房子
            houseIconView.isHidden = true
            maskIconView.isHidden = true
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    
    //这个东西是自动提示出来的
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置界面
    private func setupUI() -> Void {
        
        //开发中能用颜色就不要用图像
        backgroundColor = UIColor.cz_color(withHex: 0xEDEDED) //背景颜色和遮罩颜色一样
        
        //1.添加控件
        addSubview(iconView)
        addSubview(maskIconView)
        addSubview(houseIconView)
        addSubview(tipLabel)
        addSubview(registerButton)
        addSubview(loginButton)
        
        //文本居中
        tipLabel.textAlignment = .center
        
        //2.取消 autoresizing
        for  v in subviews {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
        
        //3.自动布局  这就是纯代码的自动布局
        let margin: CGFloat = 20.0
        
        //图像视图
        addConstraint(NSLayoutConstraint(item: iconView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: iconView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -60))
        
        //小房子
        addConstraint(NSLayoutConstraint(item: houseIconView, attribute: .centerX, relatedBy: .equal, toItem: iconView, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: houseIconView, attribute: .centerY, relatedBy: .equal, toItem: iconView, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        //提示标签
        addConstraint(NSLayoutConstraint(item: tipLabel, attribute: .centerX, relatedBy: .equal, toItem: iconView, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: tipLabel, attribute: .top, relatedBy: .equal, toItem: iconView, attribute: .bottom, multiplier: 1.0, constant: margin))
        //设置 宽高度 的时候,toItem没有,attribute -> notAnAttribute
        addConstraint(NSLayoutConstraint(item: tipLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 236)) // 236是宽度数值,
        
        //注册按钮
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: .left, relatedBy: .equal, toItem: tipLabel, attribute: .left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: .top, relatedBy: .equal, toItem: tipLabel, attribute: .bottom, multiplier: 1.0, constant: margin))
        addConstraint(NSLayoutConstraint(item: registerButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        
        //登录按钮
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: .right, relatedBy: .equal, toItem: tipLabel, attribute: .right, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: .top, relatedBy: .equal, toItem: tipLabel, attribute: .bottom, multiplier: 1.0, constant: margin))
        addConstraint(NSLayoutConstraint(item: loginButton, attribute: .width, relatedBy: .equal, toItem: registerButton, attribute: .width, multiplier: 1.0, constant: 0)) //设置登录按钮盒注册按钮等宽
        
        //设置遮罩图像
        //views: 定义 VFL 中的控件名称和时间名称映射关系
        //metrics: 定义VFL 中()指定的常数映射关系
        let viewDic:[String:Any] = ["maskIconView":maskIconView,
                       "registerButton":registerButton]
        let metrics = ["spacing":-60]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskIconView]-0-|", options: [], metrics: nil, views: viewDic))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[maskIconView]-(spacing)-[registerButton]", options: [], metrics: metrics, views: viewDic))
    }

    ///旋转图标动画
    func startAnimation() -> Void {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = 2 * Double.pi
        animation.repeatCount = MAXFLOAT
        animation.duration = 15
        //完成之后不删除, 在点击 tabbar 切换的时候,动画就停止了, 这个属性在设置连续播放的动画时候要加上, 点击 Home 键再返回的时候,动画依然执行
        animation.isRemovedOnCompletion = false
        iconView.layer.add(animation, forKey: nil)
    }
    
    
    //MARK:-私有控件
    //懒加载属性只有调用 UIKit 控件的指定构造函数,其他的都需要指定类型 (如果都指定类型就不需要考虑这么多)
    //图像视图
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
    //蒙版视图
    private lazy var maskIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
    //小房子
    private lazy var houseIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
    //提示标签
    private lazy var tipLabel: UILabel = UILabel.cz_label(withText: "关注一些人,回这里看看有什么惊喜,关注一些人,回这里看看有什么惊喜,", fontSize: 14, color: UIColor.darkGray)
    //注册按钮
    lazy var registerButton: UIButton = UIButton.cz_textButton("注册", fontSize: 16, normalColor: UIColor.orange, highlightedColor: UIColor.black, backgroundImageName: "common_button_white_disable")
    //登录按钮
    lazy var loginButton: UIButton = UIButton.cz_textButton("登录", fontSize: 16, normalColor: UIColor.darkGray, highlightedColor: UIColor.black, backgroundImageName: "common_button_white_disable")
}


// MARK: - 设置界面
extension WBVisitorView {
    
    //    private func setupUI() -> Void {
    //    }
    
}





