//
//  main_clientUITests.swift
//  praxisruf-ios-mobile-clientUITests
//
//  Created by J. Villing on 27.02.22.
//

import XCTest

import Foundation

class main_clientTests: XCTestCase {
    
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
    
    func testHome() {
        app.buttons["Home"].tap()
        
        app.staticTexts["Gegensprechanlage"].tap() // Workaround to make test wait for element to be visible
        XCTAssert(app.staticTexts["Gegensprechanlage"].exists)
        XCTAssert(app.staticTexts["Alle Zimmer"].exists)
        XCTAssert(app.staticTexts["Steri"].exists)
        
        XCTAssert(app.staticTexts["Benachrichtigungen"].exists)
        XCTAssert(app.staticTexts["Alarm"].exists)
    }
    
    func testInbox() {
        app.buttons["Inbox"].tap()
        
        XCTAssert(app.staticTexts["Keine Meldungen"].exists)
        XCTAssert(app.images.element.exists)
    }
    
    func testSettings() {
        app.buttons["Settings"].tap()
        
        XCTAssert(app.buttons["Abmelden"].exists)
        XCTAssert(app.staticTexts["Benutzer"].exists)
        XCTAssert(app.staticTexts["Zimmer"].exists)
    }
}
