//
//  VC3.swift
//  NavigationTransitions
//
//  Copyright © 2018 Chili. All rights reserved.
//

import UIKit

class VC3: UIViewController {
    @IBAction func popToRoot(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}
