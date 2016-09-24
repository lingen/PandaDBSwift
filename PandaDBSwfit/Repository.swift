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
    
    private var tables:Array<TableProtocol>;
    
    init(dbName:String,tables:Array<TableProtocol>,version:Int){
        self.dbHelper = SQLiteManager.createInstance(dbName: dbName)
        self.queue = DispatchQueue(label: "Panda.DB.Swift.\(dbName)")
        self.tables = tables
    }
    
    func executeUpdate(sql:String) -> Bool {
        return false
    }
    
    func executeUpdate(sql:String,params:Dictionary<String,Any>?) -> Bool {
        return false
    }
    
    func executeQuery(sql:String) -> Array<Dictionary<String,Any>>? {
        return nil;
    }
    
    func executeQuery(sql:String,params:Dictionary<String,Any>?) -> Array<Dictionary<String,Any>>? {
        return nil;
    }
    
    func executeSingleQuery(sql:String) -> Dictionary<String,Any>? {
        return nil;
    }
    
    func executeSingleQuery(sql:String,params:Dictionary<String,Any>?) -> Dictionary<String,Any>? {
        return nil;
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
    
    func open() -> Bool {
       return self.dbHelper.open()
    }
    
    func close() {
        self.dbHelper.close()
    }
}
