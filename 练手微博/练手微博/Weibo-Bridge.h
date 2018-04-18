//
//  Weibo-Bridge.h
//  练手微博
//
//  Created by yuency yang on 27/06/2017.
//  Copyright © 2017 yuency yang. All rights reserved.
//

//下面的这些东西可以随便起, 无所谓
//#ifndef Weibo_Bridge_h
//#define Weibo_Bridge_h
//
//
//#endif /* Weibo_Bridge_h */


//桥接文件,专门用于引入 OC 的头文件, 一旦引入, Swift 就可以正常使用 (宏除外)
/**
 1.创建桥接文件, 也就是 OC 的头文件
 2.在这里 import 需要使用的头文件
 3.在 build settings里面 `bridg` -> Objective-C Bridging Header -> 写入头文件名字 "项目名/桥文件名"
 */


#import "CZAdditions.h"
#import "HMPhotoBrowserController.h"

