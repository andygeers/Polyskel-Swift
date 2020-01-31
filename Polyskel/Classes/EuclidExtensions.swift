//
//  EuclidExtensions.swift
//  Euclid
//
//  Created by Andy Geers on 29/11/2019.
//

import Euclid

// Tolerance used for calculating approximate equality
let epsilon = 1e-6

internal extension Vector {
    // Approximate equality
    func isEqual(to other: Vector, withPrecision p: Double = epsilon) -> Bool {
        return abs(x - other.x) < p && abs(y - other.y) < p && abs(z - other.z) < p
    }
}

public extension Plane {
    
    func intersectionWith(_ p: Plane) -> Line? {
        if (self.normal.isEqual(to: p.normal)) {
            // Planes do not intersect
            return nil;
        }
        
        let direction = self.normal.cross(p.normal)
        
        guard let point = self.solveSimultaneousEquationsWith(p) else { return nil; }
        
        return Line(origin: point, direction: direction)
    }
    
}

internal extension Plane {
    
    func solveSimultaneousEquationsWith(_ p2: Plane) -> Vector? {
        // Try all the permutations of the equations we could solve until we find a solvable combination
        let vars1 = [self.normal.x, self.normal.y, self.normal.z]
        let vars2 = [p2.normal.x, p2.normal.y, p2.normal.z]
        
        for k1 in 0...2 {
            for k2 in 0...2 {
                if (k2 == k1) {
                    continue
                }
                for k3 in 0...2 {
                    if ((k3 == k1) || (k3 == k2)) {
                        continue
                    }
                
                    let vv1 = Vector(vars1[k1], vars1[k2], vars1[k3])
                    let vv2 = Vector(vars2[k1], vars2[k2], vars2[k3])
                    let point = Plane.performGaussianElimination(v1: vv1, w1: self.w, v2: vv2, w2: p2.w)
                    if (point != nil) {
                        let pointVars = [point!.x, point!.y, point!.z]
                        
                        // Rotate the variables back in to their proper place
                        return Vector(pointVars[k1], pointVars[k2], pointVars[k3])
                    }
                }
            }
        }
        
        return nil;
    }
    
    static func performGaussianElimination(v1: Vector, w1: Double, v2: Vector, w2: Double) -> Vector? {
        // Solve simultaneous equations using Gaussian elimination
        // http://mathsfirst.massey.ac.nz/Algebra/SystemsofLinEq/EMeth.htm
        
        if (v1.x == 0) {
            return nil;
        }
        
        // Assume z = 0 always
        
        // Multiply the two equations until they have an equal leading coefficient
        let n1 = v1 * v2.x
        let n2 = v2 * v1.x
        let ww1 = w1 * v2.x
        let ww2 = w2 * v1.x
        
        // Subtract the second from the first
        let diff = n1 - n2
        let wdiff = ww1 - ww2
        
        // Solve this new equation for y:
        // diff.y * y = wdiff
        if (diff.y == 0) {
            return nil;
        }
        let y = wdiff / diff.y
        
        // Substitute this back in to the first equation
        // self.normal.x * x + self.normal.y * y = self.w
        // self.normal.x * x = self.w - self.normal.y * y
        // x = (self.w - self.normal.y * y) / self.normal.x
        let x = (w1 - v1.y * y) / v1.x
        
        return Vector(x, y, 0)
    }
    
}

public extension Vector {
    var description : String {
        return String(format: "%.2f,%.2f,%.2f", self.x, self.y, self.z)
    }
}

public extension LineSegment {
    var description : String {
        return String(format: "LineSegment(<%@> to <%@>)", self.start.description, self.end.description)                
    }
}

public extension Ray {
    var description : String {
        return String(format: "Ray(%@ + u<%@>)", origin.description, direction.description)
    }
}
