//
//  WBRegularExpressionViewController.swift
//  练手微博
//
//  Created by yuency on 19/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

class WBRegularExpressionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        
        // 正则表达式的使用方法就这样, 改变的只是匹配方案
        EXT()
        
    }
    
    
    /// 正则表达式
    private func EXT() {
        
        //<a href="http://weibo.com" rel="nofollow">新浪微博</a>
        
        //0.目标取出 href 中的链接,以及文本描述
        let string = "<a href=\"http://weibo.com\" rel=\"nofollow\">新浪微博</a>"
        
        //1.创建匹配方案
        //索引
        // 0: 和匹配方案完全一致的字符串
        // 1: 第一个() 中的内容
        // 2: 第二个() 中的内容
        // ... 索引从左向右顺序递增
        // 对于模糊查,如果关心的内容,就使用 (.*?) 然后可以通过索引获取结果
        // 如果是不关心的内容,就是 .*? 不加小括号,可以匹配任意内容
        let pattern = "<a href=\"(.*?)\" .*?>(.*?)</a>"
        
        //2.创建正则表达式 如果 pattern 失败,抛出异常
        guard let regxx = try? NSRegularExpression(pattern: pattern, options: []) else {
            return
        }
        
        //3.进行查找
        // [只找第一个匹配项 / 查找多个匹配项]
        guard let result =  regxx.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.characters.count)) else {
            print("没有找到匹配项")
            return
        }
        
        // result 中只有两个重点,
        //1. result.NumberOfRange -> 查找到的范围数量
        //2.result.range(at.idx) -> 指定索引位置的范围
        print(result)
        
        for idx in 0..<result.numberOfRanges {
            let r = result.rangeAt(idx)
            let subStr = (string as NSString).substring(with: r)
            print("索引: \(idx), 查找内容: \(subStr)")
        }
    }
    
    
    private func setupUI() {
        self.title = "正则表达式 .*?"
        view.backgroundColor = UIColor.cz_random()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", target:  self, action: #selector(close))
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
