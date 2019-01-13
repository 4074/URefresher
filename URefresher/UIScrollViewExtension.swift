//
//  UIScrollViewExtension.swift
//  URefresherDemo
//
//  Created by wen on 2019/1/13.
//  Copyright © 2019 wenfeng. All rights reserved.
//

import UIKit

public let URefresherTag: Int = 1987

public extension UIScrollView {
    
    public var urefresher: URefresher? {
        get {
            return viewWithTag(URefresherTag) as? URefresher
        }
    }
    
    @discardableResult
    public func addURefresher(
        _ action: @escaping (() -> ()),
        animator: URefresherAnimator
    ) -> URefresher {
        if let r = urefresher {
            return r
        }
        let height = animator.frame.height
        let refresher = URefresher(action: action, frame: CGRect(x: 0, y: -height, width: frame.width, height: height), animator: animator)
        refresher.tag = URefresherTag
        addSubview(refresher)
        return refresher
    }
    
    @discardableResult
    public func addURefresher(
        launcher: @escaping (() -> (Any)),
        recycler: @escaping ((Any) -> ()),
        animator: URefresherAnimator
        ) -> URefresher {
        if let r = urefresher {
            return r
        }
        let height = animator.frame.height
        let refresher = URefresher(launcher: launcher, recycler: recycler, frame: CGRect(x: 0, y: -height, width: frame.width, height: height), animator: animator)
        refresher.tag = URefresherTag
        addSubview(refresher)
        sendSubviewToBack(refresher)
        return refresher
    }
    
    public func startURefresher() {
        urefresher?.state = .loading
    }
    
    public func stopURefresher() {
        if urefresher?.state == .loading || urefresher?.state == .process {
            urefresher?.state = .release
        }
    }
}
