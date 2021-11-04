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
    func isDateNoTime() -> Bool {
        let dateFormatter = DateFormatter()
        
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
        
        return false
    }
    
    func stringToDate() -> Date {
        let dateFormatter = DateFormatter()
        
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
        
        return Date()
    }
}
