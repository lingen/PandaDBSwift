//
//  TableProtocol.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/9/24.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import Foundation

protocol TableProtocol {
    
    static func createTable() -> Table
    
    static func updateTable(fromVersion:Int,toVersion:Int)
    
}
