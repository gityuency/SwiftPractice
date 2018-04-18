//
//  WBStatusModel.swift
//  练手微博
//
//  Created by yuency on 06/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit
import YYModel

/// 微博数据模型
class WBStatusModel: NSObject {
    
    //基本数据类型要写默认值, Int64是微博官方文档中给出的数据类型
    //如果不写 Int64 在 iPad2 / iPhone 5/5c/4s/4 上都无法正常运行,这些机器是32位. Int64在64位机器上是64位,在32位机器上是32位
    var id: Int64 = 0
    
    //微博信息内容
    var text:String?
    
    
    /// 微博创建时间的字符串
    var created_at: String? {
        didSet{
            createDate = Date.cz_sinaDate(string: created_at ?? "")
        }
    }
    
    //微博创建事件的字符串
    var createDate: Date?
    
    /// 微博来源
    var source: String? {
        didSet{
            //重新计算来源并且保存了 //在didSet给 source 再次设置值,不会调用 didSet, 不会造成 死循环
            source = "来自于 " + (source?.cz_href()?.text ?? "新日暮里")
        }
    }
    
    //转发数
    var reposts_count: Int = 0
    //评论数
    var comments_count: Int = 0
    //点赞数
    var attitudes_count: Int = 0
    
    /// 微博用户信息模型,注意.这个字段的名称一定要和服务器返回的字段名字一致
    var user: WBUser?
    
    /// 被转发的原创微博
    var retweeted_status: WBStatusModel?
    
    
    /// 微博配图模型数组
    var pic_urls: [WBStatusPicture]?
    
    
    
    //重写描述方法 这是计算型的属性, 就写成 get 和 set
    override var description: String {
        
        //  get {
        //          return "id:\(id),text:\(String(describing: text))"
        //      }
        
        return yy_modelDescription()
    }
    
    
    /// 类函数 - 告诉第三方框架 YY_Model 如果遇到数组类型的属性,数组中存放的对象是什么类?
    ///
    /// - NSArray 中保存的对象类型通常是 `id` 类型  OC 中的泛型是 Swift 推出后,苹果为了兼容 OC 增加的,
    /// 从运行时的角度,仍然不知道数组中应该存放什么类型的对象
    class func modelContainerPropertyGenericClass() -> [String : Any] {
        return ["pic_urls":WBStatusPicture.self]
    }
}
