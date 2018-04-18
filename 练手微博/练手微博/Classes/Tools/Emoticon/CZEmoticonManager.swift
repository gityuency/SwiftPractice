//
//  CZEmoticonManager.swift
//  练手微博
//
//  Created by yuency on 18/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import Foundation
import UIKit

/// 表情管理器, 单例, 在不需要字典转模型的时候,这个类就不需要父类了
class CZEmoticonManager {
    
    /// 表情管理的单例
    static let shared = CZEmoticonManager()
    
    /// 表情包的懒加载数组 - 第一个数组是最近表情,加载之后,表情数组默认为空,
    lazy var packages = [CZEmoticonPackage]()
    
    /// 表情素材的 bundle
    lazy var bundel: Bundle = {
        let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil)
        return Bundle(path: path!)!
    }()
    
    
    
    /// 在构造函数 init 之前增加 private 修饰符, 可以要求调用者必须通过 shared 访问对象, 锁住单例创建方式
    /// OC 要重写 allocWithZone 方法
    private init() {
        loadPackages()
    }
    
    
    /// 添加最近使用的表情
    ///
    /// - Parameter em: 选中的表情
    func recentEmoticon(em: CZEmoticon) {
        
        //1.增加表情使用次数
        em.times += 1
        
        //2.判断是否已经记录的该表情, 如果没有记录,添加记录
        if !packages[0].emoticons.contains(em) {
            packages[0].emoticons.append(em)
        }
        
        
        //3.根据使用次数排序,使用次数高的靠前
//        packages[0].emoticons.sort { (em1, em2) -> Bool in
//            return em1.times > em2.times
//        }
        //可以这么排序
        packages[0].emoticons.sort { $0.times > $1.times }
        
        
        //4.判断表情数组是否超出,如果超出,删除末尾的表情
        if packages[0].emoticons.count > 20 {
            packages[0].emoticons.removeSubrange(20..<packages[0].emoticons.count)
        }
    }
}



// MARK: - 挑选合适的表情
extension CZEmoticonManager {
    
    /// 根据 string [爱你] 在所有的表情符号中查找对应的表情模型对象
    ///
    /// - 如果找到,返回表情模型
    /// - 如果找不到, 返回 nil
    func findEmoticon(string: String) -> CZEmoticon? {
        
        //遍历表情包 , OC 中过滤数组使用 [谓词]
        for p in packages {
            
            //方法1 - 常见方法
            //            let result = p.emoticons.filter({ (em) -> Bool in
            //                return em.chs == string
            //            })
            
            //方法2 - 尾随闭包
            //            let result = p.emoticons.filter(){ (em) -> Bool in
            //                return em.chs == string
            //            }
            
            //方法3 - 如果闭包中只有一句,并且是返回
            //1.闭包格式定义可以省略
            //2.参数省略之后,使用$0,$1依次替代原有的参数
            //            let result = p.emoticons.filter(){
            //                return $0.chs == string
            //            }
            
            //方法4 - 如果闭包中只有一句,并且是返回
            //1.闭包格式定义可以省略
            //2.参数省略之后,使用$0,$1依次替代原有的参数
            //3.return 也可以省略
            let result = p.emoticons.filter(){ $0.chs == string }
            
            
            //判断结果数组的数量
            if result.count == 1 {
                return result[0]
            }
        }
        return nil
    }
}

// MARK: - 获取 Bundle 中表情包的数据
private extension CZEmoticonManager {
    
    func loadPackages() -> Void {
        
        //读取 emoticons.plist
        //只要按照 Bundle默认的目录结构设定, 就可以直接读取 Resources 目录下的文件
        
        //获取其他 Bundle 中的文件
        guard let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
            let bundle = Bundle(path: path),
            //直接找出文件, 不需要其他路径
            let plistPath = bundle.path(forResource: "emoticons.plist", ofType: nil),
            //plist 转数组,这个 plists是数组存的字典
            let array = NSArray(contentsOfFile: plistPath) as? [[String: String]],
            //建立模型
            let models = NSArray.yy_modelArray(with: CZEmoticonPackage.self, json: array) as? [CZEmoticonPackage]
            else {
                return
        }
        
        // 使用 += 不需要再次给 packages 分配空间,直接追加数据
        packages += models
    }
}


// MARK: - 普通字符串展转换成为表情字符串
extension CZEmoticonManager {
    
    /// 将给定的字符串转换成属性文本
    ///
    /// 关键点：要按照匹配结果 倒序! 替换属性文本！ 如果正序替换文本, 将会导致后续的替换结点的 range 值发生改变,替换就会失败
    ///
    /// - parameter string: 完整的字符串
    ///
    /// - returns: 属性文本
    func emoticonString(string: String, font: UIFont) -> NSAttributedString {
        
        //先把传入的字符串做成富文本
        let attrString = NSMutableAttributedString(string: string)
        
        //建立正则表达式,过滤所有的表情文字
        // () [] 都是正则表达式用的关键字, 使用的时候需要转义
        let pattern = "\\[.*?\\]"
        
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else {
            return attrString
        }
        
        //匹配所有项
        let matches = regx.matches(in: string, options: [], range: NSRange(location: 0, length: attrString.length))
        
        //遍历所有匹配结果, 倒叙替换文本
        for m in matches.reversed() {
            let r = m.rangeAt(0)
            let subStr = (attrString.string as NSString).substring(with: r)
            
            //使用 subStr查找对应的表情符号
            
            if let em = CZEmoticonManager.shared.findEmoticon(string: subStr) {
                //使用表情符号中的属性文本,替换原有的属性文本中的内容
                attrString.replaceCharacters(in: r, with: em.imageText(font: font))
            }
        }
        
        //4. *** 统一设置一遍字符串的属性 注意! 生成的属性文本一定要在最后全部替换字体, 否则将引起布局的混乱, 还需要设置颜色!
        attrString.addAttributes([NSFontAttributeName: font,
                                  NSForegroundColorAttributeName : UIColor.darkGray 
                                  ], range: NSRange(location: 0, length: attrString.length))
        
        return attrString
    }
}




