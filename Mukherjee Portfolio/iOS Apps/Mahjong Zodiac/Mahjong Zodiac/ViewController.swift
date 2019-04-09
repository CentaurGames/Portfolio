//
//  ViewController.swift
//  Mahjong Zodiac
//
//  Created by Priyanjoli Mukherjee & Christopher Brown on 1/1/19.
//  Copyright © 2019 Centaur Games. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    var webView1: WKWebView!
    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView1 = WKWebView(frame: .zero, configuration: webConfiguration)
        //webView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView1.uiDelegate = self
        view = webView1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            guard let filePath = Bundle.main.path(forResource: "index", ofType: "html")
                else {
                    // File Error
                    print ("File reading error")
                    return
            }
            
            let contents = try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            self.view.isOpaque = true
            self.view.backgroundColor = UIColor.black
            webView1.isOpaque = false
            webView1.backgroundColor = UIColor.clear
            self.view.frame = UIScreen.main.bounds
            webView1.frame = UIScreen.main.bounds
            webView1.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch {
            print ("File HTML error")
        }
    }
}





