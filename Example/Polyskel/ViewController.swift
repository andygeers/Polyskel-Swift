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
        Polyskel.debugLog = true
        
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
        
        let skeleton = Polyskel.skeletonize(polygon: squarePoly, holes: nil, isGabled: { _ in return true })
        let roofPolygons = skeleton.generateRoofPolygons(angle: Double.pi / 4)
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
        
        let skeleton = Polyskel.skeletonize(polygon: squarePoly, holes: nil, isGabled: { _ in return true })
        NSLog("Found %d node(s)", skeleton.subtrees.count)
        for arc in skeleton.subtrees {
            NSLog(" - %d sink(s)", arc.sinks.count)
            for sink in arc.sinks {
                NSLog("From %f,%f,%f to %f,%f,%f", arc.source.x, arc.source.y, arc.source.z, sink.x, sink.y, sink.z)
                let lineMesh = meshFromLineSegment(LineSegment(arc.source, sink)!)
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
        let vectors = [lineSegment.start, lineSegment.end, lineSegment.end + offset, lineSegment.start + offset]
        let outline = Path(vectors.map { PathPoint($0, isCurved: false) })
        let polygon = Euclid.Polygon(shape: outline.closed(), material: UIColor.blue)
        if (polygon != nil) {
            return Mesh([polygon!, polygon!.inverted()])
        } else {
            return nil
        }
    }

    func square() -> Euclid.Polygon? {
        let points = [
            Vector(-0.01,0.00,0.04),
            Vector(-0.70,0.00,0.04),
            Vector(-0.70,0.00,-0.31),
            Vector(0.53,0.00,-0.31),
            Vector(0.53,0.00,-0.92),
            Vector(-0.98,0.00,-0.92), // corner starts
            Vector(-0.98,0.00,-0.70), // corner middle
            Vector(-1.52,0.00,-0.70), // corner ends
            Vector(-1.52,0.00,0.84),
            Vector(-1.05,0.00,0.84),
            Vector(-0.01,0.00,0.84),
            Vector(-0.01,0.00,0.04)
        ]
        
        let outline = Path(points.map { PathPoint($0, isCurved: false) }).closed()
        
        return Euclid.Polygon(shape: outline, material: UIColor.red)
    }
}

