//
//  WBNetworkManager.swift
//  练手微博
//
//  Created by yuency on 06/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit
import AFNetworking  //注意,这里导入东西直接写三方的文件夹的名字

/**
 状态码: 405 不支持的网络请求方法,首先查找网络请求方法是否正确
 */
enum WBHTTPMethod {
    case GET
    case POST
}

/// 网络管理工具 单例
class WBNetworkManager: AFHTTPSessionManager {
    
    //静态区 / 常量 / 闭包
    //第一次访问时,执行闭包,并将结果保存在 shared 常量中
    //static let shared = WBNetworkManager{ () -> WBNetworkManager in
    static let shared: WBNetworkManager = {  //直接指定类型 这是个闭包
        //实例化对象
        let instance = WBNetworkManager()
        //设置响应反序列化支持的数据类型
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
        return instance
    }()
    
    
 
    /// 用户账户的懒加载属性
    lazy var userAccount = WBUserAccountModel()
    
    
    //用户登录标记(计算型属性)
    var userLogon: Bool {
        return userAccount.access_token != nil
    }
    
    
    /// 专门负责拼接 token 的网络请求方法
    
    /// 专门负责拼接 token 的网络请求方法
    ///
    /// - Parameters:
    ///   - method:     GET / POST
    ///   - URLStirng:  请求地址
    ///   - parameters: 参数字典
    ///   - name:       上传文件使用的字段名, 默认为 nil, 就不是上传文件
    ///   - data:       上传文件的二进制数据, 默认为 nil, 不上传文件
    ///   - completion: 完成回调
    func tokenRequest(method: WBHTTPMethod = .GET, URLStirng: String, parameters: [String: Any]?, name: String? = nil, data: Data? = nil, completion: @escaping (_ json: Any?, _ isSuccess: Bool) -> ()) {
        
        //处理 token 字典 如果 token 为 nil, 就直接返回, 程序执行过程中一般 token 不会为 nil
        guard let token = userAccount.access_token else {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: nil)
            
            print("Token 为 nil")
            completion(nil, false)
            return //返回
        }
        
        //判断参数字典是否存在
        var parameters = parameters; //为了更改从参数中传递过来的字典
        if parameters == nil {
            parameters = [String:Any]()
        }
        
        //设置参数字典, 代码在这个地方一定有值,上面实例化
        parameters!["access_token"] = token
        
        //判断name和 data
        if let name = name, let data = data {
            //上传文件网络请求
            upload(URLStirng: URLStirng, parameters: parameters, name: name, data: data, completion: completion)
        } else {
            //普通的网络请求
            request(method: method, URLStirng: URLStirng, parameters: parameters, completion: completion)
        }
    }
    
    
    // MARK: - 封装 AFN 方法
    /// 封装 AFN 的上传文件的方法 上传文件只能是 POST 方法
    ///
    ///   - URLStirng: 接口地址
    ///   - parameters: 参数字典
    ///   - name: 接收上传数据的服务器字段(name) 新浪给定的 `pic`
    ///   - data: 要上传的二进制数据
    ///   - completion: 完成回调
    func upload(URLStirng: String, parameters: [String: Any]?, name: String, data: Data, completion: @escaping (_ json: Any?, _ isSuccess: Bool) -> ()) {
        
        post(URLStirng, parameters: parameters, constructingBodyWith: { (formData) in
            
            /**
             1. data: 要上传的二进制数据
             2. name: 服务器接收数据的字段名
             3. fileName: 保存在服务器的文件名,大多数服务器现在可以乱写,很多服务器上传完图片后,会生成缩略图,中图,大图....
             4. mimeType: 告诉服务器上传文件的类型: image/png, image/jpg, image/gif, 如果不想告诉,可以使用 application/octet-stream
             */
            formData.appendPart(withFileData: data, name: name, fileName: "xxx", mimeType: "application/octet-stream")
            
            
        }, progress: nil, success: { (_, json) in
            
            completion(json, true)

        }) { (task, error) in
            
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                print("Token 过期了")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: "bad token")
            }
            print("封装基类 - 网络请求错误 \(error)")
            completion(nil, false)
        }
        
        
    }
    
    
    /// 封装 AFN 的 GET / POST 请求
    ///
    /// - Parameters:
    ///   - method: 请求方式,默认 GET
    ///   - URLStirng:  请求地址
    ///   - parameters: 请求参数
    ///   - completion: 完成回调(字典/数组/是否成功)
    func request(method: WBHTTPMethod = .GET, URLStirng: String, parameters: [String: Any]?, completion: @escaping (_ json: Any?, _ isSuccess: Bool) -> ()) {
        
        //成功的回调
        let success = { (task: URLSessionDataTask, json: Any?) -> () in
            completion(json, true)
        }
        
        //失败的回调
        let failure = { (task: URLSessionDataTask?, error: Error) -> () in
            
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                print("Token 过期了")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: "bad token")
            }
            
            
            print("封装基类 - 网络请求错误 \(error)")
            completion(nil, false)
        }
        
        if method == .GET {
            get(URLStirng, parameters: parameters, progress: nil, success: success, failure: failure)
        } else {
            post(URLStirng, parameters: parameters, progress: nil, success: success, failure: failure)
        }
        
    }
    
}
