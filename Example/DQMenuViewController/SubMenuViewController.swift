//
//  SubMenuViewController.swift
//  DQMenuViewController_Example
//
//  Created by Ju on 2020/5/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import DQMenuViewController

class SubMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        initializerMenuContainer()
    }
    
    private var scrollContainerController: DQMenuViewController!
    
    private var titleAVC: TitleAViewController!
    private var titleBVC: TitleBViewController!
    
    // MARK: - For menu container
    private func initializerMenuContainer() {
        
        // Button items
        var titles: [String] = []
        titles.append("TitleA")
        titles.append("TitleB")
        
        // SubViewControllers
        titleAVC = TitleAViewController()
        
        titleBVC = TitleBViewController()
        
        var viewItems = [UIViewController]()
        
        viewItems.append(titleAVC)
        viewItems.append(titleBVC)
        
        scrollContainerController = DQMenuViewController(frame: view.bounds,
                                                         titles: titles,
                                                         viewItems: viewItems,
                                                         managerController: self)
        scrollContainerController.configureContainerUI(useSeperateLine: true)
        
        scrollContainerController.delegate = self
        scrollContainerController.menuTitleViewBackgroundColor = UIColor.white

        // 记得添加约束
        addChildViewController(scrollContainerController)
        view.addSubview(scrollContainerController.view)
        view.constrainToEdges(scrollContainerController.view, topSpace: 88, leadingSpace: 0, bottomSpace: 0, trailingSpace: 0)
        scrollContainerController.didMove(toParentViewController: self)
    }
    
}

extension SubMenuViewController: DQMenuViewControllerDelegate {
    func scrollContainerView(containerView: DQMenuViewController, scrollAt page: Int, isFirstScrollToIt: Bool) {
        // delegate
    }
}

