//
//  WBStatusCell.swift
//  练手微博
//
//  Created by yuency on 11/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit


/// 微博 cell 的协议, 点击了微博 cell 中的链接, 需要通知控制器来跳转页面, 子控件向父控件传值, 写代理
/// - 需要遵守 NSObjectProtocol
/// - 协议 @objc
/// - 方法 @objc optional
@objc protocol WBStatusCellDelegate: NSObjectProtocol {  //注意,这里需要继承 NSObjectProtocol, 就这么写. 没有给理由
    
    /// 微博 cell 选中 URL 字符串
    /// 如果代理方法是可选的(optional), 那么代理方法和协议前面都需要加上 @objc
    @objc optional func statusCellDidTapUrlString(cell: WBStatusCell, urlString: String)
    
    
}


class WBStatusCell: UITableViewCell {
    
    
    /// 代理属性要这么写, 弱引用, 可选, var,
    weak var delegate: WBStatusCellDelegate?
    
    
    /// 微博视图模型
    var viewModel: WBStatusViewModel? {
        didSet{
            //微博文本
            statusLabel.attributedText = viewModel?.statusAttrText
            
            //设置被转发微博的文字
            retweedLabel?.attributedText = viewModel?.retweetedAttrText
            
            //姓名
            nameLabel.text = viewModel?.status.user?.screen_name
            
            //判断 mbrank 的值,来设置图标,这个设置放到了 ViewModel 里面, 就不用每次刷表格的时候去算用哪个图标
            menberIconView.image = viewModel?.memberIcon
            
            //认证图标
            vipIconView.image = viewModel?.vipIcon
            
            //用户头像
            iconView.cz_setImage(urlString: viewModel?.status.user?.profile_image_url, placeholderImage: UIImage(named: "avatar_default_big"), isAvatar: true)
            
            //底部工具栏
            toolBar.viewModel = viewModel
            
            //配图视图的模型
            pictureView.viewModel = viewModel
            
            
            //设置配图视图的 URL 数据
            //测试4张图像
            //            if (viewModel?.status.pic_urls?.count)! > 4 {
            //                var picurls = viewModel!.status.pic_urls
            //                picurls?.removeSubrange(((picurls?.startIndex)! + 4)..<(picurls?.endIndex)!)
            //                pictureView.urls = picurls
            //            } else {
            //                pictureView.urls = viewModel?.status.pic_urls
            //            }
            
            
            //设置来源
            sourceLabel.text = viewModel?.status.source
            
            //设置时间
            timeLabel.text = viewModel?.status.createDate?.cz_dateDescription
            
        }
    }
    
    
    /// 头像
    @IBOutlet weak var iconView: UIImageView!
    /// 姓名
    @IBOutlet weak var nameLabel: UILabel!
    /// 会员图标
    @IBOutlet weak var menberIconView: UIImageView!
    /// 时间
    @IBOutlet weak var timeLabel: UILabel!
    /// 来源
    @IBOutlet weak var sourceLabel: UILabel!
    /// 认证图标
    @IBOutlet weak var vipIconView: UIImageView!
    /// 微博正文
    @IBOutlet weak var statusLabel: FFLabel!
    /// 底部工具栏
    @IBOutlet weak var toolBar: WBStatusToolbar!
    /// 配图视图
    @IBOutlet weak var pictureView: WBStatusPictureView!
    
    
    /// 被转发微博的标签 - 原创微博是没有这个控件的 一定要改成 ? 不能使用 !
    @IBOutlet weak var retweedLabel: FFLabel?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //离屏渲染 - 异步绘制  会使得表格更流畅,但是 CPU 会消耗更多 就这么一句话
        self.layer.drawsAsynchronously = true
        //栅格化 - 异步绘制之后会生成一张独立的图像 cell 在屏幕上滚动的时候,本质上是滚动这张图片,
        //cell优化, 要减少图层的数量, 相当于只有一层
        //停止滚动之后可以接收监听
        self.layer.shouldRasterize = true
        //使用`栅格化` 必须注意指定分辨率
        self.layer.rasterizationScale = UIScreen.main.scale
        
        //设置微博文本代理
        statusLabel.delegate = self
        retweedLabel?.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


extension WBStatusCell: FFLabelDelegate {
    
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        
        //判断是否是 URL
        if !text.hasPrefix("http://") {
            return
        }
        
        // 手动改写 插入 ? 表示如果代理 没有实现 协议方法, 就什么都不做
        // 系统提示 插入 ! 表示如果代理 没有实现 协议方法, 仍然强行执行,会崩溃
        delegate?.statusCellDidTapUrlString?(cell: self, urlString: text)
        
    }
    
}




