//
//  ViewController.swift
//  ar
//
//  Created by Eamon White on 1/27/18.
//  Copyright © 2018 EamonWhite. All rights reserved.
//

import UIKit
import CoreLocation

class LoginController: UIViewController, CLLocationManagerDelegate {
    
    var ref: DatabaseReference!
    var locationManager: CLLocationManager!
    var loginButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        loginButton.titleLabel?.text = "Login"
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        loginButton.backgroundColor = .blue
        view.addSubview(loginButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginButton.frame = CGRect(x: 0, y: view.bounds.size.height - 64, width: view.bounds.size.width, height: 64)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @objc func login() {
        UIApplication.shared.keyWindow?.rootViewController = ViewController()
    }
}

