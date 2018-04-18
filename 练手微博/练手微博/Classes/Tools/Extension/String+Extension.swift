//
//  String+Extension.swift
//  练手微博
//
//  Created by yuency on 18/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import Foundation

extension String {
    
    /// 从当前字符串中提取链接和文本
    /// 提供了元组, 可以同时返回多个值
    func cz_href() -> (link: String, text: String)? {
        
        //0.匹配方案
        let pattern = "<a href=\"(.*?)\" .*?>(.*?)</a>"
        
        //1.创建正则表达式
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []),
            let result = regx.firstMatch(in: self, options: [], range: NSRange(location: 0, length: characters.count))
            else {
                return nil
        }
        
        //3.获取结果
        let link = (self as NSString).substring(with: result.rangeAt(1))
        let text = (self as NSString).substring(with: result.rangeAt(2))
        return (link, text)
    }
}

