//
//  OPDSQLiteManager.swift
//  PandaDBSwfit
//
//  Created by lingen on 9/21/16.
//  Copyright © 2016 lingen.liu. All rights reserved.
//

import Foundation


/**
 * SQLite数据库管理类
 */
class OPDSQLiteManager: NSObject {
    
    
    typealias CCharPointer = UnsafeMutablePointer<CChar>

    
    //单例对象
    static let instance:OPDSQLiteManager = OPDSQLiteManager();
    
    
    private let SQLITE_STATIC = unsafeBitCast(0, to:sqlite3_destructor_type.self)
    
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to:sqlite3_destructor_type.self)

    
    private override init() {
        
    }

    public class func sharedInstance() -> OPDSQLiteManager {
        return .instance
    }
    
    
    private var db: OpaquePointer? = nil
    
    private var error: CCharPointer? = nil
    
    
    func close() {
        sqlite3_close(db)
    }
    
    /**
     打开数据库 DB(DataBase)
     - parameter dbName: 数据库名称
     */
    func openDB(dbName: String) {
        // 获取沙盒路径
        let documentPath:NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString
        
        // 获取数据库完整路径
        let path:String = documentPath.appendingPathComponent(dbName)

        /*
         参数:
         1.fileName: 数据库完整路径
         2.数据库句柄:
         返回值:
         Int
         SQLITE_OK 表示打开数据库成功
         
         注意:
         1.如果数据库不存在,会创建数据库,再打开
         2.如果存在,直接打开
         */
        //        sqlite3_open(path.cStringUsingEncoding(NSUTF8StringEncoding)!, &db)
        if sqlite3_open(path.cString(using: String.Encoding.utf8)!, &db) != SQLITE_OK {
            print("打开数据库失败")
            return
        }
        
        print("打开数据库成功:\(path)")
        
    }
    
    /**
     执行sql语句
     - parameter sql: sql语句
     - returns: sql语句是否执行成功
     */
    func executeUpdate(sql: String) -> Bool {
        /**
         sqlite执行sql语句:
         
         参数:
         1.COpaquePointer: 数据库句柄
         2.sql: 要执行的sql语句
         3.callback: 执行完成sql后的回调,通常为nil
         4.UnsafeMutablePointer<Void>: 回调函数第一个参数的地址,通常为nil
         5.错误信息的指针,通常为nil
         
         返回值:
         Int:    SQLITE_OK表示执行成功
         */

        let success =  (sqlite3_exec(db, sql, nil, nil, &error) == SQLITE_OK)
//        _ = String(utf8String: error!)
        return success
    }
    
    //执行一个带 参数的 SQL
    func executeUpdate(sql:String,params:Dictionary<String,Any>) -> Bool {
        
        var stmt:OpaquePointer? = nil
        
        sqlite3_exec(db, "BEGIN TRANSACTION;", nil, nil, nil);
        
        let prepare_result = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        if prepare_result != SQLITE_OK {
            return false
        }
        
        let count = sqlite3_bind_parameter_count(stmt)
        
        for index in 1...count {
            
            let name:String = String(utf8String: sqlite3_bind_parameter_name(stmt,index))!
            
            let param = name.substring(from: name.index(name.startIndex, offsetBy: 1))
            
            let value = params[param]!
            
            
            if value is String {
                let stringValue:String = value as! String
                
                sqlite3_bind_text(stmt,index,stringValue,-1,SQLITE_TRANSIENT)
                
                print("COUNT:\(index),value:\(stringValue)")
                
            }else if value is Int {
                let intValue:Int = value as! Int
                
                sqlite3_bind_int(stmt, index, Int32(intValue))
                
                print("COUNT:\(index),value:\(intValue)")

            }
            
        }
        
        let step_result = sqlite3_step(stmt)
        
        sqlite3_finalize(stmt)
        
        sqlite3_exec(db, "COMMIT", nil, nil, nil);
        
        if step_result == SQLITE_OK || step_result == SQLITE_DONE {
            return true
        }
        
        
        return false
    }
    
    
    func executeQuery(sql:String,params:Dictionary<String,Any>) -> Array<Dictionary<String,Any>>? {
        
        var stmt:OpaquePointer? = nil
        
        let prepare_result = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        
        var results:Array<Dictionary<String,Any>>? = nil
        
        if prepare_result != SQLITE_OK {
            return results
        }
        
        let count = sqlite3_bind_parameter_count(stmt)
        
        if count > 0 {
            for index in 1...count {
                
                let name:String = String(utf8String: sqlite3_bind_parameter_name(stmt,index))!
                
                let param = name.substring(from: name.index(name.startIndex, offsetBy: 1))
                
                let value = params[param]!
                
                
                if value is String {
                    let stringValue:String = value as! String
                    
                    sqlite3_bind_text(stmt,index,stringValue,-1,SQLITE_TRANSIENT)
                    
                    print("COUNT:\(index),value:\(stringValue)")
                    
                }else if value is Int {
                    let intValue:Int = value as! Int
                    
                    sqlite3_bind_int(stmt, index, Int32(intValue))
                    
                    print("COUNT:\(index),value:\(intValue)")
                    
                    
                    
                }
                
            }
        }

        
        var step_result = sqlite3_step(stmt)
        
        results = []
        
        while step_result == SQLITE_ROW {
            
            var rowData:Dictionary<String,Any> = [:]
            
            let columnCount = sqlite3_column_count(stmt)
            
            for index in 0..<columnCount {
                let name:String = String(validatingUTF8:sqlite3_column_name(stmt, index))!
                
                let columnType = sqlite3_column_decltype(stmt, index)
                
                let tmp = String(validatingUTF8:columnType!)!.uppercased()
                
                if tmp == "TEXT" {
                    let vv = sqlite3_column_text(stmt, index)
                    
                    rowData[name] = String(cString: vv!)
                }
                
                else if tmp == "INT" {
                    let vv = sqlite3_column_int(stmt, index)
                    rowData[name] = Int(vv)
                }
            }
            
            results!.append(rowData)
            
            step_result = sqlite3_step(stmt)
        }
        
        return results
        
    }
    
}
