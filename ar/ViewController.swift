//
//  ViewController.swift
//  ar
//
//  Created by Eamon White on 1/27/18.
//  Copyright © 2018 EamonWhite. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import FirebaseDatabase
import UserNotifications

class ViewController: UIViewController, SceneLocationViewDelegate {
    
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        //print("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        //print("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
        print("did confirm location of node -------------- \(node.name!)")
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        //print("sceneLocationViewDidUpdateLocationAndScaleOfLocationNode ------------ \(locationNode.childNodes)")
    }

    //@IBOutlet var sceneView: ARSCNView!
    var sceneLocationView: SceneLocationView!
    var ref: DatabaseReference!
    var counter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        //sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        self.sceneLocationView = SceneLocationView()
        self.sceneLocationView.locationDelegate = self
        //self.sceneLocationView.antialiasingMode = .multisampling4X
        
        self.counter = UILabel()
        self.counter.layer.masksToBounds = true
        self.counter.layer.borderWidth = 2
        self.counter.layer.borderColor = UIColor(red: 36.0/255.0, green: 41.0/255.0, blue: 102.0/255.0, alpha: 1.0).cgColor
        self.counter.backgroundColor = UIColor(red: 175.0/255.0, green: 175.0/255.0, blue: 175.0/255.0, alpha: 1.0)
        self.counter.textColor = UIColor(red: 200.0/255.0, green: 34.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        self.counter.text = "0"
        self.counter.textAlignment = .center
        self.counter.font = UIFont(name: "Helvetica-Bold", size: 48)
        
        self.placeShips { (success) in
            self.view.addSubview(self.sceneLocationView)
            self.view.insertSubview(self.counter, aboveSubview: self.sceneLocationView)
        }
    }
    
    func placeShips(completionHandler:@escaping (Bool) -> ()) {
        ref = Database.database().reference()
        ref.child("coords").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get coord value
            let value = snapshot.value as? NSDictionary
            print(value?.description ?? "--------- default value -------")
            print(snapshot.key)
            
            for (key, val) in value! {
                print("Key: \(key) - Value: \(val)")
                
                let valu = val as! NSDictionary
                
                let lat = valu["latitude"]
                let lon = valu["longitude"]
                let alt = valu["altitude"] as! NSNumber
                
                print("\(String(describing: lat)) + \(String(describing: lon)) + \(String(describing: alt))")
                
                let coordinate = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: lon as! CLLocationDegrees)
                
                if key as! String == "ship0" {
                    self.monitorRegionAtLocation(center: coordinate, identifier: key as! String)
                }
                
                let location = CLLocation(coordinate: coordinate, altitude: CLLocationDistance(truncating: alt))
                
                let scene = SCNScene(named: "art.scnassets/ship.scn")!
                let annotationNode = LocationAnnotationNode(location: location, scene: scene, key: key as! String)
                annotationNode.scaleRelativeToDistance = true
                //annotationNode.continuallyAdjustNodePositionWhenWithinRange = false
                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
            }
            
            completionHandler(true)
        }) { (error) in
            print(error.localizedDescription)
            completionHandler(false)
        }
    }
    
    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String ) {
        // Make sure the app is authorized.
        print("in monitorregionatlocation -----------------------")
        print(sceneLocationView.locationManager.authorizationStatus!)
        if sceneLocationView.locationManager.authorizationStatus == CLAuthorizationStatus.authorizedAlways {
            print("in authorized always -----------------------")

            // Make sure region monitoring is supported.
            if sceneLocationView.locationManager.monitoringAvailable {
                print("in monitoring available -----------------------")

                // Register the region.
                let maxDistance = 300.0
                let region = CLCircularRegion(center: center,
                                              radius: maxDistance, identifier: identifier)
                region.notifyOnEntry = true
                region.notifyOnExit = false
                
                _ = UNLocationNotificationTrigger(region: region, repeats: false)
                
                print("\(region.description) ----------- region description")
                
                sceneLocationView.locationManager.locationManager?.startMonitoring(for: region)
                sceneLocationView.locationManager.locationManager?.requestState(for: region)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        //sceneView.session.pause()
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
        
        if UIApplication.shared.statusBarOrientation == .portrait {
            counter.frame = CGRect(
                x: self.view.frame.size.width - 0.25 * self.view.frame.size.width - 10,
                y: 30,
                width: 0.25 * self.view.frame.size.width,
                height: 0.25 * self.view.frame.size.width)
        }
        else {
            counter.frame = CGRect(
                x: self.view.frame.size.width - (1/6) * self.view.frame.size.width - 10,
                y: 10,
                width: (1/6) * self.view.frame.size.width,
                height: (1/6) * self.view.frame.size.width)
        }
        
        self.counter.layer.cornerRadius = 0.5 * self.counter.frame.size.width
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
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
