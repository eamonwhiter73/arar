//
//  arUITests.swift
//  arUITests
//
//  Created by Eamon White on 1/27/18.
//  Copyright © 2018 EamonWhite. All rights reserved.
//

import XCTest

class arUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCUIDevice.shared.orientation = .faceUp
        XCUIDevice.shared.orientation = .portrait
        
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).otherElements.children(matching: .button).element.tap()
        
        let element = app.otherElements.containing(.staticText, identifier:"0").children(matching: .other).element
        
        
        XCTAssert(element.isHittable)
    }
    
}
