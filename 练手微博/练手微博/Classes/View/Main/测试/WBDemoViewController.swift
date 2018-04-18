//
//  WBDemoViewController.swift
//  练手微博
//
//  Created by yuency yang on 03/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

class WBDemoViewController: WBBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //设置标题
        title = "第 \(navigationController?.childViewControllers.count ?? 0) 个"
    }
    
    func showNext() {
        let vc = WBDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - 设置控制器
extension WBDemoViewController {
    
    
    override func setupTableView() {
        //需要调用父类方法,要不然是看不到背景颜色做了更改的
        super.setupTableView()
        
        navItem.rightBarButtonItem = UIBarButtonItem(title: "下一个", target:  self, action: #selector(showNext))
    }
}
