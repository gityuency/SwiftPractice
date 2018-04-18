//
//  WBTextKitViewController.swift
//  练手微博
//
//  Created by yuency on 18/07/2017.
//  Copyright © 2017 ChickenMaster. All rights reserved.
//

import UIKit

class WBTextKitViewController: UIViewController {
    
    
    @IBOutlet weak var label: CZLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        
        
        //设置文本
        label.text = "换换个链接  http://www.qq.com"
        
        
        
    }
    
    private func setupUI() {
        self.title = "TextKit iOS7"
        view.backgroundColor = UIColor.cz_random()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", target:  self, action: #selector(close))
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
