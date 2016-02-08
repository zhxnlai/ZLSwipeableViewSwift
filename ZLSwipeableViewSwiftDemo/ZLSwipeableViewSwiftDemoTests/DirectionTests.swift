//
//  DirectionTests.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 10/22/15.
//  Copyright © 2015 Zhixuan Lai. All rights reserved.
//

import XCTest
import ZLSwipeableViewSwiftDemo

class DirectionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFromPoint() {
        XCTAssertEqual(Direction.fromPoint(CGPoint(x: 1, y: 0)), Direction.Right)
        XCTAssertEqual(Direction.fromPoint(CGPoint(x: -1, y: 0)), Direction.Left)
        XCTAssertEqual(Direction.fromPoint(CGPoint(x: 0, y: -1)), Direction.Up)
        XCTAssertEqual(Direction.fromPoint(CGPoint(x: 0, y: 1)), Direction.Down)
        XCTAssertEqual(Direction.fromPoint(CGPoint(x: 0, y: 0)), Direction.None)
    }

}
