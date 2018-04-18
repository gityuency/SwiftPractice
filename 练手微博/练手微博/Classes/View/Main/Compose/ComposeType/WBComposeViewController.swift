//
//  WBComposeViewController.swift
//  练手微博
//
//  Created by yuency on 17/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit
import SVProgressHUD

///撰写微博控制器
/**
 加载视图控制器的时候, 如果 XIB 和控制器同名, 默认的构造函数会优先加载 XIB
 */
class WBComposeViewController: UIViewController {
    
    /// 文本编辑视图
    @IBOutlet weak var textView: WBComposeTextView!
    /// 底部工具栏
    @IBOutlet weak var toolBar: UIToolbar!
    /// 发布按钮, 这个按钮写在了 Xib 里面,但是没有加到 XIB 的 控制器 View 里面
    @IBOutlet var sendButton: UIButton!
    /// 标题标签 在 XIB 中设置富文本换行 option + 回车 就可以换行
    /// 逐行选中文本并且设置属性
    /// 如果想要调整行间距,可以增加一个空行,设置空行的字体 lineHeihgt
    @IBOutlet var titleLabel: UILabel!
    
    /// 工具栏底部约束
    @IBOutlet weak var toolBarBottomCons: NSLayoutConstraint!
    
    
    //表情输入视图, 这里需要注意循环引用!!! 类引用了闭包, 闭包中引用了自己
    lazy var emoticonView: CZEmoticonInputView = CZEmoticonInputView.inputView {[weak self]  (em) in
        self?.textView.insertEmoticon(em: em)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        //监听键盘通知定义在 UIWindow.h 里面. 使用快捷键 command + shift + o 输入头文件名,跳进去
        //第四个参数 object: 比如页面上有两个文本框, 而只想监听指定的文本框, 就传入这个指定的文本框 object: textView1
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //关闭键盘, 写这个东西是因为如果点击了左上角"关闭"页面按钮, 键盘还会滞留在屏幕上一段时间, 消除这个尴尬的场面
        textView.resignFirstResponder()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //激活键盘 在页面出现的时候,直接激活键盘, 让用户表达他的情怀
        textView.becomeFirstResponder()
    }
    
    
    //MARK: - 键盘监听方法
    @objc private func keyboardChanged(n: Notification) {
        
        //1.目标 rect
        //可选字典的解包,在可选字典后面加?
        //结构体保存在字典里面是 NSValue
        guard let rect = (n.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (n.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            else {
                return
        }
        //2.设置底部约束的高度
        let offset = view.bounds.height - rect.origin.y
        //3.跟新底部约束
        toolBarBottomCons.constant = offset
        //4.动画更新约束
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.white
        
        
        setUpNatigationBar()
        
        setupToolBar()
        
    }
    
    
    /// 设置工具栏 (XIB 中残留的 barItem 没有清除掉,但是好像没有影响. 代码写完了就覆盖了一样.)
    private func setupToolBar() {
        
        let itemSettings = [["imageName": "compose_toolbar_picture"],
                            ["imageName": "compose_mentionbutton_background"],
                            ["imageName": "compose_trendbutton_background"],
                            ["imageName": "compose_emoticonbutton_background", "actionName": "emoticonKeyboard"],
                            ["imageName": "compose_add_background"]]
        
        //数组
        var items = [UIBarButtonItem]()
        
        //遍历数组
        for s in itemSettings {
            
            guard let imageName = s["imageName"] else {
                continue
            }
            
            let image = UIImage(named: imageName)
            let imageH = UIImage(named: imageName + "_highlighted")
            
            let btn = UIButton()
            
            btn.setImage(image, for: [])
            btn.setImage(imageH, for: .highlighted)
            
            btn.sizeToFit()
            
            //判断 actionName
            if let actionName = s["actionName"] {
                //给按钮添加监听方法
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }
            
            
            
            //追加按钮
            items.append(UIBarButtonItem(customView: btn))
            
            //追加弹簧 增加间距
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        
        //删除末尾多余的弹簧
        items.removeLast()
        //把按钮交给 ToolBar
        toolBar.items = items
    }
    
    
    /// 设置导航栏
    private func setUpNatigationBar() {
        
        //关闭按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", target:  self, action: #selector(close))
        //发送按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
        //设置标题视图
        navigationItem.titleView = titleLabel
        
        sendButton.isEnabled = false
    }
    
    
    
    /// 发布微博按钮
    @IBAction func postStatus() {
        
        //获取发送给服务器的表情微博文字
        let text = textView.emoticonText
        
        let newText = text + "BBK VIVO http://huati.weibo.com/k/vivo2000%E4%B8%87%E5%8F%8C%E6%91%84X9s?from=501"
        
        //发微博
        let image = UIImage(named: "icon_small_kangaroo_loading_1")
        WBNetworkManager.shared.postStatus(text: newText, image: image) { (result, isSuccess) in
            
            let message = isSuccess ? "发布成功" : "出错!"
            
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.showInfo(withStatus: message)
            
            if isSuccess {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { //尾随闭包
                    
                    SVProgressHUD.setDefaultStyle(.light)
                    self.close()
                }
            }
        }
    }
    
    
    /// 退出按钮
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    
    /// 切换表情键盘
    @objc private func emoticonKeyboard() {
        
        //textView.inputView 就是文本框的输入视图
        //如果使用系统默认的键盘,输入视图为 nil
        //1.测试键盘视图, - 视图的宽度可以随意指定, 出现之后就是屏幕的宽度
        //let keyboardView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 271))
        //keyboardView.backgroundColor = UIColor.blue
        
        
        //2.设置键盘视图, 如果使用了系统的键盘就用我的键盘,如果不是用的系统键盘就用系统键盘
        textView.inputView = (textView.inputView == nil) ?  emoticonView : nil
        //3.刷新键盘视图
        textView.reloadInputViews()
        
    }
}


/*
 通知: 一对多 数组存放对象 只要有注册的监听者,在注销之前,都可以收到通知    发生事件的时候,将通知发送给通知中心,通知中心再 "广播" 通知
 代理: 一对一 最后设置的代理对象有效!                                发生事件的时候,直接让代理执行协议方法
 
 代理的效率高,直接反向传值
 如果嵌套层次比较多,可以使用通知传值
 
 苹果的日常开发中,代理的使用是最多的, 通知使用较少
 */
// MARK: - 文本框代理
extension WBComposeViewController: UITextViewDelegate {
    
    /// 文本视图文字变化
    func textViewDidChange(_ textView: UITextView) {
        
        sendButton.isEnabled = textView.hasText
        
    }
}



//    /// 懒加载写发布按钮
//    lazy var sendButton: UIButton = {
//
//        let btn = UIButton()
//
//        btn.setTitle("发布", for: [])
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//
//        //设置标题颜色
//        btn.setTitleColor(UIColor.white, for: [])
//        btn.setTitleColor(UIColor.gray, for: .disabled)
//
//        //设置背景图片
//        btn.setBackgroundImage(UIImage(named: "common_button_orange"), for: [])
//        btn.setBackgroundImage(UIImage(named: "common_button_orange_highlighted"), for: .highlighted)
//        btn.setBackgroundImage(UIImage(named: "common_button_white_disable"), for: .disabled)
//
//        //设置大小
//        btn.frame = CGRect(x: 0, y: 0, width: 45, height: 35)
//
//        return btn
//    }()


