//
//  Lines.swift
//  Euclid
//
//  Created by Andy Geers on 20/11/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/Euclid
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

enum AxisSwap {
    case none
    case xz
    case yz
    case notPossible
}

protocol LinearGeometry {
    func containsColinearPoint(_ point : Vector) -> Bool
    var direction : Vector { get }
    var line : Line { get }
    
    func swappedToXZ() -> LinearGeometry
    func swappedToYZ() -> LinearGeometry
}

extension LinearGeometry {
    func linearGeomIntersection(with: LinearGeometry) -> Vector? {
        return intersectionBetween(self, with: with)
    }
}

extension LineSegment : LinearGeometry {
    
    public var line : Line {
        return Line(origin: start, direction: direction)!
    }
    
    public var midPoint : Vector {
        return (self.start + self.end) * 0.5
    }
    
    public var length : Double {
        return (self.end - self.start).length
    }
}

extension LineSegment {
    public func intersection(with: LineSegment) -> Vector? {
        return self.linearGeomIntersection(with: with)
    }
    
    public func intersection(with: Ray) -> Vector? {
        return self.linearGeomIntersection(with: with)
    }
    
    public func intersection(with: Line) -> Vector? {
        return self.linearGeomIntersection(with: with)
    }
    
    func swappedToXZ() -> LinearGeometry {
        let p0 = Vector(self.start.x, self.start.z, self.start.y)
        let p1 = Vector(self.end.x, self.end.z, self.end.y)
        return LineSegment(p0, p1)!
    }
    
    func swappedToYZ() -> LinearGeometry {
        let p0 = Vector(self.start.y, self.start.z, self.start.x)
        let p1 = Vector(self.end.y, self.end.z, self.end.x)
        return LineSegment(p0, p1)!
    }
    
    func containsColinearPoint(_ point : Vector) -> Bool {
        let ua = pointParameter(point, self.start, self.end)
        return ua >= 0.0 && ua <= 1.0
    }
    
    public func contains(_ point : Vector) -> Bool {
        // First see if this point lies on this line
        return line.contains(point) && containsColinearPoint(point)
    }
    
    internal static func getAxisSwapForIntersection(_ first: LinearGeometry, with: LinearGeometry) -> AxisSwap {
        
        if ((first.direction.z == 0) && (with.direction.z == 0) && (first.line.origin.z == with.line.origin.z)) {
            return .none
        } else if ((first.direction.y == 0) && (with.direction.y == 0) && (first.line.origin.y == with.line.origin.y)) {
            // Switch dimensions and then solve
            return .xz
        } else if ((first.direction.x == 0) && (with.direction.x == 0) && (first.line.origin.x == with.line.origin.x)) {
            // Switch dimensions and then solve
            return .yz
        } else {
            // TOOO: Generalize to 3D
            return .notPossible
        }
    }
}

public struct Ray : Hashable, LinearGeometry {
    public init(_ origin: Vector, _ direction: Vector) {
        self.origin = origin
        self.direction = direction.normalized()
    }
    
    public var origin: Vector {
        didSet { origin = origin.quantized() }
    }
    
    public var direction: Vector {
        didSet { direction = direction.normalized() }
    }
    
    public var line : Line {
        return Line(origin: origin, direction: direction)!
    }
}

extension Ray {
    public func intersection(with: LineSegment) -> Vector? {
        return self.linearGeomIntersection(with: with)
    }
    
    public func intersection(with: Ray) -> Vector? {
        return self.linearGeomIntersection(with: with)
    }
    
    public func intersection(with: Line) -> Vector? {
        return self.linearGeomIntersection(with: with)
    }
    
    func swappedToXZ() -> LinearGeometry {
        let p0 = Vector(self.origin.x, self.origin.z, self.origin.y)
        let p1 = Vector(self.direction.x, self.direction.z, self.direction.y)
        return Ray(p0, p1)
    }
    
    func swappedToYZ() -> LinearGeometry {
        let p0 = Vector(self.origin.y, self.origin.z, self.origin.x)
        let p1 = Vector(self.direction.y, self.direction.z, self.direction.x)
        return Ray(p0, p1)
    }
    
    public func containsColinearPoint(_ point : Vector) -> Bool {
        let ua = pointParameter(point, self.origin, self.origin + self.direction)
        return ua >= 0.0
    }
}

private func intersectionBetween(_ geometry1 : LinearGeometry, with: LinearGeometry) -> Vector? {
    
    let axisSwap = LineSegment.getAxisSwapForIntersection(geometry1, with: with)
    switch (axisSwap) {
        case .notPossible:
            return nil
    
        case .none:
            return linearGeometryIntersection(geometry1, with)
            
        case .xz:
            let segment1 = geometry1.swappedToXZ()
            let segment2 = with.swappedToXZ()
            let intersection = linearGeometryIntersection(segment1, segment2)
            if (intersection != nil) {
                // Switch back
                return Vector(intersection!.x, intersection!.z, intersection!.y)
            } else {
               return nil
           }
        
        case .yz:
            let segment1 = geometry1.swappedToYZ()
            let segment2 = with.swappedToYZ()
            let intersection = linearGeometryIntersection(segment1, segment2)
            if (intersection != nil) {
                // Switch back
                // Switch back
                return Vector(intersection!.z, intersection!.x, intersection!.y)
            } else {
                return nil
            }
        
    }
}

