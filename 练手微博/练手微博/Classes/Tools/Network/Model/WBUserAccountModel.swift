//
//  WBUserAccountModel.swift
//  练手微博
//
//  Created by yuency on 07/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

private let accountFile: NSString = "useraccount.json"

/// 用户账户信息
class WBUserAccountModel: NSObject {
    
    /// 访问令牌
    var access_token: String?
    
    /// 用户代号
    var uid: String?
    
    /// access_token生命周期,单位是秒, 开发者5年,使用者3天,会从第一次登录递减
    //本质是 Double
    var expires_in: TimeInterval = 0 {
        didSet {
            expiressDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    
    /// 过期日期
    var expiressDate: Date?
    
    /// 用户昵称
    var screen_name: String?
    
    /// 用户头像 大图
    var avatar_large: String?
    
    
    
    // 这是一个计算型的属性
    override var description: String {
        return yy_modelDescription()
    }
    
    
    override init() {
        super.init()
        
        //从磁盘加载保存的文件
        //加载磁盘二进制文件数据
        guard let path = accountFile.cz_appendDocumentDir(),
            let data = NSData(contentsOfFile: path),
            //这一句是从 data -> Dic
            let json = try? JSONSerialization.jsonObject(with: data as Data, options: []) as? [String:Any]
            else {
                return
        }
        
        //使用字典设置属性值 这个东西转换完成之后就应该是字典了
        yy_modelSet(with: json ?? [:])
        
        
        print("从沙盒加载用户信息 \(path)")
        
        //判断 token 是否过期
        //expiressDate = Date(timeIntervalSinceNow: -3600*24) //测试账户是否过期的代码
        //print(expiressDate ?? "没有日期")
        if expiressDate?.compare(Date()) != .orderedDescending {
            print("账户过期")
            //清空 token
            access_token = nil
            uid = nil
            try? FileManager.default.removeItem(atPath: path)
        }
        print("账户正常")
    }
    
    
    /**
     * 关于数据存储
     * 1.偏好设置 (小)
     * 2.沙盒 归档/plist/json
     * 3.数据库 (FMDB/CoreData)
     * 4.钥匙串访问(小/自动加密 - 需要使用 SSKeyChain)
     */
    func saveAccount() {
        
        //模型转字典
        var dict = (self.yy_modelToJSONObject() as? [String : Any]) ?? [:] //没有就是空字典
        dict.removeValue(forKey: "expires_in")
        
        //字典序列化 data
        //写入磁盘
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
            let fileName = accountFile.cz_appendDocumentDir()
            else {
                return
        }
        (data as NSData).write(toFile: fileName, atomically: true)
        
        print("用户账户保存成功 \(fileName)")
    }
    
    
}
