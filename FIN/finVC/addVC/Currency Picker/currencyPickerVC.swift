//
//  currencyPickerVC.swift
//  FIN
//
//  Created by Florian Riel on 27.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData
import Network

class currencyPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var currencyTable: UITableView!
    
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var exchangeRateTextField: UITextField!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let remote = alpakoPHPRequest()
    
    var currencyData = [Int:[String:Any]]()
    var settleCurrency:Bool = false
    let currencyFormatter = NumberFormatter()
    
    var lastCurrencyCode:String?
    
    override func loadView() {
        super.loadView()
        // NotificationCenter.default.addObserver(self, selector: #selector(getCurrencyData), name: Notification.Name("savedUpdatedExchangeRates"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        
        currencyFormatter.locale = .current
        
        currencyTable.dataSource = self
        currencyTable.delegate = self
        
        if (lastCurrencyCode?.count ?? 0) <= 0 {
            lastCurrencyCode = dataHandler.loadSettings(entitie: "Settings", attibute: "lastCurrencyCode") as? String ?? "EUR"
        }
        
        initView()
        getCurrencyData()
        
//        self.isModalInPresentation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            self.view.layoutIfNeeded()
            self.view.updateConstraintsIfNeeded()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyData.count-1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCurrencyPicker", for: indexPath) as! cellCurrencyPicker
        
        cell.leftLabel.text = currencyData[indexPath.row]?["currencyName"] as? String ?? ""
        cell.rightLabel.text = currencyData[indexPath.row]?["currencySymbol"] as? String ?? ""
        
        if (currencyData[indexPath.row]?["currencyCode"] as? String ?? "") == lastCurrencyCode {
            currencyTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            currencyNameLabel.text = currencyData[indexPath.row]?["currencyName"] as? String ?? ""
            exchangeRateLabel.text = String(Locale.current.currencyCode ?? "EUR") + (currencyData[indexPath.row]?["currencyCode"] as! String)
            exchangeRateTextField.text = currencyData[indexPath.row]?["exchangeRate"] as? String ?? ""
            currencyExchangeRate = (exchangeRateTextField.text! as NSString).doubleValue
            currencyCodeSet = currencyData[indexPath.row]?["currencyCode"] as? String ?? "EUR"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currencyNameLabel.text = currencyData[indexPath.row]?["currencyName"] as? String ?? ""
        exchangeRateLabel.text = String(Locale.current.currencyCode ?? "EUR") + (currencyData[indexPath.row]?["currencyCode"] as? String ?? "")
        exchangeRateTextField.text = currencyData[indexPath.row]?["exchangeRate"] as? String ?? ""
        currencyExchangeRate = (exchangeRateTextField.text! as NSString).doubleValue
        currencyCodeSet = currencyData[indexPath.row]?["currencyCode"] as? String ?? "EUR"
        dataHandler.saveSettings(settingsChange: "lastCurrencyCode", newValue: currencyCodeSet)
        if (lastCurrencyCode?.count ?? 0) > 0 { lastCurrencyCode = "" }
    }
    
    // MARK: -INIT VIEW
    func initView() {
        headerView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
        currencyNameLabel.textColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        
        currencyNameLabel.text = NSLocalizedString(currencyCodeSet, comment: "Country")
        exchangeRateLabel.text = currencyCodeSet
        exchangeRateTextField.text = String(currencyExchangeRate ?? 1.0)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Set", comment: "Set Navbar Button"), style: .plain, target: self, action: #selector(addTapped))
        exchangeRateTextField.keyboardType = .decimalPad
    }
    
    // MARK: -FUNCTIONS
    func getSymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code)
        }
        return locale.displayName(forKey: .currencySymbol, value: code)
    }
    
    // MARK: GET DATA
    @objc func getCurrencyData() {
        currencyData.removeAll()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = Locale.current.groupingSeparator
        formatter.groupingSize = 3
        formatter.minimumFractionDigits = 3
        formatter.maximumFractionDigits = 3
        
        let currencyDB = dataHandler.loadBulkData(entitie: "Currency", orderBy: "currencyCode")
        if currencyDB.count > 0 {
            for data in currencyDB {
                currencyData[data.value(forKey: "id") as? Int ?? 0] = [
                    "currencyName": NSLocalizedString((data.value(forKey: "currencyCode") as? String ?? ""), comment: "Country"),
                    "currencySymbol":getSymbol(forCurrencyCode: (data.value(forKey: "currencyCode") as? String ?? "")) ?? "€",
                    "exchangeRate":formatter.string(for: data.value(forKey: "exchangeRate") as? Double ?? 1.00) ?? "1.00",
                    "automated":data.value(forKey: "automated") as? Bool ?? false,
                    "currencyCode":data.value(forKey: "currencyCode") as? String ?? ""
                ]
            }
        }
    }
    
    // MARK: -ACTIONS
    @objc func addTapped() {
        if !settleCurrency {
            if let exchrate = currencyFormatter.number(from: exchangeRateTextField.text ?? "1.00") as? Double {
                currencyExchangeRate = abs(exchrate)
            } else {
                currencyExchangeRate = 1.00
            }
            dataHandler.saveSettings(settingsChange: "lastCurrencyCode", newValue: currencyCodeSet)
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("currencyChanged"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: -TextViewDelegate
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let exchrate = currencyFormatter.number(from: exchangeRateTextField.text ?? "1.00") as? Double {
            currencyExchangeRate = abs(exchrate)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let exchrate = currencyFormatter.number(from: exchangeRateTextField.text ?? "1.00") as? Double {
            currencyExchangeRate = abs(exchrate)
        }
        textField.resignFirstResponder()
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
