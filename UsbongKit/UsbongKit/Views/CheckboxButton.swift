//
//  CheckboxButton.swift
//  CheckboxButton
//
//  Created by Joe Amanse on 30/11/2015.
//  Copyright © 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit

@IBDesignable
open class CheckboxButton: UIButton {
    // MARK: Box and check properties
    let boxLayer = CAShapeLayer()
    let checkLayer = CAShapeLayer()
    
    var boxFrame: CGRect {
        let width = bounds.width
        let height = bounds.height
        
        let x: CGFloat
        let y: CGFloat
        
        let sideLength: CGFloat
        if width > height {
            sideLength = height
            x = (width - sideLength) / 2
            y = 0
        } else {
            sideLength = width
            x = 0
            y = (height - sideLength) / 2
        }
        
        let halfLineWidth = boxLineWidth / 2
        return CGRect(x: x + halfLineWidth, y: y + halfLineWidth, width: sideLength - boxLineWidth, height: sideLength - boxLineWidth)
    }
    
    var boxPath: UIBezierPath {
        return UIBezierPath(rect: boxFrame)
    }
    var checkPath: UIBezierPath {
        let inset = (boxLineWidth + checkLineWidth) / 2
        let innerRect = boxFrame.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath()
        
        let unit = innerRect.width / 8
        let origin = innerRect.origin
        let x = origin.x
        let y = origin.y
        
        path.move(to: CGPoint(x: x + unit, y: y + unit * 5))
        path.addLine(to: CGPoint(x: x + unit * 3, y: y + unit * 7))
        path.addLine(to: CGPoint(x: x + unit * 7, y: y + unit))
        
        return path
    }
    
    // MARK: Inspectable properties
    @IBInspectable open var boxLineWidth: CGFloat = 2.0 {
        didSet {
            layoutLayers()
        }
    }
    @IBInspectable open var checkLineWidth: CGFloat = 2.0 {
        didSet {
            layoutLayers()
        }
    }
    @IBInspectable open var boxLineColor: UIColor = UIColor.black {
        didSet {
            colorLayers()
        }
    }
    @IBInspectable open var checkLineColor: UIColor = UIColor.black {
        didSet {
            colorLayers()
        }
    }
    
    // MARK: Initialization
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        customInitialization()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        customInitialization()
    }
    
    func customInitialization() {
        boxLayer.fillColor = UIColor.clear.cgColor
        checkLayer.fillColor = UIColor.clear.cgColor
        
        colorLayers()
        layoutLayers()
        
        layer.addSublayer(boxLayer)
        layer.addSublayer(checkLayer)
    }
    
    // MARK: Layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutLayers()
    }
    
    // MARK: Layout layers
    fileprivate func layoutLayers() {
        boxLayer.frame = bounds
        boxLayer.lineWidth = boxLineWidth
        boxLayer.path = boxPath.cgPath
        
        checkLayer.frame = bounds
        checkLayer.lineWidth = checkLineWidth
        checkLayer.path = checkPath.cgPath
    }
    
    // MARK: Color layers
    fileprivate func colorLayers() {
        boxLayer.strokeColor = boxLineColor.cgColor
        checkLayer.strokeColor = isSelected ? checkLineColor.cgColor : UIColor.clear.cgColor
    }
    
    // MARK: Selection
    open override var isSelected: Bool {
        didSet {
            colorLayers()
        }
    }
    
    // MARK: Interface builder
    open override func prepareForInterfaceBuilder() {
        customInitialization()
    }
}
