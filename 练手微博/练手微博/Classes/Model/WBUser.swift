//
//  WBUser.swift
//  练手微博
//
//  Created by yuency on 12/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit


/// 使用字典转模型的时候, 一定要继承自 NSObject
class WBUser: NSObject {

    //基本数据类型和 private 不能使用 KVC 赋值
    
    /// 用户 ID
    var id: Int = 0
    /// 用户昵称
    var screen_name: String?
    /// 用户头像地址
    var profile_image_url: String?
    /// 认证类型
    var verified_type: Int = 0
    /// 会员等级
    var mbrank: Int = 0 
    
    /// 为了打印调试方便.勤快地写上这个东西
    override var description: String {
        return yy_modelDescription()
    }
    
}
