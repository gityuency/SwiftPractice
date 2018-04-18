//
//  WBStatusToolbar.swift
//  练手微博
//
//  Created by yuency on 12/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

class WBStatusToolbar: UIView {
    
    var viewModel: WBStatusViewModel? {
    
        didSet {
            retweetedButton.setTitle(viewModel?.retweetedStr, for: [])
            commentButton.setTitle(viewModel?.commentStr, for: [])
            likeButton.setTitle(viewModel?.likeStr, for: [])
        } 
    }
    
    /// 转发
    @IBOutlet weak var retweetedButton: UIButton!
    /// 评论
    @IBOutlet weak var commentButton: UIButton!
    /// 点赞
    @IBOutlet weak var likeButton: UIButton!
    
}
