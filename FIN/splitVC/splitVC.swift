//
//  splitVC.swift
//  FIN
//
//  Created by Florian Riel on 27.09.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class splitVC: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.preferredDisplayMode = .oneBesideSecondary
        let minimumWidth = min(self.view.bounds.width,self.view.bounds.height)
        self.minimumPrimaryColumnWidth = minimumWidth / 2
        self.maximumPrimaryColumnWidth = minimumWidth
    }
    
    func splitViewController(
             _ splitViewController: UISplitViewController,
             collapseSecondary secondaryViewController: UIViewController,
             onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
//        initFirstSelected()
    }
    
    // MARK: -FUNCTIONS
//    func initFirstSelected() {
//        let masterSplitMC = (self.viewControllers.first as? UINavigationController)?.viewControllers.first as? splitMasterTVC
//        if !self.isCollapsed && self.displayMode == .oneBesideSecondary {
//            masterSplitMC?.isWideScreen = !self.isCollapsed
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
