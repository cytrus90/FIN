//
//  iconPickerTVC.swift
//  FIN
//
//  Created by Florian Riel on 19.02.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class iconPickerTVC: UITableViewController {

    @IBOutlet var iconTable: UITableView!
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle = NSLocalizedString("setIcon", comment: "Set Icon")
    
    var viewDisappear = false
    
    var selectedColor:Int16 = 1
    var selectedIcon:String = "alpakaLogoWhite"
    var selectedLabelText = NSLocalizedString("previewIcon", comment: "Preview")
    var light = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
        
        initView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        viewDisappear = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView.updatePosition()
        if !viewDisappear {
            if UIDevice().model.contains("iPhone") && UIDevice.current.orientation.isLandscape {
                if headerView.frame.origin.y <= 0 {
                    super.navigationController?.navigationBar.topItem?.title = navTitle
                } else {
                    super.navigationController?.navigationBar.topItem?.title = ""
                }
            } else {
                if headerView.frame.origin.y <= (headerView.headerLabel.frame.height) {
                    super.navigationController?.navigationBar.topItem?.title = navTitle
                } else {
                    super.navigationController?.navigationBar.topItem?.title = ""
                }
            }
        }
        viewDisappear = false
//        (self.splitViewController as! splitVC).initFirstSelected()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            iconTable.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            iconTable.backgroundColor = .secondarySystemBackground
        }
        initView()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! cellAddTVC
            cell.addButton.setTitle(NSLocalizedString("setIconButton", comment: "setIcon"), for: .normal)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategorySave", for: indexPath) as! cellCategorySave
            cell.saveLabel.text = NSLocalizedString("lightColorIcon", comment: "light")
            cell.saveSwitch.isOn = light
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategoryIcons", for: indexPath) as! cellCategoryIcons
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategoryColor", for: indexPath) as! cellCategoryColor
            cell.colorPickerView.preselectedIndex = Int(selectedColor)
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellListEntry", for: indexPath) as! cellListEntry
            cell.descriptionLabel.text = NSLocalizedString("previewIcon", comment: "Preview")
            
            if selectedLabelText.count <= 0 {
                cell.circleLabel.isHidden = true
                cell.circleImage.isHidden = false
                cell.circleImage.image = UIImage(named: selectedIcon)
            } else {
                cell.circleImage.isHidden = true
                cell.circleLabel.isHidden = false
                if selectedLabelText.count == 1 {
                    cell.circleLabel.text = selectedLabelText.prefix(1).uppercased()
                } else {
                    cell.circleLabel.text = selectedLabelText.prefix(2).uppercased()
                }
            }
            
            cell.circleView.backgroundColor =  UIColor.randomColor(color: Int(selectedColor), returnText: false, light: false)
            cell.circleView.layer.borderColor = cell.circleView.backgroundColor?.cgColor
            
            return cell
        }
    }

    // MARK: -Init View
    func initView() {
        initTableAndHeaderView()
    }
    
    func initTableAndHeaderView() {
        iconTable.sectionHeaderHeight = UITableView.automaticDimension
     
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            iconTable.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            iconTable.backgroundColor = .secondarySystemBackground
            headerView.backgroundColor = .secondarySystemBackground
        }
        
        headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerView.headerLabel.text = navTitle
        
        headerView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.frame.width,
            height: 78//view.frame.height * headerHeightFactor
        )
        
        headerView.maxHeight = view.frame.height * headerHeightFactor
        headerView.maxLabelPointSize = headerView.headerLabel.font.pointSize
        headerView.minLabelPointSize = 20.0
        headerView.scrollView = iconTable
        
        iconTable.backgroundView = UIView()
        iconTable.backgroundView?.addSubview(headerView)
        iconTable.contentInset = UIEdgeInsets(
            top: 78,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
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

extension iconPickerTVC: cellCategoryColorDelegate {
    func colorChanged(newColor: Int16) {
        selectedColor = newColor
        if let cell = iconTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellListEntry {
            cell.circleView.backgroundColor = UIColor.randomColor(color: Int(selectedColor), returnText: false, light: false)
            cell.circleView.layer.borderColor = cell.circleView.backgroundColor?.cgColor
        }
    }
}

extension iconPickerTVC: cellCategorySaveDelegate {
    func saveSwitchChanged(newState:Bool) {
        light = newState
    }
}

extension iconPickerTVC: cellCategoryIconsDelegate {
    func iconSelected(selectedName:String) {
        if selectedName.count > 0 {
            selectedIcon = selectedName
            if let cell = iconTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellListEntry {
                cell.circleImage.image = UIImage(named: selectedIcon)
                cell.circleImage.isHidden = false
                cell.circleLabel.isHidden = true
            }
        } else {
            selectedIcon = ""
            if let cell = iconTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellListEntry {
                cell.circleImage.isHidden = true
                cell.circleLabel.isHidden = false
                if selectedLabelText.count == 1 {
                    cell.circleLabel.text = selectedLabelText.prefix(1).uppercased()
                } else {
                    cell.circleLabel.text = selectedLabelText.prefix(2).uppercased()
                }
            }
        }
    }
}
