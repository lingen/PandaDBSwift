//
//  SQLiteManagerTests.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/9/24.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import XCTest
@testable import PandaDBSwfit

class SQLiteManagerTests: XCTestCase {
    
    let dbName:String = "abc.sqlite"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateTable() {
        
        let dbManager:SQLiteManager = SQLiteManager.createInstance(dbName: dbName)
        
        let success = dbManager.open()
        
        if success {
            let createTableSQL:String = "create table if not exists users (name text not null, age int,weight real,info BLOB)"
            
            
            let success = dbManager.executeUpdate(sql: createTableSQL)
            
            print(success)
            
            dbManager.close()
        }
        else{
            print("数据库打开失败")
        }
    }
    
    func testInsertData() {
        let dbManager:SQLiteManager = SQLiteManager.createInstance(dbName: dbName)
        
        let success = dbManager.open()

        if success {
            let now:Date = Date()
            let begin:TimeInterval = now.timeIntervalSince1970
            
            for index in 1 ... 2 {
                let insertTableSQL = "insert into users (name,age,weight,info) values (:name,:age,:weight,:info)"
                
                
                let params:Dictionary<String,Any> = ["age":index,"name":"AAA\(index)","weight":10.00,"info":Data(bytes: Array("ABC\(index)".utf8))]
                
                let success = dbManager.executeUpdate(sql: insertTableSQL, params: params)
                
                print("插入表数据 :\(success)")
            }
            
            let end = Date().timeIntervalSince1970 - begin
            
            print("非批量情况下的耗时:\(end)")
            dbManager.close()
        }else{
             print("数据库打开失败")
        }
        

        
    }
    
    func testBatchInsertData() {
        let dbManager:SQLiteManager = SQLiteManager.createInstance(dbName: dbName)
        
        let success = dbManager.open()
        
        if success {
            let now:Date = Date()
            let begin:TimeInterval = now.timeIntervalSince1970
            
            dbManager.beginTransaction()
            
            for index in 1 ... 1000 {
                let insertTableSQL = "insert into users (name,age,weight,info) values (:name,:age,:weight,:info)"
                
                
                let params:Dictionary<String,Any> = ["age":index,"name":"AAA\(index)","weight":10.00,"info":Data(bytes: Array("ABC\(index)".utf8))]
                
                let success = dbManager.executeUpdate(sql: insertTableSQL, params: params)
                
                print("插入表数据 :\(success)")
            }
            
            dbManager.commit()
            
            let end = Date().timeIntervalSince1970 - begin
            
            print("批量情况下的耗时:\(end)")
            dbManager.close()
        }else{
            print("数据库打开失败")
        }
        

        
    }
    
    func testDeleteDatas() {
        let dbManager:SQLiteManager = SQLiteManager.createInstance(dbName: dbName)
        
        let success = dbManager.open()
        
        if success {
            let createTableSQL:String = "delete from users"
            
            let success = dbManager.executeUpdate(sql: createTableSQL)
            
            print(success)
            
            dbManager.close()
            
        }else{
            print("数据库打开失败")
        }
        

    }
    
    func testQuery() {
        let dbManager:SQLiteManager = SQLiteManager.createInstance(dbName: dbName)
        
        let success = dbManager.open()
        
        if success {
            let querySQL:String = "select * from users"
            
            let results = dbManager.executeQuery(sql: querySQL)
            
            print("查询出来的结果是：\(results)")
            dbManager.close()
        }else{
            print("数据库打开失败")
        }
    }
    
    func testQueryWithParams()  {
        let dbManager:SQLiteManager = SQLiteManager.createInstance(dbName: dbName)
        
        let success = dbManager.open()
        
        if success {
            let querySQL:String = "select * from users WHERE age in (:age)"
            
            let results = dbManager.executeQuery(sql: querySQL, params: ["age":[1,2,3] ])
            
            print("查询出来的结果是：\(results)")
            dbManager.close()
        }else{
            print("数据库打开失败")
        }
        
        

    }
    
}
