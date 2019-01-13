//
//  URefresher.swift
//  URefresherDemo
//
//  Created by wen on 2019/1/13.
//  Copyright © 2019 wenfeng. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices

public enum URefresherState {
    case normal
    case loading
    case process
    case pull
    case release
}

open class URefresher: UIView {
    private var observation: NSKeyValueObservation?
    private var scrollViewInsetsDefaultValue: UIEdgeInsets = .zero
    private var prevOffsetY: CGFloat = 0
    
    private var originHeight: CGFloat = 0
    private var animator: URefresherAnimator!
    
    private var action: (() -> ()) = {}
    private var launcher: (() -> (Any)) = { return }
    private var recycler: ((Any) -> ()) = {_ in }
    private var launcherResult: Any? = nil
    
    public var prestart: Bool = false
    public var processDelay: Double = 0.15
    public var animateDuration: Double = 0.3
    
    internal var state: URefresherState = .normal {
        didSet {
            if state != oldValue {
                switch state {
                case .normal:
                    reset()
                case .loading:
                    if prestart {
                        launch()
                    } else {
                        start()
                    }
                case .process:
                    recycle()
                case .release:
                    stop()
                default:
                    break
                }
            }
        }
    }
    
    convenience init(
        action: @escaping (() -> ()),
        frame: CGRect,
        animator: URefresherAnimator
        ) {
        self.init(frame: frame)
        self.animator = animator
        self.animator.refresher = self
        
        self.action = action;
        
        originHeight = frame.height
        addSubview(self.animator)
    }
    
    convenience init(
        launcher: @escaping (() -> (Any)),
        recycler: @escaping ((Any) -> ()),
        frame: CGRect,
        animator: URefresherAnimator
        ) {
        self.init(frame: frame)
        self.animator = animator
        self.animator.refresher = self
        
        self.prestart = true
        self.launcher = launcher;
        self.recycler = recycler;
        
        originHeight = frame.height
        clipsToBounds = true
        addSubview(self.animator)
    }
    
    open override func willMove(toSuperview newSuperview: UIView!) {
        observation?.invalidate()
        if let scrollView = newSuperview as? UIScrollView {
            scrollViewInsetsDefaultValue = scrollView.contentInset
            observation = scrollView.observe(\.contentOffset, options: [.initial]) { [unowned self] (scrollView, change) in
                if self.prestart {
                    self.handleDidScrollPrestart(scrollView: scrollView)
                } else {
                    self.handleDidScroll(scrollView: scrollView)
                }
            }
        }
    }
    
    func launch() {
        self.animator?.didStart()
        impactOccurred()
        launcherResult = self.launcher()
    }
    
    func impactOccurred() {
        if #available(iOS 10.0, *) {
            let i = UIImpactFeedbackGenerator()
            i.impactOccurred()
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    func recycle() {
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        
        var insets = scrollView.contentInset
        insets.top += originHeight
        
        scrollView.contentOffset.y = prevOffsetY
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            scrollView.contentInset = insets
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: -insets.top)
        }, completion: {finished in
            if let r = self.launcherResult {
                self.recycler(r)
            }
        })
    }
    
    func reset() {
        setHeightCover(y: 0)
    }
    
    func start() {
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        
        var insets = scrollView.contentInset
        insets.top += originHeight
        
        scrollView.contentOffset.y = prevOffsetY
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            scrollView.contentInset = insets
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: -insets.top)
        }, completion: {finished in
            self.animator?.didStart()
            self.action()
        })
        
    }
    
    func stop() {
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        
        animator?.didEnd()
        UIView.animate(withDuration: animateDuration, delay: prestart ? processDelay : 0, options: UIView.AnimationOptions(), animations: {
            scrollView.contentInset = self.scrollViewInsetsDefaultValue
        }, completion: { finished in
            self.animator?.didChange(y: 0, progress: 0)
            self.state = .normal
        })
        
    }
    
    func handleDidScrollPrestart(scrollView: UIScrollView) {
        let offsetY = prevOffsetY + scrollViewInsetsDefaultValue.top
        
        if (offsetY < -originHeight) {
            if state == .normal {
                state = .loading
            }
        }
        
        if scrollView.isDragging == false {
            if state == .loading {
                state = .process
            }
        }
        
        animator.didChange(y: -scrollView.contentOffset.y, progress: -offsetY / self.originHeight)
        setHeightCover(y: -scrollView.contentOffset.y)
        prevOffsetY = scrollView.contentOffset.y
    }
    
    func handleDidScroll(scrollView: UIScrollView) {
        let offsetY = prevOffsetY + scrollViewInsetsDefaultValue.top
        
        if (offsetY < -originHeight) {
            if (scrollView.isDragging == false && state == .normal) {
                state = .loading
            }
        }
        
        animator.didChange(y: -scrollView.contentOffset.y, progress: -offsetY / self.originHeight)
        setHeightCover(y: -scrollView.contentOffset.y)
        prevOffsetY = scrollView.contentOffset.y
    }
    
    func setHeightCover(y: CGFloat) {
        if state == .normal && y == 0 {
            frame = CGRect(x: frame.minX, y: -originHeight, width: frame.width, height: originHeight)
        } else {
            frame = CGRect(x: frame.minX, y: min(0, -y), width: frame.width, height: max(originHeight, y))
        }
    }
}

