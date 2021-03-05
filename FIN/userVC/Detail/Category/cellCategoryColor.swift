//
//  cellCategoryColor.swift
//  FIN
//
//  Created by Florian Riel on 30.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import IGColorPicker

class cellCategoryColor: UITableViewCell, ColorPickerViewDelegate, ColorPickerViewDelegateFlowLayout {
    

    @IBOutlet weak var cellOutlineView: UIView!
    @IBOutlet weak var colorPickerView: ColorPickerView!
    
    weak var delegate: cellCategoryColorDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorPickerView.layoutDelegate = self
        colorPickerView.delegate = self
        
        cellOutlineView.layer.borderWidth = 1
        cellOutlineView.layer.cornerRadius = 10
        
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initView()
    }
    
    func initView() {
        var colorsArray = [UIColor]()
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            cellOutlineView.backgroundColor = .white
            cellOutlineView.layer.borderColor = UIColor.white.cgColor
            for i in 0...74 {
                colorsArray.append(UIColor.randomColor(color: i))
            }
        } else {
            self.backgroundColor = .clear
            cellOutlineView.backgroundColor = .black
            cellOutlineView.layer.borderColor = UIColor.black.cgColor
            for i in 0...74 {
                colorsArray.append(UIColor.randomColor(color: i))
            }
        }
        colorPickerView.colors = colorsArray
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.colorChanged(newColor: Int16(indexPath.row))
        print(indexPath.row)
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didDeselectItemAt indexPath: IndexPath) {
    }

    func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return CGSize(width: 50, height: 50)
    }

    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }

    func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

//    func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets {
//      // Inset used aroud the view
//    }
    
}

protocol cellCategoryColorDelegate: AnyObject {
    func colorChanged(newColor: Int16)
}
