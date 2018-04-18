//
//  WBMainViewController.swift
//  练手微博
//
//  Created by yuency yang on 27/06/2017.
//  Copyright © 2017 yuency yang. All rights reserved.
//

import UIKit
import SVProgressHUD

class WBMainViewController: UITabBarController {
    
    /// 为了添加中间那个撰写按钮,使用一个 button 来替代, 这个 button 写成懒加载
    lazy var composeButton: UIButton = UIButton.cz_imageButton("tabbar_compose_icon_add", backgroundImageName: "tabbar_compose_button")
    
    /// 弄一个定时器,定时监测未读消息的数量
    var timer: Timer?
    
    
    /// 撰写微博
    @objc func composeStatus() {
        print("撰写微博")
        // 判断是否登录
        
        //实例化视图
        let v = WBComposeTypeView.composeTypeView()
        
        //显示视图 - 这里闭包有个循环引用
        v.show {[weak v] (clsName) in
            
            guard let clsName = clsName,
            let cls = NSClassFromString(Bundle.main.nameSpaceStirng + "." + clsName) as? UIViewController.Type else {
                v?.removeFromSuperview()
                return;
            }
            let vc = cls.init()
            let nav = UINavigationController(rootViewController: vc)
            
            //让导航控制器强行更新约束 - 会直接更新所有子视图的约束
            // 开发中如果发现不希望的布局和动画混在一起,应该向前寻找,强制更新约束
            nav.view.layoutIfNeeded()
            
            self.present(nav, animated: true, completion: {
                v?.removeFromSuperview()
            })
        
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置子控制器
        setupChildControllers()
        
        //设置中间的撰写按钮
        setComposeButton()
        
        //设置时钟
        setUpTimer()
        
        
        //设置新特性视图
        setUpNewFeatureViews()
        
        //设置 tabbar 的代理
        delegate = self
        
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(userLogin(n:)), name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: nil)
        
    }
    
    
    func userLogin(n: Notification) {
        print("用户登录通知")
        
        var when = DispatchTime.now()
        
        //判断通知是否有值,有值,提示用户重新登录
        if n.object != nil {
            SVProgressHUD.setDefaultMaskType(.gradient)
            SVProgressHUD.showInfo(withStatus: "用户登录已经过期,需要重新登录")
            when = DispatchTime.now() + 2
        }
        
        DispatchQueue.main.asyncAfter(deadline: when + 1) {
            SVProgressHUD.setDefaultMaskType(.clear)
            //展现登录控制器  通常会和 UINavigationController 连用,  方便返回
            let nav = UINavigationController(rootViewController: WBOAuthViewController())
            self.present(nav, animated: true, completion: nil)
            
        }
    }
    
    
    //像这样变成了属性的东西就写 getter 和 setter
    /*
     portrait: 竖屏  肖像
     landscape: 横屏 风景画
     */
    //使用代码控制设备的方向, 可以在需要横屏的时候单独处理
    //设置支持的方向之后,当前的控制器及子控制器都会遵守这个方向
    //如果播放视频,通常都是通过 model 展现的 , 在工程配置文件中,并不强制竖屏
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
        set {
        }
    }
    
    
    deinit {
        //销毁定时器
        timer?.invalidate()
        //注销通知
        NotificationCenter.default.removeObserver(self)
    }
}



// MARK: - 新特性视图处理
extension WBMainViewController {

    
    /// 设置新特性视图
    func setUpNewFeatureViews() {
        
        //判断是否登录
        if !WBNetworkManager.shared.userLogon {
            return
        }
        
        //1.如果更新,显示新特性, 否则显示欢迎
        let v = isNewVersion ? WBNewFeatureView.newFeatureView() : WBWelcomeView.welcomeView()
        
        
        //2.添加视图
        view.addSubview(v)
        
    }
    
    
    /// 扩展中可以写计算型的属性. 不会占有存储空间  这是冒充的方法
    /// 构造函数会给属性分配空间
    /*
     版本号: 
     - 在 AppStore 中每次升级应用程序,版本号都需要增加, 不能递减
     - 组成  主版本号/ 次版本号 / 修订版本号
     - 主版本号:意味着大的修改,使用者也需要做大的适应
     - 次版本号:意味着小的修改.某些函数和方法的使用或者参数有变化
     - 修订号: 框架 / 程序 内部 bug 的修订,不会对使用者造成任何的影响
     */
    private var isNewVersion: Bool {
        
        //1.取当前的版本号 1.0.1
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        print("当前版本: \(currentVersion)")
        
        //2.取保存在`Document(iTunes 备份)`[最理想保存在用户偏好] 目录中之前的版本号
        let path: String = ("version " as NSString).cz_appendDocumentDir() //加个类型,不用考虑解包
        let sandBoxVersion = try? String(contentsOfFile: path)
        print("沙盒版本号 \(path) \(String(describing: sandBoxVersion))")
        
        //3.取当前版本号保存在沙盒 1.0.1
        try? currentVersion.write(toFile: path, atomically: true, encoding: .utf8)
        
        //4.返回两个版本号 `是否一致` new
        return currentVersion != sandBoxVersion
//        return currentVersion == sandBoxVersion
    }
    
}




