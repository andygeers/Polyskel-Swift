//
//  PlanesTests.swift
//  GeometryScriptTests
//
//  Created by Andy Geers on 20/11/2019.
//  Copyright © 2019 Andy Geers. All rights reserved.
//

import Polyskel
@testable import Euclid
import XCTest

class PlanesTests: XCTestCase {
    func testIntersectionWithParallelPlane() {
        let plane1 = Plane(normal: Vector(0, 1, 0), pointOnPlane: Vector(0, 0, 0))
        let plane2 = Plane(normal: Vector(0, 1, 0), pointOnPlane: Vector(0, 1, 0))
        
        XCTAssertNil(plane1!.intersectionWith(plane2!))
    }
    
    func testIntersectionWithPerpendicularPlane() {
        let plane1 = Plane(normal: Vector(0, 1, 0), pointOnPlane: Vector(0, 0, 0))
        let plane2 = Plane(normal: Vector(1, 0, 0), pointOnPlane: Vector(0, 0, 0))
        
        let intersection = plane1!.intersectionWith(plane2!)
        XCTAssertNotNil(intersection)
        if (intersection != nil) {
            XCTAssert(plane1!.containsPoint(intersection!.origin))
            XCTAssert(plane2!.containsPoint(intersection!.origin))
            
            XCTAssert(plane1!.containsPoint(intersection!.origin + intersection!.direction))
            XCTAssert(plane2!.containsPoint(intersection!.origin + intersection!.direction))
        }
    }
    
    func testIntersectionWithRandomPlane() {
        let plane1 = Plane(normal: Vector(1.2, 0.4, 5.7), w: 6)
        let plane2 = Plane(normal: Vector(0.5, 0.7, 0.1), w: 8)
        
        let intersection = plane1!.intersectionWith(plane2!)
        XCTAssertNotNil(intersection)
        if (intersection != nil) {
            XCTAssertEqual(plane1!.normal.dot(intersection!.origin), plane1!.w);
            XCTAssertEqual(plane2!.normal.dot(intersection!.origin), plane2!.w);
            
            XCTAssert(plane1!.containsPoint(intersection!.origin))
            XCTAssert(plane2!.containsPoint(intersection!.origin))
            
            XCTAssert(plane1!.containsPoint(intersection!.origin + intersection!.direction))
            XCTAssert(plane2!.containsPoint(intersection!.origin + intersection!.direction))
        }
    }
}
