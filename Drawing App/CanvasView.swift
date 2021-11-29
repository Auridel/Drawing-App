//
//  CanvasView.swift
//  Drawing App
//
//  Created by Олег Ефимов on 29.11.2021.
//

import UIKit

struct TouchesAndColors {
    var color: UIColor?
    var width: CGFloat?
    var opacity: CGFloat?
    var points: [CGPoint]?
    
    init(color: UIColor, points: [CGPoint]) {
        self.color = color
        self.points = points
    }
}

class CanvasView: UIView {
    
    public var strokeWidth: CGFloat = 5
    
    public var strokeColor: UIColor = .black
    
    public var strokeOpacity: CGFloat = 1
    
    private var lines = [TouchesAndColors]()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        lines.forEach { (line) in
            for (i, p) in (line.points?.enumerated())! {
                if i == 0 {
                    context.move(to: p)
                } else {
                    context.addLine(to: p)
                }
                
                guard let lineColor = line.color?.withAlphaComponent(line.opacity ?? 1).cgColor else {
                    continue
                }
                context.setStrokeColor(lineColor)
                context.setLineWidth(line.width ?? 1)
            }
            context.setLineCap(.round)
            context.strokePath()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(TouchesAndColors(color: UIColor(), points: [CGPoint]()))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: nil),
        var lastPoint = lines.popLast()
        else {
            return
        }
        lastPoint.points?.append(touch)
        lastPoint.color = strokeColor
        lastPoint.width = strokeWidth
        lastPoint.opacity = strokeOpacity
        lines.append(lastPoint)
        setNeedsDisplay()
    }
    
    public func clearCanvas() {
        lines.removeAll()
        setNeedsDisplay()
    }
    
    public func undoDrawing() {
        guard lines.count > 0 else {
            return
        }
        lines.removeLast()
        setNeedsDisplay()
    }
}

// MARK: Save image

extension UIView {
    public func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,
                                               false,
                                               UIScreen.main.scale)
        drawHierarchy(in: self.bounds,
                      afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = image else {
            return UIImage()
        }
        return image
    }
}

