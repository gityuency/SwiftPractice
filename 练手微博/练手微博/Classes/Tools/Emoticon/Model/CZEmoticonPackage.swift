//
//  CZEmoticonPackage.swift
//  练手微博
//
//  Created by yuency on 18/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit
import YYModel

/// 表情包模型
class CZEmoticonPackage: NSObject {
    
    /// 表情包分组名字
    var groupName: String?
    
    /// 背景图片名称
    var bgImageName: String?
    
    /// 表情包目录,从目录下加载 info.plist 可以创建表情模型数组
    var directory: String? {
        didSet {
            //当设置目录的时候,从目录加载 info.plist
            
            guard let directory = directory,
                //寻找表情的 Bundle 路径
                let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
                //寻找表情包的 bundle
                let bundle = Bundle(path: path),
                //寻找表情包 Bunlde 里面文件夹里面的 info.plist
                let infoPath = bundle.path(forResource: "info.plist", ofType: nil, inDirectory: directory),
                //把表情包里面的 info.plist  ->  数组,数组里面弄的是字典
                let array = NSArray(contentsOfFile: infoPath) as? [[String: String]],
                //把上一步数组里面的东西字典转模型
                let models = NSArray.yy_modelArray(with: CZEmoticon.self, json: array) as? [CZEmoticon]
                else {
                    return
            }
            
            //为了直接拿到图片, 这里要设置每一个表情符号的目录
            for m in models {
                m.directory = directory
            }
            
            emoticons += models
        }
    }
    
    /// 懒加载表情模型空数组, 使用懒加载可以避免后续的解包
    lazy var emoticons = [CZEmoticon]()
    
    /// 表情页面数量, 就是算9宫格的行数
    var mumberOfPages: Int {
        return (emoticons.count - 1) / 20 + 1 //为什么要先 -1 然后 /20, 是因为如果这个表情包正好20个表情,.....
    }
    
    
    ///从懒加载的表情包中. 按照 page 截取做多20个表情模型的数组
    /// page == 0, 0~20个模型
    func findEmotiocn(page: Int) -> [CZEmoticon] {
        
        let couont = 20
        
        let location = page * couont
        
        var length = couont
        
        if location + length > emoticons.count { //判断数组越界
            length = emoticons.count - location
        }
        
        let range = NSRange(location: location, length: length)
        
        //截取数组的子数组
        let subArray = (emoticons as NSArray).subarray(with: range)
        
        return subArray as! [CZEmoticon]
    }
    
    
    override var description: String {
        return yy_modelDescription()
    }
}
