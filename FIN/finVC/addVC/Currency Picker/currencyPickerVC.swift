//
//  currencyPickerVC.swift
//  FIN
//
//  Created by Florian Riel on 27.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class currencyPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var currencyTable: UITableView!
    
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var exchangeRateTextField: UITextField!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    struct Rates: Codable {
        var CAD: Double?
        var HKD: Double?
        var ISK: Double?
        var PHP: Double?
        var DKK: Double?
        var HUF: Double?
        var CZK: Double?
        var GBP: Double?
        var RON: Double?
        var SEK: Double?
        var IDR: Double?
        var INR: Double?
        var BRL: Double?
        var RUB: Double?
        var HRK: Double?
        var JPY: Double?
        var THB: Double?
        var CHF: Double?
        var EUR: Double?
        var MYR: Double?
        var BGN: Double?
        var TRY: Double?
        var CNY: Double?
        var NOK: Double?
        var NZD: Double?
        var ZAR: Double?
        var USD: Double?
        var MXN: Double?
        var SGD: Double?
        var AUD: Double?
        var ILS: Double?
        var KRW: Double?
        var PLN: Double?
    }

    struct Response: Codable { // or Decodable
        let base: String
        let date: String
        let rates: Rates
    }
    
    var currenciesRAM: Rates?
    var currencyData = [Int:[String:Any]]()
    var settleCurrency:Bool = false
    let currencyFormatter = NumberFormatter()
    
    var lastCurrencyCode:String?
    
    override func loadView() {
        super.loadView()
        NotificationCenter.default.addObserver(self, selector: #selector(saveUpdatedExchangeRates), name: Notification.Name("saveUpdatedExchangeRates"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyFormatter.locale = .current
        
        performBackgroundOperation()
        
        currencyTable.dataSource = self
        currencyTable.delegate = self
        
        if (lastCurrencyCode?.count ?? 0) <= 0 {
            lastCurrencyCode = loadSettings(entitie: "Settings", attibute: "lastCurrencyCode") as? String ?? "EUR"
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
        saveSettings(settingsChange: "lastCurrencyCode", newValue: currencyCodeSet)
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
    func getCurrencyData() {
        currencyData.removeAll()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
//        formatter.locale = Locale.current
        
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = Locale.current.groupingSeparator
        formatter.groupingSize = 3
        formatter.minimumFractionDigits = 3
        formatter.maximumFractionDigits = 3
        
        if let currencyDB = loadBulkData(entitie: "Currency", orderBy: "currencyCode") as? [NSManagedObject] {
            for data in currencyDB {
                currencyData[data.value(forKey: "id") as? Int ?? 0] = [
                    "currencyName": NSLocalizedString((data.value(forKey: "currencyCode") as? String ?? ""), comment: "Country"),
                    "currencySymbol":getSymbol(forCurrencyCode: (data.value(forKey: "currencyCode") as? String ?? "")) ?? "€",
                    "exchangeRate":formatter.string(for: data.value(forKey: "exchangeRate") as? Double ?? 1.00) ?? "1.00",
                    "automated":data.value(forKey: "automated") as? Bool ?? false,
                    "currencyCode":data.value(forKey: "currencyCode") as? String ?? ""
                ]
            }
        } else {
            initCurrency()
        }
        activityIndicator.isHidden = true
    }
    
    // MARK: -ACTIONS
    @objc func addTapped() {
        if !settleCurrency {
            if let exchrate = currencyFormatter.number(from: exchangeRateTextField.text ?? "1.00") as? Double {
                currencyExchangeRate = abs(exchrate)
            } else {
                currencyExchangeRate = 1.00
            }
            saveSettings(settingsChange: "lastCurrencyCode", newValue: currencyCodeSet)
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
    
    // MARK: -UPDATE CURRENCY
    private func performBackgroundOperation() {
        // Add async operation
        OperationQueue().addOperation {
            OperationQueue.main.addOperation {
                self.willLoadData() // on main thread
            }
            self.loadDataAsync() // async
            OperationQueue.main.addOperation {
                self.didLoadData() // on main thread
            }
        }
    }

    func loadDataAsync() {
        // do something on the main thread before loading
    }

    func willLoadData() {
//        updateExchangeRates()
    }

    func didLoadData() {
        activityIndicator.isHidden = false
        updateExchangeRates(completion: {(success) -> Void in
            self.activityIndicator.isHidden = true
        })
        // do something on the main thread after loading
    }
    
    func updateExchangeRates(completion: (Bool) -> ()) {
        let query = NSPredicate(format: "id == %i", 0)
        
        if let lastSavedDate = loadQueriedAttribute(entitie: "Currency", attibute: "saved", query: query) as? Date {
            if Date().timeIntervalSince(lastSavedDate) > 1 {
                let config = URLSessionConfiguration.default
                config.waitsForConnectivity = true
                config.timeoutIntervalForResource = 15

                let session = URLSession(configuration: config)

                let url = URL(string: "https://www.example.com/")!

                session.dataTask(with: url) { data, response, error in
                    self.initCurrency()
                }.resume()
            }
        }
        completion(true)
    }
    
    func initCurrency() {
        let currentInputCurrency = Locale.current.currencyCode ?? "EUR"
//        let currentInputCurrency = "EUR"
        
        let urlRAM = "https://api.exchangeratesapi.io/latest?base=" + currentInputCurrency

        if let url = URL(string: urlRAM) {
            URLSession.shared.dataTask(with: url) { [self] data, response, error in
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode(Response.self, from: data)
                        currenciesRAM = res.rates
                        
                        let nc = NotificationCenter.default
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            nc.post(name: Notification.Name("saveUpdatedExchangeRates"), object: nil)
                        })
                    } catch let error {
                        print(error)
                    }
                }
            }.resume()
        }
    }

    func csv(data: String, sep: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: sep)
            result.append(columns)
        }
        return result
    }
        
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func cleanRows(file:String)->String {
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    @objc func saveUpdatedExchangeRates() {
        var data = readDataFromCSV(fileName: "currency_table", fileType: "csv")
        data = cleanRows(file: data ?? "")
        let csvRows = csv(data: data ?? "", sep: ";")
        
        var j:Int16 = 0
        for currency in csvRows {
            switch currency[0] {
            case "CAD":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.CAD ?? 1.0, automated: true, id: j)
                break
            case "HKD":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.HKD ?? 1.0, automated: true, id: j)
                break
            case "ISK":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.ISK ?? 1.0, automated: true, id: j)
                break
            case "PHP":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.PHP ?? 1.0, automated: true, id: j)
                break
            case "DKK":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.DKK ?? 1.0, automated: true, id: j)
                break
            case "HUF":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.HUF ?? 1.0, automated: true, id: j)
                break
            case "CZK":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.CZK ?? 1.0, automated: true, id: j)
                break
            case "GBP":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.GBP ?? 1.0, automated: true, id: j)
                break
            case "RON":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.RON ?? 1.0, automated: true, id: j)
                break
            case "SEK":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.SEK ?? 1.0, automated: true, id: j)
                break
            case "IDR":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.IDR ?? 1.0, automated: true, id: j)
                break
            case "INR":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.INR ?? 1.0, automated: true, id: j)
                break
            case "BRL":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.BRL ?? 1.0, automated: true, id: j)
                break
            case "RUB":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.RUB ?? 1.0, automated: true, id: j)
                break
            case "HRK":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.HRK ?? 1.0, automated: true, id: j)
                break
            case "JPY":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.JPY ?? 1.0, automated: true, id: j)
                break
            case "THB":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.THB ?? 1.0, automated: true, id: j)
                break
            case "CHF":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.CHF ?? 1.0, automated: true, id: j)
                break
            case "EUR":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.EUR ?? 1.0, automated: true, id: j)
                break
            case "MYR":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.MYR ?? 1.0, automated: true, id: j)
                break
            case "BGN":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.BGN ?? 1.0, automated: true, id: j)
                break
            case "TRY":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.TRY ?? 1.0, automated: true, id: j)
                break
            case "CNY":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.CNY ?? 1.0, automated: true, id: j)
                break
            case "NOK":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.NOK ?? 1.0, automated: true, id: j)
                break
            case "NZD":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.NZD ?? 1.0, automated: true, id: j)
                break
            case "ZAR":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.ZAR ?? 1.0, automated: true, id: j)
                break
            case "USD":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.USD ?? 1.0, automated: true, id: j)
                break
            case "MXN":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.MXN ?? 1.0, automated: true, id: j)
                break
            case "SGD":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.SGD ?? 1.0, automated: true, id: j)
                break
            case "AUD":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.AUD ?? 1.0, automated: true, id: j)
                break
            case "ILS":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.ILS ?? 1.0, automated: true, id: j)
                break
            case "KRW":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.KRW ?? 1.0, automated: true, id: j)
                break
            case "PLN":
                self.saveCurrency(currencyCode: currency[0], exchangeRate: currenciesRAM?.PLN ?? 1.0, automated: true, id: j)
                break
            default:
                self.saveCurrency(currencyCode: currency[0], exchangeRate: 1.0, automated: false, id: j)
                break
            }
            j = j+1
        }
        self.getCurrencyData()
    }

    func saveCurrency(currencyCode: String, exchangeRate: Double?, automated: Bool, id: Int16) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let currencySave = Currency(context: managedContext)
        
        currencySave.currencyCode = currencyCode
        currencySave.exchangeRate = exchangeRate ?? 1.0
        currencySave.automated = automated
        currencySave.saved = Date()
        currencySave.id = id
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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

extension currencyPickerVC {
    func loadBulkData(entitie:String, orderBy:String) -> Any {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: orderBy, ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if loadData.count > 0 {
                return loadData
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    func loadQueriedAttribute(entitie:String, attibute:String, query:NSPredicate) -> Any {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
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
    
    func loadSettings(entitie:String, attibute:String) -> Any {
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
}
