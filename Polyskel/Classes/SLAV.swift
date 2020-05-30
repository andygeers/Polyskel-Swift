//
//  SLAV.swift
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
import Foundation

class SLAV : Sequence {
    internal var lavs : [LAV] = []
    internal var originalEdges : [ContourEdge]
    var plane : Plane
    
    init(contour: Contour, holes: [Contour]?) {
        var contours = [contour]
        if (holes != nil) {
            contours.append(contentsOf: holes!)
        }
        
        self.plane = contour.plane
        
        self.originalEdges = []
        
        self.lavs = contours.map { LAV.fromContour($0, slav: self) }

        // store original polygon edges for calculating split events
        self.originalEdges = Array(self.lavs.joined()).map { ContourEdge(lineSegment: LineSegment($0.prev!.point, $0.point)!, bisectorLeft: $0.prev!.bisector, bisectorRight: $0.bisector) }
    }
    
    func makeIterator() -> IndexingIterator<[LAV]> {
        return lavs.makeIterator()
    }

    var count : Int {
        get {
            return self.lavs.count
        }
    }

    var isEmpty : Bool {
        get {
            return self.lavs.isEmpty
        }
    }
    func handleEvent(_ event : SkeletonEvent) -> (Subtree?, [SkeletonEvent]) {
        if (event is EdgeEvent) {
            return self.handleEdgeEvent(event as! EdgeEvent)
        } else if (event is SplitEvent) {
            return self.handleSplitEvent(event as! SplitEvent)
        } else {
            return (nil, [])
        }
    }
    
    func handleEdgeEvent(_ event : EdgeEvent) -> (Subtree?, [SkeletonEvent]) {
        var sinks : [Vector] = []
        var events : [SkeletonEvent] = []
        var edges : Set<LineSegment> = Set()

        let lav = event.vertexA.lav
        if (event.vertexA.prev === event.vertexB.next) {
            if (Polyskel.debugLog) { NSLog("%.2f Peak event at intersection %f,%f,%f from <%@,%@,%@> in %@", event.distance, event.intersectionPoint.x, event.intersectionPoint.y, event.intersectionPoint.z, event.vertexA.description, event.vertexB.description, event.vertexA.prev!.description, lav!.description) }
            self.lavs = self.lavs.filter { $0 !== lav }
            
            for vertex in lav! {
                sinks.append(vertex.point)
                edges.insert(vertex.edgeLeft)
                edges.insert(vertex.edgeRight)
                vertex.invalidate()
            }
        } else {
            if (Polyskel.debugLog) { NSLog("%.2f Edge event at intersection %f,%f,%f from <%@,%@> in %@", event.distance, event.intersectionPoint.x, event.intersectionPoint.y, event.intersectionPoint.z, event.vertexA.description, event.vertexB.description, lav!.description) }
            let newVertex = lav!.unify(vertexA: event.vertexA, vertexB: event.vertexB, point: event.intersectionPoint)
            if ((lav!.head === event.vertexA) || (lav!.head === event.vertexB)) {
                lav!.head = newVertex
            }
            sinks.append(contentsOf: [event.vertexA.point, event.vertexB.point])
            edges.insert(event.vertexA.edgeLeft)
            edges.insert(event.vertexA.edgeRight)
            edges.insert(event.vertexB.edgeLeft)
            edges.insert(event.vertexB.edgeRight)
            
            let nextEvent = newVertex.nextEvent()
            if (nextEvent != nil) {
                events.append(nextEvent!)
            }
        }
        return (Subtree(source: event.intersectionPoint, height: event.distance, sinks: sinks, edges: Array(edges)), events)
    }
    
