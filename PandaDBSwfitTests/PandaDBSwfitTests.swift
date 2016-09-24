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
    
    func testCreateTable() {
        
        let dbManager:SQLiteManager = SQLiteManager.sharedInstance()
        
        dbManager.openDB(dbName: "abc.sqlite")
        
        let createTableSQL:String = "create table if not exists users (name text not null, age int )"

        
        let success = dbManager.executeUpdate(sql: createTableSQL)
        
        print(success)
        
        dbManager.close()
    }
    
    func testInsertData() {
        let dbManager:SQLiteManager = SQLiteManager.sharedInstance()
        
        dbManager.openDB(dbName: "abc.sqlite")
        
        let now:Date = Date()
        let begin:TimeInterval = now.timeIntervalSince1970
        
        for index in 1 ... 1000 {
            let insertTableSQL = "insert into users (name,age) values (:name,:age)"
            
            let params:Dictionary<String,Any> = ["age":index,"name":"AAA\(index)"]
            
            let success = dbManager.executeUpdate(sql: insertTableSQL, params: params)
            
            print("插入表数据 :\(success)")
        }
        
        let end = Date().timeIntervalSince1970 - begin
        
        print("非批量情况下的耗时:\(end)")
        dbManager.close()
        
    }
    
    func testBatchInsertData() {
        let dbManager:SQLiteManager = SQLiteManager.sharedInstance()
        
        dbManager.openDB(dbName: "abc.sqlite")
        
        let now:Date = Date()
        let begin:TimeInterval = now.timeIntervalSince1970
        
        dbManager.beginTransaction()
        
        for index in 1 ... 1000 {
            let insertTableSQL = "insert into users (name,age) values (:name,:age)"
            
            let params:Dictionary<String,Any> = ["age":index,"name":"AAA\(index)"]
            
            let success = dbManager.executeUpdate(sql: insertTableSQL, params: params)
            
            print("插入表数据 :\(success)")
        }
        
        dbManager.commit()
        
        let end = Date().timeIntervalSince1970 - begin
        
        print("批量情况下的耗时:\(end)")
        dbManager.close()
        
    }
    
    func testDeleteDatas() {
        let dbManager:SQLiteManager = SQLiteManager.sharedInstance()
        
        dbManager.openDB(dbName: "abc.sqlite")
        
        let createTableSQL:String = "delete from users"
        
        
        let success = dbManager.executeUpdate(sql: createTableSQL)
        
        print(success)
        
        dbManager.close()
    }
    
    func testQuery() {
        let dbManager:SQLiteManager = SQLiteManager.sharedInstance()
        dbManager.openDB(dbName: "abc.sqlite")
        
        
        let querySQL:String = "select * from users"
        
        let results = dbManager.executeQuery(sql: querySQL, params: [:])
        
        print("查询出来的结果是：\(results)")
        dbManager.close()
    }
    
}
