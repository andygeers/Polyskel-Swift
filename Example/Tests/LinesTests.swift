//
//  LinesTests.swift
//  GeometryScriptTests
//
//  Created by Andy Geers on 20/11/2019.
//  Copyright © 2019 Andy Geers. All rights reserved.
//

import Polyskel
import Euclid
import XCTest

class LinesTests: XCTestCase {
    
    // MARK: Vector distance
    
    func testDistanceFromPointSimple() {
        let l = Line(point: Vector(0, 0, 0), direction: Vector(1, 0, 0))
        let p = Vector(15, 2, 0)
        XCTAssertEqual(l.distance(to: p), 2)
    }
    
    func testDistanceFromPointHarder() {
        let l = Line(point: Vector(0, 0, 0), direction: Vector(1, 0, 0))
        let p = Vector(15, 2, 3)
        XCTAssertEqual(l.distance(to: p), (2*2 + 3*3).squareRoot())
    }
    
    func testLineIntersectionXY() {
        let l1 = Line(point: Vector(1, 0, 3), direction: Vector(1, 0, 0))
        let l2 = Line(point: Vector(0, 1, 3), direction: Vector(0, -1, 0))
        
        let intersection = l1.intersection(with: l2)
        XCTAssertNotNil(intersection)
        if (intersection != nil) {
            XCTAssertEqual(intersection, Vector(0, 0, 3).quantized())
        }
    }
    
    func testLineIntersectionXZ() {
        let l1 = Line(point: Vector(1, 3, 0), direction: Vector(1, 0, 0))
        let l2 = Line(point: Vector(0, 3, 1), direction: Vector(0, 0, -1))
        
        let intersection = l1.intersection(with: l2)
        XCTAssertNotNil(intersection)
        if (intersection != nil) {
            XCTAssertEqual(intersection, Vector(0, 3, 0).quantized())
        }
    }
    
    func testLineIntersectionYZ() {
        let l1 = Line(point: Vector(3, 1, 0), direction: Vector(0, 1, 0))
        let l2 = Line(point: Vector(3, 0, 1), direction: Vector(0, 0, -1))
        
        let intersection = l1.intersection(with: l2)
        XCTAssertNotNil(intersection)
        if (intersection != nil) {
            XCTAssertEqual(intersection, Vector(3, 0, 0).quantized())
        }
    }
    
    func testLineSegmentMidpoint() {
        let l = LineSegment(Vector(0, 0, 0), Vector(10, 0, 0))
        let midpoint = l.midPoint
        XCTAssertEqual(Vector(5, 0, 0), midpoint)
    }
}
