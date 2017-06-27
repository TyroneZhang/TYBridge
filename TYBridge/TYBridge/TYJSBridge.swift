//
//  TYJSBridge.swift
//  DSBridgeDemo
//
//  Created by Demon_Yao on 13/06/2017.
//  Copyright © 2017 Tyrone Zhang. All rights reserved.
//

import UIKit


class TYJSBridge: NSObject {
    
}

extension TYJSBridge {
    
    public static let JS_INIT_BRIDGE = "function getJsBridge() { return { call: function(nativeFuncName, paras, callBack) { var result = ''; if (typeof paras == 'function') {    callBack = paras;    paras = {};    }    if (typeof callBack == 'function') {    window.callBackNum = window.callBackNum || 0;    var callBackKey = 'callBack' + window.callBackNum++;    window[callBackKey] = callBack;    paras.callBackKey = callBackKey;    }    paras = JSON.stringify(paras || {});    if (window._tybridge) {    result = prompt(window._tybridge + nativeFuncName, paras);    } else {    if (typeof _tybridge == 'function') {    result = _tybridge(nativeFuncName, paras);    } else {    result = _tybridge.call(nativeFuncName, paras);    }    }    return result;    }    }   };"
    
    /// js传递过来的json参数里，这个key的value对应了js里window的某一个属性，而这个属性的值就是js的callback.
    public static let JS_CALLBACK_KEY = "callBackKey"
    
    /// js里prompt的promt字符串的前缀是这个值（prompt实际上是这个前缀加上js将要调用的native的函数名）.
    public static let PROMPT_PREFIX = "_tybridge="
    
    /// dom初始化完毕后，执行prompt，返回的promt前缀
    public static let DOM_READ_PREFIX = "_bridgeInited"
    
    /// 存储completionHandler的dict的key
    public static let COMPLETION_HANDLER_KEY = "completionHandler"
    
}
