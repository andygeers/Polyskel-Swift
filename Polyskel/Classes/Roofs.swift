//
//  Roofs.swift
//  Polyskel
//
//  Created by Andy Geers on 29/11/2019.
//

import Euclid

public extension StraightSkeleton {
    
    
    func generateRoofPolygons(angle: Double = Double.pi / 4.0) -> [Euclid.Polygon] {
        return generateRoof(angle: angle).flatMap { $0.1 }
    }
    
    private func vertexNormal(_ position : Vector, planeNormal: Vector) -> Vector {
        // See if this appears to be a gable or not
        if (abs(planeNormal.y) < epsilon) {
            return planeNormal
        } else {
            // See if this is one of the contour nodes or not
            if let contourNode = self.contour.nodes.first(where: { $0.point == position }) {
                if self.bisectorsForVertexNormals {
                    // Return the bisector at this point
                    return contourNode.bisector.direction
                } else {
                    // Return the plane normal but projected on the contour plane
                    return Vector(planeNormal.x, 0.0, planeNormal.z).normalized()
                }
            } else {
                // Point straight up
                return Plane.xz.normal
            }
        }
    }
    
    func generateRoof(angle: Double = Double.pi / 4.0) -> [(ContourEdge, [Euclid.Polygon])] {
        var edgePolygons : [(ContourEdge, [Euclid.Polygon])] = []
        
        // Iterate over each edge in the original polygon
        for edge in self.contour.edges {
            // Find all nodes in the skeleton that are related to this edge
            let sorted = nodesFor(edge: edge.lineSegment, angle: angle)
            
            let colour = randomColour()
            
            var lastNode : Vector? = nil
            var polygons : [Euclid.Polygon] = []
            
            for node in sorted + [edge.start] {
                if (lastNode != nil) {
                    let points = [edge.end, lastNode!, node]
                    let planeNormal : Vector
                    if let plane = Plane(points: points) {
                        planeNormal = plane.normal
                    } else {
                        planeNormal = self.contour.plane.normal
                    }
                    let vertices = points.map { Vertex($0, vertexNormal($0, planeNormal: planeNormal), textureCoordinate(point: $0, edge: edge.lineSegment)) }
                    if let poly = Euclid.Polygon(vertices, material: colour) {
                        if let combined = polygons.last?.merge(poly) {
                            polygons[polygons.count - 1] = combined
                        } else {
                            polygons.append(poly)
                        }
                    }
                }
                
                lastNode = node
            }
            
            edgePolygons.append((edge, polygons))
        }

        return edgePolygons
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
        let polyPlane = self.contour.plane
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
