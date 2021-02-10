//
//  importTVC.swift
//  FIN
//
//  Created by Florian Riel on 20.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class importTVC: UITableViewController {

    @IBOutlet var importTableView: UITableView!
    
    let delimiters = [";",",","\t"]
    let delimitersTitle = [";",",","tab"]
    
    let newLine = ["\r","\n","\r\n"]
    let newLineTitle = ["\\r","\\n","\\r\\n"]
    
    var selectedDelimiter:Int = 1
    var selectedNewLine:Int = 0
    
    var csvURL:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("backButton", comment: "Back"), style: .done, target: self, action: #selector(cancel))
        initView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("detailListDisappeared"), object: nil)
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        navigationBarAppearace.barTintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellImportText", for: indexPath) as! cellImportText
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellImportOptions", for: indexPath) as! cellImportOptions
            
            cell.label.text = NSLocalizedString("delimiterTitle", comment: "Delimiter")
            
            cell.segment.setTitle(delimitersTitle[0], forSegmentAt: 0)
            cell.segment.setTitle(delimitersTitle[1], forSegmentAt: 1)
            cell.segment.setTitle(delimitersTitle[2], forSegmentAt: 2)
            
            cell.segment.selectedSegmentIndex = selectedDelimiter
            
            cell.tag = indexPath.row
            cell.delegete = self
            return cell
//        } else if indexPath.row == 2 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cellImportOptions", for: indexPath) as! cellImportOptions
//
//            cell.label.text = NSLocalizedString("delimiterTitle", comment: "Delimiter")
//
//            cell.segment.setTitle(newLineTitle[0], forSegmentAt: 0)
//            cell.segment.setTitle(newLineTitle[1], forSegmentAt: 1)
//            cell.segment.setTitle(newLineTitle[2], forSegmentAt: 2)
//
//            cell.tag = indexPath.row
//            cell.delegete = self
//            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellImportStartButton", for: indexPath) as! cellImportStartButton
            cell.startButton.setTitle(NSLocalizedString("startButtonTitle", comment: "Start Button"), for: .normal)
            cell.delegate = self
            return cell

        }
    }

    // MARK: -initViewFunctions
    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            importTableView.backgroundColor = backgroundGeneralColor
        } else {
            importTableView.backgroundColor = .secondarySystemBackground
        }
    }
    
    @objc func cancel() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier ?? "") {
        case "previewImport":
            guard let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.topViewController as? importPreviewTVC
            else {
                fatalError()
            }
            viewController.delimiter = delimiters[selectedDelimiter]
            break
        default:
            break
        }
    }
}

extension importTVC: cellImportStartButtonDelegate {
    func startButtonPressed() {
        let preImportText = NSLocalizedString("preImportText", comment: "Pre Import")
        let preImport = UIAlertController(title: NSLocalizedString("preImportTitle", comment: "Pre Import Title"), message: preImportText, preferredStyle: .alert)
        preImport.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: { action in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "previewImport", sender: nil)
            }
        }))
        preImport.popoverPresentationController?.sourceView = self.view
        preImport.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(preImport, animated: true)
    }
}

extension importTVC:cellImportOptionsDelegate {
    func segmentControlChanged(selected: Int, tag:Int) {
        if tag == 1 {
            selectedDelimiter = selected
        }
    }
}
