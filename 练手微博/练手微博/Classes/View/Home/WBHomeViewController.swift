//
//  WBHomeViewController.swift
//  练手微博
//
//  Created by yuency yang on 27/06/2017.
//  Copyright © 2017 yuency yang. All rights reserved.
//

import UIKit


//定义全局常量, 尽量使用 private 修饰, 否则到处都可以访问
/// 原创微博的可重用 cell
private let originCellID = "originCellID"

/// 被转发微博的可重用 cellid
private let retweetCellID = "retweetCellID"

class WBHomeViewController: WBBaseViewController {
    
    //视图模型 懒加载
    lazy var listViewModel = WBStatusListViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(browserPhoto(n:)), name: NSNotification.Name(rawValue: WBstatusCellBrowserPhotoNotification), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    /// 浏览照片
    @objc private func browserPhoto(n: Notification) {
        //从通知的 userinfo 提取参数
        guard let selectedIndex = n.userInfo?[WBstatusCellBrowserPhotoSelectedIndexKey] as? Int,
            let urls = n.userInfo?[WBstatusCellBrowserPhotoURLsKey] as? [String],
            let imageViewList = n.userInfo?[WBstatusCellBrowserPhotoImageViewsKey] as? [UIImageView]
        else {
            return
        }
        
        //2.展现照片浏览控制器
        let vc = HMPhotoBrowserController.photoBrowser(withSelectedIndex: selectedIndex, urls: urls, parentImageViews: imageViewList)
        present(vc, animated: true, completion: nil)
        
    }
    
    
    /// 加载数据
    override func loadData() {
        
        listViewModel.loadStatus(pullUp: isPullUp) { (isSuccess, shouldRefresh) in
            
            //结束刷新
            self.refreshControl?.endRefreshing()
            //恢复上拉刷新标记
            self.isPullUp = false
            //刷新表格
            if shouldRefresh {
                self.tableView?.reloadData()
            }
        }
    }
    
    /// 显示好友
    func showFriends() -> () {
        let vc = WBDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


// MARK: - 表格数据源方法
extension WBHomeViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //取出视图模型,来判断可重用 cell
        let vm = listViewModel.statusList[indexPath.row]

        let cellId = (vm.status.retweeted_status != nil) ? retweetCellID : originCellID
        
        // 本身会调用代理方法(如果有) / 如果没有会找到 cell 按照自动布局的规则从上向下计算. 找到向下的约束, 计算动态行高
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! WBStatusCell
 
        //设置 cell
        cell.viewModel = vm

        //设置代理, 如果代理方法没有实现, 如果 cell 里面的代理是强行!调用方法, 会崩溃
        //如果用 block,需要在每一个 cell 设置 block, 这个括号里面就是每次都需要创建一段代码,......
        //cell.completion = { //..... }
        //设置代理只是传递了一个指针地址
        cell.delegate = self
        
        return cell
    }
    
    //这里没有 override, 这个方法都不进来, 父类需要有这个方法, 然后子类里面才能有 override
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let vm = listViewModel.statusList[indexPath.row]
        return vm.rowHeight
    }
    
}




// MARK: - cell 代理函数
extension WBHomeViewController: WBStatusCellDelegate {
    
    func statusCellDidTapUrlString(cell: WBStatusCell, urlString: String) {
    
        let vc = WBWebViewController()
        vc.urlString = urlString
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 设置界面
extension WBHomeViewController {
    
    override func setupTableView() {
        super.setupTableView()
        
        //使用扩展里面自己写的按钮r
        //这里要使用自己的 NavItem, 系统的是 navigationItem.leftBarButtonItem = ....
        navItem.leftBarButtonItem = UIBarButtonItem(title: "好友", target:  self, action: #selector(showFriends))
        
        //注册 cell
        tableView?.register(UINib(nibName: "WBStatusNormalCell", bundle: nil), forCellReuseIdentifier: originCellID) // nibName 后面不需要加 XIB
        tableView?.register(UINib(nibName: "WBStatusRetweedCell", bundle: nil), forCellReuseIdentifier: retweetCellID)
        
        //设置行高 自动设置行高
//        tableView?.rowHeight = UITableViewAutomaticDimension 取消自动行高
        tableView?.estimatedRowHeight = 300  //预设行高
        
        //取消分割线
        tableView?.separatorStyle = .none
        
        setupNaviTitle()
    }
    
    
    /// 设置导航栏标题
    func setupNaviTitle() {
        let title = WBNetworkManager.shared.userAccount.screen_name
        let button = WBTitleButton(title: title)
        navItem.titleView = button
        button.addTarget(self, action: #selector(clickTitleButton), for: .touchUpInside)
    }
 
    
    @objc func clickTitleButton(btn: UIButton) {
        
        //设置选中状态
        btn.isSelected = !btn.isSelected
    }
    
}



//设置导航栏按钮
//这种方式无法高亮显示按钮
//navigationItem.leftBarButtonItem = UIBarButtonItem(title: "好友", style: .plain, target: self, action: #selector(showFriends))


//swift 调用 OC 返回的 instancetype 的方法判断不出是否可选 , 所以显示写出类型
/*
 let btn: UIButton = UIButton.cz_textButton("好友", fontSize: 16, normalColor: UIColor.darkGray, highlightedColor: UIColor.orange)
 btn.addTarget(self, action: #selector(showFriends), for: .touchUpInside)
 navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
 */


