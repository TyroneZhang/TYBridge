//
//  ViewController.swift
//  TYBridge
//
//  Created by Demon_Yao on 27/06/2017.
//  Copyright © 2017 Tyrone Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var webView: TYWKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = TYWKWebView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.view.addSubview(webView)
        webView.jsInterfaceObeject = TestApi()
        webView.load(URLRequest(url: URL(string: "http://192.168.1.9/JSBridge")!))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

