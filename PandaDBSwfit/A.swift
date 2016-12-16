//
//  A.swift
//  PandaDBSwfit
//
//  Created by lingen on 2016/10/2.
//  Copyright © 2016年 lingen.liu. All rights reserved.
//

import Foundation


open class A {
    
    var b:B = B()
    
    open func hello() -> Void {
        print("HELLO")
    }
    
    public func hello2() ->Void {
        print("HELLO2")
    }
}

private class B{
    
}
