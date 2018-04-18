//
//  WBBaseViewController.swift
//  练手微博
//
//  Created by yuency yang on 27/06/2017.
//  Copyright © 2017 yuency yang. All rights reserved.
//

//使用扩展, 把函数按照功能分类,便于阅读和维护
/*
 extension 不能有属性
 extension 不能重写父类方法  重写父类的方法是子类干的事情,扩展是对类的扩展
 */


import UIKit

//class WBBaseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {  我们可以把遵守的协议写到扩展里面

class WBBaseViewController: UIViewController {
    
    /// 访客视图信息字典
    var visitorInfoDictionary:[String:String]?
    
    /// 表格视图 - 如果用户没有登录,就没有这个表格视图,就不创建
    var tableView: UITableView?
    //刷新控件
    var refreshControl: CZRefreshControl?
    /// 上拉刷新标记
    var isPullUp = false
    
    
    /// 使用懒加载, 自定义导航条
    lazy var navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.cz_screenWidth(), height: 64))
    ///自定义的导航条目, 以后设置导航栏的内容,统一使用 navItem
    lazy var navItem = UINavigationItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        //如果没有东西,就结束网络加载. 三目写函数, 空执行写 ()
        WBNetworkManager.shared.userLogon ? loadData() : ()
        
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: NSNotification.Name(rawValue: WBUserLoginSuccessNotification), object: nil)
        
    }
    
    
    deinit {
        //销毁通知
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 重写 title 的 setter 方法 这个方法是 View 自己带的,在UITabBarController基类里面赋值的
    override var title: String? {
        didSet {
            navItem.title = title
        }
    }
    
    
    /// 加载数据 - 具体的实现由子类负责
    func loadData() {
        //如果子类没有重写这个方法,就默认关闭刷新,就结束刷新
        refreshControl?.endRefreshing()
    }
    
    
    
}


// MARK: - 访客视图监听方法
extension WBBaseViewController {
    
    /// 登录成功处理
    func loginSuccess(n: Notification) {
        print("登录成功 \(n)")
        
        //登录前.左边是注册, 右边是登录
        navItem.leftBarButtonItem = nil
        navItem.rightBarButtonItem = nil
        
        //更新 UI : 将访客视图替换为表格视图 重新设置 View
        //在访问 view 的 getter 时.如果 view == nil 时候, 会调用 LoadView -> viewDidLoad ....... (LoadView 执行完成会走 viewDidLoad)
        view = nil
        
        //在这里需要把通知注销掉, 避免通知被重复注册
        NotificationCenter.default.removeObserver(self)
    }

    
    @objc func login() {
        //发送通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: nil)
    }
    
    @objc func register() {
        print("用户注册")
    }
    
}



// MARK: - 设置界面
extension WBBaseViewController {
    
    func setupUI() -> () {
        //设置背景色
        view.backgroundColor = UIColor.white
        //取消自动缩进,如果隐藏了导航栏,会缩进20个点
        automaticallyAdjustsScrollViewInsets = false
        //设置导航条
        setupNavigationBar()
        
        //根据状态添加不同的视图 这个三目比较吊
        WBNetworkManager.shared.userLogon ? setupTableView() : setupVisitorView()
    }
    
    
    /// 设置表格视图 用户登录之后执行 (子类不需要关注用户登录之前的逻辑)
    func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.insertSubview(tableView!, belowSubview: navigationBar) //把这个表格视图插在自定义的导航条下面
        
        //设置数据源和代理
        tableView?.dataSource = self
        tableView?.delegate = self
        
        //设置表格内容缩进,因为取消了自动缩进,因为还改写了导航栏
        tableView?.contentInset = UIEdgeInsets(top: navigationBar.bounds.height, left: 0, bottom: (tabBarController?.tabBar.bounds.height ?? 49), right: 0)
        
        
        //修改指示器的缩进 - 强行解包拿到 inset
        tableView?.scrollIndicatorInsets = tableView!.contentInset
        
        //设置刷新控件
        refreshControl = CZRefreshControl()
        tableView?.addSubview(refreshControl!)
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
    
    
    /// 设置访客视图
    func setupVisitorView() {
        let visitorView = WBVisitorView(frame: view.bounds)
        view.insertSubview(visitorView, belowSubview: navigationBar)
        
        //设置访客视图信息
        visitorView.visitorInfo = visitorInfoDictionary
        
        //添加访客视图的监听方法
        visitorView.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        visitorView.registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
        
        //设置导航条按钮
        navItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action: #selector(register))
        navItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: .plain, target: self, action: #selector(login))
        
    }
    
    
    private func setupNavigationBar() {
        //添加导航条
        view.addSubview(navigationBar)
        //将 item 设置给 bar
        navigationBar.items = [navItem]
        //设置 navBar 的渲染颜色(解决导航高亮) 设置导航条整个 背景的颜色, (20+44的颜色)
        navigationBar.barTintColor = UIColor.cz_color(withHex: 0xF6F6F6)
        // 设置 navBar 的字体颜色 navigationBar.tintColor = UIColor.darkGray  不好用
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray] //这是字典
        // 设置系统按钮文字的文字渲染颜色(UIBarButtonItem)
        navigationBar.tintColor = UIColor.orange
    }
}


// MARK: - 数据源代理方法
extension WBBaseViewController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    //基类只是准备方法,子类负责具体的实现
    //子类的数据源方法不需要 super()  这里返回只是保证没有语法错误
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 10
    }
    
    /// 在显示最后一行的时候做上拉刷新  这种刷新又叫做 `无缝` 刷新
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //1.判断 indexPath是否是最后一行 (indexPath.section 最大, indexPath.row 最后)
        let row = indexPath.row
        let section = tableView.numberOfSections - 1
        
        if row < 0 || section < 0 {
            return
        }
        
        //2.取出行数
        let count = tableView.numberOfRows(inSection: section)
        //如果是最后一行,并且没有上拉刷新.就做上拉刷新
        if row == (count - 1) && !isPullUp {
            
            isPullUp = true
            
            //开始刷新
            loadData()
        }
    }
}









