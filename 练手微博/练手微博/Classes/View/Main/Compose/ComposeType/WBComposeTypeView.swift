//
//  WBComposeTypeView.swift
//  练手微博
//
//  Created by yuency on 17/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit
import pop

/// 撰写微博类型视图
class WBComposeTypeView: UIView {
    
    //    override init(frame: CGRect) {
    //        super.init(frame: UIScreen.main.bounds)
    //        backgroundColor = UIColor.cz_random()
    //    }
    //
    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    /// 关闭按钮约束
    @IBOutlet weak var closeButtonCenterXCons: NSLayoutConstraint!
    /// 返回按钮约束
    @IBOutlet weak var returnButtonCenterXCons: NSLayoutConstraint!
    /// 返回前一页按钮
    @IBOutlet weak var returnButton: UIButton!
    
    
    /// 滚动视图
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// 按钮数据数组
    let buttonsInfo = [["imageName": "tabbar_compose_idea", "title": "文字", "clsName": "WBComposeViewController"],
                       ["imageName": "tabbar_compose_photo", "title": "图文混排", "clsName": "WBWordViewController"],
                       ["imageName": "tabbar_compose_weibo", "title": "TextKit", "clsName": "WBTextKitViewController"],
                       ["imageName": "tabbar_compose_lbs", "title": "正则表达式", "clsName": "WBRegularExpressionViewController"],
                       ["imageName": "tabbar_compose_review", "title": "表情键盘", "clsName": "WBKeyBoardTestViewController"],
                       ["imageName": "tabbar_compose_more", "title": "更多", "actionName": "clickMore"],
                       ["imageName": "tabbar_compose_friend", "title": "好友圈"],
                       ["imageName": "tabbar_compose_wbcamera", "title": "微博相机"],
                       ["imageName": "tabbar_compose_music", "title": "音乐"],
                       ["imageName": "tabbar_compose_shooting", "title": "拍摄"]
    ]

    /// 完成回调
    private var completionBlock: ((_ clsName: String) -> ())?
    
    
    /// 实例化方法 使用了 XIB 之后,上面那两个东西就不好用了. 我们使用类方法来加载这个 XIB 作为视图
    class func composeTypeView() -> WBComposeTypeView{
        
        //从 XIB 加载完视图,就会调用 awakeFromNib
        let nib = UINib(nibName: "WBComposeTypeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBComposeTypeView
        
        //再次记住, XIB 加载的View默认是 600 * 600
        v.frame = UIScreen.main.bounds
        
        v.setUpUI()
        
        return v
    }
    
    /// 显示当前视图
    //OC 中的 block 如果当前方法不能执行, 通常使用属性记录, 在需要的时候执行
    func show(completion: @escaping (_ clsName: String?) -> ()) {
        
        //记录闭包
        completionBlock = completion
        
        //将视图添加到根视图控制器, 不要随便往 window 上添加
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        //添加视图
        vc.view.addSubview(self)
     
        
        //添加动画
        showCurrentView()
    }
    
    
    
    
    /// 这个函数里面视图只是设置了约束, 但是布局没有完成, 也就是没有 frame 全都是 0
    override func awakeFromNib() {
    }
    
    
    /// 所有的 按钮点击
    func clickButton(selectedButton: WBComposeTypeButton) {
        
        //根据contentoffset 判断当前显示的视图
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        let v = scrollView.subviews[page]

        //遍历, 选中的按钮放大. 没有选中的按钮缩小
        for (i, btn) in v.subviews.enumerated() {
            
            /// 缩放动画
            let scaleAnim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            //注意, XY 在系统中使用 CGPoint 表示, 如果要转换成 id, 需要使用 `NSValue` 包装
            let scale = (selectedButton == btn) ? 2 : 0.2
            let value = NSValue(cgPoint: CGPoint(x: scale, y: scale))
            scaleAnim.toValue = value
            scaleAnim.duration = 0.5
            btn.pop_add(scaleAnim, forKey: nil)
            
            /// 渐变动画 - 动画组
            let alphaAnim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            alphaAnim.toValue = 0.2
            alphaAnim.duration = 0.5
            btn.pop_add(alphaAnim, forKey: nil)
            
            
            // 监听最后一个动画完成就可以了
            if i == 0 {
                alphaAnim.completionBlock = { _,_ in
                    //执行回调

                    self.completionBlock?(selectedButton.clsName ?? "没有控制器名字!请检查")
                    
                }
            }
            
        }
    }
    
    
    
    /// 点击更多按钮
    func clickMore()  {
        //setContentOffset这个带动画animated
        scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width, y:0), animated: true)
        //处理底部按钮,让两个按钮分开
        returnButton.isHidden = false
        let margin = scrollView.bounds.width / 6
        closeButtonCenterXCons.constant += margin
        returnButtonCenterXCons.constant -= margin
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded() //更新约束, 做动画
        }
    }
    
    
    @IBAction func returnButton(_ sender: UIButton) {
        
        //恢复滚动视图
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        //恢复按钮
        closeButtonCenterXCons.constant = 0
        returnButtonCenterXCons.constant = 0
        
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            self.returnButton.alpha = 0
        }) { (_) in
            self.returnButton.isHidden = true
            self.returnButton.alpha = 1
        }
        
    }
    
    
    
    /// 关闭当前页面
    @IBAction func close(_ sender: UIButton) {
        
        hideButton()
    }
    
}


