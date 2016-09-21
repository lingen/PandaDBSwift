//
//  PandaDBSwfitTests.swift
//  PandaDBSwfitTests
//
//  Created by lingen on 9/21/16.
//  Copyright © 2016 lingen.liu. All rights reserved.
//

import XCTest
@testable import PandaDBSwfit

class PandaDBSwfitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let dbManager:OPDSQLiteManager = OPDSQLiteManager.sharedInstance()
        
        dbManager.openDB(dbName: "abc.sqlite")
        
        let sql:String = "create table if not exists students_2 (id integer primary key autoincrement,name text,stuId integer)"
        
        let success = dbManager.execSQL(sql: sql)
        
        print(success)
        
        dbManager.close()
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
