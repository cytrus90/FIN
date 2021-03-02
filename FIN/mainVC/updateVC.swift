//
//  updateVC.swift
//  FIN
//
//  Created by Florian Riel on 15.02.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class updateVC: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var subLabel: UILabel!
    
    @IBOutlet weak var secondSubLabel: UILabel!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var fourthImageView: UIImageView!
    
    @IBOutlet weak var swipeLabel: UILabel!
    
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    @IBOutlet var tabGesture: UITapGestureRecognizer!
    
    var welcomeLabelConstraint:NSLayoutConstraint?
    
    var welcomeImageYConstraint:NSLayoutConstraint?
    var welcomeImageXConstraint:NSLayoutConstraint?
    
    var firstImageX1Constraint:NSLayoutConstraint?
    var firstImageX2Constraint:NSLayoutConstraint?
    var firstImageWidthConstraint:NSLayoutConstraint?
    
    var secondImageXConstraint:NSLayoutConstraint?
    var secondImageX1Constraint:NSLayoutConstraint?
    var secondImageX2Constraint:NSLayoutConstraint?
    
    var thirdImageX1Constraint:NSLayoutConstraint?
    var thirdImageX2Constraint:NSLayoutConstraint?
    var thirdImageWidthContraint:NSLayoutConstraint?
    
    var fourthImageXConstraint:NSLayoutConstraint?
    
    var currentView:Int = 0
    
    var light:Bool = true
    var langStr:String = "EN"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            light = true
        } else {
            light = false
        }
        
        langStr = Locale.current.languageCode ?? "EN"
        
        welcomeLabel.text = NSLocalizedString("updateLabel", comment: "Update")
        subLabel.text = NSLocalizedString("welcomeSubLabel", comment: "FIN - track your finances")
        
        swipeLabel.text = NSLocalizedString("updateSwipeText", comment: "Swipe")
        
        descriptionLabel.isHidden = true
        descriptionLabel.alpha = 0.0
        
        firstImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 20).isActive = true
        firstImageView.alpha = 0.0
        
        secondImageView.alpha = 0.0
        secondImageView.isHidden = true
        
        thirdImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 20).isActive = true
        thirdImageView.alpha = 0.0
        
        fourthImageView.alpha = 0.0
        fourthImageView.isHidden = true
        
        secondSubLabel.alpha = 0.0
        secondSubLabel.isHidden = true
        
        goButton.setTitle(NSLocalizedString("goButtonUpdateText", comment: "Go Button"), for: .normal)
        goButton.isHidden = true
        
        goButton.alpha = 0.0
        
        goButton.layer.borderWidth = 1
        goButton.layer.cornerRadius = 10
        
        goButton.layer.borderColor = UIColor.clear.cgColor
        goButton.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        goButton.tintColor = UIColor.white
        
        goButton.isEnabled = false
        
        initImageViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initWelcomePosition()
        // Disable drag to dismiss of view
        self.isModalInPresentation = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        AppUtility.lockOrientation(.all)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initWelcomePosition()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            light = true
        } else {
            light = false
        }
        initImageViews()
    }

    func initImageViews() {
        switch currentView {
        case 0, 1:
            if light {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        if UIDevice().orientation.isLandscape { // widescreen
                            thirdImageView.image = UIImage(named: "DE_light_category_iPad")
                            fourthImageView.image = UIImage(named: "light_category_overlay_iPad_2")
                        } else {
                            thirdImageView.image = UIImage(named: "DE_light_category_iPad")
                            fourthImageView.image = UIImage(named: "light_category_overlay_iPad_2")
                        }
                    } else {
                        thirdImageView.image = UIImage(named: "DE_light_category")
                        fourthImageView.image = UIImage(named: "light_category_overlay_2")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        if UIDevice().orientation.isLandscape { // widescreen
                            thirdImageView.image = UIImage(named: "EN_light_category_iPad")
                            fourthImageView.image = UIImage(named: "light_user_overlay_iPad_wide")
                        } else {
                            thirdImageView.image = UIImage(named: "EN_light_category_iPad")
                            fourthImageView.image = UIImage(named: "light_category_overlay_iPad_2")
                        }
                    } else {
                        thirdImageView.image = UIImage(named: "EN_light_category")
                        fourthImageView.image = UIImage(named: "light_category_overlay_2")
                    }
                }
            } else {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        if view.frame.height < view.frame.width { // widescreen
                            thirdImageView.image = UIImage(named: "DE_dark_category_iPad")
                            fourthImageView.image = UIImage(named: "dark_category_overlay_iPad_2")
                        } else {
                            thirdImageView.image = UIImage(named: "DE_dark_category_iPad")
                            fourthImageView.image = UIImage(named: "dark_category_overlay_iPad_2")
                        }
                    } else {
                        thirdImageView.image = UIImage(named: "DE_dark_category")
                        fourthImageView.image = UIImage(named: "dark_category_overlay_2")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        if view.frame.height < view.frame.width { // widescreen
                            thirdImageView.image = UIImage(named: "EN_dark_category_iPad")
                            fourthImageView.image = UIImage(named: "dark_category_overlay_iPad_2")
                        } else {
                            thirdImageView.image = UIImage(named: "EN_dark_category_iPad")
                            fourthImageView.image = UIImage(named: "dark_category_overlay_iPad_2")
                        }
                    } else {
                        thirdImageView.image = UIImage(named: "EN_dark_category")
                        fourthImageView.image = UIImage(named: "dark_category_overlay_2")
                    }
                }
            }
            break
        case 2:
            if light {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "light_category_overlay_iPad_4")
                    } else {
                        fourthImageView.image = UIImage(named: "light_category_overlay_4")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "light_category_overlay_iPad_4")
                    } else {
                        fourthImageView.image = UIImage(named: "light_category_overlay_4")
                    }
                }
            } else {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_iPad_4")
                    } else {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_4")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_iPad_4")
                    } else {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_4")
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    func nextStep() {
        switch currentView {
        case 0:
            currentView = 1
            firstToSecondAnimation()
            break
        case 1:
            currentView = 2
            firstToSecond2Animation()
            break
        case 2:
            currentView = 3
            twoToThreeAnimation()
        default:
            break
        }
    }
    
    func initWelcomePosition() {
        let diffWelcomeImage = imageStackView.frame.minY/3
        welcomeImageYConstraint = welcomeLabel.bottomAnchor.constraint(equalTo: imageStackView.topAnchor, constant: -diffWelcomeImage)
        welcomeImageYConstraint?.isActive = true
        
        welcomeImageXConstraint?.isActive = false
        welcomeImageXConstraint = welcomeLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        welcomeImageXConstraint?.isActive = true
    }
    
    func firstToSecondAnimation() {
        swipeGesture.isEnabled = false
        tabGesture.isEnabled = false
        
        secondSubLabel.text = NSLocalizedString("twoUpdateDescriptionText", comment: "Description")
        descriptionLabel.text = NSLocalizedString("twoUpdateSecondDescriptionText", comment: "Subtext")
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.imageStackView.trailingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
            self.imageStackView.alpha = 0.0
            self.swipeLabel.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: {_ in
            self.imageStackView.isHidden = true
            self.swipeLabel.isHidden = true
            self.thirdImageView.isHidden = false
            self.welcomeLabelConstraint = self.welcomeLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50)
            self.welcomeLabelConstraint?.isActive = true
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                self.welcomeLabel.transform = self.welcomeLabel.transform.scaledBy(x: 0.7, y: 0.7)
                self.welcomeLabel.alpha = 0.0
            }, completion: { _ in
                self.welcomeImageYConstraint?.isActive = false
            })
        })
        UIView.animate(withDuration: 1.0, delay: 0.9, options: .curveEaseInOut, animations: {
            self.firstImageX1Constraint = self.thirdImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15)
            self.firstImageX2Constraint = self.thirdImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
            self.firstImageX1Constraint?.isActive = true
            self.firstImageX2Constraint?.isActive = true
            
            self.secondImageX1Constraint = self.fourthImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15)
            self.secondImageX2Constraint = self.fourthImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
            self.secondImageX1Constraint?.isActive = true
            self.secondImageX2Constraint?.isActive = true
            
            self.thirdImageView.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: {_ in
            self.fourthImageView.isHidden = false
            self.descriptionLabel.isHidden = false
            self.secondSubLabel.isHidden = false
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
                self.fourthImageView.alpha = 1.0
                self.descriptionLabel.alpha = 1.0
                self.secondSubLabel.alpha = 1.0
            }, completion: { _ in
                self.swipeGesture.isEnabled = true
                self.tabGesture.isEnabled = true
            })
        })
    }
    
    func firstToSecond2Animation() {
        swipeGesture.isEnabled = false
        tabGesture.isEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.descriptionLabel.alpha = 0.0
            self.secondSubLabel.alpha = 0.0
            self.fourthImageView.alpha = 0.0
        }, completion: { _ in
            self.descriptionLabel.text = NSLocalizedString("threeUpdateSecondDescriptionText", comment: "Description")
            self.secondSubLabel.text = NSLocalizedString("threeUpdateDescriptionText", comment: "Subtext")
            self.initImageViews()
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                self.descriptionLabel.alpha = 1.0
                self.secondSubLabel.alpha = 1.0
                self.fourthImageView.alpha = 1.0
            })
        })
        
        swipeGesture.isEnabled = true
        tabGesture.isEnabled = true
    }
    
    func twoToThreeAnimation() {
        swipeGesture.isEnabled = false
        tabGesture.isEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.descriptionLabel.alpha = 0.0
            self.secondSubLabel.alpha = 0.0
            self.fourthImageView.alpha = 0.0
        }, completion: { _ in
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            self.descriptionLabel.text = NSLocalizedString("updateFinalDescriptionLabelText", comment: "Final Text")
            
            let firstWidth = self.firstImageView.frame.width
            
            self.firstImageX1Constraint?.isActive = false
            self.firstImageX2Constraint?.isActive = false
            self.firstImageX2Constraint = self.thirdImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            self.firstImageX1Constraint = self.thirdImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: -(firstWidth+20))
            self.firstImageX2Constraint?.isActive = true
            self.firstImageX1Constraint?.isActive = true
            
            self.welcomeImageXConstraint?.isActive = false
            
            self.welcomeLabelConstraint?.isActive = false
            self.welcomeLabelConstraint = self.welcomeLabel.bottomAnchor.constraint(equalTo: self.descriptionLabel.topAnchor, constant: -30)
            self.welcomeLabelConstraint?.isActive = true
            
            self.view.bringSubviewToFront(self.welcomeLabel)
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                self.thirdImageView.alpha = 0.0
                self.view.layoutIfNeeded()
            })
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
                self.welcomeLabel.transform = self.welcomeLabel.transform.scaledBy(x: 0.01, y: 0.01)
                self.welcomeLabel.alpha = 0.0
            }, completion: { _ in
                self.goButton.isHidden = false
                self.welcomeLabel.text = NSLocalizedString("updateLabelFinalText", comment: "Ready")
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
                    self.welcomeLabel.alpha = 1.0
                    self.welcomeLabel.transform = CGAffineTransform.identity
                    self.goButton.isEnabled = true
                }, completion: { _ in
                    UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.descriptionLabel.alpha = 1.0
                        self.goButton.alpha = 1.0
                    })
                })
            })
        })
    }
    
    @IBAction func swipeAction(_ sender: Any) {
        nextStep()
    }
    
    @IBAction func tabAction(_ sender: Any) {
        nextStep()
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.goButton.transform = self.goButton.transform.scaledBy(x: 0.9, y: 0.9)
            }, completion: { _ in
              UIView.animate(withDuration: 0.1, animations: {
                self.goButton.transform = CGAffineTransform.identity
              }, completion: { _ in
                self.dismiss(animated: true, completion: nil)
              })
            })
    }
}