// MARK: - 动画方法扩展
private extension WBComposeTypeView {
    
    // 按钮退场动画
    func hideButton() {
        
        //根据contentoffset 判断当前显示的视图
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        let v = scrollView.subviews[page]
        //遍历 V 中的所有按钮
        for (i, btn) in v.subviews.enumerated().reversed() {
            
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim.fromValue = btn.center.y
            anim.toValue = btn.center.y + 350
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(v.subviews.count - i) * 0.025
            btn.layer.pop_add(anim, forKey: nil)
            
            //第0个按钮的动画是最后一个执行的
            if i == 0 {
                //手写闭包吧, 提出不出来
                anim.completionBlock = { (_,_) -> () in
                    self.hideCurrentView()
                }
            }
        }
    }
    
    
    /// 隐藏当前视图
    private func hideCurrentView() {
        let anim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.fromValue = 1
        anim.toValue = 0
        anim.duration = 0.25
        pop_add(anim, forKey: nil)
        
        //添加完成的监听方法
        anim.completionBlock = { _,_ in
            self.removeFromSuperview()
        }
    }
    
    
    /// 动画显示当前视图
    func showCurrentView() {
        
        let anim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.fromValue = 0
        anim.toValue = 1
        anim.duration = 0.25
        pop_add(anim, forKey: nil)
        
        showButtons()
    }
    
    
    /// 弹力显示所有按钮
    func showButtons() {
        
        let v = scrollView.subviews[0]
        
        for (i, btn) in v.subviews.enumerated() {
            
            //创建动画
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim.fromValue = btn.center.y + 350
            anim.toValue = btn.center.y
            anim.springBounciness = 8 //弹力系数 0-20
            anim.springSpeed = 8 //弹力速度
            
            //设置动画启动时间. 要一个一个弹
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(i) * 0.025
            
            btn.pop_add(anim, forKey: nil)
        }
    }
}



// MARK: - 这个private会让扩展中的所有东西变成私有
private extension WBComposeTypeView {
    
    func setUpUI() {
        
        //强行更新布局, 因为在这里拿不到滚动视图的 frame, 有约束变动的时候直接使用这句话来更新视图, 在动画里可以使用
        layoutIfNeeded()
        
        //向 scrollview添加视图
        let rect = scrollView.bounds
        
        let width = scrollView.bounds.width
        
        for i in 0..<2 {
            let v = UIView(frame: rect.offsetBy(dx: CGFloat(i) * width, dy: 0))
            //向视图添加按钮
            addButtons(v: v, idx: i * 6)
            //视图添加到 scrollView
            scrollView.addSubview(v)
        }
        
        //设置 ScrollVioew 的 contentsize
        scrollView.contentSize = CGSize(width: width * 2, height: 0) //垂直方向不用滚动, 直接写0就可以
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        //禁用滚动
        scrollView.isScrollEnabled = false
        
    }
    
    
    func addButtons(v: UIView, idx: Int) {
        
        //从 idx 开始,添加6个按钮
        let count = 6
        //循环创建
        for i in idx..<(idx + count) {
            
            if i >= buttonsInfo.count {
                break
            }
            
            let dict = buttonsInfo[i]
            
            guard let imageName = dict["imageName"], let title = dict["title"]  else {
                continue
            }
            
            //创建按钮
            let btn = WBComposeTypeButton.composeTypeButton(imageName: imageName, title: title)
            btn.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            v.addSubview(btn)
            
            //添加监听方法
            if let actionName = dict["actionName"] {
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            } else {
                btn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
            }
            
            //设置要展现的类名 - 不需要任何的判断,有就设置.没有就不设置
            btn.clsName = dict["clsName"]
        }
        
        
        //遍历子视图 布局按钮,
        let btnSize = CGSize(width: 100, height: 100)
        let margin = (v.bounds.width - 3 * btnSize.width) / 4
        
        for (i, btn) in v.subviews.enumerated() {
            
            let y: CGFloat = (i > 2) ? (v.bounds.height - btnSize.height) : 0
            
            let col = i % 3
            
            let x = CGFloat(col + 1) * margin + CGFloat(col) * btnSize.width
            
            btn.frame = CGRect(x: x, y: y, width: btnSize.width, height: btnSize.height)
        }
        
        
        
    }
    
    
}

/*
 //创建类型按钮
 let btn = WBComposeTypeButton.composeTypeButton(imageName: "tabbar_compose_music", title: "十一放到")
 
 btn.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
 
 addSubview(btn)
 
 
 //添加监听方法
 btn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
 
 */



