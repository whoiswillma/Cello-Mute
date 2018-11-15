//
//  NoteTest.swift
//  Cello Mute Tests
//
//  Created by William Ma on 11/14/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

@testable import Cello_Mute
import XCTest

class NoteTest: TestCase {

    func testSemitoneArrays() {
        for (i, noteName) in Note.semitonesUsingFlats.enumerated() {
            XCTAssertEqual(i, noteName.semitone)
        }
        
        for (i, noteName) in Note.semitonesUsingSharps.enumerated() {
            XCTAssertEqual(i, noteName.semitone)
        }
    }

}
