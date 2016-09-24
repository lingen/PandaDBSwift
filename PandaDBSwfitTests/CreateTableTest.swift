//
//  CreateTableTest.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/9/24.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import XCTest
@testable import PandaDBSwfit

class CreateTableTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testCreateTable1()  {
        let name:Column = Column(name: "name")
        let age:Column = Column(name: "age", type: .ColumnInt)
        let weight:Column = Column(name: "weight", type: .ColumnReal)
        let data:Column = Column(name: "data", type: .ColumnBlob)
        let table:Table = Table(tableName: "user_2", columns: [name,age,weight,data])
        let createTableSQL = table.createTableSQL()
        print("创建表的语句为:\(createTableSQL)")
    }
    
}
