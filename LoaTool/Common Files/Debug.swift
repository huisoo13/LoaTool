//
//  Debug.swift
//  Sample
//
//  Created by Trading Taijoo on 2021/05/31.
//

import Foundation

// Debug print
let isDebug: Bool = true
public func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    if isDebug {
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print("[LOATOOL][\(DateManager.shared.currentDate())] " + output, terminator: terminator)
    }
    #endif
}

// Index out of range 제거
extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

