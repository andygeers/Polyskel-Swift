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
        XCTAssertFalse(skeleton.subtrees.isEmpty)
        XCTAssertEqual(skeleton.subtrees.count, 2)
        if (skeleton.subtrees.count == 2) {
            for n in (0 ..< skeleton.subtrees.count) {
                NSLog("%d: %f,%f,%f (%f): %d", n, skeleton.subtrees[n].source.x, skeleton.subtrees[n].source.y, skeleton.subtrees[n].source.z, skeleton.subtrees[n].height, skeleton.subtrees[n].sinks.count);
                
                for sink in skeleton.subtrees[n].sinks {
                    NSLog(" - sink at %f,%f,%f", sink.x, sink.y, sink.z)
                }
            }
        }
    }
    
    static func square() -> Euclid.Polygon? {
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
        
        return Euclid.Polygon(shape: outline.closed())
    }
}
