//
//  URefresherAnimator.swift
//  URefresherDemo
//
//  Created by wen on 2019/1/13.
//  Copyright © 2019 wenfeng. All rights reserved.
//

import UIKit

open class URefresherAnimator: UIView {
    
    public var refresher: URefresher?
    public var state: URefresherState = .normal {
        didSet {
            if oldValue != state {
                didChange(state: state)
            }
        }
    }
    
    public func initView() {}
    
    public func didStart() {}
    
    public func didEnd() {}

    public func didChange(state: URefresherState) {}
    
    public func didChange(y: CGFloat, progress: CGFloat) {}
    
}
