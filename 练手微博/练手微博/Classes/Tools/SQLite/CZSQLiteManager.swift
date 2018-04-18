//
//  CZSQLiteManager.swift
//  练手微博
//
//  Created by yuency on 21/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import Foundation
import FMDB


/// 最大的数据库缓存时间, 以 s 为单位
private let maxDBCacheTime: TimeInterval = -60 //-5 * 24 * 60 * 60

/// SQLite 管理器

/*
 1. 数据库本质上是保存在沙盒中的一个文件,首先需要创建并打开数据库
 FMDB - 队列
 
 2. 创建数据表
 
 3. 增删改查 - 数据库开发,程序代码几乎是一致的,区别在于 SQL 的正确性, 首先要在 Navicat 中测试 SQL 的正确性
 
 */
class CZSQLiteManager {
    
    /// 单例,全局数据库访问点
    static let shared = CZSQLiteManager()
    
    ///数据库队列
    let queue: FMDatabaseQueue //常量有一次赋初值的机会
    
    /// 构造函数
    private init() {
        
        //数据库的(全)路径 path
        let dbName = "status.db"
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] //这个方法一定会返回值,直接取第一项
        path = (path as NSString).appendingPathComponent(dbName)
        print("数据库路径 \(path)")
        
        //创建数据库队列  "创建 或者 打开" 数据库
        queue = FMDatabaseQueue(path: path)
        
        //打开数据库
        createTable()
        
        //注册通知 监听应用程序进入后台 UIApplicationDidEnterBackground
        NotificationCenter.default.addObserver(self, selector: #selector(clearDBCache), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
    }
    
    
    /// 清理数据缓存
    /// SQLite如果删了数据,数据库的大小不会变小,
    /// 如果要变小,1.将数据库文件复制一个新的副本, 2.新建一个空的数据库文件, 3自己编写 SQL 将老数据库的文件拷贝到新的数据库 
    @objc private func clearDBCache() {
        
        let dateString = Date.cz_dateString(delta: maxDBCacheTime)
        
        //准备 SQL
        let sql = "DELETE FROM T_Status WHERE createTime < ?;" // ?占位符不需要单引号
        
        //执行
        queue.inDatabase { (db) in
            
            if db.executeUpdate(sql, withArgumentsIn: [dateString]) == true {
                print("删除了 \(db.changes) 条记录")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}





// MARK: - 微博数据操作
extension CZSQLiteManager {
    
    
    /// 从数据库加载微博数据数组
    ///
    /// - Parameters:
    ///   - userId: 当前登录的用户
    ///   - since_id: 返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
    ///   - max_id: 返回ID小于或等于max_id的微博，默认为0。
    /// - Returns: 微博的字典数组,将数据库中的status 字段对应的二进制数据反序列化,生成字典
    func loadStatus(userId: String, since_id: Int64 = 0, max_id: Int64 = 0) -> [[String: Any]] {
        
        
        //准备 SQL
        var sql = "SELECT statusId, userId, status FROM T_Status \n"
        sql += "WHERE userId = \(userId) \n"
        
        //-- 上拉/下拉 都是针对同一个 id 进行判断
        if since_id > 0 {
            sql += "AND statusId > \(since_id) \n"
        } else if max_id > 0 {
            sql += "AND statusId < \(max_id) \n"
        } // else 的情况是这两个 id 都是0,也就是第一次进入时候的状态,这时候没有这句 sql条件
        
        sql += "ORDER BY statusId DESC LIMIT 20;"  //SQL 语句后面一定要加分号

        //拼接 SQL 结束后一定要测试.....
        
        //执行 SQL
        let array = execRecordSet(sql: sql)
        
        //遍历数组,将数组中的 status 反序列化
        var result = [[String: Any]]()  //后面加 () 表示创建一个数组
    
        
        for dict in array {
            
            guard let jsonData = dict["status"] as? Data,
                //这个 json 的结果是双重可选的...
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                continue
            }
        
            //追加到数组
            result.append(json ?? [:])
        }
    
        return result
    }
    
    
    
    
    
    /* 从网络加载结束后,返回的是微博的"字典数组" 每一个字典对应一个完整的微博记录,
     - 完整的微博记录中包含微博代号
     - 用户代号是自己定的
     -
     */
    
    /// 新增或者修改微博数据, 微博数据在刷新的时候,可能会出现重叠
    ///
    /// - Parameters:
    ///   - userId: 当前用户的 id
    ///   - array:  从网络获取的字典数组
    func updateStatus(userId: String, array: [[String: Any]]) {
        
        //1.准备 SQL
        /* statusId: 要保存的微博代号
         userId:   当前登录用户的 Id
         status:   完整微博字典的 json 二进制数据
         */
        let sql = "INSERT OR REPLACE INTO T_Status (statusId,userId,status) VALUES (?,?,?)"  //插入的参数使用 ? 作为占位符, 不管是 int 还是 text, 都用问号,不要单引号
        
        
        //2.执行 SQL
        queue.inTransaction { (db, rollBack) in
            
            //遍历数组,逐条插入微博数据
            for dict in array {
                
                //从字典获取微博代号
                guard let statusId  = dict["idstr"] as? String,
                    //将字典序列化成为二进制数据
                    let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
                        continue
                }
                
                // SQL
                if  db.executeUpdate(sql, withArgumentsIn: [statusId, userId, jsonData]) == false {
                    
                    //插入失败需要回滚 在 OC 里面, *rollback == YES 就可以了
                    //swift  3.0的写法是这样的
                    rollBack.pointee = true
                    break
                }
            }
            
        }
    }
}


// MARK: - 创建数据表以及其他私有方法
extension CZSQLiteManager {
    
    
    /// 执行一个 SQL 返回字典的数组
    ///
    /// - Parameter sql: 执行的 SQL
    /// - Returns: 返回的字典数组
    func execRecordSet(sql: String) -> [[String: Any]] {
        
        //这么做是实例化一个数组
        var result = [[String: Any]]()
        
        //执行 SQL - 查询数据, 不会修改数据, 所以不需要开启事务
        //事务的目的 是为了保证数据的有效性,一旦失效,回滚到初始状态
        queue.inDatabase { (db) in
            
            guard let rs = db.executeQuery(sql, withArgumentsIn: []) else {
                return
            }
            
            //遍历结果集
            while rs.next() {
                
                //列数
                let colCount = rs.columnCount
                //遍历所有列
                for col in 0..<colCount {
                    
                    //列名 -> key //值 -> value
                    guard let name = rs.columnName(for: col), let value = rs.object(forColumnIndex: col) else {
                        continue
                    }
                    //5.追加结果
                    result.append([name: value])
                }
            }
        }
        return result
    }
    
    
    
    /// 创建或者打开数据库
    func createTable() {
        
        guard let path = Bundle.main.path(forResource: "status.sql", ofType: nil),
            let sql = try? String(contentsOfFile: path) else {
                return
        }
        
        print(sql)
        
        //执行 SQL -- FMDB 的内部队列,串行队列,同步执行, 可以保证同一时间,只有一个任务操作数据库,从而保证数据库的读写安全
        queue.inDatabase { (db) in
            
            //只有在创表的时候,使用执行多条语句,可以一次创建多个表,
            //在执行增删改查的时候,一定不要使用Statements方法,否则有可能被注入
            if db.executeStatements(sql) == true {
                //创建表成功
                print("创表成功")
            } else {
                //创表失败
                print("创表失败")
            }
        }
        print("数据库创建或打开完毕")
    }
}


