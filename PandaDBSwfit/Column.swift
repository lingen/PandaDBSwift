//
//  Column.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/9/24.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import Foundation

/*
 * 一个 Column数据库所属的类型
 */
public enum ColumnType {
    /*
     * text类型
     */
    case ColumnText
    
    /*
     * int类型
     */
    case ColumnInt
    
    /*
     * blob类型
     */
    case ColumnBlob
    
    /*
     * Real类型
     */
    case ColumnReal
}

/*
 * 一个 Column对象代表一列
 */
public class Column {
    
    private static let COLUMN_TEXT = "TEXT"
    
    private static let COLUMN_BLOB = "BLOB"
    
    private static let COLUMN_INT = "INT"
    
    private static let COLUMN_REAL = "REAL"
    
    private static let NOT_NULL_SQL = " not null"
    
    /*
     * 数据库名
     */
    var name:String = ""
    
    /*
     * 数据库类型
     */
    var type:ColumnType = .ColumnText
    
    /*
     * 是否允许为空
     */
    var nullable:Bool = true
    
    /*
     * 默认INIT,指定列名，列类型以及是否为空
     */
    init(name:String,type:ColumnType,nullable:Bool) {
        self.name = name
        self.type = type
        self.nullable = nullable
    }
    
    /*
     * 指定一个name的列，类型为 TEXT,可以为空
     */
    convenience init(name:String){
        self.init(name:name,type:.ColumnText,nullable:true)
    }
    
    /*
     * 默认INIT,指定列名，列类型,允许为空
     */
    convenience init(name:String,type:ColumnType){
        self.init(name:name,type:type,nullable:true)
    }
    
    /*
     * 默认INIT,指定列名，列类型,允许为空
     */
    func columnCreateSQL() -> String {
        var createTableSQL = ""
        createTableSQL.append("\(self.name) ")
        createTableSQL.append(self.columnTypeString())
        if nullable == false {
            createTableSQL.append(Column.NOT_NULL_SQL)
        }
        return createTableSQL
    }
    
    private func columnTypeString() -> String {

        switch type {
         case .ColumnText:
            return Column.COLUMN_TEXT
         case .ColumnInt:
            return Column.COLUMN_INT
         case .ColumnBlob:
            return Column.COLUMN_BLOB
         case .ColumnReal:
            return Column.COLUMN_REAL
        }
    }
}
