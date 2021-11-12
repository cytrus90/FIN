//
//  cellShowReceiptTVC.swift
//  FIN
//
//  Created by Florian Riel on 01.11.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit
import Vision
import SwiftUI

class cellShowReceiptTVC: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var receiptImageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    @IBOutlet weak var imageAspectRatio: NSLayoutConstraint!
    
    @IBOutlet weak var changeReceiptButton: UIButton!
    
    weak var delegate: cellShowReceiptDelegate?
    
    // Layer into which to draw bounding box paths.
    var pathLayer: CALayer?
//    var pathLayerView: UIView?
    
    // Image parameters for reuse
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    
    var numberReceiptSelected:String?
    var dateReceiptSelected:Date?
    
    var receiptData = [Int:String]()
    
    var numberFormatter = NumberFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = Locale.current
        
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = Locale.current.groupingSeparator
        numberFormatter.groupingSize = 3
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
//        activityIndicator.translatesAutoresizingMaskIntoConstraints  = false
        
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        if receiptImageView != nil {
            let tabGesture = UILongPressGestureRecognizer(target: self, action: #selector(getNewImage))
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
        
        changeReceiptButton.setImage(UIImage(named: "editIcon")?.withTintColor(.link), for: .normal)
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
            requestTextFromImage(image: receiptImageView.image!, directlyFromCamera: false)
        }
    }

    public func requestTextFromImage(image: UIImage, directlyFromCamera:Bool) {
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
        show(image: image, directlyFromCamera: directlyFromCamera)
        
        if directlyFromCamera {
            numberReceiptSelected = nil
            dateReceiptSelected = nil
        }
        
        // Convert from UIImageOrientation to CGImagePropertyOrientation.
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)

        // Fire off request based on URL of chosen photo.
        guard let cgImage = image.cgImage else {
            return
        }
        performVisionRequest(image: cgImage, orientation: cgOrientation)
    }
    
    @IBAction func editReceiptButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.changeReceiptButton.transform = self.changeReceiptButton.transform.scaledBy(x: 0.8, y: 0.8)
        }, completion: {_ in
            UIView.animate(withDuration: 0.1, animations: {
                self.changeReceiptButton.transform = CGAffineTransform.identity
            }, completion: {_ in
                self.delegate?.receiptLongPressed()
            })
        })
    }
    
    @objc func getNewImage() {
        self.delegate?.receiptLongPressed()
    }
    
    // MARK: -TEXT RECONGNITION
    fileprivate func show(image: UIImage, directlyFromCamera:Bool) {

        // Remove previous paths & image
        pathLayer?.removeFromSuperlayer()
        pathLayer = nil
        receiptImageView.image = nil
        receiptImageView.subviews.forEach { $0.removeFromSuperview() }

        // Account for image orientation by transforming view.
        let correctedImage = scaleAndOrient(image: image)

        // Place photo inside imageView.
        receiptImageView.image = correctedImage

        if directlyFromCamera {
            self.delegate?.replaceImage(newImage: correctedImage)
        }
        
        let drawingLayer = CALayer()
        drawingLayer.anchorPoint = CGPoint.zero
        drawingLayer.opacity = 0.5
        drawingLayer.bounds = receiptImageView.frame
        pathLayer = drawingLayer
        
//        pathLayerView?.layer.addSublayer(pathLayer!)
        
        receiptImageView.layer.addSublayer(pathLayer!)
//        receiptImageView.addSubview(pathLayerView!)
    }

    lazy var textDetectionRequest: VNRecognizeTextRequest = {
        let textRequest = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        let localLanguage = (Locale.current.languageCode ?? "en") + "_" + (Locale.current.regionCode ?? "GB")
        textRequest.recognitionLanguages = ["en_GB", "de_DE", localLanguage]
        return textRequest
    }()

    lazy var rectangleDetectionRequest: VNDetectRectanglesRequest = {
        let rectDetectRequest = VNDetectRectanglesRequest(completionHandler: self.handleDetectedRectangles)
        // Customize & configure the request to detect only certain rectangles.
        rectDetectRequest.maximumObservations = 8 // Vision currently supports up to 16.
        rectDetectRequest.minimumConfidence = 0.7 // Be confident.
//        rectDetectRequest.minimumAspectRatio = 0.3 // height / width
        return rectDetectRequest
    }()
    
    fileprivate func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {

        // Fetch desired requests based on switch status.
        let requests = createVisionRequests()
        // Create a request handler.
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])

        // Send the requests to the request handler.
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }

    fileprivate func createVisionRequests() -> [VNRequest] {
        // Create an array to collect all desired requests.
        var requests: [VNRequest] = []

//        requests.append(rectangleDetectionRequest)
        requests.append(textDetectionRequest)

        // Return grouped requests as a single array.
        return requests
    }

    fileprivate func handleDetectedRectangles(request: VNRequest?, error: Error?) {
        if (error as NSError?) != nil {
            print("Rectangle Detection Error")
            return
        }
        // Since handlers are executing on a background thread, explicitly send draw calls to the main thread.
        DispatchQueue.main.async {
            guard let drawLayer = self.pathLayer,
                let results = request?.results as? [VNRectangleObservation] else {
                    return
            }
            self.draw(rectangles: results, onImageWithBounds: drawLayer.bounds)
            drawLayer.setNeedsDisplay()
        }
    }
    
    fileprivate func handleDetectedText(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            print("Text Detection Error: \(nsError)")
            return
        }
        // Perform drawing on the main thread.
        DispatchQueue.main.async {
            guard let drawLayer = self.pathLayer,
                let results = request?.results as? [VNRecognizedTextObservation] else {
                    return
            }
            self.draw(text: results, onImageWithBounds: self.receiptImageView.bounds)
            drawLayer.setNeedsDisplay()
            
            let amountFormatter = NumberFormatter()
            amountFormatter.locale = .current
            let thSep:String = Locale.current.groupingSeparator ?? ","
            
            var amountValue = 0.00
            
            for result in results.reversed() {
                if result.topCandidates(1).count > 0 {
                    let textValue = result.topCandidates(1)[0].string
                    let textNoCurrencySymbol = textValue.replacingOccurrences(of: Locale.current.currencySymbol ?? "€", with: "").replacingOccurrences(of: Locale.current.currencyCode ?? "EUR", with: "")
                    for partText in textNoCurrencySymbol.split(separator: " ") {
                        if String(partText).isDateNoTime() {
                            if self.dateReceiptSelected == nil {
                                self.dateReceiptSelected = String(partText).stringToDate()
                            }
                        } else {
                            if partText.split(separator: ".").count == 2 || partText.split(separator: ",").count == 2 {
                                let number = Double(truncating: NSNumber(value: (amountFormatter.number(from: (partText).replacingOccurrences(of: thSep, with: "")) as? Double) ?? -0.00))
                                amountValue = max(amountValue, number)
                            }
                        }
                    }
                }
            }
            
            if amountValue != -0.00 {
                self.delegate?.receiptAmountPressed(toSetAmount: self.numberFormatter.string(from: NSNumber(value: amountValue)) ?? "0.00")
            }
            
            if self.dateReceiptSelected != nil {
                self.delegate?.receiptDatePressed(toSetDate: self.dateReceiptSelected ?? Date())
                self.dateReceiptSelected = nil
            }
        }
    }

    
    
    // Lines of text are RED.  Individual characters are PURPLE.
    fileprivate func draw(text: [VNRecognizedTextObservation], onImageWithBounds bounds: CGRect) {
        CATransaction.begin()
        var i = 0
        for wordObservation in text {
            let wordBox = boundingBox(forRegionOfInterest: wordObservation.boundingBox, withinImageBounds: bounds)
            let wordLayer = shapeLayer(color: .red, frame: wordBox)

            wordLayer.name = String(i)
            receiptData[i] = wordObservation.topCandidates(1)[0].string
            i = i + 1
            
            // Add to pathLayer on top of image.
            pathLayer?.addSublayer(wordLayer)
            
        }
        CATransaction.commit()
    }
    
    // Rectangles are BLUE.
    fileprivate func draw(rectangles: [VNRectangleObservation], onImageWithBounds bounds: CGRect) {
        CATransaction.begin()
        for observation in rectangles {
            let rectBox = boundingBox(forRegionOfInterest: observation.boundingBox, withinImageBounds: bounds)
            let rectLayer = shapeLayer(color: .green, frame: rectBox)
            
            // Add to pathLayer on top of image.
            pathLayer?.addSublayer(rectLayer)
        }
        CATransaction.commit()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            let point = touch.location(in: self)
            let numberLayers = pathLayer?.sublayers?.count ?? 0
            if numberLayers > 1 {
                for i in 0...(numberLayers-1) {
                    if (pathLayer?.sublayers![i].frame.contains(point)) == true || pathLayer?.sublayers![i].bounds.contains(point) == true {
                        if (receiptData[Int(pathLayer?.sublayers![i].name ?? "0") ?? 0] ?? "").count > 0 {
                            setTouchedValue(touchedValue: receiptData[Int(pathLayer?.sublayers![i].name ?? "0") ?? 0] ?? "")
                        }
                        break
                    }
                }
            }
        }
    }
    
    @objc func animateView() {
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
    
    fileprivate func setTouchedValue(touchedValue: String) {
        var valueSent = false
        
        let amountFormatter = NumberFormatter()
        amountFormatter.locale = .current
        let thSep:String = Locale.current.groupingSeparator ?? ","
        
        let textNoCurrencySymbol = touchedValue.replacingOccurrences(of: Locale.current.currencySymbol ?? "€", with: "")
        for partText in textNoCurrencySymbol.split(separator: " ") {
            if String(partText).isDateNoTime() {
                self.delegate?.receiptDatePressed(toSetDate: String(partText).stringToDate())
                valueSent = true
                break
            } else {
                let number = (self.numberFormatter.string(from: NSNumber(value: (amountFormatter.number(from: (partText).replacingOccurrences(of: thSep, with: "")) as? Double) ?? -0.00)))
                let compareNumber = (self.numberFormatter.string(from: NSNumber(value: (amountFormatter.number(from: ("-0.00")) as? Double) ?? -0.00)))
                if number != compareNumber && valueSent == false {
                    self.delegate?.receiptAmountPressed(toSetAmount: number ?? "")
                    valueSent = true
                    break
                }
            }
        }
        
        if valueSent == false {
            self.delegate?.receiptStringPressed(toSetDescription: touchedValue)
        }
    }

    fileprivate func boundingBox(forRegionOfInterest: CGRect, withinImageBounds bounds: CGRect) -> CGRect {
        let imageWidth = bounds.width
        let imageHeight = bounds.height

        // Begin with input rect.
        var rect = forRegionOfInterest

        // Reposition origin.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.origin.x + 10 // + 10 because of inset inside cell
        rect.origin.y = (1 - rect.origin.y) * imageHeight + bounds.origin.y + 10 // + 10 because of inset inside cell

        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight

        return rect
    }

    fileprivate func shapeLayer(color: UIColor, frame: CGRect) -> CAShapeLayer {
        // Create a new layer.
        let layer = CAShapeLayer()

        // Configure layer's appearance.
        layer.fillColor = nil // No fill to show boxed object
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.borderWidth = 2

        // Vary the line color according to input.
        layer.borderColor = color.cgColor

        // Locate the layer.
        layer.anchorPoint = .zero
        layer.frame = frame
        layer.masksToBounds = true

        // Transform the layer to have same coordinate system as the imageView underneath it.
        layer.transform = CATransform3DMakeScale(1, -1, 1)

        return layer
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

protocol cellShowReceiptDelegate: AnyObject {
    func receiptDatePressed(toSetDate: Date)
    func receiptStringPressed(toSetDescription: String)
    func receiptAmountPressed(toSetAmount: String)
    func receiptLongPressed()
    func replaceImage(newImage: UIImage)
}

// Convert UIImageOrientation to CGImageOrientation for use in Vision analysis.
extension CGImagePropertyOrientation {
    init(_ uiImageOrientation: UIImage.Orientation) {
        switch uiImageOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        default: self = .up
        }
    }
}
