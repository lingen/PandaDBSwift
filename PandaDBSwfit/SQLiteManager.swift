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
class SQLiteManager: NSObject {
    
    private static let BEGIN_TRANSACTION:String = "BEGIN TRANSACTION;"
    
    private static let COMMIT = "COMMIT;"
    
    private static let ROLLBACK = "ROLLBACK;"
    
    typealias CCharPointer = UnsafeMutablePointer<CChar>
    
    

    
    //单例对象
    static let instance:SQLiteManager = SQLiteManager();
    
    
    private let SQLITE_STATIC = unsafeBitCast(0, to:sqlite3_destructor_type.self)
    
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to:sqlite3_destructor_type.self)

    
    private override init() {
        
    }

    public class func sharedInstance() -> SQLiteManager {
        return .instance
    }
    
    
    private var db: OpaquePointer? = nil
    
    private var error: CCharPointer? = nil
    
    
    func close() {
        sqlite3_close(db)
    }
    
    
    func openDB(dbName: String) {
        let documentPath:NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString
        
        let path:String = documentPath.appendingPathComponent(dbName)
        
        if sqlite3_open(path.cString(using: String.Encoding.utf8)!, &db) != SQLITE_OK {
            print("打开数据库失败")
            return
        }
        
        print("打开数据库成功:\(path)")
        
    }
    
    func executeUpdate(sql: String) -> Bool {
        return self.executeUpdate(sql: sql, params: nil)
    }
    
    //执行一个带 参数的 SQL
    func executeUpdate(sql:String,params:Dictionary<String,Any>?) -> Bool {
        
        var stmt:OpaquePointer? = nil
        
        let prepare_result = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        if prepare_result != SQLITE_OK {
            return false
        }
        
        self.bindParams(stmt: stmt, params: params)
        
        let step_result = sqlite3_step(stmt)
        
        sqlite3_finalize(stmt)
        
        if step_result == SQLITE_OK || step_result == SQLITE_DONE {
            return true
        }
        
        
        return false
    }
    
    func executeQuery(sql:String) -> Array<Dictionary<String,Any>>? {
        return self.executeQuery(sql: sql, params: nil)
    }
    
    func executeQuery(sql:String,params:Dictionary<String,Any>?) -> Array<Dictionary<String,Any>>? {
        
        let copySQLParam = self.dealWithArray(sqlParam: (sql,params))
        
        let copySql = copySQLParam.0
        
        let copyParam = copySQLParam.1
        
        
        var stmt:OpaquePointer? = nil
        
        let prepare_result = sqlite3_prepare_v2(db, copySql, -1, &stmt, nil)
        
        var results:Array<Dictionary<String,Any>>? = nil
        
        
        if prepare_result != SQLITE_OK {
            let error:String = String(cString: sqlite3_errmsg(stmt))
            return results
        }
        
        self.bindParams(stmt: stmt, params: copyParam)
        
        var step_result = sqlite3_step(stmt)
        
        results = []
        
        while step_result == SQLITE_ROW {
            
            var rowData:Dictionary<String,Any> = [:]
            
            let columnCount = sqlite3_column_count(stmt)
            
            for index in 0..<columnCount {
                let name:String = String(validatingUTF8:sqlite3_column_name(stmt, index))!
                
                let value:Any? = toSwiftValue(stmt: stmt, index: index)
                
                rowData[name] = value
                
            }
            
            results!.append(rowData)
            
            step_result = sqlite3_step(stmt)
        }
        
        sqlite3_finalize(stmt)
        
        return results
        
    }
    
    func beginTransaction() {
        sqlite3_exec(db,SQLiteManager.BEGIN_TRANSACTION, nil, nil, nil);
    }
    
    func commit() {
        sqlite3_exec(db, SQLiteManager.COMMIT, nil, nil, nil);
    }
    
    func rollback() {
        sqlite3_exec(db, SQLiteManager.ROLLBACK, nil, nil, nil);
    }
    
    
    
    private func bindParams(stmt:OpaquePointer?,params:Dictionary<String,Any>?){
        
        if params == nil {
            return
        }
        
        let count = sqlite3_bind_parameter_count(stmt)

        if count > 0 {
            for index in 1...count {
                
                let name:String = String(utf8String: sqlite3_bind_parameter_name(stmt,index))!
                
                let param = name.substring(from: name.index(name.startIndex, offsetBy: 1))
                
                let value = params?[param]!
                
                if value is String {
                    let stringValue:String = value as! String
                    
                    sqlite3_bind_text(stmt,index,stringValue,-1,SQLITE_TRANSIENT)
                                        
                    print("COUNT:\(index),value:\(stringValue)")
                    
                }else if value is Int {
                    let intValue:Int = value as! Int
                    
                    sqlite3_bind_int(stmt, index, Int32(intValue))
                    
                    print("COUNT:\(index),value:\(intValue)")
                    
                }
                else if value is Double {
                    let doubleValue:Double = value as! Double
                    
                    sqlite3_bind_double(stmt, index, doubleValue)
                }
                    
                else if value is Data {
                    let dataValue:Data = value as! Data
                    let array = dataValue.withUnsafeBytes {
                        [UInt8](UnsafeBufferPointer(start: $0, count: dataValue.count))
                    }
                    sqlite3_bind_blob(stmt, index, array, Int32(dataValue.count), SQLITE_TRANSIENT)
                }
                
                else if value is Array<Any> {
                    let arrayValue:Array = value as! Array<Any>
                    
                    let valueString = self.parseArray(values: arrayValue)
                    
                    sqlite3_bind_text(stmt, index, valueString, -1, SQLITE_TRANSIENT)
                    
                }
            }
        }
    }
    
    private func parseArray(values:Array<Any>) -> String {
        var result:String = ""
        
        for index in 0..<values.count {
            let value = values[index]
            if value is String {
                let stringValue:String = value as! String
                result.append(stringValue)
            }else if value is Int{
                let intValue:Int = value as! Int
                result.append("\(intValue)")
            }
            
            if index != (values.count - 1) {
                result.append(",")
            }
            
        }
        
        return result
        
    }
    
    private func toSwiftValue(stmt:OpaquePointer?,index:Int32) -> Any? {
        
        let columnType = sqlite3_column_decltype(stmt, index)

        let columnTypeString = String(validatingUTF8:columnType!)!.uppercased()

        if columnTypeString == "TEXT" {
            let vv = sqlite3_column_text(stmt, index)
            
            return String(cString: vv!)
        }
        
        else if columnTypeString == "INT" {
            let vv = sqlite3_column_int(stmt, index)
            return Int(vv)
        }
        
        else if columnTypeString == "REAL" {
            let vv = sqlite3_column_double(stmt, index)
            return Double(vv)
        }
        
        else if columnTypeString == "BLOB" {
            let vv = sqlite3_column_blob(stmt, index)
            let size = sqlite3_column_bytes(stmt, index)
            return Data(bytes: vv!, count: Int(size))
        }
        return nil
    }
    
    private func dealWithArray(sqlParam:(String,Dictionary<String,Any>?)) -> (String,Dictionary<String,Any>?) {
        let sql:String = sqlParam.0
        
        if sqlParam.1 == nil {
            return sqlParam
        }
        
        let params:Dictionary<String,Any> = sqlParam.1!

        
        var copyPrams:Dictionary<String,Any> = [:]
        
        var copySql:String = ""
        
        for (key,value) in params {
            if value is Array<Any> {
                let arrayValue:Array<Any> = value as! Array
                let replaceKey:String = "(:\(key))"

                var replaceValue:String = ""
                replaceValue.append("(")

                for index in 0..<arrayValue.count {
                    let copyKey:String = "\(key)\(index)"
                    let copyValue:Any = arrayValue[index]
                    
                    copyPrams[copyKey] = copyValue
                    
                    replaceValue.append(":\(copyKey)")
                    
                    if index != ( arrayValue.count - 1 ) {
                        replaceValue.append(",")
                    }
                }
                
                replaceValue.append(")")
                
               copySql =  sql.replacingOccurrences(of: replaceKey, with: replaceValue)
                
            }else{
                copyPrams[key] = value
            }
        }
        
        return (copySql,copyPrams)
    }
}
