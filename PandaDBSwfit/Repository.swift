//
//  Repository.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/9/24.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import Foundation

class Repository: NSObject {
    
    private var dbHelper:SQLiteManager
    
    private var queue:DispatchQueue
    
    private var tables:Array<(Void)->Table>
    
    private var version:Int
    
    private let DB_THREAD_MARK = "PANDA DB SWIFT THREAD"
    
    private let CREATE_VERSION_TABLE = "create table if not exists panda_version_ (value_ int not null)"
    
    private let INIT_VERSION_TABLE_CONTENT =  "insert into panda_version_ (value_) values (:value)";
    
    private let QUERY_CURRENT_VERSION = "SELECT VALUE_ FROM PANDA_VERSION_ LIMIT 1"
    
    
    private init(dbName:String,tables:Array<(Void)->Table>,version:Int){
        self.dbHelper = SQLiteManager.createInstance(dbName: dbName)
        self.queue = DispatchQueue(label: "Panda.DB.Swift.\(dbName)")
        self.tables = tables
        self.version = version
    }
    
    class func createRepository(dbName:String,tables:Array<(Void)->Table>,version:Int) -> Repository{
        let repository = Repository(dbName: dbName, tables: tables, version: version)
        repository.open()
        repository.initOrUpdateRepository()
        return repository
    }
    
    private func initOrUpdateRepository() {
        let dbExists = self.tableExists(tableName: "PANDA_VERSION_")
        if dbExists {
            self.updateRepository()
        }else{
            self.initRepository()
        }
    }
    
    
    private func initRepository(){
        self.queue.sync {
            self.dbHelper.beginTransaction()
            
            var success = self.dbHelper.executeUpdate(sql: CREATE_VERSION_TABLE)
            if success {
                print("Panda Success：初始化数据库，创建版本号表成功")
            }else {
                print("Panda Error：初始化数据库，创建版本号表失败")
                self.dbHelper.rollback()
                return
            }
            
            success = self.dbHelper.executeUpdate(sql: INIT_VERSION_TABLE_CONTENT, params: ["value":self.version])
            if success {
                print("Panda Success：初始化版本值为:\(version)")
            }else {
                print("Panda Error：初始化版本值失败")
                self.dbHelper.rollback()
                return
            }
            
            
            var sqls:String = ""
            
            for tableIndex in self.tables {
                let table = tableIndex()
                
                let createSQL = table.createTableSQL()
                let indexSQL = table.createIndexSQL()
                
                sqls.append(createSQL)
                sqls.append(indexSQL)
            }
            self.dbHelper.executeUpdate(sql: sqls)
            self.dbHelper.commit()
        }
    }
    
    private func updateRepository(){
        
    }
    
    
    func executeUpdate(sql:String) -> Bool {
        var success:Bool = false
        self.wirter { (dbHelper) in
            success = dbHelper.executeUpdate(sql: sql)
        }
        return success
    }
    
    func executeUpdate(sql:String,params:Dictionary<String,Any>?) -> Bool {
        var success:Bool = false
        self.wirter { (dbHelper) in
            success = dbHelper.executeUpdate(sql: sql, params: params)
        }
        return success
    }
    
    func executeInTransaction(dbBlock:(Void) -> Void) {
        if self.isInTransaction() {
            dbBlock()
        }else{
            self.queue.sync {
                self.dbHelper.beginTransaction()
                self.markInTrsaction()
                dbBlock()
                self.cancelMarkInTransaction()
                self.dbHelper.commit()
            }
        }
    }
    
    func executeQuery(sql:String) -> Array<Dictionary<String,Any>>? {
        var result:Array<Dictionary<String,Any>>?
        self.reader { (dbHelper) in
            result = dbHelper.executeQuery(sql: sql)
        }
        return result;
    }
    
    func executeQuery(sql:String,params:Dictionary<String,Any>?) -> Array<Dictionary<String,Any>>? {
        var result:Array<Dictionary<String,Any>>?
        self.reader { (dbHelper) in
            result = dbHelper.executeQuery(sql: sql, params: params)
        }
        return result;
    }
    
    
    func executeSingleQuery(sql:String) -> Dictionary<String,Any>? {
        var result:Dictionary<String,Any>?
        self.reader { (dbHelper) in
            let dicResults = dbHelper.executeQuery(sql: sql)
            if dicResults != nil && (dicResults?.count)! > 0 {
                result = (dicResults?[0])!
            }
        }
        return result;
    }
    
    
    func executeSingleQuery(sql:String,params:Dictionary<String,Any>?) -> Dictionary<String,Any>? {
        var result:Dictionary<String,Any>?
        self.reader { (dbHelper) in
            let dicResults = dbHelper.executeQuery(sql: sql,params:params)
            if dicResults != nil && (dicResults?.count)! > 0 {
                result = (dicResults?[0])!
            }
        }
        return result;
    }
    
    
    func tableExists(tableName:String) -> Bool {
        var exists = false;
        
        self.queue.sync {
            let querySQL = "SELECT * FROM sqlite_master WHERE type='table' AND name=:name COLLATE NOCASE"
            let result = self.dbHelper.executeQuery(sql: querySQL, params: ["name":tableName])
            
            if result != nil && (result?.count)! > 0 {
                exists = true
            }
        }

        return exists
    }
    
    private func open() -> Bool {
       return self.dbHelper.open()
    }
    
    func close() {
        self.dbHelper.close()
    }
    
    private func isInTransaction() -> Bool{
        let threadName = Thread.current.name
        return threadName == DB_THREAD_MARK
    }
    
    private func markInTrsaction() {
        Thread.current.name = DB_THREAD_MARK
    }
    
    private func cancelMarkInTransaction() {
        Thread.current.name = nil
    }
    
    func reader(readBlock: (_ dbHtlper:SQLiteManager) -> Void) {
        if self.isInTransaction() {
            readBlock(self.dbHelper)
        }else{
            self.queue.sync {
                self.markInTrsaction()
                readBlock(self.dbHelper)
                self.cancelMarkInTransaction()
            }
        }
    }
    
    func wirter(writeBlock: (_ dbHelper:SQLiteManager) -> Void) {
        if self.isInTransaction() {
            writeBlock(self.dbHelper)
        }else{
            self.queue.sync {
                self.dbHelper.beginTransaction()
                self.markInTrsaction()
                writeBlock(self.dbHelper)
                self.cancelMarkInTransaction()
                self.dbHelper.commit()
            }
        }
    }
}