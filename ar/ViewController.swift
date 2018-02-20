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
import GeoFire
import GameKit

struct Coords {
    var x: Float = 0.0
    var y: Float = 0.0
    var z: Float = 0.0
}

class ViewController: UIViewController, SceneLocationViewDelegate {
    
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
        self.currentLocation = location
        
        /*print(date.timeIntervalSinceNow)
        
        if (date.timeIntervalSinceNow < -30) {
            date = NSDate.init()
            
            for node in self.sceneLocationView.locationNodes {
                self.sceneLocationView.removeLocationNode(locationNode: node)
            }
            
            print("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
            
            let geoFire = GeoFire(firebaseRef: self.ref.child("location_coord"))
            
            // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
            let circleQuery = geoFire.query(at: location, withRadius: 0.05);
            
            _ = circleQuery.observe(.keyEntered) { (key: String!, location: CLLocation!) in
                print("Key '\(key)' entered the search area and is at location '\(location)'")
                
                self.ref.child("ships_for_locations/" + key).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get coord value
                    let value = snapshot.value as? NSDictionary
                    print(value?.description ?? "--------- default value -------")
                    print(snapshot.key)
                    
                    var lastAlt: NSNumber = 0
                    for (key, val) in value! {
                        print("Key: \(key) - Value: \(val)")
                        
                        guard let valu: NSDictionary = val as? NSDictionary else {
                            return
                        }
                        
                        let coords: NSArray
                        
                        coords = (valu["l"] as? NSArray)!
                        
                        let lat = coords[0] as! NSNumber
                        let lon = coords[1] as! NSNumber
                        let alt = valu["altitude"] != nil ? valu["altitude"] as! NSNumber : lastAlt
                        lastAlt = alt
                        
                        print("\(String(describing: lat)) + \(String(describing: lon)) + \(String(describing: alt))")
                        
                        let coordinate = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: lon as! CLLocationDegrees)
                        
                        let location = CLLocation(coordinate: coordinate, altitude: CLLocationDistance(truncating: alt))
                        
                        let scene = SCNScene(named: "art.scnassets/ship.scn")!
                        let annotationNode = LocationAnnotationNode(location: location, scene: scene, key: key as! String)
                        annotationNode.scaleRelativeToDistance = true
                        //annotationNode.continuallyAdjustNodePositionWhenWithinRange = false
                        annotationNode.name = snapshot.key
                        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                    }
                    
                    //completionHandler(true)
                }) { (error) in
                    print(error.localizedDescription)
                    //completionHandler(false)
                }
            }
            
            _ = circleQuery.observe(.keyExited) { (key: String!, location: CLLocation!) in
                print("Key '\(key)' exited the search area and is at location '\(location)'")
                
                let array = self.sceneLocationView.sceneNode?.childNodes(passingTest: { (node, UnsafeMutablePointer) -> Bool in
                    return node.name == key
                })
                
                for node in array! {
                    self.sceneLocationView.removeLocationNode(locationNode: node as! LocationNode)
                }
            }
        }*/
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        //print("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
        print("did confirm location of node -------------- \(node.name!)")
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        print("\(sceneNode) name name name name name" )
        let random = GKRandomSource()
        let dice3d6 = GKGaussianDistribution(randomSource: random, lowestValue: -3, highestValue: 3)
        var groupArray: Array<SCNAction>
        
        var moveBy: SCNAction
        var coords = Coords()
        
