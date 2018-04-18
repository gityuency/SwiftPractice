//
//  WBStatusListDAL.swift
//  练手微博
//
//  Created by yuency on 24/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import Foundation


/// DAL - Data Access Layer 数据访问层
/// 负责处理数据库和网络数据, 给 ListViewModel 返回微博的[字典数组]
/// 在调整系统的时候,尽量做最小的调整
class WBStatusListDAL {
    
    /// 从本地数据库或者网络加载数据//网络返回的是从闭包里面拿, 数据库直接是返回值, 为了统一返回
    ///
    /// 参数参照网络接口, 在使用的时候,对代码的改动是最小的
    ///
    /// - Parameters:
    ///   - since_id: 下拉刷新 ID
    ///   - max_id:  上拉加载 ID
    ///   - completion:  完成回调 (字典数组,是否成功)
    class func loadStatus(since_id: Int64 = 0, max_id: Int64 = 0, completion: @escaping (_ list: [[String:Any]]?, _ isSuccess: Bool) -> ()) {
        
        //0.获取用户 id
        guard let userId = WBNetworkManager.shared.userAccount.uid else {
            return
        }
        
        /*
        //1.检查本地数据,如果有,直接返回, 没有数据返回的是空数组,不是 nil
        let array = CZSQLiteManager.shared.loadStatus(userId: userId, since_id: since_id, max_id: max_id)
        
        //这个数组是必选的, 只是元素个数的问题
        if array.count > 0 {
            
            completion(array, true)
            
            //如果有数据就不需要往下面走了
            return
        }
        */
        
        //2.加载网络数据
        WBNetworkManager.shared.statusList(since_id: since_id, max_id: max_id) { (list, isSuccess) in
            
            //判断网络请求是否成功
            if !isSuccess {
                completion(nil, false)
                return
            }
            
            //判断数据
            if list.count <= 0 {
                completion(list, false)
                return
            }
            
            //3.加载完成之后,将网络数据[字典数组] 写入数据库
            CZSQLiteManager.shared.updateStatus(userId: userId, array: list)
            
            //4.返回网络数据
            completion(list, isSuccess)
            
        }
    }
}
