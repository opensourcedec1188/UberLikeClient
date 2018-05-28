//
//  EgoUITests.swift
//  EgoUITests
//
//  Created by MacBookPro on 3/21/17.
//  Copyright © 2017 Amer. All rights reserved.
//

import XCTest

class EgoUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEnterMobile() {
        
        
        app = XCUIApplication()
        app.buttons["signUpBtn"].tap()
        let textField = app.textFields["phoneTextField"]
        textField.tap()
        textField.typeText("")
        XCTAssertTrue(textField.value as! String == "", "empty phone number")
        
        //Enter wrong mobile number
        textField.typeText("054")
        app.buttons["enterMobNextBtn"].tap()
        
        //Enter right mobile number
        textField.typeText("")
        textField.typeText("0542133696")
        app.buttons["enterMobNextBtn"].tap()
        
        //Enter first digit  firstDigitTF
        app.textFields["firstDigitTF"].typeText("")
        app.textFields["secondDigitTF"].typeText("")
        app.textFields["thirdDigitTF"].typeText("")
        app.textFields["forthDigitTF"].typeText("")
        
    }
    
    
}
