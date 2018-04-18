//
//  CZRefreshControl.swift
//  练手微博
//
//  Created by yuency on 14/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit


/// 下拉刷新状态切换的临界点
private let CZRefreshOffset: CGFloat = 126


/// 刷新状态
///
/// - Normal: 普通状态,什么也不做
/// - Pulling: 超过临界点, 如果放手,开始刷新
/// - WillRefresh: 用户超过临界点,并且放手
enum CZRefreshState {
    case Normal
    case Pulling
    case WillRefresh
}


/// 负责刷新相关的逻辑处理
class CZRefreshControl: UIControl {
    
    
    /// 刷新控件的伏视图. 这里需要下拉刷新控件适用于 表格视图/集合视图, 这里使用 weak 修饰.就不会强引用
    private weak var scrollView: UIScrollView?
    /// 刷新视图
    private lazy var refreshView: CZRefreshView = CZRefreshView.refreshView()
    
    
    //MARK: - 构造函数
    init() {
        super.init(frame: CGRect())
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    

    func  setupUI() {
        backgroundColor = super.backgroundColor
        
        //设置超出边界不显示
        //clipsToBounds = true
        
        //添加刷新视图 - 从 XIB 中加载出来, 默认是 XIB 中指定的宽高
        addSubview(refreshView)
        
        //自动布局  -  设置 XIB 控件中的自动布局需要指定宽高约束
        //第一句话!
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))

        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: refreshView.bounds.width))
        
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: refreshView.bounds.height))

    }
    
    
    ///  addSubView会调用这个方法
    /// 1.当添加到父视图的时候,newSuperview就是父视图  2.当父视图被移除,newSuperview就是 nil
    override func willMove(toSuperview newSuperview: UIView?) {
        
        //记录父视图
        guard let sv = newSuperview as? UIScrollView else {
            return
        }

        //记录父视图
        scrollView = sv
        
        //KVO 监听父视图的 contentOffset,
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    
    /// 本视图从父视图移除
    /// 所有的下拉刷新框架都是监听 父视图的 contentOffset
    /// 所有框架的 KVO 监听实现思路都是这个
    override func removeFromSuperview() {
        
        //superView还存在
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        
        super.removeFromSuperview()
        
        //superView不存在
    }
    
    
    /// 所有 KVO 会调用这个方法  bound.y 的值就是 contentOffset.y的值
    /*
     - 通知中心: 如果不释放,什么也不会发生,但是内存会泄露,会有多次注册的可能
     - KVO: 如果不释放,会崩溃
     */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        print(scrollView?.contentOffset ?? "MMPMMMMPPMPMPMPMP")
        
        guard let sv = scrollView else {
            return
        }
        
        //初始高度应该是0
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        
        if height < 0 { //表格往上拽的时候, 这个东西也能有高度并且出现
            return
        }
        
        
        //根据高度设置刷新控件的 frame
        self.frame = CGRect(x: 0, y: -height, width: sv.bounds.width, height: height)
        
        
        // --- 传递父视图高度, 如果正在刷新中, 不传递
        //把代码放在最合适的地方......
        if refreshView.refreshState != .WillRefresh {
            refreshView.parentViewHeight = height
        }
        
        //判断临界点 - 只需要判断一次, 要不然每次满足条件都会走进来这个方法
        if sv.isDragging { //在拖拽
            
            if height > CZRefreshOffset && (refreshView.refreshState == .Normal) {
                //放手刷新
                refreshView.refreshState = .Pulling
            } else if height <= CZRefreshOffset && (refreshView.refreshState == .Pulling) {
                //再使劲拽一下
                refreshView.refreshState = .Normal
            }
        
        } else { //放手
            //判断是否超过临界点
            if refreshView.refreshState == .Pulling {
                //准备开始刷新
                beginRefreshing()
                
                sendActions(for: .valueChanged)
            }
        }
        
        
    }
    
    /// 开始刷新
    func beginRefreshing() {
        
        // 判断父视图
        guard let sv = scrollView else {
            return
        }
        
        //判断是否正在刷新, 如果是正在刷新, 就直接返回
        if refreshView.refreshState == .WillRefresh {
            return
        }
        
        //设置父视图的状态
        refreshView.refreshState = .WillRefresh
        
        //调整表格的间距r
        var inset = sv.contentInset
        inset.top += CZRefreshOffset
        sv.contentInset = inset
        
        //设置刷新视图的父视图高度
        refreshView.parentViewHeight = CZRefreshOffset
        
        //发送刷新数据时间 如果开始调用 beginRefresh 会重复发送刷新事件
        //sendActions(for: .valueChanged)
    }
    
    
    /// 结束刷新
    func endRefreshing() {
        
        guard let sv = scrollView else {
            return
        }
        
        //判断状态. 是否正在刷新, 如果不是, 直接返回
        if refreshView.refreshState != .WillRefresh {
            return
        }
        
        //恢复刷新视图的状态,
        refreshView.refreshState = .Normal
        
        //恢复表格视图的 contentInset
        var inset = sv.contentInset
        inset.top -= CZRefreshOffset
        sv.contentInset = inset
    }
    
}