        for node in sceneNode.childNodes {
            var childCount = 0
            print("\(node) nodee")
            for nodeInner in node.childNodes {
                print("\(nodeInner) nodee")
                for nodeInnermost in nodeInner.childNodes {
                    if (nodeInnermost.name?.localizedStandardContains("ship"))! {
                        print("\(nodeInnermost) nodeInnermost")
                        for node2 in nodeInnermost.childNodes {
                            print("\(node2) node2")
                            groupArray = []
                            if (node2.name?.localizedStandardContains("shipMesh") != nil) {
                                let location = self.sceneLocationView.locationOfLocationNode(node as! LocationNode)
                                var miles = degreesToRadians(deg: Float(location.coordinate.latitude)) * 69.172
                                var metersL = 1.60934 * miles * 1000
                                let distance = location.distance(from: self.currentLocation)
                                
                                let latDiff = self.currentLocation.coordinate.latitude - location.coordinate.latitude
                                let lonDiff = self.currentLocation.coordinate.longitude - location.coordinate.longitude
                                
                                nodeInnermost.setWorldTransform(SCNMatrix4MakeTranslation(-Float(latDiff), 0.00, -Float(lonDiff)))
                                
                                // -------------------------------------------------

                                var seqArray: Array<SCNAction> = []
                                // Roll the dice...
                                var x = Double(dice3d6.nextInt())
                                var y = Double(dice3d6.nextInt())
                                var z = Double(dice3d6.nextInt())
                                
                                while (x == 0.0 && y == 0.0 && z == 0.0) {
                                    x = Double(dice3d6.nextInt())
                                    y = Double(dice3d6.nextInt())
                                    z = Double(dice3d6.nextInt())
                                }
                                
                                var xSquared = x * x
                                var ySquared = y * y
                                var zSquared = z * z
                                var togSquared = xSquared + ySquared + zSquared
                                var root = 1.0/(Double(togSquared).squareRoot())
                                x = x * root
                                y = y * root
                                z = z * root
                                
                                coords.x = (Float(x) * Float(drand48() * 0.7))
                                coords.y = (Float(y) * Float(drand48() * 0.7))
                                coords.z = (Float(z) * Float(drand48() * 0.7))
                                
                                print("\(coords.x) + \(coords.y) + \(coords.z) + \(nodeInnermost.worldPosition.x) - \(nodeInnermost.worldPosition.y) - \(nodeInnermost.worldPosition.z) coords before move")
                                
                                moveBy = SCNAction.move(to: SCNVector3(coords.x + nodeInnermost.position.x, coords.y + nodeInnermost.position.y, nodeInnermost.position.z + coords.z), duration: 1)
                                
                                seqArray.append(moveBy)
                                
                                var count = 0
                                while count < 3 {
                                    x = Double(dice3d6.nextInt())
                                    y = Double(dice3d6.nextInt())
                                    z = Double(dice3d6.nextInt())
                                    
                                    xSquared = x * x
                                    ySquared = y * y
                                    zSquared = z * z
                                    togSquared = xSquared + ySquared + zSquared
                                    root = 1.0/(Double(togSquared).squareRoot())
                                    x = x * root
                                    y = y * root
                                    z = z * root
                                    
                                    coords.x = (Float(x) * Float(drand48() * 0.7))
                                    coords.y = (Float(y) * Float(drand48() * 0.7))
                                    coords.z = (Float(z) * Float(drand48() * 0.7))
                                    
                                    moveBy = SCNAction.move(to: SCNVector3(coords.x + nodeInnermost.position.x, coords.y + nodeInnermost.position.y, nodeInnermost.position.z + coords.z), duration: 1)
                                    
                                    seqArray.append(moveBy)
                                    
                                    count+=1
                                }
                                
                                for action in seqArray.reversed() {
                                    seqArray.append(action.reversed())
                                }
                                
                                let seq = SCNAction.repeatForever(SCNAction.sequence(seqArray))
                                nodeInnermost.runAction(seq)
                                
                            }
                            else {
                                let sequence = SCNAction.sequence(groupArray)
                                let animation = SCNAction.repeatForever(sequence)
                                
                                nodeInnermost.runAction(animation)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        //print("sceneLocationViewDidUpdateLocationAndScaleOfLocationNode ------------ \(locationNode.childNodes)")
    }

    //@IBOutlet var sceneView: ARSCNView!
    var sceneLocationView: SceneLocationView!
    var ref: DatabaseReference!
    var counter: UILabel!
    var currentLocation: CLLocation!
    var date: NSDate! = NSDate.init()
    var text: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        //sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        self.ref = Database.database().reference()

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
        
        self.placeShips(key: self.text) { (success) in
            self.view.addSubview(self.sceneLocationView)
            //self.view.insertSubview(self.counter, aboveSubview: self.sceneLocationView)
        }
    }
    
    func degreesToRadians(deg: Float) -> Float {
        return (deg * .pi)/180
    }
    
    func placeShips(key: String, completionHandler:@escaping (Bool) -> ()) {
        self.ref.child("ships_for_locations/" + key).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get coord value
            let value = snapshot.value as? NSDictionary
            print(value?.description ?? "--------- default value -------")
            print(snapshot.key)
            
            var lastAlt: NSNumber = 0
            for (key, val) in value! {
                print("Key: \(key) - Value: \(val)")
                
                guard let valu: NSDictionary = val as? NSDictionary else {
                    return
                }
                
                let coords: NSArray
                
                coords = (valu["l"] as? NSArray)!
                
                let lat = coords[0] as! NSNumber
                let lon = coords[1] as! NSNumber
                let alt = valu["altitude"] != nil ? valu["altitude"] as! NSNumber : lastAlt
                lastAlt = alt
                
                print("\(String(describing: lat)) + \(String(describing: lon)) + \(String(describing: alt))")
                
                let coordinate = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: lon as! CLLocationDegrees)
                
                let location = CLLocation(coordinate: coordinate, altitude: CLLocationDistance(truncating: alt))
                
                let scene = SCNScene(named: "art.scnassets/ship.scn")!
                
                let annotationNode = LocationAnnotationNode(location: location, scene: scene, key: key as! String)
                //annotationNode.scaleRelativeToDistance = true
                //annotationNode.continuallyAdjustNodePositionWhenWithinRange = false
                annotationNode.name = snapshot.key
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
        
        self.ref.removeAllObservers()
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
