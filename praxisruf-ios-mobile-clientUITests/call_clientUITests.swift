//
//  main_clientUITests.swift
//  praxisruf-ios-mobile-clientUITests
//
//  Created by J. Villing on 27.02.22.
//

import XCTest

import Foundation

class call_clientUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        app.launch()
        app.textFields["Benutzername"].tap()
        app.textFields["Benutzername"].typeText("admin")
        app.secureTextFields.element.tap()
        app.secureTextFields.element.typeText("admin")
        app.buttons["Anmelden"].tap()
        app.staticTexts.element(boundBy: 2).tap()
        app.buttons["Fertig"].tap()
    }

    override func tearDownWithError() throws {
        app.buttons["Settings"].tap()
        app.buttons["Abmelden"].tap()
    }
    
    func testActiveCallView() {
        app.staticTexts["Alle Zimmer"].tap()
        
        XCTAssert(app.staticTexts["Behandlungszimmer 1"].exists)
        XCTAssert(app.staticTexts["Steri"].exists)
        
        XCTAssert(app.buttons.element(boundBy: 0).exists)
        XCTAssert(app.buttons.element(boundBy: 1).exists)
        XCTAssert(app.buttons.element(boundBy: 2).exists)
        
        app.buttons.element(boundBy: 2).tap()
        
    }
    
    
}
