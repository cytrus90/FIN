//
//  setPasscode.swift
//  FIN
//
//  Created by Florian Riel on 14.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class setPasscode: UIViewController {
    
    @IBOutlet weak var dotOne: UIView!
    @IBOutlet weak var dotTwo: UIView!
    @IBOutlet weak var dotThree: UIView!
    @IBOutlet weak var dotFour: UIView!
    
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    @IBOutlet weak var buttonFour: UIButton!
    @IBOutlet weak var buttonFive: UIButton!
    @IBOutlet weak var buttonSix: UIButton!
    @IBOutlet weak var buttonSeven: UIButton!
    @IBOutlet weak var buttonEight: UIButton!
    @IBOutlet weak var buttonNine: UIButton!
    @IBOutlet weak var buttonZero: UIButton!
    
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonHash: UIButton!
    
    @IBOutlet weak var dotView: UIStackView!
    
    @IBOutlet weak var forgotCodeButton: UIButton!
    
    @IBOutlet weak var enterPasscodeLabel: UILabel!
    
    var codeInput:[Int] = []
    
    var codePreviouslySet:Bool = false
    var stage:Int? // 0: Verify Previous, 1: First Input, 2: Second Input
    var firstInput:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if codePreviouslySet {
            stage = 0
        } else {
            stage = 1
        }
        initView()
        self.isModalInPresentation = true
        // Rotate and lock
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }

    
    // Orientation Lock
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
    }
    
    // MARK: -ACTIONS
    @IBAction func one(_ sender: Any) {
        addDigit(button: 1)
    }
    
    @IBAction func two(_ sender: Any) {
        addDigit(button: 2)
    }
    
    @IBAction func three(_ sender: Any) {
        addDigit(button: 3)
    }
    
    @IBAction func four(_ sender: Any) {
        addDigit(button: 4)
    }
    
    @IBAction func five(_ sender: Any) {
        addDigit(button: 5)
    }
    
    @IBAction func six(_ sender: Any) {
        addDigit(button: 6)
    }
    
    @IBAction func seven(_ sender: Any) {
        addDigit(button: 7)
    }
    
    @IBAction func eight(_ sender: Any) {
        addDigit(button: 8)
    }
    
    @IBAction func nine(_ sender: Any) {
        addDigit(button: 9)
    }
    
    @IBAction func zero(_ sender: Any) {
        addDigit(button: 0)
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        if codeInput.count > 0 {
            codeInput.remove(at: (codeInput.count)-1)
        } else {
            animateDots()
        }
        setDots()
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: -FUNCTIONS
    func checkCode() {
        toggleButtonsActive(setActive: false)
        switch stage {// 0: Verify Previous, 1: First Input, 2: Second Input
        case 1:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            firstInput = String(codeInput[0] * 1000 + codeInput[1] * 100 + codeInput[2] * 10 + codeInput[3]).sha1()
            stage = 2
            codeInput.removeAll()
            animateGoodDots()
            break
        case 2:
            let userInputCode = String(codeInput[0] * 1000 + codeInput[1] * 100 + codeInput[2] * 10 + codeInput[3]).sha1()
            if userInputCode == firstInput {
                saveSettings(settingsChange: "userCode", newValue: userInputCode)
                loginSuccessfull = false
                loginEnabled = true
                enterPasscodeLabel.text = NSLocalizedString("New Passcode Success", comment: "Enter New Passcode Success Title")
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                animateDots(success: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                stage = 1
                codeInput.removeAll()
                enterPasscodeLabel.text = NSLocalizedString("New Passcode Nomatch", comment: "Enter New Passcode Nomatch Title")
                animateBadDots()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.25, execute: {
                    self.initView()
                    self.toggleButtonsActive(setActive: true)
                })
            }
            break
        default:
            let userInputCode = String(codeInput[0] * 1000 + codeInput[1] * 100 + codeInput[2] * 10 + codeInput[3]).sha1()
            if loadData(entitie: "Settings", attibute: "userCode") as? String == userInputCode {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                stage = 1
                codeInput.removeAll()
                animateGoodDots()
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                animateDots()
                codeInput.removeAll()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.initView()
                    self.toggleButtonsActive(setActive: true)
                })
            }
            break
        }
    }
    
    func addDigit(button:Int) {
        codeInput.append(button)
        setDots()
    }
    
    func setDots() {
        let alpha = CGFloat(0.6)
        let alphaNot = CGFloat(0.1)
        switch codeInput.count {
        case 0:
            dotOne.backgroundColor = dotOne.backgroundColor?.withAlphaComponent(alphaNot)
            dotTwo.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alphaNot)
            dotThree.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alphaNot)
            dotFour.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alphaNot)
            break
        case 1:
            dotOne.backgroundColor = dotOne.backgroundColor?.withAlphaComponent(alpha)
            dotTwo.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alphaNot)
            dotThree.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alphaNot)
            dotFour.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alphaNot)
            break
        case 2:
            dotOne.backgroundColor = dotOne.backgroundColor?.withAlphaComponent(alpha)
            dotTwo.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alpha)
            dotThree.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alphaNot)
            dotFour.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alphaNot)
            break
        case 3:
            dotOne.backgroundColor = dotOne.backgroundColor?.withAlphaComponent(alpha)
            dotTwo.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alpha)
            dotThree.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alpha)
            dotFour.backgroundColor = dotTwo.backgroundColor?.withAlphaComponent(alphaNot)
            break
        default:
            dotFour.backgroundColor = dotFour.backgroundColor?.withAlphaComponent(alpha)
            checkCode()
        }
    }
    
    func initView() {
        forgotCodeButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel Set Code"), for: .normal)
        enterPasscodeLabel.textColor = dotOne.tintColor
        switch stage {// 0: Verify Previous, 1: First Input, 2: Second Input
        case 1:
            enterPasscodeLabel.text = NSLocalizedString("New Passcode", comment: "Enter New Passcode Title")
            break
        case 2:
            enterPasscodeLabel.text = NSLocalizedString("Re-Enter Passcode", comment: "Enter New Passcode Title")
            break
        default:
            enterPasscodeLabel.text = NSLocalizedString("Current Passcode", comment: "Enter Current Passcode Title")
            break
        }
        
        let alpha = CGFloat(0.1)
        
        dotOne.layer.borderWidth = 0.1
        dotOne.layer.cornerRadius = 5
        dotTwo.layer.borderWidth = 0.1
        dotTwo.layer.cornerRadius = 5
        dotThree.layer.borderWidth = 0.1
        dotThree.layer.cornerRadius = 5
        dotFour.layer.borderWidth = 0.1
        dotFour.layer.cornerRadius = 5
        
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
            
            dotOne.backgroundColor = UIColor.white.withAlphaComponent(alpha)
            dotTwo.backgroundColor = UIColor.white.withAlphaComponent(alpha)
            dotThree.backgroundColor = UIColor.white.withAlphaComponent(alpha)
            dotFour.backgroundColor = UIColor.white.withAlphaComponent(alpha)
            
            dotOne.layer.borderColor = UIColor.white.withAlphaComponent(alpha).cgColor
            dotTwo.layer.borderColor = UIColor.white.withAlphaComponent(alpha).cgColor
            dotThree.layer.borderColor = UIColor.white.withAlphaComponent(alpha).cgColor
            dotFour.layer.borderColor = UIColor.white.withAlphaComponent(alpha).cgColor
            
            buttonHash.setTitleColor(.black, for: .normal)
            buttonDelete.tintColor = UIColor.white.withAlphaComponent(0.6)
        } else {
            view.backgroundColor = .white
            
            dotOne.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            dotTwo.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            dotThree.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            dotFour.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            
            dotOne.layer.borderColor = UIColor.black.withAlphaComponent(alpha).cgColor
            dotTwo.layer.borderColor = UIColor.black.withAlphaComponent(alpha).cgColor
            dotThree.layer.borderColor = UIColor.black.withAlphaComponent(alpha).cgColor
            dotFour.layer.borderColor = UIColor.black.withAlphaComponent(alpha).cgColor
            
            buttonHash.setTitleColor(.white, for: .normal)
            buttonDelete.tintColor = UIColor.black.withAlphaComponent(0.4)
        }
        toggleButtonsActive(setActive: true)
    }
    
    func animateDots(success:Bool = false) {
        if success {
            let alpha = CGFloat(0.6)
            UIView.animate(withDuration: 0.05, animations: {() in
                self.dotOne.backgroundColor = self.dotOne.backgroundColor?.withAlphaComponent(alpha)
            })

            UIView.animate(withDuration: 0.05, delay: 0.05, animations: {() in
                self.dotTwo.backgroundColor = self.dotTwo.backgroundColor?.withAlphaComponent(alpha)
            })
            
            UIView.animate(withDuration: 0.05, delay: 0.1, animations: {() in
                self.dotThree.backgroundColor = self.dotTwo.backgroundColor?.withAlphaComponent(alpha)
            })
                    
            UIView.animate(withDuration: 0.05,delay: 0.15, animations: {() in
                self.dotFour.backgroundColor = self.dotFour.backgroundColor?.withAlphaComponent(alpha)
            })
        } else {
            let alpha = CGFloat(0.1)
            let initialX = self.dotView.center.x
            UIView.animate(withDuration: 0.1, animations: {() in
                self.dotView.center.x = initialX + self.view.frame.width*0.05
                self.dotOne.backgroundColor = self.dotOne.backgroundColor?.withAlphaComponent(alpha)
            })

            UIView.animate(withDuration: 0.1, delay: 0.1, animations: {() in
                self.dotTwo.backgroundColor = self.dotTwo.backgroundColor?.withAlphaComponent(alpha)
                self.dotThree.backgroundColor = self.dotTwo.backgroundColor?.withAlphaComponent(alpha)
                self.dotView.center.x = initialX - self.view.frame.width*0.05
            })
                    
            UIView.animate(withDuration: 0.1,delay: 0.2, animations: {() in
                self.dotFour.backgroundColor = self.dotFour.backgroundColor?.withAlphaComponent(alpha)
                self.dotView.center.x = initialX
            })
        }
    }
    
    func animateGoodDots() {
        let alpha = CGFloat(0.1)
        UIView.animate(withDuration: 0.05, animations: {() in
            self.dotOne.backgroundColor = self.dotOne.backgroundColor?.withAlphaComponent(alpha)
        })
        UIView.animate(withDuration: 0.05, delay: 0.05, animations: {() in
            self.dotTwo.backgroundColor = self.dotTwo.backgroundColor?.withAlphaComponent(alpha)
        })
        UIView.animate(withDuration: 0.05, delay: 0.1, animations: {() in
            self.dotThree.backgroundColor = self.dotThree.backgroundColor?.withAlphaComponent(alpha)
        })
        UIView.animate(withDuration: 0.05,delay: 0.15, animations: {() in
            self.dotFour.backgroundColor = self.dotFour.backgroundColor?.withAlphaComponent(alpha)
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.initView()
        })
    }
    
    func animateBadDots() {
        let alpha = CGFloat(0.1)
        UIView.animate(withDuration: 0.05, animations: {() in
            self.dotOne.backgroundColor = self.dotFour.backgroundColor?.withAlphaComponent(alpha)
        })
        UIView.animate(withDuration: 0.05, delay: 0.05, animations: {() in
            self.dotTwo.backgroundColor = self.dotThree.backgroundColor?.withAlphaComponent(alpha)
        })
        UIView.animate(withDuration: 0.05, delay: 0.1, animations: {() in
            self.dotThree.backgroundColor = self.dotTwo.backgroundColor?.withAlphaComponent(alpha)
        })
        UIView.animate(withDuration: 0.05,delay: 0.15, animations: {() in
            self.dotFour.backgroundColor = self.dotOne.backgroundColor?.withAlphaComponent(alpha)
        })
    }
    
    func toggleButtonsActive(setActive: Bool) {
        if setActive {
            buttonOne.isUserInteractionEnabled = true
            buttonTwo.isUserInteractionEnabled = true
            buttonThree.isUserInteractionEnabled = true
            buttonFour.isUserInteractionEnabled = true
            buttonFive.isUserInteractionEnabled = true
            buttonSix.isUserInteractionEnabled = true
            buttonSeven.isUserInteractionEnabled = true
            buttonEight.isUserInteractionEnabled = true
            buttonNine.isUserInteractionEnabled = true
            buttonZero.isUserInteractionEnabled = true
        } else {
            buttonOne.isUserInteractionEnabled = false
            buttonTwo.isUserInteractionEnabled = false
            buttonThree.isUserInteractionEnabled = false
            buttonFour.isUserInteractionEnabled = false
            buttonFive.isUserInteractionEnabled = false
            buttonSix.isUserInteractionEnabled = false
            buttonSeven.isUserInteractionEnabled = false
            buttonEight.isUserInteractionEnabled = false
            buttonNine.isUserInteractionEnabled = false
            buttonZero.isUserInteractionEnabled = false
        }
    }
    
    // MARK: -DATA
    func loadData(entitie:String, attibute:String) -> Any {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    return data.value(forKey: attibute) ?? false
                }
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    func saveSettings(settingsChange: String, newValue: Any) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetchedSettings = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            fetchedSettings[0].setValue(newValue, forKey: settingsChange)

            try managedContext.save()
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
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
