//
//  ViewController.swift
//  ar
//
//  Created by Eamon White on 1/27/18.
//  Copyright © 2018 EamonWhite. All rights reserved.
//

import UIKit
import CoreLocation
import GeoFire
import GooglePlaces

@objc(Place)
class Place : NSObject {
    var placeID = ""
    var name = ""
}

class LoginController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        guard let place = self.places[row] as? Place else {
            if let placeNext = self.places[row] as? GMSPlace {
                cell.textLabel?.text = placeNext.name
            }
            else {
                cell.textLabel?.text = "Default"
            }
            
            return cell
        }
        
        cell.textLabel?.text = place.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let row = indexPath.row
        print(self.places[row])
        
        let viewController = ViewController()
        
        if let place = self.places[row] as? GMSPlace {
            let id = place.placeID
            viewController.text = id
        }
        else {
            if let place = self.places[row] as? Place {
                let id = place.placeID
                viewController.text = id
            }
        }
        
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    var ref: DatabaseReference!
    var locationManager: CLLocationManager!
    var placesClient: GMSPlacesClient!
    var places: Array<Any> = []
    let textCellIdentifier = "MyCell"
    
    var tableView: UITableView!
    //var addressLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.enableLocationServices() {
            (result: Bool) in
            print("got back: \(result)")
        }
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        self.placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                for place in placeLikelihoodList.likelihoods {
                    for type in place.place.types {
                        if type == "restaurant" {
                            print(place.place.name)
                            self.places.append(place.place)
                            break
                        }
                    }
                }
                
                let home = Place()
                home.placeID = "ChIJpd7tz5B_44kRfvSIyNDxpMo"
                home.name = "home"
                
                self.places.append(home)
                
                self.tableView.reloadData()
            }
        })
        
        view.addSubview(tableView)
    }
    
    func enableLocationServices(completion: (_ result: Bool) -> Void) {
        print("in enableLocationServices -----------------")
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request always auth
            self.locationManager?.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            //disableMyLocationBasedFeatures()
            print("in denied")
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            //enableMyWhenInUseFeatures()
            print("in authorizedWhenInUse")
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            //enableMyAlwaysFeatures()
            print("in authorizedAlways")
            break
        }
        
        completion(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: view.bounds.size.width - (view.bounds.size.width - 64), y: view.bounds.size.height - (view.bounds.size.height - 192), width: view.bounds.size.width - 128, height: 300)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @objc func login() {
        UIApplication.shared.keyWindow?.rootViewController = ViewController()
    }
}

