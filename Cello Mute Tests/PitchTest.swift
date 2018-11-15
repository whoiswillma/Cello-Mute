//
//  PitchTest.swift
//  Cello Mute Tests
//
//  Created by William Ma on 11/14/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

@testable import Cello_Mute
import XCTest

class PitchTest: TestCase {

    func testFrequencyInit() {
        XCTAssertEqual(Pitch(frequency: 220), Pitch(octave: 3, semitone: 9, cents: 0))
        XCTAssertEqual(Pitch(frequency: 440), Pitch(octave: 4, semitone: 9, cents: 0))
        XCTAssertEqual(Pitch(frequency: 880), Pitch(octave: 5, semitone: 9, cents: 0))

        XCTAssertEqual(Pitch(frequency: 493.88), Pitch(octave: 4, semitone: 11, cents: 0))
        XCTAssertEqual(Pitch(frequency: 506.88), Pitch(octave: 4, semitone: 11, cents: 45))
        XCTAssertEqual(Pitch(frequency: 509.82), Pitch(octave: 5, semitone: 0, cents: -45))

        XCTAssertEqual(Pitch(frequency: 554.37), Pitch(octave: 5, semitone: 1, cents: 0))
        XCTAssertEqual(Pitch(frequency: 123.47), Pitch(octave: 2, semitone: 11, cents: 0))
        XCTAssertEqual(Pitch(frequency: 5587.65), Pitch(octave: 8, semitone: 5, cents: 0))

        XCTAssertEqual(Pitch(frequency: 441.01), Pitch(octave: 4, semitone: 9, cents: 4))
        XCTAssertEqual(Pitch(frequency: 325.27), Pitch(octave: 4, semitone: 4, cents: -23))
        XCTAssertEqual(Pitch(frequency: 1704.96), Pitch(octave: 6, semitone: 8, cents: 45))

        XCTAssertNil(Pitch(frequency: -25))
        XCTAssertNil(Pitch(frequency: 0))
    }

    func testOctaveSemitoneCents() {

        func testPitch(octave: Int, semitone: Int, cents: Int) {
            let pitch = Pitch(octave: octave, semitone: semitone, cents: cents)!
            XCTAssertEqual(pitch.octave, octave)
            XCTAssertEqual(pitch.semitone, semitone)
            XCTAssertEqual(pitch.cents, cents)
        }

        testPitch(octave: 4, semitone: 9, cents: 0)

        for cents in 1...49 {
            testPitch(octave: 0, semitone: 0, cents: cents)
        }

        for semitone in 1...11 {
            for cents in -50...49 {
                testPitch(octave: 0, semitone: semitone, cents: cents)
            }
        }

        for octave in 1...100 {
            for semitone in 0...11 {
                for cents in -50...49 {
                    testPitch(octave: octave, semitone: semitone, cents: cents)
                }
            }
        }
    }

    func testClosestNote() {
        XCTAssertEqual(Pitch(frequency: 220)?.closestNote(using: .sharps), Note(.a(.natural), 3))
        XCTAssertEqual(Pitch(frequency: 440)?.closestNote(using: .sharps), Note(.a(.natural), 4))
        XCTAssertEqual(Pitch(frequency: 880)?.closestNote(using: .sharps), Note(.a(.natural), 5))
    }

}
