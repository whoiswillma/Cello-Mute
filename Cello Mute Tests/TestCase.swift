//
//  TestCase.swift
//  Cello Mute Tests
//
//  Created by William Ma on 11/14/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import XCTest

class TestCase: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testSelf() {
        XCTAssertFalse(continueAfterFailure)
    }

}