extension Line : LinearGeometry {
    public init(from: LineSegment) {
        self.init(origin: from.start, direction: from.direction)!
    }
    
    public var description : String {
        return String(format: "{<%@> u<%@>}", origin.description, direction.description)
    }
    
    public var line : Line {
        return self
    }
    
    public func distance(to: Vector) -> Double {
        // See "Vector formulation" at https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
        let aMinusP = self.origin - to
        let v = aMinusP - (self.direction * aMinusP.dot(self.direction))
        return v.length
    }
    
    public func contains(_ point : Vector) -> Bool {
        // First see if this point lies on this line
        return distance(to: point) == 0.0
    }
}

extension Line {
    public func intersection(with: LineSegment) -> Vector? {
        return self.linearGeomIntersection(with: with)
    }
    
    public func intersection(with: Ray) -> Vector? {
        return self.linearGeomIntersection(with: with)
    }
    
//    public func intersection(with: Line) -> Vector? {
//        return self.linearGeomIntersection(with: with)
//    }
    
    func swappedToXZ() -> LinearGeometry {
        let p0 = Vector(self.origin.x, self.origin.z, self.origin.y)
        let p1 = Vector(self.direction.x, self.direction.z, self.direction.y)
        return Line(origin: p0, direction: p1)!
    }
    
    func swappedToYZ() -> LinearGeometry {
        let p0 = Vector(self.origin.y, self.origin.z, self.origin.x)
        let p1 = Vector(self.direction.y, self.direction.z, self.direction.x)
        return Line(origin: p0, direction: p1)!
    }
    
    func containsColinearPoint(_ point : Vector) -> Bool {
        return true
    }
}

// MARK: Private utility functions

// Get the intersection point between two lines
// TODO: extend this to work in 3D
// TODO: improve this using https://en.wikipedia.org/wiki/Line–line_intersection
private func lineIntersection(_ line1: Line, _ line2: Line) -> Vector? {
    
    let p0 = line1.origin
    let p1 = p0 + line1.direction
    let p2 = line2.origin
    let p3 = p2 + line2.direction
    
    let x1 = p0.x, y1 = p0.y
    let x2 = p1.x, y2 = p1.y
    let x3 = p2.x, y3 = p2.y
    let x4 = p3.x, y4 = p3.y

    let x1y2 = x1 * y2, y1x2 = y1 * x2
    let x1y2minusy1x2 = x1y2 - y1x2

    let x3minusx4 = x3 - x4
    let x1minusx2 = x1 - x2

    let x3y4 = x3 * y4, y3x4 = y3 * x4
    let x3y4minusy3x4 = x3y4 - y3x4

    let y3minusy4 = y3 - y4
    let y1minusy2 = y1 - y2

    let d = x1minusx2 * y3minusy4 - y1minusy2 * x3minusx4
    if abs(d) < epsilon {
        return nil // lines are parallel
    }
    let ix = (x1y2minusy1x2 * x3minusx4 - x1minusx2 * x3y4minusy3x4) / d
    let iy = (x1y2minusy1x2 * y3minusy4 - y1minusy2 * x3y4minusy3x4) / d

    return Vector(ix, iy, p0.z).quantized()
}

private func pointParameter(_ point : Vector, _ point1 : Vector, _ point2: Vector) -> Double {
    return (point - point1).dot(point2 - point1) / (point2 - point1).length
}

private func linearGeometryIntersection(_ l1: LinearGeometry, _ l2: LinearGeometry) -> Vector? {
    guard let pi = lineIntersection(l1.line, l2.line) else {
        return nil // lines are parallel
    }
    
    if (l1.containsColinearPoint(pi) && l2.containsColinearPoint(pi)) {
        return pi
    } else {
        return nil
    }
}

public extension Euclid.Polygon {
    var edges : [LineSegment] {
        // Iterate over each edge in the original polygon
        var firstPosition : Vector? = nil
        var lastPosition : Vector? = nil
        var lineSegments : [LineSegment] = []
        for vertex in self.vertices {
            let thisPosition = vertex.position
            if (firstPosition == nil) {
                firstPosition = thisPosition
            }
            if (lastPosition != nil) {
                let edge = LineSegment(lastPosition!, thisPosition)
                if (edge != nil) {
                    lineSegments.append(edge!)
                }
            }
            lastPosition = thisPosition
        }
        if ((firstPosition != nil) && (lastPosition != nil) && (firstPosition != lastPosition)) {
            let edge = LineSegment(lastPosition!, firstPosition!)
            if (edge != nil) {
                lineSegments.append(edge!)
            }
        }
        
        return lineSegments
    }
}
