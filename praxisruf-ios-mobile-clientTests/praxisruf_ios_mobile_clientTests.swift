//
//  praxisruf_ios_mobile_clientTests.swift
//  praxisruf-ios-mobile-clientTests
//
//  Created by user on 17.10.21.
//

import XCTest
@testable import praxisruf_ios_mobile_client

class praxisruf_ios_mobile_clientTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let string = "{\"sender\":\"3a2ad734-b4f0-413c-8cf1-03346ba9bd00\",\"recipient\":\"5DF86410-ED89-4840-96D0-6353A235CCCA\",\"type\":\"UNAVAILABLE\",\"payload\":\"\"}"
        let sig = try JSONDecoder().decode(Signal.self, from: string.data(using: .utf8)!)
        print(sig)
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
