//
//  CGRectExtension.swift
//  InteractGraph
//
//  Created by lim on 15/11/2021.
//

import CoreGraphics

extension CGRect {
    
    @inlinable
    internal var topCenter: CGPoint {
        CGPoint(x: centerX, y: minY)
    }
    
    @inlinable
    internal var bottomCenter: CGPoint {
        CGPoint(x: centerX, y: maxY)
    }
    
    @inlinable
    internal var centerX: CGFloat {
        maxX - (width / 2)
    }
    
    @inlinable
    internal var centerY: CGFloat {
        maxY - (height / 2)
    }
    
    @inlinable
    internal var center: CGPoint {
        CGPoint(x: centerX, y: centerY)
    }
    
}
