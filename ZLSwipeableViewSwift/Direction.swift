//
//  Direction.swift
//  ZLSwipeableViewSwift
//
//  Created by Andrew Breckenridge on 5/17/16.
//  Copyright © 2016 Andrew Breckenridge. All rights reserved.
//

import UIKit

public typealias ZLSwipeableViewDirection = Direction

extension Direction: Equatable {}
public func ==(lhs: Direction, rhs: Direction) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

/**
 *  Swiped direction.
 */
public struct Direction : OptionSet, CustomStringConvertible {
    
    public var rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let none = Direction(rawValue: 0b0000)
    public static let left = Direction(rawValue: 0b0001)
    public static let right = Direction(rawValue: 0b0010)
    public static let up = Direction(rawValue: 0b0100)
    public static let down = Direction(rawValue: 0b1000)
    public static let horizontal: Direction = [left, right]
    public static let vertical: Direction = [up, down]
    public static let all: Direction = [horizontal, vertical]
    
    public static func from(_ point: CGPoint) -> Direction {
        switch (point.x, point.y) {
        case let (x, y) where abs(x) >= abs(y) && x > 0:
            return .right
        case let (x, y) where abs(x) >= abs(y) && x < 0:
            return .left
        case let (x, y) where abs(x) < abs(y) && y < 0:
            return .up
        case let (x, y) where abs(x) < abs(y) && y > 0:
            return .down
        case (_, _):
            return .none
        }
    }
    
    public var description: String {
        switch self {
        case Direction.none:
            return "None"
        case Direction.left:
            return "Left"
        case Direction.right:
            return "Right"
        case Direction.up:
            return "Up"
        case Direction.down:
            return "Down"
        case Direction.horizontal:
            return "Horizontal"
        case Direction.vertical:
            return "Vertical"
        case Direction.all:
            return "All"
        default:
            return "Unknown"
        }
    }
    
}
