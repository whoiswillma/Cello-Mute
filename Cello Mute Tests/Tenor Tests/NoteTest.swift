//
//  NoteTest.swift
//  Cello Mute Tests
//
//  Created by William Ma on 11/14/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

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

    func testSemitonesTo() {
        let middleC = Note(name: .c(.natural), octave: 4)
        XCTAssertEqual(0, middleC.semitones(to: middleC))

        let c5 = Note(name: .c(.natural), octave: 5)
        XCTAssertEqual(12, middleC.semitones(to: c5))
        XCTAssertEqual(-12, c5.semitones(to: middleC))

        let a4 = Note(name: .a(.natural), octave: 4)
        XCTAssertEqual(9, middleC.semitones(to: a4))
        XCTAssertEqual(-9, a4.semitones(to: middleC))
    }

}
