//
//  ViewController.swift
//  Polyskel
//
//  Created by andygeers on 11/22/2019.
//  Copyright (c) 2019 andy@geero.net. All rights reserved.
//

import UIKit
import SceneKit
import Euclid
import Polyskel

class ViewController: UIViewController {

    @IBOutlet var sceneView : SCNView?
    
    var scene = SCNScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configure()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure() {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 3, z: 0)
        if #available(iOS 11.0, *) {
            cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        } else {
            // Fallback on earlier versions
        }

        let node = buildRoofGeometry()
        scene.rootNode.addChildNode(node)
        
        sceneView!.scene = scene
                
        sceneView!.autoenablesDefaultLighting = true
        sceneView!.allowsCameraControl = true
        sceneView!.showsStatistics = true
        sceneView!.backgroundColor = .white
    }
    
    func buildRoofGeometry() -> SCNNode {
        let squarePoly = square()!
        
        let skeleton = Polyskel.skeletonize(polygon: squarePoly, holes: nil)
        let roofPolygons = skeleton.generateRoofPolygons()
        NSLog("Returned %d roof poly(s)", roofPolygons.count)
        let mesh = Mesh(roofPolygons)
        
        let geometry = SCNGeometry(mesh) {
            let material = SCNMaterial()
            material.diffuse.contents = $0 as? UIColor
            return material
        }
        
        return SCNNode(geometry: geometry)
    }
    
    func buildSkeletonGeometry() -> SCNNode {
        let squarePoly = square()!
        var mesh = Mesh([squarePoly])
        
        let skeleton = Polyskel.skeletonize(polygon: squarePoly, holes: nil)
        NSLog("Found %d node(s)", skeleton.subtrees.count)
        for arc in skeleton.subtrees {
            NSLog(" - %d sink(s)", arc.sinks.count)
            for sink in arc.sinks {
                NSLog("From %f,%f,%f to %f,%f,%f", arc.source.x, arc.source.y, arc.source.z, sink.x, sink.y, sink.z)
                let lineMesh = meshFromLineSegment(LineSegment(arc.source, sink))
                if (lineMesh != nil) {
                    mesh = mesh.merge(lineMesh!)
                }
            }
        }
        
        let geometry = SCNGeometry(mesh) {
            let material = SCNMaterial()
            material.diffuse.contents = $0 as? UIColor
            return material
        }
        
        return SCNNode(geometry: geometry)
    }
    
    func meshFromLineSegment(_ lineSegment: LineSegment) -> Mesh? {
        let offset = Vector(0.01, 0.01, 0)
        let vectors = [lineSegment.point1, lineSegment.point2, lineSegment.point2 + offset, lineSegment.point1 + offset]
        let outline = Path(vectors.map { PathPoint($0, isCurved: false) })
        let polygon = Polygon(shape: outline.closed(), material: UIColor.blue)
        if (polygon != nil) {
            return Mesh([polygon!, polygon!.inverted()])
        } else {
            return nil
        }
    }

    func square() -> Polygon? {
        let p1 = Vector(0, 0, 0)
        let p2 = Vector(0, 0, 2)
        let p3 = Vector(2, 0, 2)
        let p4 = Vector(2, 0, 0.8)
        let p5 = Vector(1, 0, 0.8)
        let p6 = Vector(1, 0, 0)
        let p7 = Vector(0, 0, 0)
        
        let outline = Path([
            PathPoint(p1, isCurved: false),
            PathPoint(p2, isCurved: false),
            PathPoint(p3, isCurved: false),
            PathPoint(p4, isCurved: false),
            PathPoint(p5, isCurved: false),
            PathPoint(p6, isCurved: false),
            PathPoint(p7, isCurved: false)
        ]).closed()
        
        return Polygon(shape: outline, material: UIColor.red)
    }
}

