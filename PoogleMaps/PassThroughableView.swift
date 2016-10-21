//
//  PassThroughableView.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 10/20/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit

class PassThroughableView : UIView {
    
    // Usually true for a view, but in this case we only want it to be true if it's touching
    //  one of the actionable views (which are subviews). Otherwise, pass it on to superview.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.alpha > 0
                && subview.isUserInteractionEnabled
                && subview.point(inside: convert(point, to: subview), with: event) {
                
                return true
            }
        }
        return false
    }
    
}
