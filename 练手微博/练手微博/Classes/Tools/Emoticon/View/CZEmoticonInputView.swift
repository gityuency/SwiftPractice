//
//  CZEmoticonInputView.swift
//  POD
//
//  Created by yuency on 20/07/2017.
//  Copyright © 2017 yuency yang. All rights reserved.
//

import UIKit

//在 XIB 中拖拽代理和数据源的时候, 因为这是个 View. 这次拖动的代理 是 Emoticon Input View 不是 File's Owner

//可重用标示符
private let cellID = "cellID"

class CZEmoticonInputView: UIView {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    /// 工具栏
    @IBOutlet weak var toolBar: CZEmoticonToolBar! //这里需要改一下类型,在设置代理的时候
    /// 分页控件
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    /// 选中表情闭包回调属性 1.整个闭包设置成为可选
    var selectedEmoticonCallBack: ((_ emoticon: CZEmoticon?) -> ())?
    
    
    /// 键盘视图的实例化方法,给外界调用的时候只用了这一句, 为了让外界能够获得选中的表情, 在这里使用闭包传递这个表情
    class func inputView(seclectedEmoticon: @escaping (_ emoticon: CZEmoticon?) -> ()) -> CZEmoticonInputView {
        
        let nib = UINib(nibName: "CZEmoticonInputView", bundle: nil)
        let view =  nib.instantiate(withOwner: nil, options: nil)[0] as! CZEmoticonInputView; //这里强制解包
        
        //类方法里面不能执行闭包,需要用一个属性来进行引用
        //记录闭包
        view.selectedEmoticonCallBack = seclectedEmoticon
        
        return view
    }
    
    
    override func awakeFromNib() {
        //使用代码加载, 为了取得 cell 的 bounds
        collectionView.register(CZEmoticonCell.self, forCellWithReuseIdentifier: cellID)
        
        //设置工具栏代理 - 这里已经加载完了这个工具栏
        toolBar.delegate = self;
        
        //设置分页控件的图片
        let bundle = CZEmoticonManager.shared.bundel
        guard let normalImage = UIImage(named: "compose_keyboard_dot_normal", in: bundle, compatibleWith: nil),
            let selectedImage = UIImage(named: "compose_keyboard_dot_selected", in: bundle, compatibleWith: nil) else {
                return
        }
        
        
        // 使用这两句话设置他的 indecator 会有拉伸破缺的效果.
        //pageControl.pageIndicatorTintColor = UIColor(patternImage: normalImage)
        //pageControl.currentPageIndicatorTintColor = UIColor(patternImage: selectedImage)
        // 使用 KVC 设置私有成员属性
        pageControl.setValue(normalImage, forKey: "_pageImage")
        pageControl.setValue(selectedImage, forKey: "_currentPageImage")
    }
    
}


// MARK: - 底部工具栏的代理
extension CZEmoticonInputView: CZEmoticonToolBarDelegate {

    func emoticonToolBarDidSelectedItemIndex(toolBar: CZEmoticonToolBar, index: Int) {
     
        //让 collectionview 发生滚动 - 滚动到每一个分组的第 0 页
        let indexPath = IndexPath(item: 0, section: index)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
        //设置分组按钮的选中状态
        toolBar.selectedIndex = index
    }

}




// MARK: - 集合视图事件代理
extension CZEmoticonInputView: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //1.获取中心点
        var center = scrollView.center
        center.x += scrollView.contentOffset.x
        
        //2.获取当前显示的cell 的 indexPath
        let paths = collectionView.indexPathsForVisibleItems
        
        //3.判断中心点在哪一个 indexPath 上,在哪一个页面上
        var targetIndexPath: IndexPath?
        
        for indexPath in paths {
            
            //1.根据 indexPath 获取 cell
            let cell = collectionView.cellForItem(at: indexPath)
            //2.判断中心点位置
            if cell?.frame.contains(center) == true {
                targetIndexPath = indexPath
                break
            }
        }
        
        guard let target = targetIndexPath else {
            return
        }
        //4.判断是否找到目标
        toolBar.selectedIndex = target.section
        
        //设置分页控件, 每个大组设置了分页, 每个小组也设置了分页
        pageControl.numberOfPages = collectionView.numberOfItems(inSection: target.section)
        pageControl.currentPage = target.item
        
    }
    
}



// MARK: - 集合视图数据源代理
extension CZEmoticonInputView: UICollectionViewDataSource {
    
    //分组数量 返回表情包的数量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return CZEmoticonManager.shared.packages.count
    }
    
    //返回每个分组中表情 页 的数量
    //每个分组的表情包中表情页面的数量 emoticons 数组 / 20
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CZEmoticonManager.shared.packages[section].mumberOfPages
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CZEmoticonCell
        
        cell.emoticons = CZEmoticonManager.shared.packages[indexPath.section].findEmotiocn(page: indexPath.item)
        

        //设置代理,不适合用闭包
        cell.delegate = self
        
        return cell
    }
    
}

//MARK : - cell 代理
extension CZEmoticonInputView: CZEmoticonCellDelegate {

    
    /// 选中的表情回调
    ///
    /// - Parameters:
    ///   - cell: 分页 cell
    ///   - em:  选中的表情,删除键为 nil
    func emoticonCellDidSelectedEmoticon(cell: CZEmoticonCell, em: CZEmoticon?) {
             
        //执行闭包
        selectedEmoticonCallBack?(em)
        
        //添加最近使用的表情
        guard let em = em else {
            return
        }
        
        //如果当前的 collectionView 就是最近的分组,不添加最近使用的表情,要不然最近分组的表情点击就会排序
        let indexPath = collectionView.indexPathsForVisibleItems[0] //取得当前可见的索引
        if indexPath.section == 0 {
            return
        }
        
        
        CZEmoticonManager.shared.recentEmoticon(em: em)
        
        //刷新数据 - 第 0 组
        var indexSet = IndexSet()
        indexSet.insert(0)
        
        collectionView.reloadSections(indexSet)
    }
}


