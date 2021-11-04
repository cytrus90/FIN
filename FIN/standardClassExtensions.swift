//
//  standardClassExtensions.swift
//  FIN
//
//  Created by Florian Riel on 04.11.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func correctlyOrientedImage(imageOrientation: Int16) -> UIImage {
        var radians:CGFloat = .pi
        print("lfkajdfölasdflö")
        
        if imageOrientation == 0 { // UP -> 90°
            print("UP")
            radians = radians / 2.0
        } else if imageOrientation == 1 { // RIGHT
            print("RIGHT")
//            radians = radians / 2.0
        } else if imageOrientation == 2 { // DOWN -> pi
            print("DOWN")
        } else if imageOrientation == 3 { // LEFT
            print("LEFT")
//            radians = 3.0 * radians / 2.0
        } else {
            return self
        }
        
        let rotatedSize = CGRect(origin: .zero, size: size)
                    .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
                    .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x, width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        } else {
            return self
        }
    }
}

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
