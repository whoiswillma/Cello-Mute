//
//  CircularBuffer.swift
//  Cello Mute
//
//  Created by William Ma on 11/14/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import Foundation

class CircularBuffer<T> {

    private(set) var buffer: [T?]
    private var index: Int

    var count: Int {
        var count = 0
        for value in buffer {
            if value != nil {
                count += 1
            }
        }
        return count
    }

    init(size: Int) {
        buffer = [T?](repeating: nil, count: size)
        index = 0
    }

    func add(_ value: T) {
        buffer[index] = value
        index = (index + 1) % buffer.count
    }

    func replaceAll(_ value: T) {
        buffer = [T?](repeating: value, count: buffer.count)
    }

    func removeAll() {
        buffer = [T?](repeating: nil, count: buffer.count)
    }

}
