//
//  UIView++.swift
//  VideoChatApp
//
//  Created by Güney Köse on 8.06.2023.
//

import Foundation
import UIKit

extension UIView {
    
    /**
     Makes a UIView object draggable within the screen bounds.
     */
    func makeDraggable() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.view != nil else { return }
        
        let width = Int(UIScreen.main.bounds.width)
        let height = Int(UIScreen.main.bounds.height)
        
        let limit = CGRect(x: 12,
                           y: 100,
                           width: width - 24,
                           height: height - 262)
        
        let translation = gesture.translation(in: gesture.view?.superview)
        
        var newX = gesture.view!.center.x + translation.x
        var newY = gesture.view!.center.y + translation.y
        
        let halfWidth = gesture.view!.bounds.width / 2.0
        let halfHeight = gesture.view!.bounds.height / 2.0
        
        // Limit the movement to stay within the bounds of the screen
        newX = max(halfWidth + limit.minX, newX)
        newX = min(limit.width - halfWidth + limit.minX, newX)
        newY = max(halfHeight + limit.minY, newY)
        newY = min(limit.height - halfHeight + limit.minY, newY)
        
        gesture.view?.center = CGPoint(x: newX, y: newY)
        gesture.setTranslation(CGPoint.zero, in: gesture.view?.superview)
        
        switch gesture.state {
        case .ended, .cancelled:
            let nearestX = (center.x < CGFloat(width) / 2) ?
            Int((12 + frame.width / 2 )): width - 12 - Int(frame.width) / 2
            
            UIView.animate(withDuration: 0.2) {
                self.center.x = CGFloat(nearestX)
            }
        default: break
        }
    }
}
