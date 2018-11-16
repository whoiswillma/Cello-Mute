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

    var absoluteSize: Int {
        get {
            return buffer.count
        }
        set {
            var newBuffer = [T?](repeating: nil, count: count)
            if count >= buffer.count {
                for (i, value) in buffer.enumerated() {
                    newBuffer[i] = value
                }
            } else {
                for i in 0..<count {
                    newBuffer[i] = buffer[i]
                }
                index %= count
            }
        }
    }

    var count: Int {
        var count = 0
        for value in buffer {
            if value != nil {
                count += 1
            }
        }
        return count
    }

    var isFilled: Bool {
        return count == buffer.count
    } 

    var isEmpty: Bool {
        return count == 0
    }

    init(absoluteSize: Int) {
        buffer = [T?](repeating: nil, count: absoluteSize)
        index = 0
    }

    func add(_ value: T) {
        buffer[index] = value
        index = (index + 1) % buffer.count
    }

    func fill(_ value: T) {
        buffer = [T?](repeating: value, count: buffer.count)
    }

    func clear() {
        buffer = [T?](repeating: nil, count: buffer.count)
    }

}
