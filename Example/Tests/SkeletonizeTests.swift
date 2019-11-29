//
//  SkeletonizeTests.swift
//  Polyskel_Example
//
//  Created by Andy Geers on 22/11/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import Polyskel
import Euclid

class SkeletonizeTests: XCTestCase {
    func testSkeletonizeSquare() {
        let p = SkeletonizeTests.square()
        let skeleton = Polyskel.skeletonize(polygon: p!, holes: nil)
        XCTAssertFalse(skeleton.isEmpty)
        XCTAssertEqual(skeleton.count, 2)
        if (skeleton.count == 2) {
            for n in (0 ..< skeleton.count) {
                NSLog("%d: %f,%f,%f (%f): %d", n, skeleton[n].source.x, skeleton[n].source.y, skeleton[n].source.z, skeleton[n].height, skeleton[n].sinks.count);
                
                for sink in skeleton[n].sinks {
                    NSLog(" - sink at %f,%f,%f", sink.x, sink.y, sink.z)
                }
            }
        }
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
