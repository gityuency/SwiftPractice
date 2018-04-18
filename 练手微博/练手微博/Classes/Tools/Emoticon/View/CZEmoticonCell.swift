//
//  CZEmoticonCell.swift
//  练手微博
//
//  Created by yuency on 21/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

/// 表情 cell 的协议
@objc protocol CZEmoticonCellDelegate: NSObjectProtocol {

    /// 选中的表情 em表情模型, nil 表示删除
    func emoticonCellDidSelectedEmoticon(cell: CZEmoticonCell, em: CZEmoticon?)

}


/// 表情的页面 cell , 每一个 cell 用九宫格算法自行添加 20个表情
/// 每一个 cell 就是和 collectionView 一样大小
/// 3 * 7 最后一个位置放删除按钮
class CZEmoticonCell: UICollectionViewCell {
    
    /// 代理, weak var 可选
    weak var delegate: CZEmoticonCellDelegate?
    
    /// 当前页的表情模型数组,最多20个
    var emoticons: [CZEmoticon]? {
        didSet {
            // 因为这些按钮又是一次性全部创建出来的, 所以先隐藏再显示
            // 这些 cell 添加控件都往 contentView上 添加
            for v in contentView.subviews {
                v.isHidden = true
            }
            
            //显示删除按钮
            contentView.subviews.last?.isHidden = false
            
            //遍历表情数组
            for (i, em) in (emoticons ?? []).enumerated() {
                
                //取出按钮
                if let btn = contentView.subviews[i] as? UIButton {
                    
                    // 设置图像 - 如果图像为 nil, 会清空图像,避免复用 ,不要画蛇添足写   if em.emoji != nil { ... }
                    btn.setImage(em.image, for: [])
                    
                    //设置 emoji 的字符串 如果 emoji 为 nil, 会清空 title,避免复用
                    btn.setTitle(em.emoji, for: [])
                    
                    btn.isHidden = false
                }
            }
        }
    }
    
    
    /// 表情选择提示视图 - 懒加载
    private lazy var tipView = CZEmotiocnTipView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        guard let w = newWindow else {
            return
        }
        
        //将提示窗口添加到 Window上
        w.addSubview(tipView)
        tipView.isHidden = true
    }
    
    
    ///设置界面
    ///从 XIB 中加载, bounds 是 XIB 中定义的大小,不是 size 的大小
    /// 如果是从纯代码创建, bounds 就是布局属性中设置的 itemSize (在CZEmoticonLayout -> itemSize = collectionView.bounds.size)
    private func setupUI() {
        
        let rowCount = 3 //行
        let colCount = 7 //列
        
        //左右间距
        let lrMargin: CGFloat = 8
        //底部间距,为了分页控件预留
        let bottomMargin: CGFloat = 16
        
        //宽
        let w = (bounds.width - 2 * lrMargin) / CGFloat(colCount)
        //高
        let h = (bounds.height - bottomMargin) / CGFloat(rowCount)
        
        //连续创建21个按钮 3 * 7
        for i in 0..<21 {
            
            //行 0,1,2 算法和行数rowCount无关
            let row = i / colCount
            //列 0,1,2,3,4,5,6 算法和行数rowCount无关
            let col = i % colCount
            
            let btn = UIButton()
            
            //设置按钮的带下
            let x = lrMargin + CGFloat(col) * w
            let y = CGFloat(row) * h
            btn.frame = CGRect(x: x, y: y, width: w, height: h)
            
            btn.backgroundColor = UIColor.red
            contentView.addSubview(btn)
            
            //设置按钮的字体大小, (就是放大 emoji ,)  lineHeight 基本上和图片大小差不多
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
            
            //设置按钮的 tag
            btn.tag = i
            btn.addTarget(self, action: #selector(selectedEmoticonButton(btn:)), for: .touchUpInside)
            
        }
        
        //取出末尾的删除按钮
        let removeBtn = contentView.subviews.last as! UIButton
        //不要带上@2x
        let image = UIImage(named: "compose_emotion_delete", in: CZEmoticonManager.shared.bundel, compatibleWith: nil)
        removeBtn.setImage(image, for: [])
        
        //添加长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longGesture))
        longPress.minimumPressDuration = 0.1
        addGestureRecognizer(longPress)
        
    }
    
    
    
    /// 长按手势 - 可以保证一个对象监听两种手势, 而且不需要考虑解决手势冲突
    @objc private func longGesture(gesture: UILongPressGestureRecognizer) {
        
        //1.获取触摸的位置
        let location = gesture.location(in: self)
        
        //2.获取触摸位置对应的按钮
        guard let button = buttonWithLocation(location: location) else {
            return
        }
        
        //3.处理手势状态 - 在处理手势细节的时候,不要试图一下子把所有状态都处理完毕
        switch gesture.state {
        case .began, .changed:
            tipView.isHidden = false
            
            //坐标系的转换, -> 将按参照 cell 的坐标系,转换到 Window的坐标位置
            let center = self.convert(button.center, to: window)
            
            //设置位置
            tipView.center = center
            
            //设置提示视图的表情模型
            if button.tag < (emoticons?.count ?? 0) {
                tipView.emoticon = emoticons?[button.tag]
            }
            
        case .ended:
            tipView.isHidden = true
            //执行选中按钮的函数
            selectedEmoticonButton(btn: button)
            
        case .cancelled, .failed:
            tipView.isHidden = true
            
        default:
            break
        }        
    }
    
    
    private func buttonWithLocation(location: CGPoint) -> UIButton? {
        
        //遍历contentView所有的子视图, 如果可见,并且同时在 location 上,就确认是按钮
        for btn in contentView.subviews as! [UIButton] {
            
            //去掉隐藏的按钮, 最后一个按钮,
            if btn.frame.contains(location) && !btn.isHidden && btn != contentView.subviews.last {
                return btn
            }
        }
        return nil
    }
    
    
    
    ///MARK:- 按钮的监听方法, 选中表情按钮
    @objc private func selectedEmoticonButton(btn: UIButton) {
        
        // 0~20, 20对应的是删除按钮
        let tag = btn.tag
        
        //根据 tag 判断是否是删除按钮
        var em: CZEmoticon?
        if tag < (emoticons?.count)! {
            em = emoticons?[tag]
        }
        
        delegate?.emoticonCellDidSelectedEmoticon(cell: self, em: em)
    }
    
    
    
}
