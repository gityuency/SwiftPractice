//
//  UIImageView+WebImage.swift
//  练手微博
//
//  Created by yuency on 12/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import SDWebImage

extension UIImageView {
    
    
    /// 隔离SDWebImage设置头像
    ///
    /// - Parameters:
    ///   - urlString: 头像的 string 地址
    ///   - placeholderImage: 展位图像
    ///   - isAvatar: 是否是头像
    func cz_setImage(urlString: String?, placeholderImage: UIImage?, isAvatar: Bool = false) {
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            //设置站位图像
            image = placeholderImage
            
            return
        }
        
        //可选项只是用在 Swift 中, OC 有时候用 ! 同样可以传入 nil
        //这里要防止循环引用, 这个东西调用了自己的方法,自己的方法里面有闭包, 在闭包里面还调用了自己的属性
        sd_setImage(with: url, placeholderImage: placeholderImage, options: [], progress: nil) {[weak self] (image, _, _, _) in
            //完成回调. 判断是否是头像
            if isAvatar {
                self?.image = image?.cz_avatarImage(size: self?.bounds.size)
            }
        }
    }
    
    
    
    /// 直接设置被裁切后的图像 Cell 中使用的图像. 这个办法并不是很好, 图像的显示内容变得有限.
    ///
    /// - Parameters:
    ///   - urlString: 头像的 string 地址
    ///   - placeholderImage: 展位图像
    ///   - isAvatar: 是否是头像
    func yy_setImage(urlString: String?, placeholderImage: UIImage?) {
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            //设置站位图像
            image = placeholderImage
            return
        }
        
        //可选项只是用在 Swift 中, OC 有时候用 ! 同样可以传入 nil
        //这里要防止循环引用, 这个东西调用了自己的方法,自己的方法里面有闭包, 在闭包里面还调用了自己的属性
        sd_setImage(with: url, placeholderImage: placeholderImage, options: [], progress: nil) {[weak self] (image, _, _, _) in
            //直接设置被重新裁切后的图像
            self?.image = image?.cz_image(size: self?.bounds.size, backColor: UIColor.clear)
        }
    }
}


