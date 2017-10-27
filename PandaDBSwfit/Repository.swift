//
//  Repository.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/9/24.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import Foundation

public class Repository {
    
    private var dbHelper:SQLiteManager
    
    private var queue:DispatchQueue
    
    private var tables:Array<()->Table>
    
    private var version:Int
    
    private let DB_THREAD_MARK = "PANDA DB SWIFT THREAD"
    
    private let CREATE_VERSION_TABLE = "create table if not exists panda_version_ (value_ int not null)"
    
    private let INIT_VERSION_TABLE_CONTENT =  "insert into panda_version_ (value_) values (:value)";
    
    private let QUERY_CURRENT_VERSION = "SELECT VALUE_ FROM PANDA_VERSION_ LIMIT 1"
    
    private let UPDATE_VERSION = "UPDATE PANDA_VERSION_ SET VALUE_ = :value"

    var updateBlock:((_ from:Int,_ to:Int)->String)? = nil
    
    private init(dbName:String,tables:Array<()->Table>,version:Int){
        self.dbHelper = SQLiteManager(dbName:dbName)
        self.queue = DispatchQueue(label: "Panda.DB.Swift.\(dbName)")
        self.tables = tables
        self.version = version
    }
    
    public class func createRepository(dbName:String,tables:Array<()->Table>,version:Int) -> Repository{
        let repository = Repository(dbName: dbName, tables: tables, version: version)
        let success = repository.open()
        if success {
            repository.initOrUpdateRepository()
        }
        return repository
    }
    
    public class func createRepository(dbName:String,tables:Array<()->Table>,version:Int,updateBlock:((_ from:Int,_ to:Int)->String)? ) -> Repository{
        let repository = Repository(dbName: dbName, tables: tables, version: version)
        repository.updateBlock = updateBlock;
    
        let success = repository.open()
        if success {
            repository.initOrUpdateRepository()
        }
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
            success = self.dbHelper.executeUpdate(sql: sqls)
            if success {
                self.dbHelper.commit()
            }else{
                print("Panda Error：建表初始化失败")
                self.dbHelper.rollback()
            }

        }
    }
    
    private func updateRepository(){
        
        if self.updateBlock == nil {
            return
        }
        
        self.queue.sync {
            self.dbHelper.beginTransaction()
            self.markInTrsaction()
            
            let sqlVersionDic = self.executeSingleQuery(sql: QUERY_CURRENT_VERSION)
            let currentVersion:Int = (sqlVersionDic?["value_"])! as! Int
            var sqls:String = ""
            if currentVersion < self.version {
                for index in currentVersion ..< self.version {
                    let sql = self.updateBlock!(index,index+1)
                    sqls.append(sql)
                }
            }
            
            var success = self.dbHelper.executeUpdate(sql: sqls)
            
            //更新版本号
            success = self.dbHelper.executeUpdate(sql: UPDATE_VERSION, params: ["value":self.version])
            
            if success {
                self.dbHelper.commit()
            }else{
                print("Panda Error：版本更新失败")
                self.dbHelper.rollback()
            }
            self.cancelMarkInTransaction()
            
        }
    }
    
    
    public func executeUpdate(sql:String) -> Bool {
        var success:Bool = false
        self.wirter { (dbHelper) in
            success = dbHelper.executeUpdate(sql: sql)
        }
        return success
    }
    
    public func executeUpdate(sql:String,params:Dictionary<String,Any>?) -> Bool {
        var success:Bool = false
        self.wirter { (dbHelper) in
            success = dbHelper.executeUpdate(sql: sql, params: params)
        }
        return success
    }
    
    public func executeInTransaction(dbBlock:() -> Void) {
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
    
    public func executeQuery(sql:String) -> Array<Dictionary<String,Any>>? {
        var result:Array<Dictionary<String,Any>>?
        self.reader { (dbHelper) in
            result = dbHelper.executeQuery(sql: sql)
        }
        return result;
    }
    
    public func executeQuery(sql:String,params:Dictionary<String,Any>?) -> Array<Dictionary<String,Any>>? {
        var result:Array<Dictionary<String,Any>>?
        self.reader { (dbHelper) in
            result = dbHelper.executeQuery(sql: sql, params: params)
        }
        return result;
    }
    
    
    public func executeSingleQuery(sql:String) -> Dictionary<String,Any>? {
        var result:Dictionary<String,Any>?
        self.reader { (dbHelper) in
            let dicResults = dbHelper.executeQuery(sql: sql)
            if dicResults != nil && (dicResults?.count)! > 0 {
                result = (dicResults?[0])!
            }
        }
        return result;
    }
    
    
    public func executeSingleQuery(sql:String,params:Dictionary<String,Any>?) -> Dictionary<String,Any>? {
        var result:Dictionary<String,Any>?
        self.reader { (dbHelper) in
            let dicResults = dbHelper.executeQuery(sql: sql,params:params)
            if dicResults != nil && (dicResults?.count)! > 0 {
                result = (dicResults?[0])!
            }
        }
        return result;
    }
    
    
    public func tableExists(tableName:String) -> Bool {
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
    
    public func close() {
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
    
    private func reader(readBlock: (_ dbHtlper:SQLiteManager) -> Void) {
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
    
    private func wirter(writeBlock: (_ dbHelper:SQLiteManager) -> Void) {
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
