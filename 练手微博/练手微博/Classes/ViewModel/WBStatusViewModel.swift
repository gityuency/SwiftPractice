//
//  WBStatusViewModel.swift
//  练手微博
//
//  Created by yuency on 12/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import Foundation

/**
 关于微博的视图模型
 - 尽量少计算,所有的素材提前计算好
 - 尽量不要设置圆角半径, 所有的图像渲染的属性,都要注意
 - 不要动态创建控件,所有需要的控件吗,都要提前计算好,根据数据隐藏/显示
 - cell 中控件的层次越少越好.数量越少越好
 - 要测量,不要猜测
 */


/// 单条微博的视图模型, 如果没有任何的父类, 在开发的时候需要
class WBStatusViewModel: CustomStringConvertible {
    
    var status: WBStatusModel
    
    /// 会员图标 - 存储型的属性
    var memberIcon: UIImage?
    /// 认证类型 -1 没有认证 0认证用户 2.3.5企业认证, 220达人
    var vipIcon: UIImage?
    /// 转发文字
    var retweetedStr: String?
    /// 评论文字
    var commentStr: String?
    /// 点赞文字
    var likeStr: String?
    
    /// 配图视图的大小
    var pictureViewSize = CGSize() //这么写默认就是0
    
    
    /// 如果是被转发的微博,原创微博一定没有图
    var picURLs: [WBStatusPicture]? {
        // 如果有被转发的微博,返回被转发微博的配图
        // 如果没有被转发的微博,返回原创微博的配图
        // 如果都没有,返回 nil
        return status.retweeted_status?.pic_urls ?? status.pic_urls
    }
    
    
    ///微博正文属性文本
    var statusAttrText: NSAttributedString?
    /// 转发文字的属性文本
    var retweetedAttrText: NSAttributedString?

    /// 被转发微博的文字
    var retweedText: String?
    
    
    /// 要开始计算行高了
    var rowHeight: CGFloat = 0
    
    
    /// 构造函数
    ///
    /// - Parameter model: 微博模型
    init(model: WBStatusModel) {
        self.status = model
        
        //会员等级 - 直接计算 (用内存换 CPU)
        if (model.user?.mbrank)! > 0 && (model.user?.mbrank)! < 7 {
            let imageName = "common_icon_membership_level\(model.user?.mbrank ?? 1)"
            memberIcon = UIImage(named: imageName)
        }
        
        //认证图标
        switch model.user?.verified_type ?? -1 {
        case 0:
            vipIcon =  UIImage(named: "avatar_vip")?.cz_avatarImage(size: nil)
        case 2,3,5:
            vipIcon = UIImage(named: "avatar_enterprise_vip")?.cz_avatarImage(size: nil)
        case 220:
            vipIcon = UIImage(named: "avatar_grassroot")?.cz_avatarImage(size: nil)
        default:
            break
        }
        
        //设置底部计数字符串
        //测试超过一万的字符串
        //model.reposts_count = Int(arc4random_uniform(100000))
        retweetedStr = countString(count: model.reposts_count, defaultStr: "转发")
        commentStr = countString(count: model.comments_count, defaultStr: "评论")
        likeStr = countString(count: model.attitudes_count, defaultStr: "赞")
        
        //计算配图视图大小 (有原创的就计算原创的, 有转发的就就计算转发的)
        pictureViewSize = calcPictureViewSize(count: picURLs?.count)
        
        //-------- 设置微博文本 --------
        let originalFont = UIFont.systemFont(ofSize: 15)
        let retweetedFont = UIFont.systemFont(ofSize: 14)
        //微博正文属性文本
        statusAttrText = CZEmoticonManager.shared.emoticonString(string: model.text ?? "", font: originalFont)
        //拼接转发微博的文字
        let rText = "@"
            + (status.retweeted_status?.user?.screen_name ?? "")
            + ":" + (status.retweeted_status?.text ?? "")
        
        retweetedAttrText = CZEmoticonManager.shared.emoticonString(string: rText, font: retweetedFont)
        
        
        // 计算行高
        updateRowHeight()
        
    }
    
    /// CustomStringConvertible 需要遵守这个协议才能重写这个方法 这是个计算型的属性
    var description: String {
        return status.description
    }
    
    
    
