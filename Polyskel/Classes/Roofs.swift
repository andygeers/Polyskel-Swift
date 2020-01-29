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
        
        var textureOffset = 0.0
        
        // Iterate over each edge in the original polygon
        for edge in self.polygon.edges {
            // Find all nodes in the skeleton that are related to this edge
            let sorted = nodesFor(edge: edge, angle: angle)
            
            let colour = randomColour()
            
            var lastNode : Vector? = nil
            for node in sorted + [edge.start] {
                if (lastNode != nil) {
                    let points = [edge.end, lastNode!, node]
                    let vertices = points.map { Vertex($0, self.polygon.plane.normal, textureCoordinate(point: $0, edge: edge)) }
                    let poly = Polygon(vertices, material: colour)
                    if (poly != nil) {
                        if let combined = polygons.last?.merge(poly!) {
                            polygons[polygons.count - 1] = combined
                        } else {
                            polygons.append(poly!)
                        }
                    }
                }
                
                lastNode = node
            }
            
            textureOffset += edge.length
        }

        return polygons
    }
    
}
extension StraightSkeleton {
    func textureCoordinate(point: Vector, edge: LineSegment) -> Vector {
        // Use the edge as the "X" axis
        let direction = edge.direction
        let axis = Vector(abs(direction.x), abs(direction.y), abs(direction.z))
        let x = point.dot(axis)
        // Use the distance from the edge as the "Y" axis
        let y = edge.line.distance(to: point)
        
        return Vector(x, y, 0.0)
    }
    
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
