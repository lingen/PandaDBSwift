//
//  Table.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/9/24.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import Foundation

class Table: NSObject {
    
    private static let OPF_ID = "OPF_ID_"
    
    private var tableName:String
    
    private var columns:Array<Column>
    
    private var primaryColumns:Array<Column>?
    
    private var indexColumns:Array<Column>?
    
    init(tableName:String,columns:Array<Column>,primaryColumns:Array<Column>?,indexColumns:Array<Column>?) {
        self.tableName = tableName
        self.columns = columns
        self.primaryColumns = primaryColumns
        self.indexColumns = indexColumns
    }

    convenience init(tableName:String,columns:Array<Column>,primaryColumns:Array<Column>?) {
        self.init(tableName:tableName,columns:columns,primaryColumns:primaryColumns,indexColumns:nil)
    }
    
    convenience init(tableName:String,columns:Array<Column>){
        self.init(tableName:tableName,columns:columns,primaryColumns:nil,indexColumns:nil)
    }
    
    
    func createTableSQL() -> String {
        var createTableSQL:String = "create table if not exists "
        createTableSQL.append(self.tableName)
        createTableSQL.append(" (")

        for column:Column in self.columns {
            createTableSQL.append(column.columnCreateSQL())
            createTableSQL.append(" ,")
        }
        
        createTableSQL.append(self.primayKeySQL())
        createTableSQL.append(" );")
        return createTableSQL
    }
    
    func createIndexSQL() -> String {
        var indexSQL:String = ""
        if self.indexColumns != nil {
            let columns:Array<Column> = self.indexColumns!
            for column:Column in columns {
                indexSQL.append("CREATE INDEX index_\(column.name) ON \(self.tableName) (\(column.name))")
            }
        }
        return indexSQL
    }
    
    private func primayKeySQL() -> String {
        var primaryKeySQL = ""
        
        if primaryColumns != nil && (primaryColumns?.count)! > 0 {
            primaryKeySQL.append("PRIMARY KEY(")
            let columns:Array<Column> = primaryColumns!
            for index in 0..<(columns.count) {
                let column:Column = columns[index]
                primaryKeySQL.append(column.name)
                if index != (columns.count - 1) {
                    primaryKeySQL.append(",")
                }
            }
            primaryKeySQL.append(")")
        }
        else{
            primaryKeySQL.append("\(Table.OPF_ID) integer PRIMARY KEY autoincrement")
        }
        
        return primaryKeySQL
    }
}
