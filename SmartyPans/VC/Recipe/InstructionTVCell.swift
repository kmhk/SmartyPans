//
//  InstructionTVCell.swift
//  Smartypans
//
//  Created by Lucky on 04/06/2018.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import UIKit

class InstructionTVCell: UITableViewCell {
    @IBOutlet weak var view : UIView!
    var isFirstCell: Bool = false
    var isLastCell: Bool = false
    
    var topShapeLayer = CAShapeLayer()
    var bottomShapeLayer = CAShapeLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(){
        // Add Radius
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 1, height: 1)
//        view.layer.shadowRadius = 4.0
//        view.layer.shadowOpacity = 0.2
//        view.clipsToBounds = false
        
        //let dashedView = cell.viewWithTag(117) as! UIView
        //dashedView.addDashedLine(strokeColor: .blue, lineWidth: 2)
        
    }
    
    func drawDottedLines() {
        
            if let lblStep = self.viewWithTag(100) as? UILabel {
                let stepContainerView = lblStep.superview!
                if topShapeLayer != nil {
                    topShapeLayer.removeFromSuperlayer()
                    topShapeLayer = CAShapeLayer()
                }
                if bottomShapeLayer != nil {
                    bottomShapeLayer.removeFromSuperlayer()
                    bottomShapeLayer = CAShapeLayer()
                }
                if (!isFirstCell) {
                    drawDottedLine(start: CGPoint(x: 30, y: self.contentView.bounds.minY), end: CGPoint(x: 30, y: stepContainerView.bounds.maxY), view: self.contentView, shapeLayer: topShapeLayer)
                }
                
                if (!isLastCell) {
                    drawDottedLine(start: CGPoint(x: 30, y: stepContainerView.bounds.maxY), end: CGPoint(x: 30, y: self.contentView.bounds.maxY), view: self.contentView, shapeLayer: bottomShapeLayer)
                }
            }
    }
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView, shapeLayer: CAShapeLayer) {
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [2, 3] // 2 is the length of dash, 3 is length of the gap.
        
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.insertSublayer(shapeLayer, at: 0)
    }
}
