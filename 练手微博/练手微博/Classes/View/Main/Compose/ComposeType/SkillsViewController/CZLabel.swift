//
//  CZLabel.swift
//  练手微博
//
//  Created by yuency on 19/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

// 让链接文本变得高亮并且可以进行交互
/*
 1.使用 TextKit 接管 label底层实现 - `绘制` textStroage的文本内容
 2.使用正则过滤 URL, 设置 url 的特殊显示
 3.交互
 
 UIlabel 默认不能实现顶部垂直对齐, 使用 TextKit 可以实现顶部垂直对齐
 - 提示 iOS7.0 之前,实现相同的效果需要 CoreText
 
 - TextKit 性能还是不错的
 - YYText 自己建立了一套渲染系统
 */

class CZLabel: UILabel {
    
    
    /// 外部设置 text 的时候,需要重新准备文本内容
    /// 一旦内容变化,需要 textStorage 响应变化
    override var text: String? {
        didSet{
            prepareTextContent()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //在构造函数里面接管文本内容
        prepareTextSystem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented") //这个代码是禁止 XIB 使用这个类的.(在控制器里有一个 label, 更改了自定义类型为当前类, 这句话还在就直接崩溃)
        
        //使用下面的代码就可以让 XIB 使用当前类
        super.init(coder: aDecoder)
        
        //在构造函数里面接管文本内容
        prepareTextSystem()
    }
    
    
    /// 在这里需要拦截处理交互
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //1.获取用户点击的位置
        guard let location = touches.first?.location(in: self) else {
            return
        }
        
        //2.获取当前点中字符的索引, 这个索引可以具体到哪一个字符
        let idx = layoutManager.glyphIndex(for: location, in: textContainer)
        print("点击了第 \(idx) 个字符")
        
        //判断 idx 是否在 URLs的 ranges 范围内, 若果在, 就高亮
        for r in urlRanges ?? [] {
            
            if NSLocationInRange(idx, r) {
                print("需要高亮")
                
                //高亮就修改文本字体属性
                textStorage.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: r)
                
                //如果需要重绘, 需要调用setNeedsDisplay函数. 但不是drawRect
                setNeedsDisplay() //重绘方法
                
            } else {
                print("没有戳中");
            }
        }
    }
    
    /// 绘制文本
    /*
     - iOS 中绘制工作类似于油画, 后绘制的内容会覆盖掉 之前的内容, 绘制背景这局代码要写在绘制字形之前, 如果没有绘制背景这句代码,设置背景attributed 是没效果的
     - 尽量避免使用带透明度的颜色, 会严重影响性能
     */
    override func drawText(in rect: CGRect) {
        
        let range = NSRange(location: 0, length: textStorage.length)
        
        //绘制背景
        layoutManager.drawBackground(forGlyphRange: range, at: CGPoint())
        
        
        //绘制 Glyphs字形
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint())
        
    }
    
    
    /// 重新布局子视图
    override func layoutSubviews() {
        super.layoutSubviews() //这句代码不写会怀疑人生
        
        //指定绘制文本的区域, 就一句话
        textContainer.size = bounds.size
    }
    
    
    // MARK: - TextKit 核心对象
    /// 属性文本存储
    lazy var textStorage = NSTextStorage() //这是可变文本的一个子类
    /// 负责文本 `字形` 布局
    lazy var layoutManager = NSLayoutManager()
    /// 设定文本的绘制范围
    lazy var textContainer = NSTextContainer()
}


// MARK: - 设置 TextKit 核心对象
private extension CZLabel {
    
    func prepareTextSystem() {
        
        //0.开启用户交互
        isUserInteractionEnabled = true
        
        //1.准备文本内容
        prepareTextContent()
        
        
        //2.设置对象的关系
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
    }
    
    /// 准备文本内容, textStorage 接管 label 的内容
    func prepareTextContent() {
        
        if let attributedText = attributedText {
            textStorage.setAttributedString(attributedText)
        } else if let text = text {
            textStorage.setAttributedString(NSAttributedString(string: text))
        } else {
            textStorage.setAttributedString(NSAttributedString(string: ""))
        }
        
        
        //遍历范围数组. 设置 url 文字属性
        for r in urlRanges ?? [] {
            textStorage.addAttributes([NSForegroundColorAttributeName: UIColor.red,
                                       NSBackgroundColorAttributeName: UIColor.init(white: 0.9, alpha: 1.0)
                ], range: r)
        }
    }
}


// MARK: - 正则表达式函数
private extension CZLabel {
    
    //返回 textStorage 中的 URL range 数组
    var urlRanges: [NSRange]? {
        
        //正则表达式
        let pattern = "[a-zA-Z]*://[a-zA-Z0-9/\\.]*"
        
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        //多重匹配
        let matches = regx.matches(in: textStorage.string, options: [], range: NSRange(location: 0, length: textStorage.length))
        
        //遍历数组
        var ranges = [NSRange]()
        
        for m in matches {
            ranges.append(m.rangeAt(0))
        }
        
        return ranges
    }
}









