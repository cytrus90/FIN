//
//  login.swift
//  FIN
//
//  Created by Florian Riel on 25.06.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication
import CommonCrypto
import CoreData
//import MailCore

class loginVC: UIViewController {
    
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
    
    @IBOutlet weak var dotsConstraint: NSLayoutConstraint!
    @IBOutlet weak var dotView: UIStackView!
    
    @IBOutlet weak var forgotCodeButton: UIButton!
    
    @IBOutlet weak var enterPasscodeLabel: UILabel!
    
    let remote = alpakoPHPRequest()
    
    var codeInput:[Int] = []
    
    // Orientation Lock
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    override func loadView() {
        super.loadView()
        // MARK: PUT TO FIRST LAUNCH VIEW
        loadSettings()
        //
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Disable drag to dismiss of view
        self.isModalInPresentation = true
        
        remote.delegate = self
        
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        let identificationType:BioMetricSupported = visAuthClass.supportedBiometricType()
        if identificationType != .none {
            runIdentification()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
    }
    
    @objc func dissAppear() {
        self.dismiss(animated: true)
    }
    
    // MARK: -ACTIONS
    @IBAction func forgotCodeButtonAction(_ sender: Any) {
        let confirm = UIAlertController(title: NSLocalizedString("forgotCodeConfirmTitle", comment: "Reset Code Title"), message: NSLocalizedString("forgotCodeConfirmText", comment: "Reset Code Text"), preferredStyle: .actionSheet)
        // Popover for iPad
        if let popoverController = confirm.popoverPresentationController {
            popoverController.sourceView = self.view //to set the source of your alert
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
            popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
        }
        confirm.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeConfirmAction", comment: "Reset Code Confim"), style: .default, handler: { action in
            
            let RAM = Int.random(in: 0..<9999)
            self.saveSettings(settingsChange: "userCode", newValue: String(RAM).sha1())
            
            var newCode = "0"
            if RAM < 10 {
                newCode = "000" + String(RAM)
            } else if RAM < 100 {
                newCode = "00" + String(RAM)
            } else if RAM < 1000 {
                newCode = "0" + String(RAM)
            } else {
                newCode = String(RAM)
            }
            
            let recoveryMail = self.loadData(entitie: "Settings", attibute: "recoveryMail")

            if self.sendMailPHP(Code: newCode, toMail: recoveryMail as? String ?? "deus.florian@gmail.com", language: NSLocalizedString("forgotCodeMailLanguage", comment: "Reset Mail language")) {

//                self.saveSettings(settingsChange: "userCode", newValue: newCode.sha1())

                let positiveAlert = UIAlertController(title: NSLocalizedString("forgotCodePositiveTitle", comment: "Reset Code Postive Title"), message: NSLocalizedString("forgotCodePositiveText", comment: "Reset Code Postive Text"), preferredStyle: .alert)
                positiveAlert.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "Reset Code Ok"), style: .cancel, handler: nil))
                positiveAlert.popoverPresentationController?.sourceView = self.view
                positiveAlert.popoverPresentationController?.sourceRect = self.view.bounds
                self.present(positiveAlert, animated: true)
            } else {
                let negativeAlert = UIAlertController(title: NSLocalizedString("forgotCodeNegativeTitle", comment: "Reset Code Postive Title"), message: NSLocalizedString("forgotCodeNegativeText", comment: "Reset Code Postive Text"), preferredStyle: .alert)
                negativeAlert.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "Reset Code Ok"), style: .cancel, handler: nil))
                negativeAlert.popoverPresentationController?.sourceView = self.view
                negativeAlert.popoverPresentationController?.sourceRect = self.view.bounds
                self.present(negativeAlert, animated: true)
            }
        }))
        confirm.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeCancel", comment: "Reset Code Cancel"), style: .cancel, handler: nil))
        confirm.popoverPresentationController?.sourceView = self.view
        confirm.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(confirm, animated: true)
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
    
    // MARK: -FUNCTIONS
    func runIdentification() {
        let authTitle = NSLocalizedString("Authentication", comment: "Authentication Title")
        visAuthClass.isValidUer(reasonString: authTitle) {[unowned self] (isSuccess, stringValue) in
            if isSuccess {
                loginSuccessfull = true
                self.animateDots(success: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "TabController") as! tabController
                    self.performSegue(withIdentifier: "loginSuccess", sender: nil)
                    self.present(newViewController, animated: true, completion: nil)
                })
            } else {
                self.animateDots()
            }
        }
    }
    
    func addDigit(button:Int) {
        codeInput.append(button)
        setDots()
    }
    
    func checkCode() {
        let userInputCode = String(codeInput[0] * 1000 + codeInput[1] * 100 + codeInput[2] * 10 + codeInput[3]).sha1()
        
        if loadData(entitie: "Settings", attibute: "userCode") as? String == userInputCode {
            loginSuccessfull = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "TabController") as! tabController
            performSegue(withIdentifier: "loginSuccess", sender: nil)
            self.present(newViewController, animated: true, completion: nil)
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            animateDots()
            codeInput.removeAll()
        }
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
        forgotCodeButton.setTitle(NSLocalizedString("Forgot Code?", comment: "Forgot Code Title"), for: .normal)
        enterPasscodeLabel.text = getGreetingString()
