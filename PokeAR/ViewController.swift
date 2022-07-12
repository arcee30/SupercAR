//
//  ViewController.swift
//  PokeAR
//
//  Created by Arshaan Sayed on 7/8/22.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var player: AVAudioPlayer?
    var planeNode : SCNNode? = nil
    var currentAngleY: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
            panRecognizer.delegate = self
            sceneView.addGestureRecognizer(panRecognizer)
    }
    
    @objc func panGesture(sender: UIPanGestureRecognizer){
           let translation = sender.translation(in: sender.view)
           print(translation.x, translation.y)
        
        let hitTestResultNode = self.sceneView.hitTest(translation, options: nil).first?.node
        print(hitTestResultNode)
       }
   

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        if let audi = ARReferenceImage.referenceImages(inGroupNamed: "Audi", bundle: Bundle.main) {
            configuration.detectionImages = audi
            configuration.maximumNumberOfTrackedImages = 2
            print("Image added!")
        }
        let audi = ARReferenceImage.referenceImages(inGroupNamed: "Audi", bundle: Bundle.main)
       
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
  
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        //1. Get The Current Touch Location
        guard let currentTouchLocation = touches.first?.location(in: self.sceneView),

            //2. Get The Tapped Node From An SCNHitTest
            let hitTestResultNode = self.sceneView.hitTest(currentTouchLocation, options: nil).first?.node else { return }
        
        

        if hitTestResultNode.parent?.parent?.name! == "audi" {
            playSound("audiEngine")
            let audi = (hitTestResultNode.parent?.parent)!
            spin((hitTestResultNode.parent?.parent)!)
        


            
        }
        
        if hitTestResultNode.parent?.parent?.name! == "mercedes" {
            playSound("mercedesEngine")
            spin((hitTestResultNode.parent?.parent)!)
        }
    
        //3. Loop Through The ChildNodes
        for node in hitTestResultNode.childNodes{

            //4. If The Node Has A Name Then Print It Out
            if let validName = node.name{
                 print("Node\(validName) Is A Child Node Of \(hitTestResultNode)")
              //  print(type(of: node.name))
              //  print(node.name!)
            }
         
                
//                var charIndex = 0
//                for i in 0...5 {
//                            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
//                                node.rotation += .pi/4
//                            }
//                            charIndex += 1
//                        }
            

        }

    }
    
    func spin(_ deng: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * Float.pi/2
        let randomY = Float(arc4random_uniform(4) + 1) * Float.pi/2
        let randomZ = Float(arc4random_uniform(4) + 1) * Float.pi/2
        
        deng.runAction(SCNAction.rotateBy(
            x: 0,
            y:CGFloat(randomY * 2),
            z: 0,
            duration: 2))
    }
    
    
   
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     var mercedesNode = SCNNode()
        var audiNode = SCNNode()
        
        DispatchQueue.main.async {
         
        if let imageAnchor = anchor as? ARImageAnchor {
            
            if imageAnchor.referenceImage.name! == "mercedes2019coupe" {
                let mercedesScene = SCNScene(named: "art.scnassets/mercedesAR.scn")!
                mercedesNode = mercedesScene.rootNode.childNodes.first!
                mercedesNode.eulerAngles.y = -.pi/2
            
                node.addChildNode(mercedesNode)
                func panGesture(sender: UIPanGestureRecognizer) {
                    let translation = sender.translation(in: sender.view!)

                    let pan_x = Float(translation.x)
                    let pan_y = Float(-translation.y)
                    let anglePan = sqrt(pow(pan_x,2)+pow(pan_y,2))*(Float)(M_PI)/180.0
                    var rotVector = SCNVector4()

                    rotVector.x = -pan_y
                    rotVector.y = pan_x
                    rotVector.z = 0
                    rotVector.w = anglePan

                    // apply to your model container node
                    mercedesNode.rotation = rotVector

                    if(sender.state == UIGestureRecognizer.State.ended) {
                        let currentPivot = mercedesNode.pivot
                        let changePivot = SCNMatrix4Invert(mercedesNode.transform)
                        mercedesNode.pivot = SCNMatrix4Mult(changePivot, currentPivot)
                        mercedesNode.transform = SCNMatrix4Identity
                    }
                }
                
              
          
            }
            if imageAnchor.referenceImage.name! == "audir8" {
            let audiScene = SCNScene(named: "art.scnassets/audi.scn")!
            
            audiNode = audiScene.rootNode.childNodes.first!
                audiNode.eulerAngles.y = -.pi/2

       
            node.addChildNode(audiNode)
            
            }
        }
        }
        return node
    }
    

    
    
    func playSound(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)


            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}



