//
//  TYWKWebView.swift
//  DSBridgeDemo
//
//  Created by Demon_Yao on 13/06/2017.
//  Copyright © 2017 Tyrone Zhang. All rights reserved.
//

import UIKit
import WebKit

class TYWKWebView: WKWebView {
    
    fileprivate var confirmDone = false
    fileprivate var confirmResult = false
    var jsInterfaceObeject: AnyObject?
    
    deinit {
        print("")
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        // 插入bridge的js方法
        let js = "_tybridge='\(TYJSBridge.PROMPT_PREFIX)';\(TYJSBridge.JS_INIT_BRIDGE)"
        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        // 执行domready
        let domReady = WKUserScript(source: "prompt('\(TYJSBridge.DOM_READ_PREFIX)');", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(domReady)
        super.init(frame: frame, configuration: configuration)
        super.uiDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TYWKWebView: WKUIDelegate {
    
    // 仅仅是alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void) {
        let cancel = UIAlertAction(title: "取消", style: .cancel) { (action) in
            print("click cancel")
        }
        let confirm = UIAlertAction(title: "确定", style: .default) { (action) in
            print("click confirm")
        }
        let alertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alertController.addAction(cancel)
        alertController.addAction(confirm)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        completionHandler()
    }
    
    /// js需要拿到回馈
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Swift.Void) {
        
        let cancel = UIAlertAction(title: "取消", style: .cancel) { [weak self] (action) in
            self?.confirmResult = false
            self?.confirmDone = true
        }
        let confirm = UIAlertAction(title: "确定", style: .default) { [weak self] (action) in
            self?.confirmResult = true
            self?.confirmDone = true
        }
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(cancel)
        alertController.addAction(confirm)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        while !confirmDone {
            RunLoop.current.run(mode: .defaultRunLoopMode, before: NSDate.distantFuture)
        }
        confirmDone = false
        completionHandler(confirmResult)
        
    }
    
    /// prompt
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Swift.Void) {
        if prompt.hasPrefix(TYJSBridge.PROMPT_PREFIX) {
            if self.jsInterfaceObeject == nil {
                completionHandler(nil)
            }
            let index =  prompt.index(prompt.startIndex, offsetBy: TYJSBridge.PROMPT_PREFIX.characters.count)
            let method = prompt.substring(from: index)
            let result = TYJSBridgeHelper.call(method, args: defaultText, jsInterfaceObject: self.jsInterfaceObeject!, jsContext: webView)
            completionHandler(result)
        } else if prompt.hasPrefix(TYJSBridge.DOM_READ_PREFIX) {
            completionHandler("initial finished");
        } else {
            let cancel = UIAlertAction(title: "取消", style: .cancel) { [weak self] (action) in
                self?.confirmResult = false
                self?.confirmDone = true
            }
            let confirm = UIAlertAction(title: "确定", style: .default) { [weak self] (action) in
                self?.confirmResult = true
                self?.confirmDone = true
            }
            let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            alertController.addAction(cancel)
            alertController.addAction(confirm)
            alertController.addTextField(configurationHandler: { (textField) in
                textField.text = defaultText
            })
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            while !confirmDone {
                RunLoop.current.run(mode: .defaultRunLoopMode, before: NSDate.distantFuture)
            }
            confirmDone = false
            let result = alertController.textFields![0].text ?? "empty inputting"
            completionHandler(result)
        }
        
        
        
    }
    
}
