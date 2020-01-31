//
//  StraightSkeleton.swift
//  Euclid
//
//  Created by Andy Geers on 29/11/2019.
//

import Euclid

public struct StraightSkeleton {
    public var subtrees : [Subtree]
    var contour: Contour
    var holes: [Contour]?
    
    init(contour: Contour, holes: [Contour]?, subtrees: [Subtree]) {
        self.contour = contour
        self.holes = holes
        self.subtrees = subtrees
    }
}
