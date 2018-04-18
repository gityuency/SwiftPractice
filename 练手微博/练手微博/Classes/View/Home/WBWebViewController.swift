//
//  WBWebViewController.swift
//  练手微博
//
//  Created by yuency on 19/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit


/// 网页控制器
class WBWebViewController: WBBaseViewController {
    
    
    /// 加载网页的视图
    private lazy var webView = UIWebView(frame: UIScreen.main.bounds)
    
    /// 要加载的 URL 字符串
    var urlString: String? {
        didSet{
            guard let urlstring = urlString,
                let url = URL(string: urlstring) else {
                    return
            }
            webView.loadRequest(URLRequest(url: url))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setupTableView() {
        //super.setupTableView() 把这句话注释掉, 就不会出现 tableview 和刷新控件这种尴尬的局面
        view.insertSubview(webView, belowSubview: navigationBar)
        webView.backgroundColor = UIColor.white
        
        //设置 contentInset,这是结构体, 可以直接改
        webView.scrollView.contentInset.top = navigationBar.bounds.height
        
        navItem.title = "网页" //这是那个自定义的 nav
    }
}