//            NSLocalizedString("Enter Passcode", comment: "Enter Passcode Title")
        enterPasscodeLabel.textColor = dotOne.tintColor
        
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
    }
    
    func getGreetingString() -> String {
        var str2 = ""
        if (loadData(entitie: "Settings", attibute: "userName") as? String ?? "User") != NSLocalizedString("userText", comment: "User") {
            str2 = ", " + (loadData(entitie: "Settings", attibute: "userName") as? String ?? "User")
        }
        
        let hour = Calendar.current.component(.hour, from: Date())
        let langStr = Locale.current.languageCode
    
        var str1 = ""
        
        switch langStr {
        case "de","DE": // DE
            if hour < 10 { // Guten Morgen
                str1 = NSLocalizedString("goodMorning", comment: "Guten Morgen")
            } else if hour >= 10 && hour < 18 { // Guten Tag
                str1 = NSLocalizedString("goodAfternoon", comment: "Guten Tag")
            } else if hour >= 18 && hour < 21 { // Schönen Abend
                str1 = NSLocalizedString("goodEvening", comment: "Guten Abend")
            } else { // Gute Nacht
                str1 = NSLocalizedString("goodNight", comment: "Gute Nacht")
            }
        default: // EN
            if hour <= 11 { // Good morning
                str1 = NSLocalizedString("goodMorning", comment: "Good morning")
            } else if hour >= 12 && hour < 17 { // Good afternoon
                str1 = NSLocalizedString("goodAfternoon", comment: "Good afternoon")
            } else if hour >= 17 && hour < 21 { // Good evening
                str1 = NSLocalizedString("goodEvening", comment: "Good evening")
            } else { // Good night
                str1 = NSLocalizedString("goodNight", comment: "Good night")
            }
        }
        return (str1 + str2)
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
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "loginSuccess":
            self.dismiss(animated: true, completion: nil)
            break
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    // MARK: PUT TO FIRST LAUNCH VIEW
    
    func saveNewSettings() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let settingsSave = Settings(context: managedContext)
        // MARK: -REMOVE:
        settingsSave.userCode = String("")
//        settingsSave.recoveryMail = "flori@nriel.com"
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func loadSettings() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let settings = try managedContext.fetch(fetchRequest)
            if settings.count > 0 {
                saveSettings(settingsChange: "firstLaunch", newValue: false)
                saveSettings(settingsChange: "firstLaunchDate", newValue: Date())
            } else {
                saveNewSettings()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
    
    // MARK: -MAIL
    func sendMailPHP(Code: String, toMail: String, language:String) -> Bool {
        let parameters = ["requestType":"0","newCode":Code,"mailTo":toMail,"language":language]
        remote.sendMail(parameters: parameters, url: "https://fin.alpako.info/sendMail.php")
        return true
    }
}

extension loginVC: Downloadable {
    func didReceiveData(data: Any) {
       DispatchQueue.main.sync {
            print("Mail Sent")
       }
    }
}

extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}
