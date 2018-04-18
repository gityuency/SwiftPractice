//
//  CZEmoticon.swift
//  练手微博
//
//  Created by yuency on 18/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit
import YYModel

/// 表情模型
class CZEmoticon: NSObject {
    
    /// 表情类型 false - 图片表情 / true - emoji
    var type = false
    /// 表情字符串,发送到新浪微博服务器,节约流量
    var chs: String?
    /// 表情图片名称,用于本地图文混排
    var png: String?
    /// emoji 的十六进制编码
    var code: String? {
        didSet{
            guard let code = code else {
                return
            }
            let scnner = Scanner(string: code)
            var result: UInt32 = 0
            scnner.scanHexInt32(&result)
            emoji = String(Character(UnicodeScalar(result)!))
        }
    }
    
    /// 表情使用次数
    var times: Int = 0

    /// emoji的字符串
    var emoji: String?
    
    /// 表情符号的目录
    var directory: String?
    
    /// 图片表情对应的图像
    var image: UIImage? {
        
        if type { //如果是 emoji就直接返回
            return nil
        }
        
        guard let directory = directory,
            let png = png,
            let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
            let bundle = Bundle(path: path)
            else {
                return nil
        }
        
        return UIImage(named: "\(directory)/\(png)", in: bundle, compatibleWith: nil)
    }
    
    
    
    func imageText(font: UIFont) -> NSAttributedString {
        
        //1判断句图像是否存在
        guard let image = image else {
            return NSAttributedString(string: "")
        }
        
        //2创建文本附件
        let attchment = CZEmotiocnAttachment()
        attchment.chs = chs //因为系统的 attachment拿不到我们想要的东西. 使用子类,增加属性来记录我们需要的数据. 
        attchment.image = image
        let height = font.lineHeight
        attchment.bounds = CGRect(x: 0, y: -4, width: height, height: height)
        
        //3返回图片属性文本
        let attrStrM = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attchment))
        //设置字体属性
        attrStrM.addAttributes([NSFontAttributeName: font], range: NSRange(location: 0, length: 1))
        //返回属性文本
        return attrStrM
    }
    
    override var description: String {
        return yy_modelDescription()
    }
}

//1 使用字典转模型的时候, 需要继承自NSObject
//2 对于布尔类型,要设定初始值
//3 变量都使用 var, 设定为可选型
