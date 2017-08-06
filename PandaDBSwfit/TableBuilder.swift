//
//  TableHelper.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/9/24.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import Foundation

public class TableBuilder {
    
    
    private var columns:Array<Column> = []
    
    private var primayColumns:Array<Column> = []
    
    private var indexColumns:Array<Column> = []
    
    private var tableName:String
    
    init(tableName:String) {
        self.tableName = tableName
    }
    
    public class func createInstance(tableName:String) -> TableBuilder {
        return TableBuilder(tableName: tableName);
    }
    
    public func column(name:String,type:ColumnType,nullable:Bool) -> TableBuilder {
        let column:Column = Column(name: name, type: type, nullable: nullable)
        columns.append(column)
        return self
    }
    
    public func primaryColumn(name:String,type:ColumnType) -> TableBuilder {
        let column:Column = Column(name: name, type: type, nullable: false)
        columns.append(column)
        primayColumns.append(column)
        return self
    }
    
    public func indexColumn(name:String,type:ColumnType) -> TableBuilder {
        let column:Column = Column(name: name, type: type)
        columns.append(column)
        indexColumns.append(column)
        return self
    }
    
    public func textColumn(name:String) -> TableBuilder {
        let column:Column = Column(name: name, type: .ColumnText)
        columns.append(column)
        return self;
    }
    
    public func textNoNullColumn(name:String) -> TableBuilder {
        let column:Column = Column(name: name, type: .ColumnText,nullable:false)
        columns.append(column)
        return self;
    }
    
    public func intColumn(name:String) -> TableBuilder {
        let column:Column = Column(name: name, type: .ColumnInt)
        columns.append(column)
        return self;
    }
    
    public func intNotNullColumn(name:String) -> TableBuilder {
        let column:Column = Column(name: name, type: .ColumnInt,nullable:false)
        columns.append(column)
        return self;
    }
    
    public func realColumn(name:String) -> TableBuilder {
        let column:Column = Column(name: name, type: .ColumnReal)
        columns.append(column)
        return self;
    }
    
    public func realNotNullColumn(name:String) -> TableBuilder {
        let column:Column = Column(name: name, type: .ColumnReal,nullable:false)
        columns.append(column)
        return self;
    }
    
    public func blobColumn(name:String) -> TableBuilder {
        let column:Column = Column(name: name, type: .ColumnBlob)
        columns.append(column)
        return self;
    }
    
    public func blobNotNullColumn(name:String) -> TableBuilder {
        let column:Column = Column(name: name, type: .ColumnBlob,nullable:false)
        columns.append(column)
        return self;
    }
    
    public func build() -> Table? {
        let table = Table(tableName: self.tableName, columns: self.columns, primaryColumns: self.primayColumns, indexColumns: self.indexColumns)
        return table
    }
    
}
