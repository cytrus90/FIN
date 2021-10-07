//
//  introVC.swift
//  FIN
//
//  Created by Florian Riel on 25.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class introVC: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var subLabel: UILabel!
    
    @IBOutlet weak var secondSubLabel: UILabel!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var fourthImageView: UIImageView!
    
    @IBOutlet weak var swipeLabel: UILabel!
    
    @IBOutlet weak var firstImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstImageTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var thirdImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdImageTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var welcomeStackViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    @IBOutlet var tabGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var skipButton: UIButton!
    
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
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    
    var currentView:Int = 0
    
    var light:Bool = true
    var langStr:String = "EN"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcomeLabel.text = NSLocalizedString("welcomeLabel", comment: "Welcome")
        subLabel.text = NSLocalizedString("welcomeSubLabel", comment: "FIN - track your finances")
        
        skipButton.titleLabel?.text = NSLocalizedString("skipButtonLabel", comment: "Skip")
        
        descriptionLabel.isHidden = true
        descriptionLabel.alpha = 0.0
        descriptionLabel.text = NSLocalizedString("secondDescriptionLabelText", comment: "Second Description Label")
        
        swipeLabel.text = NSLocalizedString("swipeText", comment: "Swipe")
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            light = true
        } else {
            light = false
        }
        
        langStr = Locale.current.languageCode ?? "EN"
        
        initImageViews()
        
        firstImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 20).isActive = true
        firstImageView.alpha = 0.0
        firstImageView.isHidden = true
        
        secondImageView.alpha = 0.0
        secondImageView.isHidden = true
        
        thirdImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 20).isActive = true
        thirdImageView.alpha = 0.0
        thirdImageView.isHidden = true
        
        fourthImageView.alpha = 0.0
        fourthImageView.isHidden = true
        
        secondSubLabel.alpha = 0.0
        secondSubLabel.isHidden = true
        secondSubLabel.text = NSLocalizedString("thirdSecondDescriptionText", comment: "Types of Categories")
        
        goButton.setTitle(NSLocalizedString("goButtonText", comment: "Go Button"), for: .normal)
        goButton.isHidden = true
        
        goButton.alpha = 0.0
        
        goButton.layer.borderWidth = 1
        goButton.layer.cornerRadius = 10
        
        goButton.layer.borderColor = UIColor.clear.cgColor
        goButton.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        goButton.tintColor = UIColor.white
        
        goButton.isEnabled = false
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
                            firstImageView.image = UIImage(named: "DE_light_user_iPad_wide")
                            secondImageView.image = UIImage(named: "light_user_overlay_iPad_wide")
                        } else {
                            firstImageView.image = UIImage(named: "DE_light_user_iPad")
                            secondImageView.image = UIImage(named: "light_user_overlay_iPad")
                        }
                    } else {
                        firstImageView.image = UIImage(named: "DE_light_user")
                        secondImageView.image = UIImage(named: "light_user_overlay")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        if UIDevice().orientation.isLandscape { // widescreen
                            firstImageView.image = UIImage(named: "EN_light_user_iPad_wide")
                            secondImageView.image = UIImage(named: "light_user_overlay_iPad_wide")
                        } else {
                            firstImageView.image = UIImage(named: "EN_light_user_iPad")
                            secondImageView.image = UIImage(named: "light_user_overlay_iPad")
                        }
                    } else {
                        firstImageView.image = UIImage(named: "EN_light_user")
                        secondImageView.image = UIImage(named: "light_user_overlay")
                    }
                }
            } else {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        if view.frame.height < view.frame.width { // widescreen
                            firstImageView.image = UIImage(named: "DE_dark_user_iPad_wide")
                            secondImageView.image = UIImage(named: "dark_user_overlay_iPad_wide")
                        } else {
                            firstImageView.image = UIImage(named: "DE_dark_user_iPad")
                            secondImageView.image = UIImage(named: "dark_user_overlay_iPad")
                        }
                    } else {
                        firstImageView.image = UIImage(named: "DE_dark_user")
                        secondImageView.image = UIImage(named: "dark_user_overlay")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        if view.frame.height < view.frame.width { // widescreen
                            firstImageView.image = UIImage(named: "EN_dark_user_iPad_wide")
                            secondImageView.image = UIImage(named: "dark_user_overlay_iPad_wide")
                        } else {
                            firstImageView.image = UIImage(named: "EN_dark_user_iPad")
                            secondImageView.image = UIImage(named: "dark_user_overlay_iPad")
                        }
                        
                    } else {
                        firstImageView.image = UIImage(named: "EN_dark_user")
                        secondImageView.image = UIImage(named: "dark_user_overlay")
                    }
                    
                }
            }
            break
        case 2:
            if light {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        thirdImageView.image = UIImage(named: "DE_light_category_iPad")
                        fourthImageView.image = UIImage(named: "light_category_overlay_iPad")
                    } else {
                        thirdImageView.image = UIImage(named: "DE_light_category")
                        fourthImageView.image = UIImage(named: "light_category_overlay")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        thirdImageView.image = UIImage(named: "EN_light_category_iPad")
                        fourthImageView.image = UIImage(named: "light_category_overlay_iPad")
                    } else {
                        thirdImageView.image = UIImage(named: "EN_light_category")
                        fourthImageView.image = UIImage(named: "light_category_overlay")
                    }
                }
            } else {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        thirdImageView.image = UIImage(named: "DE_dark_category_iPad")
                        fourthImageView.image = UIImage(named: "dark_category_overlay_iPad")
                    } else {
                        thirdImageView.image = UIImage(named: "DE_dark_category")
                        fourthImageView.image = UIImage(named: "dark_category_overlay")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        thirdImageView.image = UIImage(named: "EN_dark_category_iPad")
                        fourthImageView.image = UIImage(named: "dark_category_overlay_iPad")
                    } else {
                        thirdImageView.image = UIImage(named: "EN_dark_category")
                        fourthImageView.image = UIImage(named: "dark_category_overlay")
                    }
                }
            }
            break
        case 3:
            if light {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "light_category_overlay_iPad_2")
                    } else {
                        fourthImageView.image = UIImage(named: "light_category_overlay_2")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "light_category_overlay_iPad_2")
                    } else {
                        fourthImageView.image = UIImage(named: "light_category_overlay_2")
                    }
                }
            } else {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_iPad_2")
                    } else {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_2")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_iPad_2")
                    } else {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_2")
                    }
                }
            }
            break
        case 4:
            if light {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "light_category_overlay_iPad_3")
                    } else {
                        fourthImageView.image = UIImage(named: "light_category_overlay_3")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "light_category_overlay_iPad_3")
                    } else {
                        fourthImageView.image = UIImage(named: "light_category_overlay_3")
                    }
                }
            } else {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_iPad_3")
                    } else {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_3")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_iPad_3")
                    } else {
                        fourthImageView.image = UIImage(named: "dark_category_overlay_3")
                    }
                }
            }
            break
        case 5:
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
        case 6:
            if light {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        firstImageView.image = UIImage(named: "DE_light_add_iPad")
                        secondImageView.image = UIImage(named: "light_add_overlay_iPad")
                    } else {
                        firstImageView.image = UIImage(named: "DE_light_add")
                        secondImageView.image = UIImage(named: "light_add_overlay")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        firstImageView.image = UIImage(named: "EN_light_add_iPad")
                        secondImageView.image = UIImage(named: "light_add_overlay_iPad")
                    } else {
                        firstImageView.image = UIImage(named: "EN_light_add")
                        secondImageView.image = UIImage(named: "light_add_overlay")
                    }
                }
            } else {
                if langStr == "DE" || langStr == "de" {
                    if UIDevice().model.contains("iPad") {
                        firstImageView.image = UIImage(named: "DE_dark_add_iPad")
                        secondImageView.image = UIImage(named: "dark_add_overlay_iPad")
                    } else {
                        firstImageView.image = UIImage(named: "DE_dark_add")
                        secondImageView.image = UIImage(named: "dark_add_overlay")
                    }
                } else {
                    if UIDevice().model.contains("iPad") {
                        firstImageView.image = UIImage(named: "EN_dark_add_iPad")
                        secondImageView.image = UIImage(named: "dark_add_overlay_iPad")
                    } else {
                        firstImageView.image = UIImage(named: "EN_dark_add")
                        secondImageView.image = UIImage(named: "dark_add_overlay")
                    }
                }
            }
            break
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
    
    @IBAction func swipeAction(_ sender: Any) {
        switch currentView {
        case 0:
            currentView = 1
            oneToTwoAnimation()
            break
        case 1:
            currentView = 2
            twoToThreeAnimation()
            break
        case 2:
            currentView = 3
            threeToFourthAnimation()
        case 3:
            currentView = 4
            threeToFourth2Animation()
        case 4:
            currentView = 5
            threeToFourth3Animation()
        case 5:
            currentView = 6
            fourthToFifthAnimation()
        case 6:
            currentView = 7
            fifthToFinalAnimation()
        default:
            break
        }
    }
    
    @IBAction func tabAction(_ sender: Any) {
        switch currentView {
        case 0:
            currentView = 1
            oneToTwoAnimation()
            break
        case 1:
            currentView = 2
            twoToThreeAnimation()
            break
        case 2:
            currentView = 3
            threeToFourthAnimation()
        case 3:
            currentView = 4
            threeToFourth2Animation()
        case 4:
            currentView = 5
            threeToFourth3Animation()
        case 5:
            currentView = 6
            fourthToFifthAnimation()
        case 6:
            currentView = 7
            fifthToFinalAnimation()
        default:
            break
        }
    }
    
    func oneToTwoAnimation() {
        swipeGesture.isEnabled = false
        tabGesture.isEnabled = false
        firstImageLeadingConstraint.isActive = false
        firstImageTrailingConstraint.isActive = false
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.imageStackView.trailingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
            self.imageStackView.alpha = 0.0
            self.swipeLabel.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: {_ in
            self.imageStackView.isHidden = true
            self.swipeLabel.isHidden = true
            self.firstImageView.isHidden = false
            self.welcomeLabelConstraint = self.welcomeLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50)
            self.welcomeLabelConstraint?.isActive = true
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                self.welcomeLabel.transform = self.welcomeLabel.transform.scaledBy(x: 0.7, y: 0.7)
                self.welcomeLabel.alpha = 0.0
            }, completion: { _ in
                self.welcomeStackViewConstraint.isActive = false
                self.welcomeImageYConstraint?.isActive = false
            })
        })
        UIView.animate(withDuration: 1.0, delay: 0.9, options: .curveEaseInOut, animations: {
            self.firstImageX1Constraint = self.firstImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15)
            self.firstImageX2Constraint = self.firstImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
            self.firstImageX1Constraint?.isActive = true
            self.firstImageX2Constraint?.isActive = true
            
            self.secondImageX1Constraint = self.secondImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15)
            self.secondImageX2Constraint = self.secondImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
            self.secondImageX1Constraint?.isActive = true
            self.secondImageX2Constraint?.isActive = true
            
            self.firstImageView.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: {_ in
            self.secondImageView.isHidden = false
            self.descriptionLabel.isHidden = false
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
                self.secondImageView.alpha = 1.0
                self.descriptionLabel.alpha = 1.0
            }, completion: { _ in
                self.swipeGesture.isEnabled = true
                self.tabGesture.isEnabled = true
            })
        })
    }
    
    func twoToThreeAnimation() {
        swipeGesture.isEnabled = false
        tabGesture.isEnabled = false
        
        initImageViews()
        
        self.thirdImageWidthContraint = self.thirdImageView.widthAnchor.constraint(equalTo: self.thirdImageView.widthAnchor)
        self.thirdImageWidthContraint?.isActive = true
        
        self.thirdImageLeadingConstraint.isActive = false
        self.thirdImageTrailingConstraint.isActive = false
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.secondImageView.alpha = 0.0
            self.descriptionLabel.alpha = 0.0
            
            self.thirdImageX1Constraint?.isActive = false
            self.thirdImageX1Constraint = self.thirdImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 15)
            self.thirdImageX1Constraint?.isActive = true
            self.view.layoutIfNeeded()
        }, completion: {_ in
            self.thirdImageView.isHidden = false
            
            self.firstImageWidthConstraint = self.firstImageView.widthAnchor.constraint(equalTo: self.firstImageView.widthAnchor)
            self.firstImageWidthConstraint?.isActive = true
            
            let firstWidth = self.firstImageView.frame.width
            
            self.firstImageX1Constraint?.isActive = false
            self.firstImageX2Constraint?.isActive = false
            self.firstImageX2Constraint = self.firstImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            self.firstImageX1Constraint = self.firstImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: -(firstWidth+20))
            self.firstImageX2Constraint?.isActive = true
            self.firstImageX1Constraint?.isActive = true
            
            self.thirdImageX1Constraint?.isActive = false
            self.thirdImageX2Constraint?.isActive = false
            self.thirdImageX1Constraint = self.thirdImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15)
            self.thirdImageX2Constraint = self.thirdImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
            self.thirdImageX1Constraint?.isActive = true
            self.thirdImageX2Constraint?.isActive = true
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                self.firstImageView.alpha = 0.0
                self.thirdImageView.alpha = 1.0
                self.welcomeLabel.alpha = 0.0
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.fourthImageView.isHidden = false
                self.secondSubLabel.isHidden = false
                self.descriptionLabel.isHidden = false
                self.descriptionLabel.text = NSLocalizedString("thirdDescriptionText", comment: "Category Description")
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
                    self.fourthImageView.alpha = 1.0
                    self.secondSubLabel.alpha = 1.0
                    self.descriptionLabel.alpha = 1.0
                }, completion: {_ in
                    self.swipeGesture.isEnabled = true
                    self.tabGesture.isEnabled = true
                })
            })
        })
    }
    
    func threeToFourthAnimation() {
        swipeGesture.isEnabled = false
        tabGesture.isEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.descriptionLabel.alpha = 0.0
            self.secondSubLabel.alpha = 0.0
            self.fourthImageView.alpha = 0.0
        }, completion: { _ in
            self.secondSubLabel.text = NSLocalizedString("thirdTwoDescriptionText", comment: "Description")
            self.descriptionLabel.text = NSLocalizedString("thirdTwoSecondDescriptionText", comment: "Subtext")
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
    
    func threeToFourth2Animation() {
        swipeGesture.isEnabled = false
        tabGesture.isEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.descriptionLabel.alpha = 0.0
            self.secondSubLabel.alpha = 0.0
            self.fourthImageView.alpha = 0.0
        }, completion: { _ in
            self.secondSubLabel.text = NSLocalizedString("thirdThreeDescriptionText", comment: "Description")
            self.descriptionLabel.text = NSLocalizedString("thirdThreeSecondDescriptionText", comment: "Subtext")
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
    
    func threeToFourth3Animation() {
        swipeGesture.isEnabled = false
        tabGesture.isEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.descriptionLabel.alpha = 0.0
            self.secondSubLabel.alpha = 0.0
            self.fourthImageView.alpha = 0.0
        }, completion: { _ in
            self.secondSubLabel.text = NSLocalizedString("thirdFourDescriptionText", comment: "Description")
            self.descriptionLabel.text = NSLocalizedString("thirdFourSecondDescriptionText", comment: "Subtext")
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
    
    func fourthToFifthAnimation() {
        swipeGesture.isEnabled = false
        tabGesture.isEnabled = false
        
        initImageViews()
        
        let firstWidth = self.firstImageView.frame.width
        
        firstImageView.isHidden = true
        secondImageView.isHidden = true
        
        firstImageX1Constraint?.isActive = false
        firstImageX2Constraint?.isActive = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.fourthImageView.alpha = 0.0
            self.secondSubLabel.alpha = 0.0
            self.descriptionLabel.alpha = 0.0
            self.firstImageX2Constraint = self.firstImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 20)
            self.firstImageX1Constraint = self.firstImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: (firstWidth+20))
            self.firstImageX1Constraint?.isActive = true
            self.firstImageX2Constraint?.isActive = true
            
            self.view.layoutSubviews()
        }, completion: { _ in
            self.firstImageView.isHidden = false
            
            let thirdWidth = self.thirdImageView.frame.width
            
            self.thirdImageX1Constraint?.isActive = false
            self.thirdImageX2Constraint?.isActive = false
            self.thirdImageX2Constraint = self.thirdImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            self.thirdImageX1Constraint = self.thirdImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: -(thirdWidth+20))
            self.thirdImageX2Constraint?.isActive = true
            self.thirdImageX1Constraint?.isActive = true
            
            self.firstImageX1Constraint?.isActive = false
            self.firstImageX2Constraint?.isActive = false
            self.firstImageX1Constraint = self.firstImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15)
            self.firstImageX2Constraint = self.firstImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
            self.firstImageX1Constraint?.isActive = true
            self.firstImageX2Constraint?.isActive = true
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                self.firstImageView.alpha = 1.0
                self.thirdImageView.alpha = 0.0
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.thirdImageView.isHidden = true
                
                self.descriptionLabel.text = NSLocalizedString("fourthDescriptionText", comment: "Add Transaction")
                
                self.descriptionLabel.isHidden = false
                self.secondImageView.isHidden = false
                
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
                    self.descriptionLabel.alpha = 1.0
                    self.secondImageView.alpha = 1.0
                }, completion: { _ in
                    self.swipeGesture.isEnabled = true
                    self.tabGesture.isEnabled = true
                })
            })
        })
    }
    
    func fifthToFinalAnimation() {
        swipeGesture.isEnabled = false
        tabGesture.isEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            self.descriptionLabel.alpha = 0.0
            self.secondImageView.alpha = 0.0
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            self.descriptionLabel.text = NSLocalizedString("finalDescriptionLabelText", comment: "Final Text")
        }, completion: { _ in
            let firstWidth = self.firstImageView.frame.width
            
            self.firstImageX1Constraint?.isActive = false
            self.firstImageX2Constraint?.isActive = false
            self.firstImageX2Constraint = self.firstImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            self.firstImageX1Constraint = self.firstImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: -(firstWidth+20))
            self.firstImageX2Constraint?.isActive = true
            self.firstImageX1Constraint?.isActive = true
            
            self.welcomeImageXConstraint?.isActive = false
            
            self.welcomeLabelConstraint?.isActive = false
            self.welcomeLabelConstraint = self.welcomeLabel.bottomAnchor.constraint(equalTo: self.descriptionLabel.topAnchor, constant: -30)
            self.welcomeLabelConstraint?.isActive = true
            
            self.view.bringSubviewToFront(self.welcomeLabel)
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                self.firstImageView.alpha = 0.0
                self.view.layoutIfNeeded()
            })
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
                self.welcomeLabel.transform = self.welcomeLabel.transform.scaledBy(x: 0.01, y: 0.01)
                self.welcomeLabel.alpha = 0.0
            }, completion: { _ in
                self.goButton.isHidden = false
                self.welcomeLabel.text = NSLocalizedString("welcomeLabelFinalText", comment: "Ready")
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
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
