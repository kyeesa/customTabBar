//
//  CustomTabBar.swift
//  CustomTabBar
//
//  Created by Kye Esa on 1/6/17.
//  Copyright © 2017 Swift Joureny. All rights reserved.
//

//import Foundation

import UIKit

protocol CustomTabBarDataSource {
    func tabBarItemsInCustomTabBar(_ tabBarView: CustomTabBar) -> [UITabBarItem]
}

protocol CustomTabBarDelegate {
    func didSelectViewController(_ tabBarView: CustomTabBar, atIndex index: Int)
}

class CustomTabBar: UIView {
    
    var datasource: CustomTabBarDataSource!
    var delegate: CustomTabBarDelegate!
    
    var tabBarItems: [UITabBarItem]!
    var customTabBarItems: [CustomTabBarItem]!
    var tabBarButtons: [UIButton]!
    
    var initialTabBarItemIndex: Int!
    var selectedTabBarItemIndex: Int!
    var slideMaskDelay: Double!
    var slideAnimationDuration: Double!
    
    var tabBarItemWidth: CGFloat!
    var leftMask: UIView!
    var rightMask: UIView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        // get tab bar items from default tab bar
        tabBarItems = datasource.tabBarItemsInCustomTabBar(self)
        
        customTabBarItems = []
        tabBarButtons = []

        initialTabBarItemIndex = 0
        selectedTabBarItemIndex = initialTabBarItemIndex

        slideAnimationDuration = 0.4
        slideMaskDelay = slideAnimationDuration / 3
        
        //created an array of items from orginal tab bar with equal length
        let containers = createTabBarItemContainers()
        
        //
        createTabBarItemSelectionOverlay(containers)
        
        createTabBarItemSelectionOverlayMask(containers)
        
        
        
        
        createTabBarItems(containers)
    
        //self.layer.borderColor = UIColor.darkGray.cgColor
        
//        self.layer.borderWidth = 1.5
//        self.layer.borderColor = UIColor(red:0.0/255.0, green:0.0/255.0, blue:0.0/255.0, alpha:0.2).cgColor
//        self.clipsToBounds = true
      
        
        
        
        
        let border = CALayer();
        border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 0.5)
        border.backgroundColor = UIColor.red.cgColor
        self.layer.addSublayer(border)
        
    }
    
    func createTabBarItemSelectionOverlay(_ containers: [CGRect]) {
        
        let overlayColors = [UIColor.red, UIColor.red, UIColor.red]
        
        for index in 0..<tabBarItems.count {
            let container = containers[index]
            
            //creatgn the view
            let view = UIView(frame: container)
            
            
            //creating the overalay
            let selectedItemOverlay = UIView(frame: CGRect(x: 0, y:self.frame.height-3, width: self.frame.width, height: 3))
            
            //    assign background color based on array
            selectedItemOverlay.backgroundColor = overlayColors[index]
            
            //assignb the overlay to the view
            view.addSubview(selectedItemOverlay)
            
            
            //add this to the view higharcy
            self.addSubview(view)
        }
    }
    
    func createTabBarItemSelectionOverlayMask(_ containers: [CGRect]) {
        
        tabBarItemWidth = self.frame.width / CGFloat(tabBarItems.count)
        let leftOverlaySlidingMultiplier = CGFloat(initialTabBarItemIndex) * tabBarItemWidth
        let rightOverlaySlidingMultiplier = CGFloat(initialTabBarItemIndex + 1) * tabBarItemWidth
        
        leftMask = UIView(frame: CGRect(x: 0, y: 0, width: leftOverlaySlidingMultiplier, height: self.frame.height))
        leftMask.backgroundColor = UIColor.white
        rightMask = UIView(frame: CGRect(x: rightOverlaySlidingMultiplier, y: 0, width: tabBarItemWidth * CGFloat(tabBarItems.count - 1), height: self.frame.height))
        rightMask.backgroundColor = UIColor.white
        
        self.addSubview(leftMask)
        self.addSubview(rightMask)
    }
    
    
    func createTabBarItems(_ containers: [CGRect]) {
        
        var index = 0
        for item in tabBarItems {
            
            let container = containers[index]
            
            let customTabBarItem = CustomTabBarItem(frame: container)
            customTabBarItem.setup(item)
            
            self.addSubview(customTabBarItem)
            customTabBarItems.append(customTabBarItem)
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: container.width, height: container.height))
            button.addTarget(self, action: #selector(CustomTabBar.barItemTapped(_:)), for: UIControlEvents.touchUpInside)
            
            customTabBarItem.addSubview(button)
            tabBarButtons.append(button)
            
            index += 1
        }
    }
    
    func createTabBarItemContainers() -> [CGRect] {
        
        var containerArray = [CGRect]()
        
        // create container for each tab bar item
        //returns an array of items in tab bar
        for index in 0..<tabBarItems.count {
            let tabBarContainer = createTabBarContainer(index)
            containerArray.append(tabBarContainer)
        }
        
        return containerArray
    }
    
    func createTabBarContainer(_ index: Int) -> CGRect {
        
        let tabBarContainerWidth = self.frame.width / CGFloat(tabBarItems.count)
        let tabBarContainerRect = CGRect(x: tabBarContainerWidth * CGFloat(index), y: 0, width: tabBarContainerWidth, height: self.frame.height)
        
        return tabBarContainerRect
    }
    
    func animateTabBarSelection(from: Int, to: Int) {
        //1 Again calculating sliding multiplier, as new tab bar item is selected. It’s used as a pointer at which direction the slide animation is going
        let overlaySlidingMultiplier = CGFloat(to - from) * tabBarItemWidth
        
        let leftMaskDelay: Double
        let rightMaskDelay: Double
        
        //2 Determining which side of overlay will be delayed, based on slide animation direction
        if overlaySlidingMultiplier > 0 {
            leftMaskDelay = slideMaskDelay
            rightMaskDelay = 0
        }
        else {
            leftMaskDelay = 0
            rightMaskDelay = slideMaskDelay
        }
        // 3 Animating left and right masks edges. For left mask we only need to change it’s width – moving it’s right edge. For right mask we are moving also it’s left edge, by changing it’s origin.x

        UIView.animate(withDuration: slideAnimationDuration - leftMaskDelay, delay: leftMaskDelay, options: UIViewAnimationOptions(), animations: {
            self.leftMask.frame.size.width += overlaySlidingMultiplier
        }, completion: nil)
        
        //4 Animating left and right masks edges. For left mask we only need to change it’s width – moving it’s right edge. For right mask we are moving also it’s left edge, by changing it’s origin.x

        UIView.animate(withDuration: slideAnimationDuration - rightMaskDelay, delay: rightMaskDelay, options: UIViewAnimationOptions(), animations: {
            self.rightMask.frame.origin.x += overlaySlidingMultiplier
            self.rightMask.frame.size.width += -overlaySlidingMultiplier
            self.customTabBarItems[from].iconView.tintColor = UIColor.black
            self.customTabBarItems[to].iconView.tintColor = UIColor.blue
        }, completion: nil)
        
    }

    
    func barItemTapped(_ sender : UIButton) {
        let index = tabBarButtons.index(of: sender)!
        
        //calling func animateTabBarSelection
        animateTabBarSelection(from: selectedTabBarItemIndex, to: index)
        selectedTabBarItemIndex = index
        
        delegate.didSelectViewController(self, atIndex: index)
    }
}
