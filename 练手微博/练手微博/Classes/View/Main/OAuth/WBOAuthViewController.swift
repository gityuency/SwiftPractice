//
//  WBOAuthViewController.swift
//  练手微博
//
//  Created by yuency on 07/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit
import SVProgressHUD

/// 通过 webview 加载新浪微博的授权页面控制器
class WBOAuthViewController: UIViewController {
    
    private lazy var webView = UIWebView()
    
    
    /// 重写了 loadView 方法
    override func loadView() {
        view = webView
        
        view.backgroundColor = UIColor.white
        
        //取消 webView 的滚动
        webView.scrollView.isScrollEnabled = false
        
        //设置代理
        webView.delegate = self
        
        //设置导航栏
        title = "登录新浪微博"
        //导航栏按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", target: self, action: #selector(close), isBackButton: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", target: self, action: #selector(autoFill))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //加载授权页面
        let string = "https://api.weibo.com/oauth2/authorize?client_id=\(WBAppKey)&redirect_uri=\(WBredirectURI)"
        
        // https://api.weibo.com/oauth2/authorize?client_id=3217728273&redirect_uri=http://baidu.com
        
        guard let urlstring = URL.init(string: string) else {
            return
        }
        
        let request = URLRequest(url: urlstring)
        
        webView.loadRequest(request)
        
    }
    
    /// 监听方法
    func close() {
        SVProgressHUD.dismiss()
        dismiss(animated: true, completion: nil)
    }
    
    /// 自动填充 WebView 的注入, 直接通过 js 修改 `本地浏览器中` 缓存的页面内容
    /// 点击按钮执行 submit() 将本地数据提交给服务器
    func autoFill() {
        //准备 js
        let js = "document.getElementById('userId').value = '1290660723@qq.com';" + "document.getElementById('passwd').value = '123';"
        webView.stringByEvaluatingJavaScript(from: js)
    }
}



extension WBOAuthViewController: UIWebViewDelegate {

    
    /// WebView将要 加载的请求
    ///
    /// - Parameters:
    ///   - webView:  webview
    ///   - request:  要加载请求
    ///   - navigationType: 导航类型
    ///
    /// - Returns: 是否加载请求
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        print("加载请求  \(String(describing: request.url?.absoluteString))")

        
        //如果有 code 就是授权成功
        //request.url?.absoluteString.hasPrefix(WBredirectURI) 这个东西返回的是 Bool 类型的可选项, ture/false/nil
        if request.url?.absoluteString.hasPrefix(WBredirectURI) == false {  //所以在这里判断等于 false 就可以了, 不用编译器的提示方法
            return true
        }
        
        //如果请求页面包含百度地址,就不加载,需要从回调地址中查找字符串 code = `` 也就是找到授权码
        // query 就是 URL 中 `?` 后面的所有部分, 就是查询字符串
        if request.url?.query?.hasPrefix("code=") == false { //用户没有授权,就直接返回
            close()
            return false
        }
        
        //从 query字符串中取出授权码, 代码走到这里, URL 中一定含有查询字符串,并且包含 "code="
        //code=4e056f3662ab7415052ca516ac06f150
        let code = request.url?.query?.substring(from: "code=".endIndex) ?? "" //在这里不进行强行解包, 让 code 变成必选
        
        print("授权码: \(code)")
        
        //使用授权码获得 AccessToken
        WBNetworkManager.shared.loadAccessToken(code: code) { (isSuccess) in
            if !isSuccess {
                SVProgressHUD.showInfo(withStatus: "网络请求失败")
            } else {

                //下一步做什么. 跳转`界面`如何跳转, 从哪里弹出来,页面消失就要回到哪里去
                //发通知不关心有没有监听者
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserLoginSuccessNotification), object: nil)
                
                //关闭窗口
                self.close()
            }
        }
        return false
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
}

