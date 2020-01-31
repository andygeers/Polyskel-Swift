//
//  Contour.swift
//  Polyskel
//
//  Created by Andy Geers on 31/01/2020.
//

import Foundation
import Euclid

public struct ContourNode {
    var point : Vector
    var edgeLeft : LineSegment
    var edgeRight : LineSegment
    var isReflex : Bool = false
    var bisector : Ray
    
    init(point: Vector, edgeLeft : LineSegment, edgeRight : LineSegment, plane: Plane, directionVectors: [Vector]? = nil) {
        
        self.point = point
        self.edgeLeft = edgeLeft
        self.edgeRight = edgeRight    
        
        var directionVectorsToUse = directionVectors

        let creatorVectors = [edgeLeft.direction * -1, edgeRight.direction]
        if (directionVectors == nil) {
            directionVectorsToUse = creatorVectors
        }

        let reflexCross = directionVectorsToUse![0].cross(directionVectorsToUse![1])
        self.isReflex = reflexCross.dot(plane.normal) > 0
        self.bisector = Ray(self.point, (creatorVectors[0] + creatorVectors[1]) * (self.isReflex ? -1 : 1))
        if (Polyskel.debugLog) { NSLog("Created vertex %@", self.description) }
    }
    
    public var description: String {
        return String(format: "Vertex (%@) (%.2f};{%.2f}), bisector %@, edges %@ %@", self.isReflex ? "reflex" : "convex", self.point.x, self.point.z, self.bisector.description, self.edgeLeft.description, self.edgeRight.description)
    }
}

public class Contour : Sequence {
    
    let nodes : [ContourNode]
    let plane : Plane
    
    var edges : [LineSegment] {
        return nodes.map { $0.edgeRight }
    }
    
    init(_ polygon : Polygon) {
        var vertices : [ContourNode] = []
        
        self.plane = polygon.plane
        
        for (prev, point, next) in Contour.normalizeContour(polygon) {
            let vertex = ContourNode(point: point, edgeLeft: LineSegment(prev, point)!, edgeRight: LineSegment(point, next)!, plane: self.plane)
            vertices.append(vertex)
        }
                
        self.nodes = vertices
    }
    
    private static func modulo<T: BinaryInteger>(_ lhs: T, _ rhs: T) -> T {
        let rem = lhs % rhs // -rhs <= rem <= rhs
        return rem >= 0 ? rem : rem + rhs
    }
    
    internal static func window(_ contour : [Vector]) -> [(Vector, Vector, Vector)] {
        guard !contour.isEmpty else { return [] }
        return (0 ..< contour.count).map { (contour[modulo($0 - 1, contour.count)], contour[$0], contour[($0 + 1) % contour.count]) }
    }
    
    internal static func normalizeContour(_ polygon : Polygon) -> [(Vector, Vector, Vector)] {
        
        let contour = polygon.vertices.map { $0.position }
        
        let w = window(contour)
        let filtered = w.filter({
            let (prev, point, next) = $0
            return !(point==next || ((point-prev).normalized() == (next-point).normalized()))
        }).map { $0.1 }
        return window(filtered)
    }
    
    public func makeIterator() -> IndexingIterator<[ContourNode]> {
        return nodes.makeIterator()
    }
    
    
}