// MARK: - tabbar按钮点击的代理
extension WBMainViewController: UITabBarControllerDelegate {
    
    
    /// 将要选择 tabbarItem
    ///
    /// - Parameters:
    ///   - tabBarController:
    ///   - viewController:  目标控制器
    /// - Returns: 是否切换到目标控制器
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        //获取控制器在数组中的索引
        let idx = (childViewControllers as NSArray).index(of: viewController)
        //获取当前索引,同时 idx 也是首页. 这就是重复点击了按钮
        if selectedIndex == 0 && idx == selectedIndex {
            
            print("重复点击首页 Tabbar")
            
            //拿到栈底控制器
            let nav = childViewControllers[0] as! UINavigationController
            let vc = nav.childViewControllers[0] as! WBHomeViewController
            
            vc.tableView?.setContentOffset(CGPoint(x: 0, y: -64), animated: true) //因为表格做了缩进,所以是-64,不是0
            
            //上句代码是设置表格偏移,下面是刷新表格, 这两个代码搞不好关系, 造成表格无法达到顶部. 所以在这里延迟处理
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                //刷新表格
                vc.loadData()
            })
            
            //清楚 tabbar 的消息数量
            vc.tabBarItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
            
        }
        
        return !viewController.isMember(of: UIViewController.self) //如果中间加号的那个控制器,就不进行切换
    }
    
}



///使用扩展来 扩展不可以写存储型的属性
extension WBMainViewController {
    
    /// 设置所有子控制器
    func setupChildControllers() {
        
        //获取沙盒的json 路径
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let jsonPaht = (docDir as NSString).appendingPathComponent("main.json")
        //加载 data
        var data = NSData(contentsOfFile: jsonPaht)
        //判断 data 是否有内容
        if data == nil {
            let path = Bundle.main.path(forResource: "main.json", ofType: nil)
            data = NSData(contentsOfFile: path!)
        }
        
        //从 Bundle 加载配置的 json   1.取路径  2.加载data 3.反序列化转换成数组
        guard let array = try? JSONSerialization.jsonObject(with: data! as Data, options: []) as? [[String:Any]]
            else {
                return
        }
        var arrayM = [UIViewController]()
        for dict in array! {
            arrayM.append(controller(dict: dict))
        }
        viewControllers = arrayM
    }
    
    
    private func controller(dict: [String:Any]) -> UIViewController {
        
        //取得字典内容
        guard let clsName   = dict["clsName"] as? String,
            let title     = dict["title"] as? String,
            let imageName = dict["imageName"] as? String,
            let cls = NSClassFromString(Bundle.main.nameSpaceStirng + "." + clsName) as? WBBaseViewController.Type,
            let visitorDict = dict["visitorInfo"] as? [String: String]
            else {
                return UIViewController()
        }
        
        //创建视图控制器 字符串转类
        let vc = cls.init()
        //设置文本
        vc.title = title
        //设置控制器的访客信息字典
        vc.visitorInfoDictionary = visitorDict
        //设置图片
        vc.tabBarItem.image = UIImage(named: "tabbar_" + imageName)
        vc.tabBarItem.selectedImage = UIImage(named: "tabbar_" + imageName + "_selected")?.withRenderingMode(.alwaysOriginal)
        //设置标题 改颜色可以使用 tintcolor 或者 apperance
        vc.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.orange], for: .selected)
        //系统默认是12号字体, 修改字体大小,要设置 Normal 字体大小
        vc.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: .normal)
        
        //实例化导航控制器的时候,会调用 Push 方法将 rootVC 压入栈底
        let nav = WBNavigationController(rootViewController: vc)
        return nav
    }
    
    /// 添加中间那个按钮
    func setComposeButton() {
        
        tabBar.addSubview(composeButton)
        
        //计算按钮的宽度
        let count = CGFloat(childViewControllers.count)
        let w = tabBar.bounds.width / count //在代理方法里面做了判断,这里不需要 -1了
        
        // CGRectInset 正数向内缩进,负数向外扩展
        composeButton.frame = tabBar.bounds.insetBy(dx: 2 * w, dy: 0)
        
        //设置按钮的监听方法
        composeButton.addTarget(self, action: #selector(composeStatus), for: .touchUpInside)
    }
}



// MARK: - 时钟相关的方法
extension WBMainViewController {
    
    func setUpTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer() {
        
        if !WBNetworkManager.shared.userLogon { //用户没有登录,啥也不干
            return
        }
        
        WBNetworkManager.shared.unReadCount { (count) in
            self.tabBar.items?[0].badgeValue = count > 0 ? "\(count)" : nil
            //设置 App 的 badgeNumber 从 iOS 8.0之后,要用户授权之后才能够显示
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
}



//        //现在的很多应用程序中,界面的创建都依赖网络的 json
//        let array:[[String: Any]] = [
//            ["clsName":"WBHomeViewController", "title":"首页","imageName":"home",
//             "visitorInfo":["imageName":"","message":"关注一写人,回这里看看有什么惊喜!"]
//            ],
//            ["clsName":"WBMessageViewController", "title":"消息","imageName":"message_center","visitorInfo":["imageName":"visitordiscover_image_message","message":"登陆后,别人评论你的微博,发给你的消息,都会在这里收到通知!"]
//            ],
//            ["clsName":"UIViewController"],
//            ["clsName":"WBDiscoverViewController", "title":"发现","imageName":"discover",
//             "visitorInfo":["imageName":"visitordiscover_image_message","message":"登录后,最新,最热微博尽在掌握,不再与实时潮流擦肩而过"]
//            ],
//            ["clsName":"WBProfileViewController", "title":"我","imageName":"profile",
//             "visitorInfo":["imageName":"visitordiscover_image_profile","message":"登录后,你的微博,相册,个人资料会显示在这里,展示给别人"]
//            ],
//            ]
//
//
//        //直接写入沙盒保存到 plist 测试数据格式是否正确
//        //(array as NSArray).write(toFile: "/Users/yuency/Desktop/AAAAA/demo.plist", atomically: true)
//        //数组 -> json 序列化
//        let data = try! JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted]) //漂亮的输出
//        (data as NSData).write(toFile: "/Users/yuency/Desktop/AAAAA/demo.json", atomically: true)

