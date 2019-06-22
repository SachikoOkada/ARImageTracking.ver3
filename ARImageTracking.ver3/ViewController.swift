//
//  ViewController.swift
//  ARImageTracking.ver3
//
//  Created by Sachiko OKADA on 2019/06/22.
//  Copyright © 2019 Sachiko. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let hapticGenerator = UINotificationFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources",
                                                                 bundle: nil) else { return }
        configuration.trackingImages = trackImages
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    @objc func tappedModel(_ sender: UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else { return }
        let touchLocation = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        
        // タップ時にオブジェクトがあれば実行
        if !hitResults.isEmpty {
            self.hapticGenerator.notificationOccurred(.success)
    
        }
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        //取得したimageAnchorのサイズで平面を作成
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                             height: imageAnchor.referenceImage.physicalSize.height)
        //見やすいように色を塗ってあげる
        plane.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green:  0, blue: 0, alpha: 0.5)
        let planeNode = SCNNode(geometry: plane)
        
        planeNode.eulerAngles.x = -.pi / 2 //平面はXY軸で作られるのでX軸で奥倒す
        planeNode.renderingOrder = -1
        node.addChildNode(planeNode)
        
        //シーンを作成
        guard let modelScene = SCNScene(named: "art.scnassets/Taunt/Taunt.scn") else { return }
        
        /* シーンから子ノードを取り出して新しいノードに付け替える */
        let modelNode = SCNNode()
        for childNode in modelScene.rootNode.childNodes {
            modelNode.addChildNode(childNode)
        }
        
        let (min, max) = (modelNode.boundingBox)
        let h = max.y - min.y
        let magnification = 0.15 / h
        modelNode.scale = SCNVector3(magnification, magnification, magnification)
        
        modelNode.eulerAngles.x = .pi / 2 //平面にくっついてしまうのでX軸で手前に倒す
        
        
        planeNode.addChildNode(modelNode)
        
        DispatchQueue.main.async {
            self.hapticGenerator.notificationOccurred(.warning)
            
        }
        
    }
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
