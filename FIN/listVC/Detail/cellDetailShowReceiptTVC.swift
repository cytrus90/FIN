//
//  cellDetailShowReceiptTVC.swift
//  FIN
//
//  Created by Florian Riel on 04.11.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class cellDetailShowReceiptTVC: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var receiptImageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imageAspectRatio: NSLayoutConstraint!
    
    var receiptImage: UIImage?
    
    weak var delegate: cellDetailShowReceiptDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        let receiptTab = UITapGestureRecognizer(target: self, action: #selector(cellWasTouched))
        self.addGestureRecognizer(receiptTab)
        
        if receiptImageView != nil {
            let tabGesture = UILongPressGestureRecognizer(target: self, action: #selector(saveReceipt))
            tabGesture.minimumPressDuration = 1.0
            
            receiptImageView.addGestureRecognizer(tabGesture)
        }
        
        initUI()
    }

    func initUI() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = backgroundColor
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .secondarySystemBackground
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        if receiptImageView.image != nil {
            setImage(image: receiptImageView.image!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = self.transform.scaledBy(x: 0.98, y: 0.98)
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1, animations: {
          self.transform = CGAffineTransform.identity
        })
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1, animations: {
          self.transform = CGAffineTransform.identity
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        receiptImageView.image = nil
        receiptImageView.isHidden = true
        activityIndicator.startAnimating()
    }
    
    @objc func cellWasTouched() {
        self.delegate?.cellTouched(tag: self.tag)
    }
    
    @objc func saveReceipt() {
        self.delegate?.saveImageTriggered()
    }
    
    public func requestImageForUUID(transactionUUID: UUID) {
        DispatchQueue.main.async {
            let fileManager = FileManager.default
            
            let imageName = transactionUUID.uuidString + ".png"
            let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
            
            if fileManager.fileExists(atPath: imagePath) {
                self.receiptImage = UIImage(contentsOfFile: imagePath)
                self.setImage(image: self.receiptImage ?? UIImage(systemName: "xmark.octagon")!)
                self.activityIndicator.stopAnimating()
                self.receiptImageView.isHidden = false
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
                self.delegate?.returnReceiptImage(image: self.receiptImage ?? UIImage(systemName: "xmark.octagon")!)
            }
        }
    }
    
    public func setImage(image: UIImage) {
        if image.size.height < image.size.width {
            if imageAspectRatio != nil {
                imageAspectRatio.isActive = false
            }
            receiptImageView.heightAnchor.constraint(equalTo: receiptImageView.widthAnchor, multiplier: image.size.height/image.size.width).isActive = true
            self.layoutIfNeeded()
        } else {
            if imageAspectRatio != nil {
                imageAspectRatio.isActive = false
            }
            receiptImageView.heightAnchor.constraint(equalTo: receiptImageView.widthAnchor, multiplier: image.size.height/image.size.width).isActive = true
            self.layoutIfNeeded()
        }
        // Display image on screen.
        show(image: image)
    }
    
    fileprivate func show(image: UIImage) {
//        receiptImageView.image = nil
//        receiptImageView.subviews.forEach { $0.removeFromSuperview() }

        // Account for image orientation by transforming view.
//        let correctedImage = scaleAndOrient(image: image)

        // Place photo inside imageView.
//        receiptImageView.image = correctedImage
        DispatchQueue.main.async {
            self.receiptImageView.image = image
        }
    }
    
    fileprivate func scaleAndOrient(image: UIImage) -> UIImage {

        // Set a default value for limiting image size.
        let maxResolution: CGFloat = 1024

        guard let cgImage = image.cgImage else {
            print("UIImage has no CGImage backing it!")
            return image
        }

        // Compute parameters for transform.
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        var transform = CGAffineTransform.identity

        var bounds = CGRect(x: receiptImageView.frame.minX, y: receiptImageView.frame.minY, width: width, height: height)

        if width > maxResolution || height > maxResolution {
            let ratio = width / height
            if width > height {
                bounds.size.width = maxResolution
                bounds.size.height = round(maxResolution / ratio)
            } else {
                bounds.size.width = round(maxResolution * ratio)
                bounds.size.height = maxResolution
            }
        }
                
        let scaleRatio = bounds.size.width / width
        let orientation = image.imageOrientation
        switch orientation {
        case .up:
            transform = .identity
        case .down:
            transform = CGAffineTransform(translationX: width, y: height).rotated(by: .pi)
        case .left:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: 0, y: width).rotated(by: 3.0 * .pi / 2.0)
        case .right:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: 0).rotated(by: .pi / 2.0)
        case .upMirrored:
            transform = CGAffineTransform(translationX: width, y: 0).scaledBy(x: -1, y: 1)
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0, y: height).scaledBy(x: 1, y: -1)
        case .leftMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: width).scaledBy(x: -1, y: 1).rotated(by: 3.0 * .pi / 2.0)
        case .rightMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2.0)
        default:
            transform = .identity
        }
        
        return UIGraphicsImageRenderer(size: bounds.size).image { rendererContext in
            let context = rendererContext.cgContext

            if orientation == .right || orientation == .left {
                context.scaleBy(x: -scaleRatio, y: scaleRatio)
                context.translateBy(x: -height, y: 0)
            } else {
                context.scaleBy(x: scaleRatio, y: -scaleRatio)
                context.translateBy(x: 0, y: -height)
            }
            context.concatenate(transform)
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
}

protocol cellDetailShowReceiptDelegate: AnyObject {
    func cellTouched(tag: Int)
    func returnReceiptImage(image: UIImage)
    func saveImageTriggered()
}
