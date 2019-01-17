//
//  UIRefresherBarAnimator.swift
//  URefresherDemo
//
//  Created by wen on 2019/1/13.
//  Copyright © 2019 wenfeng. All rights reserved.
//

import UIKit

open class URefresherBarAnimator: URefresherAnimator {
    
    public var wrap: UIView!
    public var bars: [UIView] = []
    public var barSize: CGSize = CGSize(width: 2, height: 12)
    public var barSpacing: CGFloat = 4
    public var barCount: Int = 4
    public var barColor: UIColor = .red
    
    public var activeIndex: Int = 0
    public var activeDuration: TimeInterval = 0.15
    public var activeHeights: [CGFloat] = [3, 6, 9, 12]
    public var animating: Bool = false
    
    override required public init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func initView() {
        let width = (barSize.width + barSpacing) * CGFloat(barCount) - barSpacing
        wrap = UIView(frame: CGRect(x: (frame.width - width) / 2, y: (frame.height - barSize.height) / 2, width: width, height: barSize.height))
        addSubview(wrap)
        
        render()
    }
    
    public func render() {
        for bar in bars {
            bar.removeFromSuperview()
        }
        bars.removeAll()
        
        for i in 0..<barCount {
            let bar = UIView(frame: CGRect(x: CGFloat(i) * (barSize.width + barSpacing), y: 0, width: barSize.width, height: 0))
            bar.backgroundColor = barColor
            wrap.addSubview(bar)
            bars.append(bar)
        }
    }
    
    private func setBarHeight(_ bar: UIView, height: CGFloat) {
        let height = max(0, min(barSize.height, height))
        bar.frame = CGRect(x: bar.frame.minX, y: barSize.height - height, width: bar.frame.width, height: height)
    }
    
    private func startBarAnimating() {
        if !animating { return }
        UIView.animate(withDuration: activeDuration, animations: {
            for (i, bar) in self.bars.enumerated() {
                self.setBarHeight(bar, height: self.activeHeights[ (self.activeHeights.count + (i - self.activeIndex)) % self.activeHeights.count])
            }
            self.activeIndex = (self.activeIndex + 1) % self.activeHeights.count
        }) { (_) in
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
        frame = CGRect(x: frame.minX, y: y - frame.height, width: frame.width, height: frame.height)
        
        if !animating {
            if progress <= 1 && progress >= 0 {
                let height = progress * barSize.height
                for bar in bars {
                    setBarHeight(bar, height: height)
                }
            }
        }
    }
}
