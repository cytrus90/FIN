//
//  standardClassExtensions.swift
//  FIN
//
//  Created by Florian Riel on 04.11.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func getCharacterAt(characterIndex: Int) -> Character {
        return self[index(startIndex, offsetBy: characterIndex)]
    }
}

extension String {
    func isDateNoTime() -> Bool {
        let dateFormatter = DateFormatter()
        
        // DMY
        // NEXT
        dateFormatter.dateFormat = "d.M.y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d-M-y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d/M/y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d_M_y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "dd.M.y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd-M-y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd/M/y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd_M_y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "d.MM.y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d-MM-y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d/MM/y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d_MM_y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "d.M.yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d-M-yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d/M/yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d_M_yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "d.M.yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d-M-yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d/M/yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "d_M_yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "dd.MM.y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd-MM-y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd/MM/y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd_MM_y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "dd.MM.yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd-MM-yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd/MM/yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd_MM_yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd-MM-yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "dd_MM_yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // YMD
        // NEXT
        dateFormatter.dateFormat = "y.M.d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y-M-d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y/M/d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y_M_D"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "y.M.dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y-M-dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y/M/dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y_M_dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "y.MM.d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y-MM-d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y/MM/d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y_MM_d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "yy.M.d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yy-M-d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yy/M/d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yy_M_d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "yyyy.M.d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yyyy-M-d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yyyy/M/d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yyyy_M_d"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "y.MM.dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y-MM-dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y/MM/dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "y_MM_dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "yy.MM.dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yy-MM-dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yy/MM/dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yy_MM_dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "yyyy.MM.dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yyyy/MM/dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "yyyy_MM_dd"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // MDY
        // NEXT
        dateFormatter.dateFormat = "M.d.y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M-d-y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M/d/y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M_d_y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "M.dd.y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M-dd-y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M/dd/y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M_dd_y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "MM.d.y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM-d-y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM/d/y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM_d_y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "M.d.yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M-d-yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M/d/yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M_d_yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "M.d.yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M-d-yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M/d/yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "M_d_yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "MM.dd.y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM-dd-y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM/dd/y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM_dd_y"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "MM.dd.yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM-dd-yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM/dd/yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM_dd_yy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        // NEXT
        dateFormatter.dateFormat = "MM.dd.yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM-dd-yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        dateFormatter.dateFormat = "MM_dd_yyyy"
        if dateFormatter.date(from: self) != nil {
            return true
        }
        
        return false
    }
    
    func stringToDate() -> Date {
        let dateFormatter = DateFormatter()
        
        // DMY
        // NEXT
        dateFormatter.dateFormat = "d.M.y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d-M-y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d/M/y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d_M_y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "dd.M.y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd-M-y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd/M/y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd_M_y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "d.MM.y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d-MM-y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d/MM/y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d_MM_y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "d.M.yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d-M-yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d/M/yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d_M_yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "d.M.yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d-M-yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d/M/yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "d_M_yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "dd.MM.y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd-MM-y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd/MM/y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd_MM_y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "dd.MM.yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd-MM-yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd/MM/yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd_MM_yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd-MM-yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "dd_MM_yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // YMD
        // NEXT
        dateFormatter.dateFormat = "y.M.d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y-M-d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y/M/d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y_M_D"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "y.M.dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y-M-dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y/M/dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y_M_dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "y.MM.d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y-MM-d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y/MM/d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y_MM_d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "yy.M.d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yy-M-d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yy/M/d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yy_M_d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "yyyy.M.d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yyyy-M-d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yyyy/M/d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yyyy_M_d"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "y.MM.dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y-MM-dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y/MM/dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "y_MM_dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "yy.MM.dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yy-MM-dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yy/MM/dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yy_MM_dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "yyyy.MM.dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yyyy/MM/dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "yyyy_MM_dd"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // MDY
        // NEXT
        dateFormatter.dateFormat = "M.d.y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M-d-y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M/d/y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M_d_y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "M.dd.y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M-dd-y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M/dd/y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M_dd_y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "MM.d.y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM-d-y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM/d/y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM_d_y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "M.d.yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M-d-yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M/d/yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M_d_yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "M.d.yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M-d-yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M/d/yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "M_d_yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "MM.dd.y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM-dd-y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM/dd/y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM_dd_y"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "MM.dd.yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM-dd-yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM/dd/yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM_dd_yy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        // NEXT
        dateFormatter.dateFormat = "MM.dd.yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM-dd-yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        dateFormatter.dateFormat = "MM_dd_yyyy"
        if let returnDate = dateFormatter.date(from: self) {
            return returnDate
        }
        
        return Date()
    }
}
