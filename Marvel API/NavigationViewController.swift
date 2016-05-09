//
//  NavigationViewController.swift
//  Marvel API
//
//  Created by Fernando Cani on 5/9/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.translucent = true
//        self.navigationBar.backgroundColor = UIColor.blackColor()
        self.navigationBar.tintColor = UIColor.blackColor() //cor dos botoes
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()] //cor do title

//        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationBar.shadowImage = UIImage()
//        self.navigationBar.translucent = true
//        self.navigationBar.tintColor = UIColor.whiteColor() //cor dos botoes
//        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()] //cor do title
    }
}