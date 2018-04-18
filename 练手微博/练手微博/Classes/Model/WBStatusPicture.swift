//
//  WBStatusPicture.swift
//  练手微博
//
//  Created by yuency on 12/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit


/// 微博配图模型
class WBStatusPicture: NSObject {

    /// 缩略图地址 - 新浪服务器返回的缩略图地址简直惨, 造成页面上显示不清晰, 在这里更改一下缩略图的地址
    var thumbnail_pic: String? {
        didSet{
            //设置大等尺寸图片
            largePic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/large/")
            
            //设置 cell 中的图片
            thumbnail_pic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/wap360/")
        }
    }
    
    
    /// 大等尺寸的图片
    var largePic: String?
    
    override var description: String {
        return yy_modelDescription()
    }
    
}
