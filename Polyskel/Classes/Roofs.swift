//
//  Roofs.swift
//  Polyskel
//
//  Created by Andy Geers on 29/11/2019.
//

import Euclid

public extension StraightSkeleton {
    func generateRoofPolygons() -> [Polygon] {
        return generateRoofPolygons(angle: Double.pi / 4.0)
    }
    
    func generateRoofPolygons(angle: Double) -> [Polygon] {
        var polygons : [Polygon] = []
        
        // Iterate over each edge in the original polygon
        for edge in self.polygon.edges {
            // Find all nodes in the skeleton that are related to this edge
            let sorted = nodesFor(edge: edge, angle: angle)
            
            let colour = randomColour()
            
            var lastNode : Vector? = nil
            for node in sorted + [edge.start] {
                if (lastNode != nil) {
                    let points = [edge.end, lastNode!, node]
                    let path = Path(points.map { PathPoint($0, isCurved: false )}).closed()
                    let poly = Polygon(shape: path, material: colour)
                    if (poly != nil) {
                        polygons.append(poly!)
                    }
                }
                
                lastNode = node
            }
        }

        return polygons
    }
    
}
extension StraightSkeleton {
    func nodesFor(edge : LineSegment, angle: Double) -> [Vector] {
        let polyPlane = self.polygon.plane
        let nodes = self.subtrees.filter { $0.edges.contains(edge) }
        let scaleFactor = scaleFactorFor(angle: angle)
        let points = nodes.map { $0.source + polyPlane.normal * ($0.height * scaleFactor) }
        
        // We need to sort the nodes along the axis parallel to the edge
        return points.sorted(by: { distanceAlong($0, edge) > distanceAlong($1, edge) })
    }
    
    func scaleFactorFor(angle: Double) -> Double {
        // angle = 0    -> scale = 0
        // angle = PI/4 -> scale = 1
        // angle = PI/2 -> scale = infinity
        // tan(0) = 0
        if (angle < Double.pi / 2) {
            return tan(angle)
        } else {
            return 0
        }
    }
}

internal func distanceAlong(_ point : Vector, _ edge : LineSegment) -> Double {
   return (point - edge.start).dot(edge.direction)
}

internal func randomColour() -> UIColor {
   return UIColor(red: CGFloat(Float.random(in: 0 ..< 1.0)), green: CGFloat(Float.random(in: 0 ..< 1.0)), blue: CGFloat(Float.random(in: 0 ..< 1.0)), alpha: CGFloat(1.0))
}
