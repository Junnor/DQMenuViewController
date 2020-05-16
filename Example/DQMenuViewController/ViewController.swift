//
//  ViewController.swift
//  DQMenuViewController
//
//  Created by Junnor on 05/16/2020.
//  Copyright (c) 2020 Junnor. All rights reserved.
//

import UIKit
import DQMenuViewController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        scrollContainerController.configureContainerUI(isTitleViewStyle: true)
        scrollContainerController.selectedItemFont = UIFont.boldSystemFont(ofSize: 22)
        scrollContainerController.unselectedItemFont = UIFont.boldSystemFont(ofSize: 17)
        scrollContainerController.selectedItemColor = UIColor.red
        scrollContainerController.unselectedItemColor = UIColor.black
        
        scrollContainerController.delegate = self
        
        // 记得添加约束
        addChildViewController(scrollContainerController)
        view.addSubview(scrollContainerController.view)
        view.constrainToEdges(scrollContainerController.view, topSpace: 88, leadingSpace: 0, bottomSpace: 0, trailingSpace: 0)
        scrollContainerController.didMove(toParentViewController: self)
    }

}

extension ViewController: DQMenuViewControllerDelegate {
    func scrollContainerView(containerView: DQMenuViewController, scrollAt page: Int, isFirstScrollToIt: Bool) {
        // delegate
    }
}

extension UIView {
    
    func constrainToEdges(_ subview: UIView,
                          topSpace: CGFloat = 0,
                          leadingSpace: CGFloat = 0,
                          bottomSpace: CGFloat = 0,
                          trailingSpace: CGFloat = 0) {
    
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let top = subview.topAnchor.constraint(equalTo: topAnchor, constant: topSpace)
        let leading = subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingSpace)
        let bottom = subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomSpace)
        let trailing = subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingSpace)
        
        NSLayoutConstraint.activate([top, leading, bottom, trailing])
    }
    
}
