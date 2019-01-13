//
//  URefresherArticleAnimator.swift
//  URefresherDemo
//
//  Created by wen on 2019/1/13.
//  Copyright © 2019 wenfeng. All rights reserved.
//

import UIKit

open class URefresherArticleAnimator: URefresherAnimator {
    
    public var wrap: UIView!
    public var bars: [UIView] = []
    public var barSize: CGSize = CGSize(width: 20, height: 2)
    public var barSpacing: CGFloat = 4
    public var barCount: Int = 3
    public var barColor: UIColor = .red
    
    public var activeIndex: Int = 0
    public var activeDuration: TimeInterval = 0.15
    public var animating: Bool = false
    
    override required public init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func render() {
        let height = (barSize.height + barSpacing) * CGFloat(barCount) - barSpacing
        wrap = UIView(frame: CGRect(x: (frame.width - barSize.width) / 2, y: (frame.height - height) / 2, width: barSize.width, height: height))
        addSubview(wrap)
        
        for i in 0..<barCount {
            let bar = UIView(frame: CGRect(x: 0, y: CGFloat(i) * (barSize.height + barSpacing), width: 0, height: barSize.height))
            bar.backgroundColor = barColor
            wrap.addSubview(bar)
            bars.append(bar)
        }
    }
    
    private func setBarWidth(_ bar: UIView, width: CGFloat) {
        let width = max(0, min(barSize.width, width))
        bar.frame = CGRect(x: bar.frame.minX, y: bar.frame.minY, width: width, height: bar.frame.height)
    }
    
    private func startBarAnimating() {
        if !animating { return }
        if self.activeIndex == 0 {
            for bar in bars {
                setBarWidth(bar, width: 0)
            }
        }
        
        UIView.animate(withDuration: activeDuration, animations: {
            self.setBarWidth(self.bars[self.activeIndex], width: self.barSize.width)
        }) { (_) in
            self.activeIndex = (self.activeIndex + 1) % self.bars.count
            self.startBarAnimating()
        }
    }
    
    public func startAnimating() {
        animating = true
        startBarAnimating()
    }
    
    public func stopAnimating() {
        animating = false
    }
    
    override public func didStart() {
        startAnimating()
    }
    
    override public func didEnd() {
        stopAnimating()
    }
    
    override public func didChange(y: CGFloat, progress: CGFloat) {
        if state == .release {
            frame = CGRect(x: frame.minX, y: y - frame.height, width: frame.width, height: frame.height)
        } else {
            frame = CGRect(x: frame.minX, y: min((y - frame.height) / 2, 0), width: frame.width, height: frame.height)
        }
        
        if !animating {
            if progress <= 1 && progress >= 0 {
                for (i, bar) in bars.enumerated() {
                    let width = (progress - CGFloat(i)/CGFloat(barCount)) * CGFloat(barCount) * barSize.width
                    setBarWidth(bar, width: width)
                }
            }
        }
    }
}
