//
//  Users.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/9/24.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import Foundation
@testable import PandaDBSwfit

class Users: NSObject,TableProtocol {
    
    var name:String
    
    var age:Int
    
    var weight:Double
    
    var data:Data
    
    init(name:String,age:Int,weight:Double,data:Data) {
        self.name = name
        self.age = age
        self.weight = weight
        self.data = data
        
    }
    
    static func createTable() -> Table {
        let name:Column = Column(name: "name")
        let age:Column = Column(name: "age", type: .ColumnInt)
        let weight:Column = Column(name: "weight", type: .ColumnReal)
        let data:Column = Column(name: "data", type: .ColumnBlob)
        let table:Table = Table(tableName: "user_6", columns: [name,age,weight,data])
  
        return table;
    }
    
    static func updateTable(fromVersion:Int,toVersion:Int){
        
    }
}
