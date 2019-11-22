//
//  LAV.swift
//  Polyskel-Swift
//
//  Created by Andy Geers on 22/11/2019.
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/andygeers/Polyskel-Swift
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Euclid
class LAV : Sequence {
    var head : LAVertex?
    var slav : SLAV
    var length : Int
    
    public var description: String {
        return String(format: "LAV %@", Array(self))
    }
    
    internal static func modulo<T: BinaryInteger>(_ lhs: T, _ rhs: T) -> T {
        let rem = lhs % rhs // -rhs <= rem <= rhs
        return rem >= 0 ? rem : rem + rhs
    }
    
    internal static func window(_ contour : [Vector]) -> [(Vector, Vector, Vector)] {
        guard !contour.isEmpty else { return [] }
        return (0 ..< contour.count).map { (contour[modulo($0 - 1, contour.count)], contour[$0], contour[($0 + 1) % contour.count]) }
    }
    
    internal static func normalizeContour(_ polygon : Polygon) -> [Vector] {
        let contour = polygon.vertices.map { $0.position }
        let w = window(contour)
        let filtered = w.filter({
            let (prev, point, next) = $0
            return !(point==next || ((point-prev).normalized() == (next-point).normalized()))
        })
        return filtered.map {
            let (_, point, _) = $0
            return point
        }
    }
    
    struct LAVIterator : IteratorProtocol {
        var cur : LAVertex?
        var head : LAVertex?
        var hasReturned : Bool = false
        
        init(lav : LAV) {
            self.cur = lav.head
            self.head = lav.head
        }
        
        mutating func next() -> LAVertex? {
            guard cur != nil else { return nil; }
            
            if (hasReturned) {
                cur = cur!.next;
            
                guard (cur! !== self.head!) else { return nil; }
            }
            
            hasReturned = true;
            return cur;
            
        }
    }
    
    init(slav : SLAV) {
        self.head = nil
        self.slav = slav
        self.length = 0
        NSLog("Created LAV %@", self.description)
    }


    static func fromPolygon(polygon : Polygon, slav : SLAV) -> LAV {
        let lav = LAV(slav: slav)
        for (prev, point, next) in window(normalizeContour(polygon)) {
            lav.length += 1
            let vertex = LAVertex(point: point, edgeLeft: LineSegment(prev, point), edgeRight: LineSegment(point, next), directionVectors: nil)
            vertex.lav = lav
            if (lav.head == nil) {
                lav.head = vertex
                vertex.prev = vertex
                vertex.next = vertex
            } else {
                vertex.next = lav.head
                vertex.prev = lav.head!.prev
                vertex.prev!.next = vertex
                lav.head!.prev = vertex
            }
        }
        return lav
    }
    
    static func fromChain(head : LAVertex, slav : SLAV) -> LAV {
        let lav = LAV(slav: slav)
        lav.head = head
        for vertex in lav {
            lav.length += 1
            vertex.lav = lav
        }
        return lav
    }

    func invalidate(vertex : LAVertex) throws {
        guard vertex.lav! === self else { throw NSError() } // "Tried to invalidate a vertex that's not mine") }
        NSLog("Invalidating %@", vertex.description)
        vertex.isValid = false
        if ((self.head != nil) && (self.head! === vertex)) {
            self.head = self.head!.next
        }
        vertex.lav = nil
    }

    func unify(vertexA : LAVertex, vertexB : LAVertex, point : Vector) -> LAVertex {
        let replacement = LAVertex(point: point, edgeLeft: vertexA.edgeLeft, edgeRight: vertexB.edgeRight, directionVectors: [vertexB.bisector.direction.normalized(), vertexA.bisector.direction.normalized()])
        replacement.lav = self

        if ((self.head! === vertexA) || (self.head! === vertexB)) {
            self.head = replacement
        }

        vertexA.prev!.next = replacement
        vertexB.next!.prev = replacement
        replacement.prev = vertexA.prev
        replacement.next = vertexB.next

        vertexA.invalidate()
        vertexB.invalidate()

        self.length -= 1
        return replacement
    }
    
    func makeIterator() -> LAVIterator {
        return LAVIterator(lav: self)
    }
    
    //internal func show() {
        
    //}
}
