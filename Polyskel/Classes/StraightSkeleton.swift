//
//  StraightSkeleton.swift
//  Euclid
//
//  Created by Andy Geers on 29/11/2019.
//

import Euclid

extension Contour {
    func containsPoint(_ point : Vector) -> Bool {
        return self.nodes.contains(where: { $0.point == point })
    }
}

public struct StraightSkeleton {
    public var subtrees : [Subtree]
    var contour: Contour
    var holes: [Contour]?
    
    init(contour: Contour, holes: [Contour]?, subtrees: [Subtree]) {
        self.contour = contour
        self.holes = holes
        self.subtrees = subtrees
    }
    
    private func gabledSubtree(_ subtree: Subtree) -> Subtree {
        // Step 1: Identify a vertex that was created by the intersection of two bisectors. These bisectors emanate from the corners of the original polygon.
        let cornerBisectors = subtree.sinks.filter({ self.contour.containsPoint($0) })
        if cornerBisectors.count >= 2 {
            // Step 2: Move the vertex from its original intersection position to the midpoint of the line which is incident to both the bisectors that created the intersection point.
            subtree.source = (cornerBisectors[0] + cornerBisectors[1]) * 0.5
        }
        
        return subtree
    }
    
    public func gabled() -> StraightSkeleton {
        let gabledSubtrees = subtrees.map { gabledSubtree($0) }
        
        return StraightSkeleton(contour: self.contour, holes: self.holes, subtrees: gabledSubtrees)
    }
}