    func handleSplitEvent(_ event : SplitEvent) -> (Subtree?, [SkeletonEvent]) {
        let lav = event.vertex.lav
        if (Polyskel.debugLog) { NSLog("%.2f Split event at intersection %f,%f,%f from vertex %@, for edge %f,%f,%f->%f,%f,%f in %@", event.distance, event.intersectionPoint.x, event.intersectionPoint.y, event.intersectionPoint.z, event.vertex.description, event.oppositeEdge.start.x, event.oppositeEdge.start.y, event.oppositeEdge.start.z, event.oppositeEdge.end.x, event.oppositeEdge.end.y, event.oppositeEdge.end.z, lav!.description) }

        var sinks = [event.vertex.point]
        var edges : Set<LineSegment> = Set([event.vertex.edgeLeft, event.vertex.edgeRight])
        var vertices : [LAVertex] = []
        var x : LAVertex? = nil   // right vertex
        var y : LAVertex?  = nil   // left vertex
        let norm = event.oppositeEdge.direction
        for v in Array(self.lavs.joined()) {
            if (Polyskel.debugLog) { NSLog("%@ in %@", v.description, v.lav!.description) }
            if ((norm == v.edgeLeft.direction) && (event.oppositeEdge.start == v.edgeLeft.start)) {
                x = v
                y = x!.prev
            } else if ((norm == v.edgeRight.direction) && (event.oppositeEdge.start == v.edgeRight.start)) {
                y = v
                x = y!.next
            }

            if (x != nil) {
                let xleft =  self.VectorGTEZero(y!.bisector.direction.cross((event.intersectionPoint - y!.point).normalized()))
                let xright = self.VectorLTEZero(x!.bisector.direction.cross((event.intersectionPoint - x!.point).normalized()))
                if (Polyskel.debugLog) { NSLog("Vertex %@ holds edge as %@ edge (%d, %d)", v.description, (x === v ? "left" : "right"), xleft, xright) }

                if (xleft && xright) {
                    break
                } else {
                    x = nil
                    y = nil
                }
            }
        }
        guard (x != nil) else {
            if (Polyskel.debugLog) { NSLog("Failed split event %@ (equivalent edge event is expected to follow)", event.description) }
            return (nil,[])
        }

        let v1 = LAVertex(point: event.intersectionPoint, edgeLeft: event.vertex.edgeLeft, edgeRight: event.oppositeEdge, plane: self.plane, directionVectors: nil)
        let v2 = LAVertex(point: event.intersectionPoint, edgeLeft: event.oppositeEdge, edgeRight: event.vertex.edgeRight, plane: self.plane, directionVectors: nil)

        v1.prev = event.vertex.prev
        v1.next = x
        event.vertex.prev!.next = v1
        x!.prev = v1

        v2.prev = y
        v2.next = event.vertex.next
        event.vertex.next!.prev = v2
        y!.next = v2

        var newLavs : [LAV] = []
        self.lavs = self.lavs.filter { $0 !== lav }
        if (lav !== x!.lav) {
            // the split event actually merges two lavs            
            self.lavs = self.lavs.filter { $0 !== x!.lav }
            newLavs = [LAV.fromChain(head: v1, slav: self)]
        } else {
            newLavs = [LAV.fromChain(head: v1, slav: self), LAV.fromChain(head: v2, slav: self)]
        }

        for l in newLavs {
            if (Polyskel.debugLog) { NSLog("%@", l.description) }
            if (l.length) > 2 {
                self.lavs.append(l)
                vertices.append(l.head!)
            } else {
                if (Polyskel.debugLog) { NSLog("LAV %@ has collapsed into the line %f,%f,%f--%f,%f,%f", l.description, l.head!.point.x, l.head!.point.y, l.head!.point.z, l.head!.next!.point.x, l.head!.next!.point.y, l.head!.next!.point.z) }
                sinks.append(l.head!.next!.point)
                edges.insert(l.head!.next!.edgeLeft)
                edges.insert(l.head!.next!.edgeRight)
                
                for v in l {
                    v.invalidate()
                }
            }
        }
        var events : [SkeletonEvent] = []
        for vertex in vertices {
            let nextEvent = vertex.nextEvent()
            if (nextEvent != nil) {
                events.append(nextEvent!)
            }
        }
        event.vertex.invalidate()
        return (Subtree(source: event.intersectionPoint, height: event.distance, sinks: sinks, edges: Array(edges)), events)
    }
    
    public func VectorGTEZero(_ vector : Vector) -> Bool {
        return vector.dot(self.plane.normal) < 0
    }
    
    public func VectorLTEZero(_ vector : Vector) -> Bool {
        return vector.dot(self.plane.normal) > 0
    }
}
