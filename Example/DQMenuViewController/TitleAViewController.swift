//
//  TitleAViewController.swift
//  DQMenuViewController_Example
//
//  Created by Ju on 2020/5/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class TitleAViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .cyan
        
        let nextButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.setTitleColor(.red, for: .normal)
        nextButton.backgroundColor = .white
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        view.addSubview(nextButton)
    }
    
    @objc private func nextPage() {
        let vc = SubMenuViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}
