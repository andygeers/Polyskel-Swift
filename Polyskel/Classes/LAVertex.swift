//
//  LAVertex.swift
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

struct OriginalEdge {
    var edge : LineSegment;
    var bisectorLeft : Ray;
    var bisectorRight : Ray;
    
    public var description : String {
        return String(format: "Edge from %@ -> %@", edge.start.description, edge.end.description)
    }
}

class LAVertex {
    
    var point : Vector
    var edgeLeft : LineSegment
    var edgeRight : LineSegment
    var prev : LAVertex?
    var next : LAVertex?
    var lav : LAV?;
    var isValid : Bool = true; // this should be handled better. Maybe membership in lav implies validity?
    var isReflex : Bool = false
    var bisector : Ray
    
    public var description: String {
        return String(format: "Vertex (%@) (%.2f};{%.2f}), bisector %@, edges %@ %@", self.isReflex ? "reflex" : "convex", self.point.x, self.point.z, self.bisector.description, self.edgeLeft.description, self.edgeRight.description)
    }
    
    init(point: Vector, edgeLeft : LineSegment, edgeRight : LineSegment, plane: Plane, directionVectors: [Vector]?) {
        self.point = point
        self.edgeLeft = edgeLeft
        self.edgeRight = edgeRight
        self.prev = nil
        self.next = nil
        self.lav = nil
        
        var directionVectorsToUse = directionVectors

        let creatorVectors = [edgeLeft.direction * -1, edgeRight.direction]
        if (directionVectors == nil) {
            directionVectorsToUse = creatorVectors
        }

        let reflexCross = directionVectorsToUse![0].cross(directionVectorsToUse![1])        
        self.isReflex = reflexCross.dot(plane.normal) > 0
        self.bisector = Ray(self.point, (creatorVectors[0] + creatorVectors[1]) * (self.isReflex ? -1 : 1))
        if (Polyskel.debugLog) { NSLog("Created vertex %@", self.description) }
        //_debug.line((self.bisector.p.x, self.bisector.p.y, self.bisector.p.x+self.bisector.v.x*100, self.bisector.p.y+self.bisector.v.y*100), fill="blue")
    }


    var originalEdges : [OriginalEdge] {
        return self.lav!.slav.originalEdges
    }

    func nextEvent(isGabled: (LineSegment) -> Bool) -> SkeletonEvent? {
        var events : [SkeletonEvent] = []
        if (self.isReflex) {
            // a reflex vertex may generate a split event
            // split events happen when a vertex hits an opposite edge, splitting the polygon in two.
            if (Polyskel.debugLog) { NSLog("looking for split candidates for vertex %@", self.description) }
            for edge in self.originalEdges {
            
                if ((edge.edge == self.edgeLeft) || (edge.edge == self.edgeRight)) {
                    continue
                }

                if (Polyskel.debugLog) { NSLog("\tconsidering EDGE %@", edge.description) }

                // a potential b is at the intersection of between our own bisector and the bisector of the
                // angle between the tested edge and any one of our own edges.

                // we choose the "less parallel" edge (in order to exclude a potentially parallel edge)
                let leftdot = abs(self.edgeLeft.direction.dot(edge.edge.direction))
                let rightdot = abs(self.edgeRight.direction.dot(edge.edge.direction))
                let selfedge = leftdot < rightdot ? self.edgeLeft : self.edgeRight                

                let i = Line(from: selfedge).intersection(with: Line(from: edge.edge))
                if ((i != nil) && (!(i! == self.point))) {
                    // locate candidate b
                    let linvec = (self.point - i!).normalized()
                    var edvec = edge.edge.direction
                    if (linvec.dot(edvec)<0) {
                        edvec = -edvec
                    }

                    let bisecvec = edvec + linvec
                    if (bisecvec.length == 0) {
                        continue
                    }
                    guard let bisector = LineSegment(i!, bisecvec) else { continue }
                    let b = bisector.intersection(with: self.bisector)

                    if (b == nil) {
                        continue
                    }

                    // check eligibility of b
                    // a valid b should lie within the area limited by the edge and the bisectors of its two vertices:
                    let xleft = !self.lav!.slav.VectorLTEZero(edge.bisectorLeft.direction.cross((b! - edge.bisectorLeft.origin).normalized()))
                    let xright = !self.lav!.slav.VectorGTEZero(edge.bisectorRight.direction.cross((b! - edge.bisectorRight.origin).normalized()))
                    let xedge = !self.lav!.slav.VectorGTEZero(edge.edge.direction.cross((b! - edge.edge.start).normalized()))

                    if (!(xleft && xright && xedge)) {
                        if (Polyskel.debugLog) { NSLog("\t\tDiscarded candidate %f,%f,%f (%@-%@-%@)", b!.x, b!.y, b!.z, xleft.description, xright.description, xedge.description) }
                        continue
                    }

                    if (Polyskel.debugLog) { NSLog("\t\tFound valid candidate %f,%f,%f", b!.x, b!.y, b!.z) }
                    events.append( SplitEvent(distance: Line(from: edge.edge).distance(to: b!), intersectionPoint: b!, vertex: self, oppositeEdge: edge.edge) )
                }
            }
        }
        var iPrev = self.bisector.intersection(with: self.prev!.bisector)
        var iNext = self.bisector.intersection(with: self.next!.bisector)

        if (iPrev != nil) {
            let distance = Line(from: self.edgeLeft).distance(to: iPrev!)
            
            if ((self.point == self.edgeLeft.end) && (isGabled(self.edgeLeft))) {
                iPrev = self.edgeLeft.midPoint
            }
            
            events.append(EdgeEvent(distance: distance, intersectionPoint: iPrev!, vertexA: self.prev!, vertexB: self))
        }
        if (iNext != nil) {
            let distance = Line(from: self.edgeRight).distance(to: iNext!)
            
            if ((self.point == self.edgeRight.start) && (isGabled(self.edgeRight))) {
                iNext = self.edgeRight.midPoint
            }
            
            events.append(EdgeEvent(distance: distance, intersectionPoint:iNext!, vertexA: self, vertexB: self.next!))
        }

        if (events.isEmpty) {
            return nil
        }
        
        let sortedEvents = events.sorted(by: { ($0.intersectionPoint - self.point).length < ($1.intersectionPoint - self.point).length })
        let ev = sortedEvents.first

        if (Polyskel.debugLog) { NSLog("Generated new event for %@: %@", self.description, ev!.description) }
        return ev
    }
    
    func invalidate() {
        if (self.lav != nil) {
            do {
                try self.lav!.invalidate(vertex: self)
            } catch {
                // Never mind
            }
        } else {
            self.isValid = false
        }
    }

    static func < (lhs : LAVertex, rhs : LAVertex) -> Bool {
        return lhs.point.x < rhs.point.x
    }
    
}
