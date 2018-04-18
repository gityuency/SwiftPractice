//
//  Bundle+Extension.swift
//  练手微博
//
//  Created by yuency yang on 28/06/2017.
//  Copyright © 2017 yuency yang. All rights reserved.
//

import Foundation


//新做一个扩展.用来获取命名空间
extension Bundle {
    
    /// 使用函数获得命名空间
    ///
    /// - Returns:
    func namespace() -> String {
        
        //return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        
        //省掉前面的东西
        return infoDictionary?["CFBundleName"] as? String ?? ""
    }
    
    /// 使用计算型属性获得命名空间
    var nameSpaceStirng: String {
        return infoDictionary?["CFBundleName"] as? String ?? ""
    }
}
