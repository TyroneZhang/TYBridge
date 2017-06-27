//
//  TYJSBridgeHelper.swift
//  DSBridgeDemo
//
//  Created by Demon_Yao on 15/06/2017.
//  Copyright © 2017 Tyrone Zhang. All rights reserved.
//

import UIKit

class TYJSBridgeHelper: NSObject {
    
    // MARK: - Public Functions
    
    class func objectToJSONString(_ object: Any) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            return jsonString ?? "{}"
        } catch {
            return "{}"
        }
    }
    
    class func jsonStringToObject(_ jsonString: String) -> Any? {
        guard let data = jsonString.data(using: String.Encoding.utf8) else {
            return nil
        }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            return object
        } catch {
            return nil
        }
    }
    
    class func call(_ method: String, args: String?, jsInterfaceObject: AnyObject, jsContext: AnyObject) -> String? {
        guard let selName = self.methodNameBy(method, aClass: jsInterfaceObject.classForCoder) else {
            print("jsInterfaceObject do not have the method.")
            return ""
        }
        var result: AnyObject? = nil
        let sel = NSSelectorFromString(selName)
        let parameters = args == nil ? nil : self.jsonStringToObject(args!)
        // 异步
        if let callBackKey = (parameters as? [String: Any])?[TYJSBridge.JS_CALLBACK_KEY] {
            if jsInterfaceObject.responds(to: sel) {
                let completionHandler: (Any) -> Void = { value in
                    let js = "try {\(callBackKey)('\(value)'); delete window.\(callBackKey);} catch(e){};"
                    (jsContext as? TYWKWebView)?.evaluateJavaScript(js, completionHandler: nil)
                }
                let handlerDict: [String: Any] = [TYJSBridge.COMPLETION_HANDLER_KEY: completionHandler]
                let _ = jsInterfaceObject.perform(sel, with: parameters, with: handlerDict)
            }
            return ""
        } else { // 同步
            if jsInterfaceObject.responds(to: sel) {
                result = jsInterfaceObject.perform(sel, with: parameters).takeUnretainedValue()
            }
        }
        if result == nil || !(result is String) {
            let jsString = "window.alert('没有该方法:\(method)'))"
            (jsContext as? TYWKWebView)?.evaluateJavaScript(jsString, completionHandler: nil)
        }
        return result as? String
    }
    
    
    // MAR: - Private Functions
    
    /**
     获取的是所有实例方法，不包含静态方法
     
     // runtime拿到的名字是"test"
     func test() {}
     // runtime拿到的名字是"testWithName:"
     func test(name: String) {}
     // runtime拿到的名字是"test:"
     func test(_ x: NSInteger) {}
     */
    class func getMethodsName(from aClass: AnyClass) -> [String] {
        var selNames: [String] = []
        var methodCount: UInt32 = 0
        let methods = class_copyMethodList(aClass, &methodCount)
        for i in 0 ..< numericCast(methodCount) {
            if let method = methods![i] {
                let sel: Selector = method_getName(method)
                if let selName = sel_getName(sel) {
                    selNames.append(String(cString: selName))
                }
            }
        }
        free(methods)
        return selNames
    }
    
    /**
     根据方法前缀名获取对应的selname
     通过这个方法会有一个bug，就是下面这种情况，会找到两个同样的方法
     func test(_ x: NSInteger) {}
     func test(_ x: NSInteger, y: NSInteger) {}
     */
    class func methodNameBy(_ namePrefix: String, aClass: AnyClass) -> String? {
        let methodNames = self.getMethodsName(from: aClass)
        for name in methodNames {
            if name.hasPrefix(namePrefix) {
                return name
            }
        }
        return nil
    }

}
