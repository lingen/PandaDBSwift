//
//  RepositoryTest.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/9/24.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import XCTest
@testable import PandaDBSwfit

class RepositoryTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRepositoryForTableExists() {
        
        let repository = Repository(dbName: "abc.sqlite", tables: [], version: 1)
        
        let open = repository.open()
        
        if open {
            let exists = repository.tableExists(tableName: "USERS_1")
            print("表是否存在:\(exists)")
        }

    }
    
}
