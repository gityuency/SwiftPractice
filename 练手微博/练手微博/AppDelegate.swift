//
//  AppDelegate.swift
//  练手微博
//
//  Created by yuency yang on 27/06/2017.
//  Copyright © 2017 yuency yang. All rights reserved.
//

import UIKit
import UserNotifications
import SVProgressHUD
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //三方的设置
        setupAdditions()
        
        
       
        
        
        window = UIWindow()
        window?.backgroundColor = UIColor.white
        window?.rootViewController = WBMainViewController()
        window?.makeKeyAndVisible()
        
        //从网络获取应用程序配置信息
        //loadAppInfo()
        
        
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}



// MARK: - 模拟异步加载网络配置文件
extension AppDelegate {
    
    func loadAppInfo() {
        //1.模拟异步
        DispatchQueue.global().async {
            
            //url
            let url = Bundle.main.url(forResource: "main.json", withExtension: nil)
            //data
            let data = NSData(contentsOf: url!)
            //写入磁盘,在下次应用程序打开的时候启用这个下载的 json 文件
            let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let jsonPaht = (docDir as NSString).appendingPathComponent("main.json")
            
            data?.write(toFile: jsonPaht, atomically: true)
            print("应用程序加载 json: \(jsonPaht)")
        }
    }
}


// MARK: - 设置应用程序额外信息
extension AppDelegate {

    
    func setupAdditions() {
        
        //设置 SVProgressHUD 最小解除时间
        SVProgressHUD.setMinimumDismissTimeInterval(1)
     
        //设置网络加载指示器
        AFNetworkActivityIndicatorManager.shared().isEnabled = true
        
        //设置用户授权显示通知
        // #available 是监测设备版本,
        if #available(iOS 10.0, *) { //iOS 10+
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) { (success, error) in
                print("iOS 10+ 通知授权" + (success ? "成功" : "失败"))
            }
        } else {
            //取得用户授权显示通知[上方的提示条/声音/badgeNumber]
            let notifySettings = UIUserNotificationSettings(types: [.alert,.sound,.badge], categories: nil)
             UIApplication.shared.registerUserNotificationSettings(notifySettings)
        }
    }
    
}



