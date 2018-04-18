//
//  WBNetworkManager+Extension.swift
//  练手微博
//
//  Created by yuency on 06/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import Foundation


// MARK: - 封装新浪微博的网络请求方法
extension WBNetworkManager {
    
    
    /// 加载微博字典的数组
    ///
    /// - Parameters:
    ///   - since_id: 返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
    ///   - max_id: 返回ID小于或等于max_id的微博，默认为0。
    ///   - completion: 完成回调[list微博字典数组/是否成功]
    func statusList(since_id: Int64 = 0, max_id: Int64 = 0, completion: @escaping (_ list: [[String:Any]], _ isSuccess: Bool) -> ()) {
        
        let urlstring  = "https://api.weibo.com/2/statuses/friends_timeline.json"
        
        let params = ["since_id":"\(since_id)","max_id":"\(max_id > 0 ? max_id - 1 : 0 )"] //这些 Int64 比较特殊的类型直接弄成字符串就好了
        
        tokenRequest(URLStirng: urlstring, parameters: params) { (json, issuccess) in
            
            if let data1 = json as? [String:Any],
                let result = data1["statuses"] as? [[String:Any]]
            {
                completion(result, issuccess)
            } else {
                print("解析失败")
            }
        }
    }
    
    
    func unReadCount(_ completion: @escaping (_ cont: Int) -> ()) {
        
        guard let uid = userAccount.uid else {
            return
        }
        
        let url = "https://rm.api.weibo.com/2/remind/unread_count.json"
        
        let para = ["uid":uid]
        
        tokenRequest(URLStirng: url, parameters: para) { (json, isSuccess) in
            
            let dic = json as? [String:Any]
            let count = dic?["status"] as? Int
            completion(count ?? 0)
            
        }
    }
}


// MARK: - 发布微博
extension WBNetworkManager {
    
    
    /// 发布微博
    /// - Parameters:
    ///   - text: 要发布的文本
    ///   - image: 要上传的图像 为nil 时,就是发布纯文本微博
    ///   - completion: 完成回调
    func postStatus(text: String, image: UIImage?, completion: @escaping (_ result: [String: Any]?, _ isSuccess: Bool) -> ()) -> () {
        
        //发微博的地址
        let urlString = "https://api.weibo.com/2/statuses/share.json"
        
        let params = ["status": text]
        
        //如果图像不为空,需要设置 name 和 data
        var name: String?
        var data: Data?
        
        if image != nil {
            name = "pic"
            data = UIImagePNGRepresentation(image!)
        }
        
        
        tokenRequest(method: .POST, URLStirng: urlString, parameters: params, name: name, data: data) { (json, isSuccess) in
            
            completion(json as? [String: Any], isSuccess)
        }
        
    }
}


// MARK: - 用户信息
extension WBNetworkManager {
    
    /// 加载用户信息 用户登录后立即执行
    func loadUserInfo(completion: @escaping ([String:Any])->()) {
        
        guard let uid = userAccount.uid else {
            return
        }
        
        let urlString = "https://api.weibo.com/2/users/show.json"
        
        let param = ["uid":uid]
        
        tokenRequest(URLStirng: urlString, parameters: param) { (json, isSuccess) in
            print("获取用户信息数据 \(String(describing: json))")
            //完成回调 这个字典有可能为空
            completion(json as? [String : Any] ?? [:])
        }
    }
}



// MARK: - OAth方法
extension WBNetworkManager {
    
    //func accessToken() {  //这个方法名和属性 accessToken 同名,会报错
    
    
    /// 加载 AccessToken
    ///
    /// - Parameters:
    ///   - code:  授权码
    ///   - completion: 完成回调
    func loadAccessToken(code: String, completion: @escaping (Bool) -> ()) {
        
        
        let urlString = "https://api.weibo.com/oauth2/access_token"
        let param = ["client_id":WBAppKey,
                     "client_secret":WBAppSecret,
                     "grant_type":"authorization_code",
                     "code":code,
                     "redirect_uri":WBredirectURI,];
        
        request(method: .POST, URLStirng: urlString, parameters: param) { (json, isSuccess) in
            
            print(json ?? "错误! AccessToken")
            
            //直接用字典设置 用户模型属性
            //空字典是 [:], 这里不能用 Xcode 提示强制解包,因为会有可能没有东西, 还是使用空字典
            self.userAccount.yy_modelSet(with: (json as? [String:Any]) ?? [:] )
            
            
            //加载当前用户信息
            self.loadUserInfo(completion: { (dict) in
                
                //使用用户信息字典,设置用户账户信息,(昵称头像和地址)
                self.userAccount.yy_modelSet(with: dict)
                
                //保存用户模型
                self.userAccount.saveAccount()
                
                //加载完成之后 完成回调
                completion(true)
                
            })
        }
    }
    
    
    
    
}









