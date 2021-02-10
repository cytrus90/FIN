//
//  balanceView.swift
//  FIN
//
//  Created by Florian Riel on 16.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class balanceView: UIView {

//    @IBOutlet var balanceViewMain: UIView!
    
    @IBOutlet weak var rightIcon: UIImageView!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var rightHelperView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    @IBOutlet weak var centerHelperView: UIView!
    
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var leftHelperView: UIView!
    @IBOutlet weak var leftView: UIView!
    
    func initView() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        leftIcon.image = UIImage(systemName: "arrow.up.arrow.down")?.withRenderingMode(.alwaysTemplate)
        rightIcon.image = UIImage(systemName: "arrow.up.arrow.down")?.withRenderingMode(.alwaysTemplate)
        
        rightHelperView.layer.borderWidth = 1
        rightHelperView.layer.cornerRadius = 2
        
        rightView.layer.borderWidth = 1
        rightView.layer.cornerRadius = 10
        
        leftHelperView.layer.borderWidth = 1
        leftHelperView.layer.cornerRadius = 2
        
        leftView.layer.borderWidth = 1
        leftView.layer.cornerRadius = 10
        
        leftHelperView.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 255/255, alpha: 1.0)
        rightHelperView.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 255/255, alpha: 1.0)
        centerHelperView.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 255/255, alpha: 1.0)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            rightHelperView.layer.borderColor = CGColor(srgbRed: 240/255, green: 243/255, blue: 255/255, alpha: 1.0)
            rightView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            leftHelperView.layer.borderColor = CGColor(srgbRed: 240/255, green: 243/255, blue: 255/255, alpha: 1.0)
            leftView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            rightHelperView.layer.borderColor = CGColor(srgbRed: 240/255, green: 243/255, blue: 255/255, alpha: 1.0)
            rightView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            leftHelperView.layer.borderColor = CGColor(srgbRed: 240/255, green: 243/255, blue: 255/255, alpha: 1.0)
            leftView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            self.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
