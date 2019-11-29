//
//  StraightSkeleton.swift
//  Euclid
//
//  Created by Andy Geers on 29/11/2019.
//

import Euclid

public struct StraightSkeleton {
    public var subtrees : [Subtree]
    var polygon: Polygon
    var holes: [Polygon]?
    
    init(polygon: Polygon, holes: [Polygon]?, subtrees: [Subtree]) {
        self.polygon = polygon
        self.holes = holes
        self.subtrees = subtrees
    }
}
