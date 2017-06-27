//
//  TestApi.swift
//  DSBridgeDemo
//
//  Created by Demon_Yao on 19/06/2017.
//  Copyright © 2017 Tyrone Zhang. All rights reserved.
//

import UIKit

class TestApi: NSObject {
    
    func sum(_ parameters: [String: NSInteger]) -> String {
        let num1 = parameters["num1"]!
        let num2 = parameters["num2"]!
        return "\(num1 + num2)"
    }
    
    func fetchData(_ parameters: [String: Any]?, completionHandlerDict: [String: Any]) {
        print(parameters ?? "there is no parameters!")
        let handler = completionHandlerDict[TYJSBridge.COMPLETION_HANDLER_KEY] as! (Any) -> Void
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            handler("异步工作完成，返回一个字符串")
        }
    }

}
