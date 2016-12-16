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
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testQueryTableExists() {
        
        let usersBlock = { () -> Table in
            Users.createTable()
        }
        
        let repository = Repository.createRepository(dbName: "abc.sqlite", tables: [usersBlock], version: 1)

        let exists = repository.tableExists(tableName: "user_6")
        
        print("表是否存在:\(exists)")
    
        
        repository.close()
    }
    
    func testExecuteQuery() {
        let repository = Repository.createRepository(dbName: "abc.sqlite", tables: [], version: 1)
        

        let results = repository.executeQuery(sql: "select * from users")
        print("查询结果:\(results)")
        
        defer {
            repository.close()
        }
    }
    
    func testExecuteUpdate() {
        let repository = Repository.createRepository(dbName: "abc.sqlite", tables: [], version: 1)
    
  
            var succss = repository.executeUpdate(sql: "delete from users")
            print("清除表:\(succss)")
            
            if succss {
                let insertTableSQL = "insert into users (name,age,weight,info) values (:name,:age,:weight,:info)"
                let params:Dictionary<String,Any>? = ["age":index,"name":"AAA\(index)","weight":10.00,"info":Data(bytes: Array("ABC\(index)".utf8))]
                
                succss = repository.executeUpdate(sql: insertTableSQL, params: params)
                
                if succss {
                     print("新增一条数据成功:\(succss)")
                }
            }
        
        
        defer {
            repository.close()
        }
    }
    
    func testExecuteBatchUpdate() {
        let repository = Repository.createRepository(dbName: "abc.sqlite", tables: [], version: 1)
        
        
            let now:Date = Date()
            let begin:TimeInterval = now.timeIntervalSince1970
        
        let batchInsert:((Void)->Void) = { (Void) -> Void in
            for index in 0...5000 {
                let insertTableSQL = "insert into users (name,age,weight,info) values (:name,:age,:weight,:info)"
                let params:Dictionary<String,Any> = ["age":index,"name":"AAA\(index)","weight":10.00,"info":Data(bytes: Array("ABC\(index)".utf8))]
                let success = repository.executeUpdate(sql: insertTableSQL, params: params)
                print("插入表数据 :\(success)")
            }
        }
        
        repository.executeInTransaction {
            batchInsert()
            repository.executeInTransaction {
                batchInsert()
            }
        }
            
            let end = Date().timeIntervalSince1970 - begin
            print("批量情况下的耗时:\(end)")

        
        defer {
            repository.close()
        }
    }
    
    func testExecuteBatchUpdate2() {
        let repository = Repository.createRepository(dbName: "abc.sqlite", tables: [], version: 1)
        
        
        let batchInsert = {
            for index in 0...5000 {
                let insertTableSQL = "insert into users (name,age,weight,info) values (:name,:age,:weight,:info)"
                let params:Dictionary<String,Any> = ["age":index,"name":"AAA\(index)","weight":10.00,"info":Data(bytes: Array("ABCAAAAAAAAAAABBBBBBBCCCCCCC\(index)".utf8))]
                let success = repository.executeUpdate(sql: insertTableSQL, params: params)
            }
        }
            let now:Date = Date()
            let begin:TimeInterval = now.timeIntervalSince1970
    
            
            repository.executeInTransaction {
                
                batchInsert()
                repository.executeInTransaction {
                    batchInsert()
                    repository.executeInTransaction {
                        batchInsert()
                    }
                }
            }
            
            let end = Date().timeIntervalSince1970 - begin
            print("批量情况下的耗时:\(end)")
        
        
        defer {
            repository.close()
        }
    }
    
    func testSingleQuery() {
        let repository = Repository.createRepository(dbName: "abc.sqlite", tables: [], version: 1)
        
        let results = repository.executeSingleQuery(sql: "select * from users where name = 'AAA1'")
        print("查询结果:\(results)")
        
        
        defer {
            repository.close()
        }
    }
    
    func testUpdate() {
        
        //定义升级block
        let updateBlock = { (from:Int,to:Int) -> String in
            
            if from == 1 && to == 2 {
                //返回1到2的数据库升级语句
                return "";
            }
            else if from == 2 && to == 3 {
                //返回2到3的数据库升级语句
                return "";
            }
            
            return "";
        }
        
        //定义表
        var tables:Array<(Void)->Table> = [];
        
        tables.append { (Void) -> Table in
            
            let table =  TableBuilder
                .createInstance(tableName: "user_3")
                .textColumn(name: "name")
                .intColumn(name: "age")
                .realColumn(name: "weight")
                .blobColumn(name: "data")
                .build()!
            
            return table;
        }
        
        
        //定义数据库repository
        let repository = Repository.createRepository(dbName: "abc.sqlite", tables: tables, version: 1, updateBlock:updateBlock)
        
        let results = repository.executeSingleQuery(sql: "select * from users where name = 'AAA1'")
        print("查询结果:\(results)")
        
        defer {
            repository.close()
        }

    }
    
    func update(from:Int,to:Int) -> String {
        return "delete from users"
    }
}
