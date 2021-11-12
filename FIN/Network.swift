//
//  Network.swift
//  NicosGame
//
//  Created by Florian Riel on 13.05.21.
//

import Foundation

protocol Downloadable: AnyObject {
    func didReceiveData(data: Any)
}

enum URLServices {
    // change to your PHP script in your own server.
    static let sendMail: String = "https://fin.alpako.info/sendMail.php"
}

class Network{
    
    struct ratesArrayFromJSON: Codable {
        struct exchangeRate: Codable {
            let pair: String
            let rate: String
        }
        
        var rates: [exchangeRate]
    }
    
    struct rate {
        var pair: String
        var rate: Double
    }
    
    func request(parameters: [String: String], url: String) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var postString = "requestID=cd81137371dfb0901f1ec81c8a617dfe3c0638ef"
        
        for (_,value) in parameters.enumerated() {
            postString = postString + "&" + value.key + "=" + String(value.value)
        }
        
//        print(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        return request
    }
    
    func response(request: URLRequest, completionBlock: @escaping (Data) -> Void) -> Void {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {   // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else { //check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            // data will be available for other models that implements the block
            completionBlock(data);
        }
        task.resume()
    }
    
    func responseExchangeRates(request: URLRequest, completionBlock: @escaping (Data) -> Void) -> Void {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {   // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            guard (200 ... 299) ~= response.statusCode else { //check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            //guard let mime = response.mimeType, mime == "application/json" else {
            //    print("Wrong MIME type!")
            //    return
            //}
            
            do {
                print("responseExchangeRates")
                let ratesArray = try JSONDecoder().decode(ratesArrayFromJSON.self, from: data)

                var rates = [rate]()
                
                for r in ratesArray.rates {
                    rates.append(rate(pair: r.pair, rate: (Double(r.rate) ?? 0.00)))
                }
                
                let basePair = "USD" + currencyCodeSet
                var baseRate = 1.0
                let baseRateStruct = (rates.filter { $0.pair == basePair })
                
                if baseRateStruct.count > 0 {
                    baseRate = baseRateStruct[0].rate
                }
                
                var calculatedRates = [String: Double]()
                for r in rates {
                    if (r.pair != basePair) && r.pair != "USDUSD" {
                        calculatedRates[r.pair.replacingOccurrences(of: "USD", with: "")] = r.rate / baseRate
                    } else if r.pair == "USDUSD" {
                        if currencyCodeSet == "USD" {
                            calculatedRates["USD"] = 1.0
                        } else {
                            calculatedRates["USD"] = r.rate / baseRate
                        }
                    } else if r.pair == ("USD" + currencyCodeSet) {
                        calculatedRates[currencyCodeSet] = 1.0
                    }
                }
                if self.writeExchangeRates(rates: calculatedRates) {
                    print("writeExchangeRates_done")
                    //let nc = NotificationCenter.default
                    //nc.post(name: Notification.Name("savedUpdatedExchangeRates"), object: nil)
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func writeExchangeRates(rates: [String: Double]) -> Bool {
        print("writeExchangeRates")
        var data = readDataFromCSV(fileName: "currency_table", fileType: "csv")
        data = cleanRows(file: data ?? "")
        let csvRows = csv(data: data ?? "", sep: ";")
        var j:Int16 = 0
        for currency in csvRows {
            if rates[currency[0]] != nil {
                DispatchQueue.main.async {
                    let query = NSPredicate(format: "currencyCode == %@", currency[0] as NSString)
                    dataHandler.saveQueriedAttributeMultiple(entity: "Currency", attribute: "exchangeRate", query: query, value: rates[currency[0]] ?? 1.00)
                }
                j += j
            } else {
                if currency[0].count > 0 {
                    print("Error: Currency: " + String(currency[0]) + " not found")
                }
            }
        }
        return true
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
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
