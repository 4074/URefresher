//
//  ViewController.swift
//  URefresherDemo
//
//  Created by wen on 2019/1/13.
//  Copyright © 2019 wenfeng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var header: UIView!
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
        view.addSubview(header)
        header.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        
        tableView = UITableView(frame: CGRect(x: 0, y: header.frame.height, width: view.frame.width, height: view.frame.height))
        view.addSubview(tableView)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        tableView.tableHeaderView = UIView(frame: tableView.bounds)
        tableView.tableHeaderView?.backgroundColor = .white
        
        let animator = URefresherArticleAnimator(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 48))
        animator.barColor = .red
        animator.render()
        
        // normal
//        tableView.addURefresher({
//            self.setTimeout(2, block: {
//                self.tableView.stopURefresher()
//            })
//        }, animator: animator)
        
        // with pre start
        tableView.addURefresher(launcher: { () -> (Any) in
            return "promise"
        }, recycler: { (result) in
            self.setTimeout(0.2, block: {
                self.tableView.stopURefresher()
            })
        }, animator: animator)
    }
    
    @discardableResult
    func setTimeout(_ interval: TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: interval, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
}

