//
//  Events.swift
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

class SkeletonEvent {
    public var distance : Double
    public var intersectionPoint : Vector
    
    init(distance : Double, intersectionPoint: Vector) {
        self.distance = distance
        self.intersectionPoint = intersectionPoint
    }
    
    func isValid() -> Bool {
        return true;
    }
    
    public var description: String {
        return "";
    }
    
    public var relatedEdges: [LineSegment] {
        return [];
    }
}

class SplitEvent : SkeletonEvent {
    
    var vertex : LAVertex
    var oppositeEdge : LineSegment
    
    init(distance : Double, intersectionPoint: Vector, vertex : LAVertex, oppositeEdge : LineSegment) {
        self.vertex = vertex
        self.oppositeEdge = oppositeEdge
        
        super.init(distance: distance, intersectionPoint: intersectionPoint)
    }
    
    override func isValid() -> Bool {
        return vertex.isValid;
    }
    
    override public var description: String {
        return String(format: "%f Split event @ %f,%f,%f from %@ to %f,%f,%f->%f,%f,%f", self.distance, self.intersectionPoint.x, self.intersectionPoint.y, self.intersectionPoint.z, self.vertex.description, self.oppositeEdge.start.x, self.oppositeEdge.start.y, self.oppositeEdge.start.z, self.oppositeEdge.end.x, self.oppositeEdge.end.y, self.oppositeEdge.end.z)
    }
    
    override public var relatedEdges: [LineSegment] {
        return [vertex.edgeLeft, vertex.edgeRight, oppositeEdge];
    }

}

class EdgeEvent : SkeletonEvent {
    var vertexA : LAVertex
    var vertexB : LAVertex
    
    init(distance : Double, intersectionPoint: Vector, vertexA : LAVertex, vertexB : LAVertex) {
        self.vertexA = vertexA
        self.vertexB = vertexB
        
        super.init(distance: distance, intersectionPoint: intersectionPoint)
    }
    
    override func isValid() -> Bool {
        return (vertexA.isValid && vertexB.isValid);
    }
    
    override public var description: String {
        return String(format: "%f Edge event @ %f,%f,%f between %@ and %@", self.distance, self.intersectionPoint.x, self.intersectionPoint.y, self.intersectionPoint.z, self.vertexA.description, self.vertexB.description)
    }
    
    override public var relatedEdges: [LineSegment] {
        return [vertexA.edgeLeft, vertexA.edgeRight, vertexB.edgeRight];
    }
}
 
