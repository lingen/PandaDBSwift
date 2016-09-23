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
        
//        let sql:String = "insert into students_2 (name,stuId) values (:name,:stuId)"
//        
//        
//        
//        let params:Dictionary<String,Any> = ["name":"aaa","stuId":"123"]
        
        let sql:String = "select * from students_2 where name = :name"
        
        let params:Dictionary<String,Any> = ["name":"aaa"]
        
        let success = dbManager.executeQuery(sql: sql,params: params)
        
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
