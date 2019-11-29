//
//  Roofs.swift
//  Polyskel
//
//  Created by Andy Geers on 29/11/2019.
//

import Euclid

public extension StraightSkeleton {
    func generateRoofPolygons() -> [Polygon] {
        var polygons : [Polygon] = []
        
        // Iterate over each edge in the original polygon
        for edge in self.polygon.edges {
            // Find all nodes in the skeleton that are related to this edge
            let sorted = nodesFor(edge: edge)
            
            let path = Path(sorted.map { PathPoint($0, isCurved: false )}).closed()
            let poly = Polygon(shape: path, material: randomColour())
            if (poly != nil) {
                polygons.append(poly!)
            }
        }

        return polygons
    }
    
}
extension StraightSkeleton {
    func nodesFor(edge : LineSegment) -> [Vector] {
        let nodes = self.subtrees.filter { $0.edges.contains(edge) }
        let points = nodes.map { $0.source }
        
        // We need to sort the nodes along the axis parallel to the edge
        return [edge.point2] + points.sorted(by: { distanceAlong($0, edge) > distanceAlong($1, edge) }) + [edge.point1]
    }
}

internal func distanceAlong(_ point : Vector, _ edge : LineSegment) -> Double {
   return (point - edge.point1).dot(edge.direction)
}

internal func randomColour() -> UIColor {
   return UIColor(red: CGFloat(Float.random(in: 0 ..< 1.0)), green: CGFloat(Float.random(in: 0 ..< 1.0)), blue: CGFloat(Float.random(in: 0 ..< 1.0)), alpha: CGFloat(1.0))
}