    /// 根据当前的视图模型内容计算行高
    func updateRowHeight() {
        // 原创微博：顶部分隔视图(12) + 间距(12) + 图像的高度(34) + 间距(12) + 正文高度(需要计算) + 配图视图高度(计算) + 间距(12) ＋ 底部视图高度(35)
        // 被转发微博：顶部分隔视图(12) + 间距(12) + 图像的高度(34) + 间距(12) + 正文高度(需要计算) + 间距(12)+间距(12)+转发文本高度(需要计算) + 配图视图高度(计算) + 间距(12) ＋ 底部视图高度(35)
        
        let margin: CGFloat = 12
        let iconHeight: CGFloat = 34
        let toolBarheight: CGFloat = 35
        
        var height: CGFloat = 0
        
        let viewSize = CGSize(width: UIScreen.cz_screenWidth() - 2 * margin, height: CGFloat(MAXFLOAT))
        
        //1.计算顶部位置
        height = margin + margin + iconHeight + margin
        
        //2.正文属性文本的高度
        if let text = statusAttrText {
            //属性文本 本身已经包含了字体属性,所以少了attributes这个参数
            height += text.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], context: nil).height
        }
        
        //3.判断是否转发微博
        if status.retweeted_status != nil {
            
            height += 2 * margin
            
            //战法文本的高度一定要用 retweedText, 因为做过了拼接
            if let text = retweetedAttrText {
                height += text.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], context: nil).height
            }
        }
        
        //4.配图视图的高度
        height += pictureViewSize.height
        height += margin
        
        //5.底部工具栏
        height += toolBarheight
        
        //6.使用属性记录
        rowHeight = height
        
    }
    
    
    
    /// 使用单个图像更新配图视图的大小
    ///
    /// - Parameter image: 网络缓存的单张图像
    func updateSingleImageSize(image: UIImage) {
        
        var size = image.size

        let maxWidth: CGFloat = 200
        let minWidth: CGFloat = 40
        
        //过宽图像处理
        if size.height > maxWidth {
            //设置最大宽度 (单图)
            size.width = 200
            //等比例调整高度
            size.height = size.width * image.size.height / image.size.width
        }
        
        //过窄图像处理
        if size.width < minWidth {
            size.width = minWidth
            size.height = size.width * image.size.height / image.size.width  / 4
        }
        
        
        //图片过高处理 - 图片的填充模式就是 scaleToFill, 高度减小会自动裁切
        if size.height > 200 {
            size.height = 200
        }
        
        //注意,尺寸需要增加顶部的12个点
        size.height += WBStatusPictureViewOtterMargin
        
        //重新设置配图视图的大小
        pictureViewSize = size
        
        //更新行高
        updateRowHeight()
        
    }
    
    
    
    /// 计算指定数量的图片对应的配图视图的大小
    ///
    /// - Parameter count: 配图数量
    /// - Returns: 配图视图的大小
    private func calcPictureViewSize(count: Int?) -> CGSize {
        
        if count == 0 || count == nil { //在判断这个东西的时候, 格子数为0 或者 是没有,
            return CGSize()
        }
        
        //常量设置已经移动到 WeiBoCommon.swift
        
        //计算高度
        //根据 count 知道行数 1 ~ 9
        /*
         1 2 3 = 0 1 2 / 3 = 0 + 1 = 1
         4 5 6 = 3 4 5 / 3 = 1 + 1 = 2
         7 8 9 = 6 7 8 / 3 = 2 + 1 = 3
         */
        let row = (count! - 1) / 3 + 1
        
        //根据行数计算高度
        var height = WBStatusPictureViewOtterMargin
        height += CGFloat(row) * WBStatusPictureViewItemWidth
        height += CGFloat(row - 1) * WBStatusPictureViewInnerMargin
        
        return CGSize(width: WBStatusPictureViewWidth, height: height)
    }
    
    
    
    /// 给定一个数字,返回对应的描述结果
    ///
    /// - Parameters:
    ///   - count: 数字
    ///   - defaultStr: 默认的字符串 转发/评论/赞
    /// - Returns: 描述结果
    /* 1.如果数量 == 0 显示默认标题  2.如果数量超过10000,显示 x.xx万, 3.如果数量 < 10000显示实际数字 */
    private func countString(count: Int, defaultStr: String) -> String {
        
        if count == 0 {
            return defaultStr
        }
        if count < 10000 {
            return count.description
        }
        return String(format: "%.02f 万",  (Double(count) / 10000))  // Double(a/1000)这是错误的写法.
    }
    
    
}
