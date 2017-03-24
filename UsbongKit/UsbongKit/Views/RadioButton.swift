//
//  RadioButton.swift
//  RadioButton
//
//  Created by Joe Amanse on 19/11/2015.
//  Copyright © 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit

@IBDesignable
open class RadioButton: UIButton {
    // MARK: Circle properties
    internal var circleLayer = CAShapeLayer()
    internal var fillCircleLayer = CAShapeLayer()
    
    @IBInspectable open var circleColor: UIColor = UIColor.black {
        didSet {
            circleLayer.strokeColor = circleColor.cgColor
        }
    }
    @IBInspectable open var fillCircleColor: UIColor = UIColor.darkGray {
        didSet {
            loadFillCircleState()
        }
    }
    
    @IBInspectable open var circleLineWidth: CGFloat = 2.0 {
        didSet {
            layoutCircleLayers()
        }
    }
    @IBInspectable open var fillCircleGap: CGFloat = 2.0 {
        didSet {
            layoutCircleLayers()
        }
    }
    
    internal var circleRadius: CGFloat {
        let width = bounds.width
        let height = bounds.height
        
        let length = width > height ? height : width
        return (length - circleLineWidth) / 2
    }
    
    fileprivate var circleFrame: CGRect {
        let width = bounds.width
        let height = bounds.height
        
        let radius = circleRadius
        let x: CGFloat
        let y: CGFloat
        
        if width > height {
            y = circleLineWidth / 2
            x = (width / 2) - radius
        } else {
            x = circleLineWidth / 2
            y = (height / 2) - radius
        }
        
        let diameter = 2 * radius
        return CGRect(x: x, y: y, width: diameter, height: diameter)
    }
    
    fileprivate var circlePath: UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame)
    }
    
    fileprivate var fillCirclePath: UIBezierPath {
        let trueGap = fillCircleGap + (circleLineWidth / 2)
        return UIBezierPath(ovalIn: circleFrame.insetBy(dx: trueGap, dy: trueGap))
    }
    
    // MARK: Initialization
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInitialization()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        customInitialization()
    }
    
    fileprivate func customInitialization() {
        circleLayer.frame = bounds
        circleLayer.lineWidth = circleLineWidth
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = circleColor.cgColor
        layer.addSublayer(circleLayer)
        
        fillCircleLayer.frame = bounds
        fillCircleLayer.lineWidth = circleLineWidth
        fillCircleLayer.fillColor = UIColor.clear.cgColor
        fillCircleLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(fillCircleLayer)
        
        loadFillCircleState()
    }
    
    // MARK: Layout
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        layoutCircleLayers()
    }
    
    fileprivate func layoutCircleLayers() {
        circleLayer.frame = bounds
        circleLayer.lineWidth = circleLineWidth
        circleLayer.path = circlePath.cgPath
        
        fillCircleLayer.frame = bounds
        fillCircleLayer.lineWidth = circleLineWidth
        fillCircleLayer.path = fillCirclePath.cgPath
    }
    
    // MARK: Selection
    override open var isSelected: Bool {
        didSet {
            loadFillCircleState()
        }
    }
    
    // MARK: Custom
    fileprivate func loadFillCircleState() {
        if self.isSelected {
            fillCircleLayer.fillColor = fillCircleColor.cgColor
        } else {
            fillCircleLayer.fillColor = UIColor.clear.cgColor
        }
    }
    
    // MARK: Interface builder
    override open func prepareForInterfaceBuilder() {
        customInitialization()
    }
}
