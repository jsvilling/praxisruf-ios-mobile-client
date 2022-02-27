//
//  praxisruf_ios_mobile_clientUITests.swift
//  praxisruf-ios-mobile-clientUITests
//
//  Created by J. Villing on 27.02.2022.
//

import XCTest

class loginLogout_clientUITests: XCTestCase {

    func testLaunchPerformance() throws {
        if #available(iOS 15.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    let app = XCUIApplication()
    
    func testFullLoginLogoutCycle() {
        let app = XCUIApplication()
        
        // Launch without saved credentials
        app.launch()

        login(app)
        assertLoginScreen(app)
        
        selectClientConfig(app)
        assertHomeView(app)
        
        // Restart with saved credentials
        app.terminate()
        app.launch()
        
        assertSplashScreen(app)
        assertHomeView(app)
        
        // Logout
        logoutFromHome(app)
        assertLoginScreen(app)
    }
    
    func testLogin() {
        // Given
        // - App is started
        // - No login data is saved / user has logged out
        let app = XCUIApplication()
        app.launch()
        
        login(app)
        assertLoginScreen(app)
        
        selectClientConfig(app)
        assertHomeView(app)
    }
    
    func testStartupWithSavedLogin() {
        // Given
        // - Application has been started before
        // - Test user has logged in before and selected the test config
        let app = XCUIApplication()
        app.launch()
        
        assertSplashScreen(app)
        assertHomeView(app)
    }
    
    func testLogout() {
        // Given
        // - Application is started
        // - User is logged in and config is selected
        let app = XCUIApplication()
        app.launch()
        
        assertSplashScreen(app)
        assertHomeView(app)
        logoutFromHome(app)
        assertLoginScreen(app)
    }

    private func login(_ app: XCUIApplication) {
        app.textFields["Benutzername"].tap()
        app.textFields["Benutzername"].typeText("admin")
        app.secureTextFields.element.tap()
        app.secureTextFields.element.typeText("admin")
        app.buttons["Anmelden"].tap()
    }
    
    private func selectClientConfig(_ app: XCUIApplication) {
        app.staticTexts.element(boundBy: 2).tap()
        app.buttons["Fertig"].tap()
    }
    
    private func logoutFromHome(_ app: XCUIApplication) {
        app.buttons["Settings"].tap()
        app.buttons["Abmelden"].tap()
    }

    private func assertLoginScreen(_ app: XCUIApplication) {
        XCTAssert(app.staticTexts["Wilkommen bei Praxisruf !"].exists)
        app.textFields["Benutzername"].tap() // Workaround to wait for field
        XCTAssert(app.textFields["Benutzername"].exists)
        XCTAssert(app.secureTextFields.element.exists)
        XCTAssert(app.buttons["Anmelden"].exists)
    }
    
    private func assertSplashScreen(_ app: XCUIApplication) {
        XCTAssert(app.staticTexts["Wilkommen bei Praxisruf !"].exists)
    }
    
    private func assertHomeView(_ app: XCUIApplication) {
        app.staticTexts["Gegensprechanlage"].tap() // Workaround to make test wait for element to be visible
        XCTAssert(app.staticTexts["Gegensprechanlage"].exists)
        XCTAssert(app.staticTexts["Alle Zimmer"].exists)
        XCTAssert(app.staticTexts["Steri"].exists)
        
        XCTAssert(app.staticTexts["Benachrichtigungen"].exists)
        XCTAssert(app.staticTexts["Alarm"].exists)
    }

}



