//
//  CZEmoticonLayout.swift
//  练手微博
//
//  Created by yuency on 21/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

/// 表情集合视图的布局
class CZEmoticonLayout: UICollectionViewFlowLayout {

    /// 这个东西就是 OC 中的 prepareLayout
    /// 然后去 XIB 选中那个 CollectionView, 然后指定它的 Layout 为当前的这个类
    /// 可以再 XIB 中指定集合视图的一些属性. 就不用写代码了
    override func prepare() {
        super.prepare()
        
        //这个方法中,collectionView 的方法已经确定
        guard let collectionView = collectionView else {
            return
        }
        
        //把格子大小设置和集合视图大小一样
        itemSize = collectionView.bounds.size
        
        //设置行间距
        //minimumLineSpacing = 0  //可以在 XIB collectionView 中的 Layout 中指定这个属性
        //设置格子间距
        //minimumInteritemSpacing = 0 //可以在 XIB collectionView 中的 Layout 中指定这个属性
        
        
        //设定滚动方向
        // 水平方向滚动, cell 垂直方向布局
        // 垂直方向滚动, cell 水平方向布局
        scrollDirection = .horizontal
        
        
        
        
    }
    
    
}
