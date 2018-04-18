//
//  WBStatusListViewModel.swift
//  练手微博
//
//  Created by yuency on 06/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import Foundation
import SDWebImage

///上拉刷新最大尝试次数
private let maxPullUpTryTimes = 3


/// 微博数据列表视图模型 负责微博数据处理 1.字典转模型 2.下拉上拉刷新数据处理
/*
 父类的选择
 - 如果类要使用 `KVC` 或者字典转模型框架设置对象,类就需要继承自 NSObject
 - 如果类知识包装一些代码(写了一些函数) 可以不用任何父类,好处:更加轻量级
 - 如果用 OC, 一律继承NSObject
 */
class WBStatusListViewModel {
    
    //微博视图模型数组懒加载
    lazy var statusList = [WBStatusViewModel]()
    
    ///上拉刷新错误次数
    private var pullUpErrorTime = 0
    
    
    func loadStatus(pullUp: Bool, completion: @escaping (_ isSuccess: Bool, _ shouldRefresh: Bool)->()) {
        
        //判断是否是上拉加载,同时检查刷新错误
        if pullUp && (pullUpErrorTime > maxPullUpTryTimes) {
            completion(false,false)
            return
        }
        
        
        //下拉刷新,取出数组的第一条微博的 id
        let since_id = pullUp ? 0 : (statusList.first?.status.id ?? 0)
        //上拉刷新,取出数组的最后一条微博的 id
        let max_id = !pullUp ? 0 : (statusList.last?.status.id ?? 0)
        
        //让数据访问层加载数据'
        WBStatusListDAL.loadStatus(since_id: since_id, max_id: max_id) { (list, isSuccess) in
            
//        }
//        //下面是个尾随闭包
//        WBNetworkManager.shared.statusList(since_id: since_id, max_id: max_id) { (list, isSuccess) in
            
            //判断网络请求是否成功
            if !isSuccess {
                completion(false,false)
                return
            }
            
            
            //字典转模型(第三方框架都支持嵌套的字典转模型 )
            //定义可变数组
            var array = [WBStatusViewModel]()
            
            //遍历返回结果
            for dict in list ?? [] {
            
                guard let model = WBStatusModel.yy_model(with: dict)  else {
                    continue // 注意!这里不能使用 return, 会跳出当前的函数
                }
                //将视图模型放入
                array.append(WBStatusViewModel(model: model))
            }
            
            
            // 拼接数据
            if pullUp {
                //上拉刷新
                self.statusList += array
            } else {
                //下拉刷新拼接数组,新刷新的东西放在前面, 这么写
                self.statusList = array + self.statusList
            }
            
            //判断上拉刷新的数据量
            if pullUp && array.count == 0 {
                self.pullUpErrorTime += 1
                completion(isSuccess,false)
            } else {
                
                //完成回调,这里面是有数据的回调, 缓存图像
                self.cacheSingleImage(list: array, finished: completion) //这就是把闭包往另一个函数里面传递, 在别的函数中完成回调的通知和功能, 闭包单做函数参数传递
                
               // 应该缓存完单张图像,并且修改过配图的大小之后再进行回调,才能够保证表格单张显示图像
               // completion(isSuccess,true),z 所以在这里进行回调是不合适的, 因为这里做了缓存图像的事情.
                
            }
        }
    }

    
    /// 缓存本次下载微博数据数组中的单张图像
    /// 应该缓存完单张图像,并且修改过配图的大小之后再进行回调,才能够保证表格单张显示图像
    /// - Parameter list: 本次下载的视图模型数据
    private func cacheSingleImage(list: [WBStatusViewModel], finished: @escaping (_ isSuccess: Bool, _ shouldRefresh: Bool)->()) {
        
        //调度组
        let group = DispatchGroup()
        
        //记录数据长度
        var length = 0
        
        //遍历数组,查找微博数组中有单张图像的进行缓存
        for vm in list {
            
            //判断图像数量
            if vm.picURLs?.count != 1 {
                continue
            }
            
            //获取 url,代码到这里,数组中有且仅有一张图片
            guard let pic = vm.picURLs?[0].thumbnail_pic,
                let url = URL(string: pic) else {
                    continue //这里不能 return
            }
            
            // 是SDWebImage 的核心方法
            // 图像下载完成后,会自动保存在沙盒中, 文件路径是 url 的 MD5
            // 如果沙盒中已经存在缓存的图像,后续使用 SD 通过 url 加载,都会加载本地沙盒的图像,
            // 同时,回调方法会调用, 方法和功能不变,但是不会再次发起网络请求
            // 如果要缓存的图像累计很大, 要找后台要接口
            
            // A> 入组
            group.enter()
            
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: [], progress: nil, completed: { (image, _, _, _) in
                
                //将图像转换成二进制数据
                if let image = image ,
                    let data = UIImagePNGRepresentation(image) {
                    //NSData 是 length 属性
                    length += data.count
                    
                    //图像缓存成功, 更新配图视图的大小
                    vm.updateSingleImageSize(image: image)
                }
                
                print("缓存的图像是  \(String(describing: image)) 长度:\(length)")
                
                // B> 出组
                group.leave()
                
            })
            
        }
        
        // C> 监听调度组情况
        group.notify(queue: DispatchQueue.main) {
            
            print("图像缓存完成  \(length / 1024)K")
            
            //执行闭包回调, 这个回调其实是上面那个加载数据的函数完成时候应该执行的回调
            finished(true,true)
        }
        
    }

}
