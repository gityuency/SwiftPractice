//
//  WBComposeTextView.swift
//  练手微博
//
//  Created by yuency on 20/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

/// 撰写微博的文本视图
class WBComposeTextView: UITextView {

    
    /// 懒加载
    private lazy var placeholderLabel = UILabel()
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    /// 从 XIB 加载
    override func awakeFromNib() {
     
        setupUI()
    }
    
    
    /// 设置页面
    private func setupUI() {
        
        //注册通知
        // 通知是一对多,如果其他控件监听当前文本视图的通知,不会影响
        // 如果使用代理,其他控件就 可能 无法使用代理来获得文本框的事件消息,因为代理对象在再次赋值的时候被覆盖掉了
        // 请注意多个代理对象的先后设置时机的问题, 代理本质是一个指针地址. 
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: NSNotification.Name.UITextViewTextDidChange, object: self) //传入了自己...
        
        //self.delegate = self 自己可以当自己的代理对象,自己这时候继承代理,实现方法就可以了,
        
        //设置占位标签
        placeholderLabel.text = "分享新鲜事..."
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8) //这个点自己测量吧
        
        placeholderLabel.sizeToFit()
        addSubview(placeholderLabel)
    }
    
    
    @objc func textChanged() {
        //如果有文本,不显示占位标签,否则显示
        placeholderLabel.isHidden = self.hasText //hasText这个方法是放在协议里面的
    }

    
}

// MARK: - 表情键盘的文字处理方法
extension WBComposeTextView {
    
    /// 返回 TextView 对应的纯文本的字符串,将属性图片再次转换成文字
    var emoticonText: String {
        
        //获取 textView 的属性文本
        guard let attrStr = self.attributedText else {
            return ""
        }
        
        //需要获得属性文本中的图片 Attachment
        /*
         参数1 遍历的范围
         参数2 选项 []
         参数3 闭包
         */
        var result = String()
        
        attrStr.enumerateAttributes(in: NSRange(location: 0, length: attrStr.length), options: [], using: { (dict, range, _) in
            
            //如果字典中包含 "NSAttachment" 这个 key, 就说明是图片,否则是文本
            if let attachment = dict["NSAttachment"] as? CZEmotiocnAttachment {
                
                result += attachment.chs ?? ""
                
            } else {
                let subStr = (attrStr.string as NSString).substring(with: range)
                result += subStr
            }
        })
        
        return result
    }
    
    
    
    /// 处理表情键盘的输入
    func insertEmoticon(em: CZEmoticon?) {
        
        guard let em = em else { // nil 是删除按钮
            //删除按钮的动作
            self.deleteBackward()
            return
        }
        
        //emoji 字符串
        if let emoji = em.emoji, let textRange = self.selectedTextRange {
            //UITextRange 仅用在此处!!
            self.replace(textRange, withText: emoji)
            return
        }
        
        //代码执行到这个地方,都是图片
        //0.获取表情中的图像属性文本
        /*
         所有的排版系统中,几乎都有一个共同的特点,插入的字符的显示,跟随前一个字符的属性,但是本身没有 `属性`
         */
        let imageText = em.imageText(font: self.font!)
        
        //1.获取当前 textView 的属性文本 => 可变的
        let attrStrM = NSMutableAttributedString(attributedString: self.attributedText)
        //2.将图像的属性文本插入到当前光标的位置
        attrStrM.replaceCharacters(in: self.selectedRange, with: imageText)
        
        //3.重新设置属性文本
        //记录光标位置
        let range = self.selectedRange
        //设置文本
        self.attributedText = attrStrM
        //恢复光标位置 //location 位置+1这样光标就退后一个位置,正好显示在插入的表情的后面  length: 直接写0,选中字符的长度, 如果使用 range.length, 在替换选中文本的时候, 插入表情之后,会直接选中后面的字符串,引起 bug
        self.selectedRange = NSRange(location: range.location + 1, length: 0)
        
        //在需要的时候通知代理执行带来方法
        delegate?.textViewDidChange?(self) //使用? 不要使用系统修正的 !
        //执行当前对象的文本变化方法 让代理执行文本变化方法(系统的文本改变方法),要不然图片输入是不会去掉 placeholder 的
        textChanged()
        
    }

}


// MARK: - 文本框代理
//extension UITextView: UITextViewDelegate {
//    
//    /// 文本视图文字变化
//    func textViewDidChange(_ textView: UITextView) {
//        print("自己收到了代理消息! \(textView)")
//    }
//}
