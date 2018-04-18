//
//  WBKeyBoardTestViewController.swift
//  练手微博
//
//  Created by yuency on 21/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

class WBKeyBoardTestViewController: UIViewController {
    
    
    @IBOutlet weak var textView: UITextView!
    
    //表情输入视图, 这里需要注意循环引用!!! 类引用了闭包, 闭包中引用了自己
    lazy var emoticonView: CZEmoticonInputView = CZEmoticonInputView.inputView {[weak self]  (em) in
        self?.insertEmoticon(em: em)
    }
    
    
    func insertEmoticon(em: CZEmoticon?) {
        
        guard let em = em else { // nil 是删除按钮
            //删除按钮的动作
            textView.deleteBackward()
            return
        }
        
        //emoji 字符串
        if let emoji = em.emoji, let textRange = textView.selectedTextRange {
            //UITextRange 仅用在此处!!
            textView.replace(textRange, withText: emoji)
            return
        }
        
        //代码执行到这个地方,都是图片
        //0.获取表情中的图像属性文本
        /*
         所有的排版系统中,几乎都有一个共同的特点,插入的字符的显示,跟随前一个字符的属性,但是本身没有 `属性`
         */
        let imageText = em.imageText(font: textView.font!)
        
        //1.获取当前 textView 的属性文本 => 可变的
        let attrStrM = NSMutableAttributedString(attributedString: textView.attributedText)
        //2.将图像的属性文本插入到当前光标的位置
        attrStrM.replaceCharacters(in: textView.selectedRange, with: imageText)
        
        //3.重新设置属性文本
        //记录光标位置
        let range = textView.selectedRange
        //设置文本
        textView.attributedText = attrStrM
        //恢复光标位置 //location 位置+1这样光标就退后一个位置,正好显示在插入的表情的后面  length: 直接写0,选中字符的长度, 如果使用 range.length, 在替换选中文本的时候, 插入表情之后,会直接选中后面的字符串,引起 bug
        textView.selectedRange = NSRange(location: range.location + 1, length: 0)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        textView.inputView = emoticonView
        textView.reloadInputViews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    
    private func setupUI() {
        self.title = "测试表情键盘"
        view.backgroundColor = UIColor.cz_random()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", target:  self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "显示", target:  self, action: #selector(showText))
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func showText() {
        
        print(emoticonText)
        
    }
    
    /// 返回 TextView 对应的纯文本的字符串,将属性图片再次转换成文字
    var emoticonText: String {
        
        //获取 textView 的属性文本
        guard let attrStr = textView.attributedText else {
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
    
    
}
