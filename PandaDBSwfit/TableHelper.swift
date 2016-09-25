//
//  TableHelper.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/9/24.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import Foundation

class TableHelper {
    
    
    private var columns:Array<Column> = []
    
    private var primayColumns:Array<Column> = []
    
    private var indexColumns:Array<Column> = []
    
    private var tableName:String
    
    init(tableName:String) {
        self.tableName = tableName
    }
    
    class func createInstance(tableName:String) -> TableHelper {
        return TableHelper(tableName: tableName);
    }
    
    func column(name:String,type:ColumnType,nullable:Bool) -> TableHelper {
        let column:Column = Column(name: name, type: type, nullable: nullable)
        columns.append(column)
        return self
    }
    
    func primaryColumn(name:String,type:ColumnType) -> TableHelper {
        let column:Column = Column(name: name, type: type, nullable: false)
        columns.append(column)
        primayColumns.append(column)
        return self
    }
    
    func indexColumn(name:String,type:ColumnType) -> TableHelper {
        let column:Column = Column(name: name, type: type)
        columns.append(column)
        indexColumns.append(column)
        return self
    }
    
    func textColumn(name:String) -> TableHelper {
        let column:Column = Column(name: name, type: .ColumnText)
        columns.append(column)
        return self;
    }
    
    func textNoNullColumn(name:String) -> TableHelper {
        let column:Column = Column(name: name, type: .ColumnText,nullable:false)
        columns.append(column)
        return self;
    }
    
    func intColumn(name:String) -> TableHelper {
        let column:Column = Column(name: name, type: .ColumnInt)
        columns.append(column)
        return self;
    }
    
    func intNotNullColumn(name:String) -> TableHelper {
        let column:Column = Column(name: name, type: .ColumnInt,nullable:false)
        columns.append(column)
        return self;
    }
    
    func realColumn(name:String) -> TableHelper {
        let column:Column = Column(name: name, type: .ColumnReal)
        columns.append(column)
        return self;
    }
    
    func realNotNullColumn(name:String) -> TableHelper {
        let column:Column = Column(name: name, type: .ColumnReal,nullable:false)
        columns.append(column)
        return self;
    }
    
    func blobColumn(name:String) -> TableHelper {
        let column:Column = Column(name: name, type: .ColumnBlob)
        columns.append(column)
        return self;
    }
    
    func blobNotNullColumn(name:String) -> TableHelper {
        let column:Column = Column(name: name, type: .ColumnBlob,nullable:false)
        columns.append(column)
        return self;
    }
    
    func build() -> Table? {
        let table = Table(tableName: self.tableName, columns: self.columns, primaryColumns: self.primayColumns, indexColumns: self.indexColumns)
        return table
    }
    
}
