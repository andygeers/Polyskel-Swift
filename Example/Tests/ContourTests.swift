//
//  ContourTest.swift
//  Polyskel_Example
//
//  Created by Andy Geers on 20/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Polyskel
@testable import Euclid
import XCTest

class ContourTests: XCTestCase {
    func testNormalizeContour() {
        let vertices = [Vector(-0.52841159105, 0.0, -0.7593594193500001),
                        Vector(-0.52841159105, 0.0, -0.37294334173000004),
                        Vector(-0.08952120692000001, 0.0, -0.37294334173000004),
                        Vector(-0.08952120692000001, 0.0, 0.9292854100500001),
                        Vector(0.27158840746, 0.0, 0.9292854100500001),
                        Vector(0.27158840895, 0.0, -0.6166646212300001),
                        Vector(0.27158840895, 0.0, -0.7593594193500001)
                    ]
        let polygon = Polygon(vertices.map { Vertex($0, Plane.xz.normal) })!
        let contour = Contour(polygon)
        
        XCTAssertEqual(6, Array(contour.edges).count)
    }
}
