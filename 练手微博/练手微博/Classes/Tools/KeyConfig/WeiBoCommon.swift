//
//  WeiBoCommon.swift
//  练手微博
//
//  Created by yuency on 07/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import Foundation

// MARK: - 应用程序信息,从新浪微博拷贝过来的
let WBAppKey = "3217728273"
let WBAppSecret = "fd3c8cd80e008bb14726de1fbbace2d8"
let WBredirectURI = "http://baidu.com"

// MARK: - 全局通知定义
/// 用户需要登录的通知
let WBUserShouldLoginNotification = "WBUserShouldLoginNotification"

/// 用户登录成功通知
let WBUserLoginSuccessNotification = "WBUserLoginSuccessNotification"
		


// MARK: - 微博配图视图常量
//计算配图视图的宽度
//常数准备
//配图视图外侧间距
let WBStatusPictureViewOtterMargin = CGFloat(12)
//配图视图内部图像视图的间距
let WBStatusPictureViewInnerMargin = CGFloat(3)
//视图宽度
let WBStatusPictureViewWidth = UIScreen.cz_screenWidth() - 2 * WBStatusPictureViewOtterMargin
//每个 item 默认的宽度
let WBStatusPictureViewItemWidth = (WBStatusPictureViewWidth - 2 * WBStatusPictureViewInnerMargin) / 3



// MARK : - 照片通知定义 微博 cell 浏览照片通知
/// @param selectedIndex    选中照片索引
/// @param urls             浏览照片 URL 字符串数组
/// @param parentImageViews 父视图的图像视图数组，用户展现和解除转场动画参照
let WBstatusCellBrowserPhotoNotification = "WBstatusCellBrowserPhotoNotification"
/// 选中索引key
let WBstatusCellBrowserPhotoSelectedIndexKey = "WBstatusCellBrowserPhotoSelectedIndexKey"
/// 浏览照片 URL 字符串 key
let WBstatusCellBrowserPhotoURLsKey = "WBstatusCellBrowserPhotoURLsKey"
/// 父视图的图像视图数组 Key
let WBstatusCellBrowserPhotoImageViewsKey = "WBstatusCellBrowserPhotoImageViewsKey"

