//
//  Mathematical.swift
//  
//
//  Created by lim on 24/11/2021.
//

import CoreGraphics


extension CGPoint {
    
    @inlinable
    internal func slope(_ point: CGPoint) -> CGFloat {
        (y - point.y) / (x - point.x)
    }
    
    /// y = kx + b
    @inlinable
    internal func slopeFormula(_ point: CGPoint) -> (k: CGFloat, b: CGFloat) {
        let k = slope(point)
        let b = y - k * x
        
        return (k, b)
    }
    
    
    @inlinable
    internal func angleOfInclination(_ point: CGPoint) -> CGFloat {
        atan(slope(point))
    }
    
}
