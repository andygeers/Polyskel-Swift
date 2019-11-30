//
//  RoofsTests.swift
//  Polyskel_Example
//
//  Created by Andy Geers on 29/11/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import Polyskel
import Euclid

class RoofsTests: XCTestCase {
    func testGenerateRoofForSquare() {
        let p = RoofsTests.square()
        let skeleton = Polyskel.skeletonize(polygon: p!, holes: nil, isGabled: { _ in return false })
        let roofPolys = skeleton.generateRoofPolygons()
        XCTAssertFalse(roofPolys.isEmpty)
        XCTAssertEqual(roofPolys.count, 4)
    }
    
    static func square() -> Polygon? {
        let p1 = Vector(0, 0, 0)
        let p2 = Vector(0, 0, 1)
        let p3 = Vector(1, 0, 1)
        let p4 = Vector(1, 0, 0)
        
        let outline = Path([
            PathPoint(p1, isCurved: false),
            PathPoint(p2, isCurved: false),
            PathPoint(p3, isCurved: false),
            PathPoint(p4, isCurved: false)
        ])
        
        return Polygon(shape: outline.closed())
    }
}
