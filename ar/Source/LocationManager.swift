//
//  LocationManager.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation)
    func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationDirection)
    func locationManagerDidDetermineState(_ locationManager: LocationManager, state: CLRegionState, region: CLRegion)
    func locationManagerDidEnterRegion(_ locationManager: LocationManager, region: CLRegion)
    func locationManagerDidExitRegion(_ locationManager: LocationManager, region: CLRegion)
}

///Handles retrieving the location and heading from CoreLocation
///Does not contain anything related to ARKit or advanced location
class LocationManager: NSObject, CLLocationManagerDelegate {
    weak var delegate: LocationManagerDelegate?
    
    public var locationManager: CLLocationManager?
    
    var currentLocation: CLLocation?
    
    var heading: CLLocationDirection?
    var headingAccuracy: CLLocationDegrees?
    
    var authorizationStatus: CLAuthorizationStatus?
    var monitoringAvailable: Bool = false

    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager!.distanceFilter = kCLDistanceFilterNone
        self.locationManager!.headingFilter = kCLHeadingFilterNone
        self.locationManager!.pausesLocationUpdatesAutomatically = false
        self.locationManager!.delegate = self
        
        self.enableLocationServices() {
            (result: Bool) in
            print("got back: \(result)")
            
            self.authorizationStatus = CLLocationManager.authorizationStatus()
            
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager?.startUpdatingLocation()
                self.locationManager?.startUpdatingHeading()
            }
            
            self.currentLocation = self.locationManager!.location
            
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                self.monitoringAvailable = true
            }
        }
            
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
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            self.delegate?.locationManagerDidUpdateLocation(self, location: location)
        }
        
        self.currentLocation = manager.location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy >= 0 {
            self.heading = newHeading.trueHeading
        } else {
            self.heading = newHeading.magneticHeading
        }
        
        self.headingAccuracy = newHeading.headingAccuracy
        
        self.delegate?.locationManagerDidUpdateHeading(self, heading: self.heading!, accuracy: newHeading.headingAccuracy)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("---------- REGION ENTERED ----------")
        self.delegate?.locationManagerDidEnterRegion(self, region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("-------------------- exited region ------------------------")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        self.delegate?.locationManagerDidDetermineState(self, state: state, region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}

